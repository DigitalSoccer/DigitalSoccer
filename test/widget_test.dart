import 'package:anfa_chiguayante/main.dart';
import 'package:anfa_chiguayante/models/club.dart';
import 'package:anfa_chiguayante/pages/club_detail_page.dart';
import 'package:anfa_chiguayante/pages/home_page.dart';
import 'package:anfa_chiguayante/pages/my_club_page.dart';
import 'package:anfa_chiguayante/pages/standings_page.dart';
import 'package:anfa_chiguayante/services/club_service.dart';
import 'package:anfa_chiguayante/theme/app_theme.dart';
import 'package:anfa_chiguayante/widgets/app_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_asset_bundle.dart';

const standingsPath = 'assets/data/standings.json';

Widget wrap(Widget child, AssetBundle bundle) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: DefaultAssetBundle(
      bundle: bundle,
      child: Scaffold(body: child),
    ),
  );
}

Club club(String id, String name) =>
    Club(id: id, name: name, shortName: name, field: '');

/// Dato destacado visible con su etiqueta (p. ej. "POSICIÓN" / "17").
Finder stat(String label, String value) {
  return find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is StatTile && w.label == label && w.value == value,
    ),
    matching: find.text(value),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('la app arranca y muestra el fixture', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Fixture'), findsOneWidget);
    expect(find.text('Tabla'), findsOneWidget);
    expect(find.text('Cancha Chiguayante Sur'), findsOneWidget);
  });

  testWidgets('la app usa la paleta centralizada gris azulada y blanca',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(context);

    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.onSurface, AppColors.text);
  });

  test('los pares de texto y fondo cumplen contraste WCAG AA (4.5:1)', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final hi = la > lb ? la : lb;
      final lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    final pairs = {
      'texto / fondo': (AppColors.text, AppColors.background),
      'texto secundario / fondo': (AppColors.textMuted, AppColors.background),
      'texto secundario / gris suave':
          (AppColors.textMuted, AppColors.surfaceMid),
      'primario / fondo': (AppColors.primary, AppColors.background),
      'blanco / primario': (AppColors.onPrimary, AppColors.primary),
      'texto / contenedor primario':
          (AppColors.onPrimaryContainer, AppColors.primaryContainer),
      'primario / contenedor primario':
          (AppColors.primary, AppColors.primaryContainer),
      'error / fondo': (AppColors.error, AppColors.background),
    };

    pairs.forEach((name, pair) {
      expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5),
          reason: name);
    });
  });

  group('Diseño adaptable (sin desbordes)', () {
    for (final size in const [Size(320, 640), Size(1280, 800)]) {
      testWidgets('pestañas principales a ${size.width.toInt()} px',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Abre la primera cancha para mostrar filas de partido.
        await tester.tap(find.text('Cancha Mario Osben'));
        await tester.pumpAndSettle();

        for (final tab in ['Mi Club', 'Tabla', 'Clubes', 'Fixture']) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('detalle de club a ${size.width.toInt()} px',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(wrap(
          ClubDetailPage(club: club('arturo-prat', 'Arturo Prat')),
          realDataBundle(),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(stat('Puntos', '42'), findsOneWidget);
      });
    }
  });

  group('Detalle de club', () {
    testWidgets('Arturo Prat muestra su posición y puntos', (tester) async {
      await tester.pumpWidget(wrap(
        ClubDetailPage(club: club('arturo-prat', 'Arturo Prat')),
        realDataBundle(),
      ));
      await tester.pumpAndSettle();

      expect(stat('Posición', '17'), findsOneWidget);
      expect(stat('Puntos', '42'), findsOneWidget);
      expect(find.text('Arturo Prat vs El Valle'), findsWidgets);
    });

    testWidgets("Bdo. O'Higgins muestra su posición y puntos",
        (tester) async {
      await tester.pumpWidget(wrap(
        ClubDetailPage(club: club('bdo-ohiggins', "Bdo. O'Higgins")),
        realDataBundle(),
      ));
      await tester.pumpAndSettle();

      expect(stat('Posición', '5'), findsOneWidget);
      expect(stat('Puntos', '90'), findsOneWidget);
    });

    testWidgets('un club fuera de la tabla no inventa posición',
        (tester) async {
      await tester.pumpWidget(wrap(
        ClubDetailPage(club: club('club-nuevo', 'Club Nuevo')),
        realDataBundle(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(StatTile), findsNothing);
      expect(
        find.text('Sin información en la tabla de posiciones.'),
        findsOneWidget,
      );
      expect(
        find.text('Este club no tiene partidos en la fecha cargada.'),
        findsOneWidget,
      );
    });
  });

  group('Tabla: estados de carga', () {
    testWidgets('error de lectura muestra mensaje y permite reintentar',
        (tester) async {
      final bundle = FakeAssetBundle({});

      await tester.pumpWidget(wrap(const StandingsPage(), bundle));
      await tester.pumpAndSettle();

      expect(find.text('No se pudo cargar la información.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      bundle.files[standingsPath] = realDataFiles()[standingsPath]!;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('No se pudo cargar la información.'), findsNothing);
      expect(find.text('Chiguayante Sur'), findsOneWidget);
    });

    testWidgets('JSON mal formado no deja la pantalla cargando',
        (tester) async {
      await tester.pumpWidget(wrap(
        const StandingsPage(),
        FakeAssetBundle({standingsPath: '{ esto no es json'}),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('tabla vacía muestra mensaje de ausencia de datos',
        (tester) async {
      await tester.pumpWidget(wrap(
        const StandingsPage(),
        FakeAssetBundle({standingsPath: '[]'}),
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('La tabla de posiciones aún no está disponible.'),
        findsOneWidget,
      );
    });
  });

  group('Fixture y Mi Club', () {
    testWidgets('búsqueda sin resultados muestra mensaje', (tester) async {
      await tester.pumpWidget(wrap(const HomePage(), realDataBundle()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      expect(
        find.text('No hay partidos para mostrar el Sábado.'),
        findsOneWidget,
      );
    });

    testWidgets('sin club favorito invita a elegir uno', (tester) async {
      await tester.pumpWidget(wrap(const MyClubPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(
        find.text('Selecciona un club en la pestaña Clubes'),
        findsOneWidget,
      );
    });

    testWidgets('Mi Club filtra el fixture por id del club', (tester) async {
      SharedPreferences.setMockInitialValues({
        ClubService.favoriteClubIdKey: 'arturo-prat',
      });

      await tester.pumpWidget(wrap(const MyClubPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('MI CLUB'), findsOneWidget);
      expect(find.text('Arturo Prat'), findsOneWidget);
      // Arturo Prat juega el sábado solo en Cancha Chiguayante Sur.
      expect(find.text('Cancha Chiguayante Sur'), findsOneWidget);
      expect(find.text('Cancha Mario Osben'), findsNothing);
      expect(find.text('2 partidos programados'), findsOneWidget);
    });
  });
}
