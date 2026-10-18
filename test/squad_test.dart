import 'dart:convert';

import 'package:anfa_chiguayante/models/club.dart';
import 'package:anfa_chiguayante/models/player.dart';
import 'package:anfa_chiguayante/models/series.dart';
import 'package:anfa_chiguayante/pages/club_detail_page.dart';
import 'package:anfa_chiguayante/pages/matchup_detail_page.dart';
import 'package:anfa_chiguayante/services/club_data_service.dart';
import 'package:anfa_chiguayante/services/squad_service.dart';
import 'package:anfa_chiguayante/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_asset_bundle.dart';

// Jugadores de EJEMPLO, solo para pruebas. No son datos reales.
final ejemploPlanteles = jsonEncode({
  'planteles': [
    {
      'clubId': 'arturo-prat',
      'category': 'Honor',
      'players': [
        {
          'id': 'p1',
          'name': 'Jugador Ejemplo Uno',
          'number': 9,
          'stats': {'played': 18, 'goals': 11, 'yellow': 3, 'red': 1},
        },
        {
          'id': 'p2',
          'name': 'Jugador Ejemplo Dos',
          'stats': {'played': 7},
        },
      ],
    },
  ],
});

Widget wrap(Widget child, AssetBundle bundle) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: DefaultAssetBundle(bundle: bundle, child: child),
  );
}

final prat = Club(
  id: 'arturo-prat',
  name: 'Arturo Prat',
  shortName: 'A. Prat',
  field: 'Cancha Chiguayante Sur',
);

FakeAssetBundle bundleWithExamples() => FakeAssetBundle({
      ...realDataFiles(),
      SquadService.path: ejemploPlanteles,
    });

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Modelos de plantel', () {
    test('estadísticas ausentes valen 0 y el número es opcional', () {
      final player = Player.fromJson({'id': 'x', 'name': 'X'});

      expect(player.number, isNull);
      expect(player.stats.played, 0);
      expect(player.stats.goals, 0);
      expect(player.stats.yellowCards, 0);
      expect(player.stats.redCards, 0);
    });

    test('lee planteles y busca por club y serie', () {
      final squads = (jsonDecode(ejemploPlanteles)['planteles'] as List)
          .map((s) => Squad.fromJson(s as Map<String, dynamic>))
          .toList();

      final honor = SquadService.playersOf(squads, 'arturo-prat', 'Honor');

      expect(honor, hasLength(2));
      expect(honor.first.stats.goals, 11);
      expect(honor.first.stats.redCards, 1);
      expect(SquadService.playersOf(squads, 'arturo-prat', 'Senior'), isEmpty);
      expect(SquadService.playersOf(squads, 'el-valle', 'Honor'), isEmpty);
    });

    test('ordena series de menor a mayor', () {
      expect(
        sortSeries(['Honor', 'Juveniles', 'Segunda', 'Juveniles', 'Otra']),
        ['Juveniles', 'Segunda', 'Honor', 'Otra'],
      );
    });
  });

  group('Datos reales de planteles', () {
    test('el archivo existe, hoy está vacío y sus clubes son válidos',
        () async {
      final bundle = realDataBundle();
      final squads = await SquadService.loadSquads(bundle);
      final ids =
          (await ClubDataService.loadClubs(bundle)).map((c) => c.id).toSet();

      // No hay jugadores cargados hasta que el club entregue los datos.
      expect(squads, isEmpty);
      for (final squad in squads) {
        expect(ids, contains(squad.clubId));
      }
    });
  });

  group('Ficha del club: pestaña Plantel', () {
    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Future<void> pumpDetail(WidgetTester tester, AssetBundle bundle) async {
      await tester.pumpWidget(wrap(
        ClubDetailPage(club: prat, today: DateTime(2026, 10, 15)),
        bundle,
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('muestra las dos pestañas y las series desplegables',
        (tester) async {
      tall(tester);
      await pumpDetail(tester, realDataBundle());

      expect(find.text('Plantel'), findsOneWidget);
      expect(find.text('Próximas fechas'), findsOneWidget);

      // Series de Arturo Prat en las fechas 11 y 21, de menor a mayor.
      final series = tester
          .widgetList<ExpansionTile>(find.byType(ExpansionTile))
          .map((t) => (t.title as Text).data)
          .toList();
      expect(series, [
        '1° Infantil',
        'Juveniles',
        'S. Senior',
        'Segunda',
        'Primera',
        'Senior',
        'Honor',
      ]);
      expect(find.text('Plantel aún no disponible'), findsNWidgets(7));

      await tester.tap(find.text('Honor'));
      await tester.pumpAndSettle();

      expect(
        find.text('El plantel de Honor aún no está disponible.'),
        findsOneWidget,
      );
    });

    testWidgets('al desplegar una serie con jugadores muestra la tabla',
        (tester) async {
      tall(tester);
      await pumpDetail(tester, bundleWithExamples());

      expect(find.text('2 jugadores'), findsOneWidget);
      expect(find.text('Jugador Ejemplo Uno'), findsNothing);

      await tester.tap(find.text('Honor'));
      await tester.pumpAndSettle();

      expect(find.text('JUGADOR'), findsOneWidget);
      expect(find.text('Jugador Ejemplo Uno'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      // Sin número de camiseta se muestra un guion.
      expect(find.text('–'), findsOneWidget);
      expect(find.text('PJ: partidos jugados'), findsOneWidget);
    });

    testWidgets('sin desbordes a 320 px con la tabla abierta', (tester) async {
      tester.view.physicalSize = const Size(320, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpDetail(tester, bundleWithExamples());
      await tester.tap(find.text('Honor'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Jugador Ejemplo Uno'), findsOneWidget);
    });
  });

  group('Ficha del club: pestaña Próximas fechas', () {
    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Future<void> openUpcoming(WidgetTester tester, DateTime today) async {
      await tester.pumpWidget(wrap(
        ClubDetailPage(club: prat, today: today),
        realDataBundle(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Próximas fechas'));
      await tester.pumpAndSettle();
    }

    testWidgets('sin fechas futuras avisa y muestra la última programada',
        (tester) async {
      tall(tester);
      // La fecha 21 se jugó el 10 y 11 de octubre.
      await openUpcoming(tester, DateTime(2026, 10, 15));

      expect(
        find.textContaining('Aún no hay próximas fechas cargadas'),
        findsOneWidget,
      );
      expect(find.text('FECHA 21 · SÁB 10 – DOM 11 OCT 2026'), findsOneWidget);
      expect(find.text('Maestranza'), findsOneWidget);

      await tester.tap(find.text('Maestranza'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchupDetailPage), findsOneWidget);
    });

    testWidgets('con una fecha futura la muestra sin aviso', (tester) async {
      tall(tester);
      await openUpcoming(tester, DateTime(2026, 10, 1));

      expect(
        find.textContaining('Aún no hay próximas fechas cargadas'),
        findsNothing,
      );
      expect(find.text('FECHA 21 · SÁB 10 – DOM 11 OCT 2026'), findsOneWidget);
      // Sábado y domingo vs Bdo. O'Higgins, y domingo vs Maestranza.
      expect(find.text("Bdo. O'Higgins"), findsNWidgets(2));
    });
  });
}
