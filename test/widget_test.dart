import 'package:anfa_chiguayante/main.dart';
import 'package:anfa_chiguayante/models/club.dart';
import 'package:anfa_chiguayante/pages/club_detail_page.dart';
import 'package:anfa_chiguayante/pages/home_page.dart';
import 'package:anfa_chiguayante/pages/matchup_detail_page.dart';
import 'package:anfa_chiguayante/pages/inicio_page.dart';
import 'package:anfa_chiguayante/pages/standings_page.dart';
import 'package:anfa_chiguayante/services/club_service.dart';
import 'package:anfa_chiguayante/theme/app_theme.dart';
import 'package:anfa_chiguayante/widgets/app_components.dart';
import 'package:anfa_chiguayante/widgets/match_row.dart';
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

    // Abre en la fecha más reciente, con el formato de la planilla.
    expect(find.text('FECHA 21'), findsOneWidget);
    expect(find.text('Sáb 10 – Dom 11 oct 2026'), findsOneWidget);
    expect(find.text('Sábado 10'), findsOneWidget);
    // El primer cruce del sábado (10:00) es Leinenweber vs Nacional.
    expect(find.text('Leinenweber'), findsOneWidget);
    // Ese cruce se juega en dos canchas; la tarjeta muestra ambas.
    expect(
      find.text('Cancha José Vilches · Cancha Chiguayante Sur'),
      findsOneWidget,
    );
  });

  testWidgets('la app usa la paleta centralizada azul (#205375) y blanca',
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
      'texto / cruce de Mi Club': (AppColors.text, AppColors.primaryContainer),
      'texto secundario / cruce de Mi Club':
          (AppColors.textMuted, AppColors.primaryContainer),
      'texto secundario / cabecera de cancha y turno':
          (AppColors.textMuted, AppColors.surfaceLow),
      'texto suave / bloque azul de Inicio':
          (AppColors.primaryContainer, AppColors.primary),
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

        await tester.tap(find.text('Fixture'));
        await tester.pumpAndSettle();

        // Abre el detalle del primer cruce (cancha y horarios) y vuelve.
        await tester.tap(find.text('Leinenweber'));
        await tester.pumpAndSettle();
        expect(find.byType(MatchRow), findsWidgets);
        await tester.pageBack();
        await tester.pumpAndSettle();

        for (final tab in ['Inicio', 'Tabla', 'Clubes', 'Fixture']) {
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

      expect(
        find.text('No hay partidos para mostrar el Sábado.'),
        findsOneWidget,
      );
    });

  });

  group('Inicio', () {
    // Ventana alta para que se construya toda la pantalla sin desplazarse.
    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('sin club invita a elegirlo y luego muestra su información',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('¡Bienvenido!'), findsOneWidget);
      expect(find.textContaining('Elige tu club'), findsOneWidget);

      await tester.tap(find.text('Arturo Prat'));
      await tester.pumpAndSettle();

      expect(find.text('¡Bienvenido!'), findsNothing);
      expect(find.text('MI CLUB'), findsOneWidget);
      expect(stat('Posición', '17'), findsOneWidget);
      expect(stat('Puntos', '42'), findsOneWidget);

      // La elección queda guardada como club favorito.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ClubService.favoriteClubIdKey), 'arturo-prat');
    });

    testWidgets('muestra los cruces del club en la fecha y abre el detalle',
        (tester) async {
      tall(tester);
      SharedPreferences.setMockInitialValues({
        ClubService.favoriteClubIdKey: 'arturo-prat',
      });

      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('FECHA 21 · SÁB 10 – DOM 11 OCT 2026'), findsOneWidget);
      expect(find.text('Sábado 10 oct'), findsOneWidget);
      expect(find.text('Domingo 11 oct'), findsOneWidget);
      // Sábado y domingo vs Bdo. O'Higgins, y domingo vs Maestranza.
      expect(find.text("Bdo. O'Higgins"), findsNWidgets(2));
      expect(find.text('Maestranza'), findsOneWidget);
      expect(find.text('14:10'), findsOneWidget);

      await tester.tap(find.text('Maestranza'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchupDetailPage), findsOneWidget);
      expect(find.text('Fecha 21 · Domingo 11 oct'), findsOneWidget);
    });

    testWidgets('permite cambiar de club', (tester) async {
      tall(tester);
      SharedPreferences.setMockInitialValues({
        ClubService.favoriteClubIdKey: 'arturo-prat',
      });

      await tester.pumpWidget(wrap(const InicioPage(), realDataBundle()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cambiar'));
      await tester.pumpAndSettle();

      expect(find.text('Cambiar mi club'), findsOneWidget);

      await tester.tap(find.text('Independiente'));
      await tester.pumpAndSettle();

      expect(find.text('Independiente'), findsOneWidget);
      expect(find.text('Libre en la fecha 21.'), findsOneWidget);
    });

    testWidgets('"Ver fixture completo" lleva a la pestaña Fixture',
        (tester) async {
      tall(tester);
      SharedPreferences.setMockInitialValues({
        ClubService.favoriteClubIdKey: 'arturo-prat',
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver fixture completo'));
      await tester.pumpAndSettle();

      expect(find.text('FECHA 21'), findsOneWidget);
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
        expect(find.text('MI CLUB'), findsOneWidget);
      });
    }
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

      // Sábado: U.L. Carrera vs San Pablo juega 4 series en dos turnos;
      // la lista lo muestra una sola vez, desde las 13:00.
      expect(find.text('U.L. Carrera'), findsOneWidget);
      expect(
        find.text('1° Infantil · Juveniles · H. Ortiz · S. Senior'),
        findsOneWidget,
      );
      // La lista ya no muestra filas de horario: están en el detalle.
      expect(find.byType(MatchRow), findsNothing);
    });

    testWidgets('al tocar un cruce se ven la cancha y los horarios',
        (tester) async {
      tallView(tester);
      await pumpHome(tester);

      await tester.tap(find.text('U.L. Carrera'));
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

      await tester.dragUntilVisible(
        find.text('Libre: Independiente'),
        find.byType(ListView).first,
        const Offset(0, -300),
      );

      expect(find.text('Libre: Independiente'), findsOneWidget);
    });

    testWidgets('resalta Mi Club sin ocultar al resto', (tester) async {
      SharedPreferences.setMockInitialValues({
        ClubService.favoriteClubIdKey: 'arturo-prat',
      });

      tallView(tester);
      await pumpHome(tester);

      // Sábado: Arturo Prat juega un solo cruce (vs Bdo. O'Higgins).
      expect(find.text('MI CLUB'), findsOneWidget);
      // Los demás cruces siguen visibles.
      expect(find.text('U.L. Carrera'), findsOneWidget);
      expect(find.text('Jackson'), findsOneWidget);
    });

    testWidgets('permite volver a la fecha anterior', (tester) async {
      await pumpHome(tester);

      expect(find.text('FECHA 21'), findsOneWidget);
      expect(find.text('Fuente: planilla de la asociación'), findsOneWidget);

      await tester.tap(find.byTooltip('Fecha anterior'));
      await tester.pumpAndSettle();

      expect(find.text('FECHA 11'), findsOneWidget);
      // La fecha 11 no tiene origen verificado y se avisa.
      expect(find.text('Fuente sin verificar'), findsOneWidget);

      await tester.tap(find.byTooltip('Fecha siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('FECHA 21'), findsOneWidget);
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

  group('Tabla: columnas PJ, DIF y PTS', () {
    testWidgets('con los datos actuales PJ y DIF muestran guion',
        (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('PJ'), findsOneWidget);
      expect(find.text('DIF'), findsOneWidget);
      expect(find.text('PTS'), findsOneWidget);
      // 17 clubes × 2 columnas sin dato.
      expect(find.text('–'), findsNWidgets(34));
      // Los puntos sí son datos reales.
      expect(find.text('161'), findsOneWidget);
    });

    testWidgets('con valores los muestra con signo en DIF', (tester) async {
      await tester.pumpWidget(wrap(
        const StandingsPage(),
        FakeAssetBundle({
          standingsPath: '[{"clubId": "a", "team": "Equipo A", "points": 30,'
              ' "played": 12, "goalDifference": 15},'
              ' {"clubId": "b", "team": "Equipo B", "points": 9,'
              ' "played": 12, "goalDifference": -7}]',
        }),
      ));
      await tester.pumpAndSettle();

      expect(find.text('12'), findsNWidgets(2));
      expect(find.text('+15'), findsOneWidget);
      expect(find.text('-7'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });
  });

  group('Tabla: menú por serie', () {
    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Future<void> choose(WidgetTester tester, String option) async {
      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    testWidgets('por defecto muestra la tabla general', (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      expect(find.text('Tabla general'), findsOneWidget);
      expect(find.text('Chiguayante Sur'), findsOneWidget);
    });

    testWidgets('ofrece las series del fixture de menor a mayor',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      final dropdown = tester.widget<DropdownButton<String?>>(
        find.byType(DropdownButton<String?>),
      );
      final labels = dropdown.items!
          .map((item) => (item.child as Text).data)
          .toList();

      expect(labels, [
        'Tabla general',
        'Serie 2° Infantil',
        'Serie 1° Infantil',
        'Serie Juveniles',
        'Serie H. Ortiz',
        'Serie S. Senior',
        'Serie Segunda',
        'Serie Primera',
        'Serie Senior',
        'Serie Honor',
      ]);
    });

    testWidgets('una serie sin datos lo indica y no inventa la tabla',
        (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(const StandingsPage(), realDataBundle()));
      await tester.pumpAndSettle();

      await choose(tester, 'Serie Honor');

      expect(
        find.text('La tabla de Honor aún no está disponible.'),
        findsOneWidget,
      );
      expect(find.text('Chiguayante Sur'), findsNothing);

      await choose(tester, 'Tabla general');

      expect(find.text('Chiguayante Sur'), findsOneWidget);
    });

    testWidgets('una serie con datos muestra su propia tabla', (tester) async {
      tall(tester);
      await tester.pumpWidget(wrap(
        const StandingsPage(),
        FakeAssetBundle({
          ...realDataFiles(),
          // Datos de EJEMPLO solo para la prueba.
          'assets/data/tablas_series.json':
              '{"series": {"Honor": ['
              '{"clubId": "b", "team": "Equipo B", "points": 3},'
              '{"clubId": "a", "team": "Equipo A", "points": 9,'
              ' "played": 3, "goalDifference": 4}]}}',
        }),
      ));
      await tester.pumpAndSettle();

      await choose(tester, 'Serie Honor');

      // Ordenada por puntos.
      final a = tester.getTopLeft(find.text('Equipo A')).dy;
      final b = tester.getTopLeft(find.text('Equipo B')).dy;
      expect(a, lessThan(b));
      expect(find.text('+4'), findsOneWidget);
      expect(find.text('Chiguayante Sur'), findsNothing);
    });

    testWidgets('si fallan los datos de series, igual muestra la general',
        (tester) async {
      await tester.pumpWidget(wrap(
        const StandingsPage(),
        FakeAssetBundle({standingsPath: realDataFiles()[standingsPath]!}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Reintentar'), findsNothing);
      expect(find.text('Chiguayante Sur'), findsOneWidget);
    });
  });
}
