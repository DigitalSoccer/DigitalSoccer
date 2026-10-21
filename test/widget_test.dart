import 'package:anfa_chiguayante/main.dart';
import 'package:anfa_chiguayante/models/club.dart';
import 'package:anfa_chiguayante/models/match.dart';
import 'package:anfa_chiguayante/pages/club_detail_page.dart';
import 'package:anfa_chiguayante/pages/home_page.dart';
import 'package:anfa_chiguayante/pages/matchup_detail_page.dart';
import 'package:anfa_chiguayante/pages/standings_page.dart';
import 'package:anfa_chiguayante/services/club_service.dart';
import 'package:anfa_chiguayante/services/data_service.dart';
import 'package:anfa_chiguayante/theme/app_theme.dart';
import 'package:anfa_chiguayante/widgets/app_components.dart';
import 'package:anfa_chiguayante/widgets/match_row.dart';
import 'package:anfa_chiguayante/widgets/matchup_card.dart';
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

  testWidgets('la app arranca en Inicio y el fixture está en su pestaña',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Fixture'), findsOneWidget);
    expect(find.text('Tabla'), findsOneWidget);
    // Sin club elegido, Inicio invita a elegir uno.
    expect(find.text('¡Bienvenido!'), findsOneWidget);

    await tester.tap(find.text('Fixture'));
    await tester.pumpAndSettle();

    // Abre en la fecha más reciente, con los cruces agrupados por día.
    expect(find.text('Fecha 21'), findsOneWidget);
    expect(find.text('Sáb 10 – Dom 11 oct 2026'), findsOneWidget);
    expect(find.text('SÁBADO 10 OCT'), findsOneWidget);
    // El primer cruce del sábado (10:00) es Leinenweber vs Nacional.
    expect(find.text('Leinenweber'), findsWidgets);
    // Ese cruce se juega en dos canchas; la tarjeta muestra ambas.
    expect(
      find.text('Cancha José Vilches · Cancha Chiguayante Sur'),
      findsWidgets,
    );
  });

  testWidgets('la app usa los tokens centralizados (rojo #B3202A y cálidos)',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(context);

    expect(theme.colorScheme.primary, const Color(0xFFB3202A));
    expect(theme.colorScheme.primary, AppColors.light.primary);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F3F2));
    expect(theme.colorScheme.onSurface, AppColors.light.text);
    expect(context.colors, AppColors.light);
  });

  test('los pares de texto y fondo cumplen contraste WCAG AA (4.5:1)', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final hi = la > lb ? la : lb;
      final lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    for (final (paletteName, c) in [
      ('claro', AppColors.light),
      ('oscuro', AppColors.dark),
    ]) {
      final pairs = {
        'texto / tarjeta': (c.text, c.surface),
        'texto / fondo': (c.text, c.background),
        'etiqueta / tarjeta': (c.textMuted, c.surface),
        'etiqueta / fondo': (c.textMuted, c.background),
        'texto secundario / pista de pestañas':
            (c.textSecondary, c.surfaceMuted),
        'texto rojo / tarjeta': (c.primaryText, c.surface),
        'texto rojo / fondo': (c.primaryText, c.background),
        'blanco / botón y chip elegido': (c.onPrimary, c.primary),
        'texto / contenedor primario':
            (c.onPrimaryContainer, c.primaryContainer),
        'insignia MI CLUB': (c.primaryText, c.primaryContainer),
        'opción elegida en hoja inferior': (c.primaryText, c.primarySoft),
        'texto / fila de Mi Club': (c.text, c.primarySoft),
        'texto secundario / fila de Mi Club': (c.textSecondary, c.primarySoft),
        'texto / fila de mi equipo': (c.text, c.ownTeam),
        'podio oro': (c.goldFg, c.goldBg),
        'podio plata': (c.silverFg, c.silverBg),
        'podio bronce': (c.bronzeFg, c.bronzeBg),
        'error / tarjeta': (c.error, c.surface),
        'aviso: título': (c.noticeText, c.noticeBg),
        'aviso: cuerpo': (c.noticeBody, c.noticeBg),
        'etiqueta neutra': (c.tagNeutralText, c.tagNeutralBg),
        'blanco / panel rojo oscuro': (c.onPrimary, c.primaryDeep),
        'texto suave / tarjeta roja': (c.onPrimaryMuted, c.primary),
        'texto suave / panel rojo oscuro': (c.onPrimaryMuted, c.primaryDeep),
      };

      pairs.forEach((name, pair) {
        expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5),
            reason: '$paletteName: $name');
      });
    }
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

        await tester.tap(find.text('Fixture'));
        await tester.pumpAndSettle();

        // Abre el detalle del primer cruce (cancha y horarios) y vuelve.
        await tester.tap(find.text('Leinenweber'));
        await tester.pumpAndSettle();
        expect(find.byType(MatchRow), findsWidgets);
        await tester.pageBack();
        await tester.pumpAndSettle();

        for (final tab in ['Inicio', 'Tabla', 'Noticias', 'Clubes', 'Fixture']) {
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
        expect(stat('Puntos', '110'), findsOneWidget);
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
      expect(stat('Puntos', '110'), findsOneWidget);
    });

    testWidgets("Bdo. O'Higgins muestra su posición y puntos",
        (tester) async {
      await tester.pumpWidget(wrap(
        ClubDetailPage(club: club('bdo-ohiggins', "Bdo. O'Higgins")),
        realDataBundle(),
      ));
      await tester.pumpAndSettle();

      expect(stat('Posición', '5'), findsOneWidget);
      expect(stat('Puntos', '258'), findsOneWidget);
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
        find.text('Este club no tiene series en las fechas cargadas.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Próximas fechas'));
      await tester.pumpAndSettle();

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

      expect(find.text('Ningún partido coincide con "zzz".'), findsOneWidget);
    });

  });

  group('Fixture con formato de planilla', () {
    Future<void> pumpHome(WidgetTester tester) async {
      await tester.pumpWidget(wrap(const HomePage(), realDataBundle()));
      await tester.pumpAndSettle();
    }

    Finder rowsWith(String text) => find.descendant(
          of: find.byType(MatchRow),
          matching: find.text(text),
        );

    // Ventana alta para que se construya todo el sábado sin desplazarse.
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('una tarjeta por cruce, con todas sus series', (tester) async {
      tallView(tester);
      await pumpHome(tester);

      // Un cruce por local y visita en cada día de la fecha 21.
      final round = await tester.runAsync(
        () => DataService.loadData(realDataBundle()),
      );
      final expected = round!.days
          .map((d) => Matchup.fromDay(d).length)
          .fold<int>(0, (a, b) => a + b);
      expect(find.byType(MatchupCard), findsNWidgets(expected));
      // Sábado: U.L. Carrera vs San Pablo juega 4 series en dos turnos.
      expect(find.text('4 partidos'), findsWidgets);
      // La lista ya no muestra filas de horario: están en el detalle.
      expect(find.byType(MatchRow), findsNothing);
    });

    testWidgets('al tocar un cruce se ven la cancha y los horarios',
        (tester) async {
      tallView(tester);
      await pumpHome(tester);

      await tester.tap(find.text('U.L. Carrera').first);
      await tester.pumpAndSettle();

      expect(find.byType(MatchupDetailPage), findsOneWidget);
      expect(find.text('Fecha 21 · Sábado 10 oct'), findsOneWidget);
      expect(find.text('Programado'), findsOneWidget);
      expect(find.text('Cancha Mario Osben'), findsOneWidget);
      expect(find.text('4 partidos'), findsOneWidget);
      for (final time in ['13:00', '14:10', '15:30', '16:40']) {
        expect(rowsWith(time), findsOneWidget, reason: time);
      }
      expect(rowsWith('S. Senior'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(MatchupDetailPage), findsNothing);
    });

    testWidgets('muestra el club libre de la fecha', (tester) async {
      await pumpHome(tester);

      expect(
        find.text('Libre: Independiente', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('No juega en esta fecha'), findsOneWidget);
    });

    testWidgets('resalta Mi Club sin ocultar al resto', (tester) async {
      SharedPreferences.setMockInitialValues({
        ClubService.favoriteClubIdKey: 'arturo-prat',
      });

      tallView(tester);
      await pumpHome(tester);

      // Arturo Prat: sábado y domingo vs Bdo. O'Higgins, domingo vs
      // Maestranza.
      expect(find.text('Tu equipo'), findsNWidgets(3));
      // Los demás cruces siguen visibles.
      expect(find.text('U.L. Carrera'), findsWidgets);
      expect(find.text('Jackson'), findsWidgets);
    });

    testWidgets('"Solo mis partidos" deja solo los cruces propios',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        ClubService.favoriteClubIdKey: 'arturo-prat',
      });

      tallView(tester);
      await pumpHome(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.byType(MatchupCard), findsNWidgets(3));
      expect(find.text('U.L. Carrera'), findsNothing);
    });

    testWidgets('sin equipo elegido no ofrece "Solo mis partidos"',
        (tester) async {
      await pumpHome(tester);

      expect(find.text('Solo mis partidos'), findsNothing);
    });

    testWidgets('permite volver a la fecha anterior', (tester) async {
      await pumpHome(tester);

      expect(find.text('Fecha 21'), findsOneWidget);
      expect(find.text('Fuente: planilla de la asociación'), findsOneWidget);

      await tester.tap(find.byTooltip('Fecha anterior'));
      await tester.pumpAndSettle();

      expect(find.text('Fecha 11'), findsOneWidget);
      // La fecha 11 no tiene origen verificado y se avisa.
      expect(find.text('Fuente sin verificar'), findsOneWidget);

      await tester.tap(find.byTooltip('Fecha siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Fecha 21'), findsOneWidget);
    });

    testWidgets('el detalle del club libre lo indica', (tester) async {
      await tester.pumpWidget(wrap(
        ClubDetailPage(club: club('independiente', 'Independiente')),
        realDataBundle(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Próximas fechas'));
      await tester.pumpAndSettle();

      expect(find.text('Libre en la fecha 21.'), findsOneWidget);
    });
  });

  group('Formato común de tarjetas y escudos en la tabla', () {
    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('el Fixture agrupa por día y lleva escudos en cada cruce',
        (tester) async {
      tall(tester);
      SharedPreferences.setMockInitialValues({
        ClubService.favoriteClubIdKey: 'arturo-prat',
      });

      await tester.pumpWidget(wrap(const HomePage(), realDataBundle()));
      await tester.pumpAndSettle();

      // Los cruces van bajo el título de su día.
      expect(find.text('SÁBADO 10 OCT'), findsOneWidget);
      // Dos escudos genéricos por tarjeta.
      expect(
        find.byType(ClubCrest),
        findsNWidgets(2 * tester.widgetList(find.byType(MatchupCard)).length),
      );
      // Los cruces de mi equipo llevan su etiqueta.
      expect(find.text('Tu equipo'), findsNWidgets(3));
    });

    testWidgets('la tabla muestra un escudo junto a cada club',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.byType(ClubCrest), findsNWidgets(17));
    });
  });
}
