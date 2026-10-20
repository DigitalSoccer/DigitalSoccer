import 'package:anfa_chiguayante/main.dart';
import 'package:anfa_chiguayante/pages/club_detail_page.dart';
import 'package:anfa_chiguayante/pages/inicio_page.dart';
import 'package:anfa_chiguayante/pages/standings_page.dart';
import 'package:anfa_chiguayante/services/club_service.dart';
import 'package:anfa_chiguayante/services/standings_catalog.dart';
import 'package:anfa_chiguayante/theme/app_theme.dart';
import 'package:anfa_chiguayante/widgets/serie_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_asset_bundle.dart';

/// Etapa 2 del mockup (`docs/diseno.md` 6.2 y 6.4): Inicio y Tabla.
/// Sin `ClubsScope`, los nombres son los de la planilla (p. ej. "A. Prat").
Widget wrap(Widget child, AssetBundle bundle) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: DefaultAssetBundle(
      bundle: bundle,
      child: Scaffold(body: child),
    ),
  );
}

void tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Toca un chip de serie (la fila se desplaza si hace falta).
Future<void> tapChip(WidgetTester tester, String label) async {
  final chip = find.descendant(
    of: find.byType(PillChips),
    matching: find.text(label),
  );
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> favorite(String clubId, [Map<String, Object>? extra]) async {
    SharedPreferences.setMockInitialValues({
      ClubService.favoriteClubIdKey: clubId,
      ...?extra,
    });
  }

  group('Inicio', () {
    testWidgets('sin club invita a elegirlo y luego muestra su posición',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('¡Bienvenido!'), findsOneWidget);

      await tester.tap(find.text('Arturo Prat'));
      await tester.pumpAndSettle();

      expect(find.text('¡Bienvenido!'), findsNothing);
      expect(find.text('POSICIÓN · GENERAL'), findsOneWidget);
      expect(find.text('17°'), findsOneWidget);
      expect(find.text('de 17 equipos'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ClubService.favoriteClubIdKey), 'arturo-prat');
    });

    testWidgets('la tarjeta de posición calcula la distancia al líder y al 3°',
        (tester) async {
      tall(tester);
      await favorite('arturo-prat');
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      // General: líder 394, 3° 312, Arturo Prat 110.
      expect(find.text('A 284 puntos del líder'), findsOneWidget);
      expect(find.text('A 202 puntos del 3°'), findsOneWidget);
    });

    testWidgets('el líder ve su ventaja sobre el siguiente', (tester) async {
      tall(tester);
      await favorite('chiguayante-sur');
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('1°'), findsOneWidget);
      expect(find.text('Lidera la tabla'), findsOneWidget);
      expect(find.text('60 puntos sobre el 2°'), findsOneWidget);
    });

    testWidgets('los chips cambian la serie y la elección se guarda',
        (tester) async {
      tall(tester);
      await favorite('arturo-prat');
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      await tapChip(tester, 'Honor');

      // Honor: líder 47, 3° 34, Arturo Prat 4 (9°).
      expect(find.text('POSICIÓN · HONOR'), findsOneWidget);
      expect(find.text('9°'), findsOneWidget);
      expect(find.text('A 43 puntos del líder'), findsOneWidget);
      expect(find.text('Tabla · Honor'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StandingsCatalog.prefsKey), 'serie:Honor');
    });

    testWidgets('la mini tabla pone al equipo con el de arriba y el de abajo',
        (tester) async {
      tall(tester);
      await favorite('chiguayante-sur', {
        StandingsCatalog.prefsKey: 'serie:Honor',
      });
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      // Primero de Honor: se muestran 1°, 2° y 3° (3° compartido).
      expect(find.text('Tabla · Honor'), findsOneWidget);
      // En el encabezado y en su fila.
      expect(find.text('Chiguayante Sur'), findsNWidgets(2));
      expect(find.text('Magallanes'), findsOneWidget);
      expect(find.text("Bdo. O'Higgins"), findsOneWidget);
      expect(find.text('San Pablo'), findsNothing);

      // La fila del equipo va resaltada.
      expect(
        find.ancestor(
          of: find.text('Chiguayante Sur'),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                (w.decoration as BoxDecoration?)?.color ==
                    AppColors.light.ownTeam,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('muestra el partido de la fecha en una línea', (tester) async {
      tall(tester);
      await favorite('arturo-prat');
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('TU PARTIDO · FECHA 21'), findsOneWidget);
      expect(find.textContaining("vs Bdo. O'Higgins · Sáb 10, "), findsOneWidget);
    });

    testWidgets('un club libre en la fecha lo indica', (tester) async {
      tall(tester);
      await favorite('independiente');
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('Libre en esta fecha'), findsOneWidget);
    });

    testWidgets('permite cambiar de equipo', (tester) async {
      tall(tester);
      await favorite('arturo-prat');
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Cambiar de equipo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Independiente'));
      await tester.pumpAndSettle();

      expect(find.text('Libre en esta fecha'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ClubService.favoriteClubIdKey), 'independiente');
    });

    testWidgets('sin noticias publicadas muestra el estado vacío',
        (tester) async {
      tall(tester);
      await favorite('arturo-prat');
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('Últimas noticias'), findsOneWidget);
      expect(find.text('Aún no hay noticias publicadas.'), findsOneWidget);
    });

    testWidgets('los enlaces llevan a Tabla, Noticias y Fixture',
        (tester) async {
      tall(tester);
      await favorite('arturo-prat');
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver completa'));
      await tester.pumpAndSettle();
      expect(find.text('Tabla de posiciones'), findsOneWidget);

      await tester.tap(find.text('Inicio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver todas'));
      await tester.pumpAndSettle();
      expect(find.text('Aún no hay noticias publicadas.'), findsOneWidget);

      await tester.tap(find.text('Inicio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TU PARTIDO · FECHA 21'));
      await tester.pumpAndSettle();
      expect(find.text('FECHA 21'), findsWidgets);
    });

    for (final size in const [Size(320, 640), Size(1280, 800)]) {
      testWidgets('sin desbordes a ${size.width.toInt()} px', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Arturo Prat'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('17°'), findsOneWidget);
      });
    }
  });

  group('Tabla', () {
    List<String> chipLabels(WidgetTester tester) =>
        tester.widget<PillChips>(find.byType(PillChips)).options;

    testWidgets('por defecto muestra la tabla general con #, Club y Pts',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(tester.widget<PillChips>(find.byType(PillChips)).selected,
          'General');
      expect(find.text('#'), findsOneWidget);
      expect(find.text('CLUB'), findsOneWidget);
      expect(find.text('PTS'), findsOneWidget);
      expect(find.text('394'), findsOneWidget);
      expect(find.text('Chiguayante Sur'), findsOneWidget);
    });

    testWidgets('ofrece general, series de mayor a menor y acumulados',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(chipLabels(tester), [
        'General',
        'Honor',
        'Primera',
        'Segunda',
        'Senior',
        'S. Senior',
        'H. Ortiz',
        'Femenina',
        'Juveniles',
        '1° Infantil',
        '2° Infantil',
        'Total infantil y juvenil',
        'Total adultos',
      ]);
    });

    testWidgets('las series y acumulados muestran la planilla oficial',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.textContaining('sujeta a modificaciones'), findsOneWidget);

      await tapChip(tester, 'Honor');

      // Honor: Chiguayante Sur primero con 47.
      expect(find.text('47'), findsOneWidget);
      final chig = tester.getTopLeft(find.text('Chiguayante Sur')).dy;
      final prat = tester.getTopLeft(find.text('A. Prat')).dy;
      expect(chig, lessThan(prat));

      await tapChip(tester, 'Total adultos');

      expect(find.text('275'), findsOneWidget);
      expect(find.text('82'), findsWidgets);
    });

    testWidgets('resalta la fila de mi equipo y explica la leyenda',
        (tester) async {
      tall(tester);
      await favorite('arturo-prat');
      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(
        find.ancestor(
          of: find.text('A. Prat'),
          matching: find.byWidgetPredicate(
            (w) => w is Material && w.color == AppColors.light.ownTeam,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text('Tu equipo. Toca un club para ver su ficha.'),
        findsOneWidget,
      );
    });

    testWidgets('sin tablas por serie solo ofrece la general',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(
        const StandingsPage(),
        FakeAssetBundle({
          ...realDataFiles(),
          'assets/data/tablas_series.json': '{"series": {}}',
        }),
      ));
      await tester.pumpAndSettle();

      expect(chipLabels(tester), ['General']);
      expect(find.text('Chiguayante Sur'), findsOneWidget);
    });

    testWidgets('una serie con datos muestra su propia tabla ordenada',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(
        const StandingsPage(),
        FakeAssetBundle({
          ...realDataFiles(),
          // Datos de EJEMPLO solo para la prueba.
          'assets/data/tablas_series.json':
              '{"series": {"Honor": ['
              '{"clubId": "b", "team": "Equipo B", "points": 3},'
              '{"clubId": "a", "team": "Equipo A", "points": 9}]}}',
        }),
      ));
      await tester.pumpAndSettle();

      await tapChip(tester, 'Honor');

      final a = tester.getTopLeft(find.text('Equipo A')).dy;
      final b = tester.getTopLeft(find.text('Equipo B')).dy;
      expect(a, lessThan(b));
      expect(find.text('Chiguayante Sur'), findsNothing);
    });

    testWidgets('si fallan los datos de series, igual muestra la general',
        (tester) async {
      await tester.pumpWidget(wrap(
        const StandingsPage(),
        FakeAssetBundle({
          'assets/data/standings.json':
              realDataFiles()['assets/data/standings.json']!,
        }),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Reintentar'), findsNothing);
      expect(find.text('Chiguayante Sur'), findsOneWidget);
    });

    testWidgets('abre en la serie elegida en Inicio', (tester) async {
      tall(tester);
      SharedPreferences.setMockInitialValues({
        StandingsCatalog.prefsKey: 'serie:Honor',
      });
      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(tester.widget<PillChips>(find.byType(PillChips)).selected,
          'Honor');
      expect(find.text('47'), findsOneWidget);
    });

    testWidgets('tocar un club abre su ficha', (tester) async {
      tall(tester);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tabla'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chiguayante Sur'));
      await tester.pumpAndSettle();

      expect(find.byType(ClubDetailPage), findsOneWidget);
    });

    for (final size in const [Size(320, 640), Size(1280, 800)]) {
      testWidgets('sin desbordes a ${size.width.toInt()} px', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await favorite('arturo-prat');
        await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
