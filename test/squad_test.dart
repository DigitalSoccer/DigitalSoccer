import 'dart:convert';

import 'package:anfa_chiguayante/models/club.dart';
import 'package:anfa_chiguayante/models/player.dart';
import 'package:anfa_chiguayante/models/series.dart';
import 'package:anfa_chiguayante/pages/club_detail_page.dart';
import 'package:anfa_chiguayante/pages/matchup_detail_page.dart';
import 'package:anfa_chiguayante/services/club_data_service.dart';
import 'package:anfa_chiguayante/services/squad_service.dart';
import 'package:anfa_chiguayante/services/standings_catalog.dart';
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

  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpDetail(
    WidgetTester tester,
    AssetBundle bundle, {
    DateTime? today,
  }) async {
    await tester.pumpWidget(wrap(
      ClubDetailPage(club: prat, today: today ?? DateTime(2026, 10, 15)),
      bundle,
    ));
    await tester.pumpAndSettle();
  }

  group('Ficha del club: plantel', () {
    testWidgets('con General lista las series del club', (tester) async {
      tall(tester);
      await pumpDetail(tester, realDataBundle());

      expect(find.text('Plantel'), findsOneWidget);

      // Series de Arturo Prat en las fechas 11 y 21, de menor a mayor
      // (la última aparición de cada nombre es la fila del plantel; antes
      // están los chips).
      const series = [
        '1° Infantil',
        'Juveniles',
        'S. Senior',
        'Segunda',
        'Primera',
        'Senior',
        'Honor',
      ];
      final ys = [
        for (final name in series) tester.getTopLeft(find.text(name).last).dy,
      ];
      for (var i = 1; i < ys.length; i++) {
        expect(ys[i], greaterThan(ys[i - 1]), reason: series[i]);
      }
      expect(find.text('Plantel aún no disponible'), findsNWidgets(7));

      // Tocar una serie la elige en los chips.
      await tester.tap(find.text('Honor').last);
      await tester.pumpAndSettle();

      expect(find.text('Plantel · Honor'), findsOneWidget);
      expect(
        find.text('El plantel de Honor aún no está disponible.'),
        findsOneWidget,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StandingsCatalog.prefsKey), 'serie:Honor');
    });

    testWidgets('con una serie con jugadores muestra la tabla',
        (tester) async {
      tall(tester);
      SharedPreferences.setMockInitialValues({
        StandingsCatalog.prefsKey: 'serie:Honor',
      });
      await pumpDetail(tester, bundleWithExamples());

      expect(find.text('Plantel · Honor'), findsOneWidget);
      expect(find.text('JUGADOR'), findsOneWidget);
      expect(find.text('Jugador Ejemplo Uno'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('PJ: partidos jugados'), findsOneWidget);
    });

    testWidgets('con General cuenta los jugadores de cada serie',
        (tester) async {
      tall(tester);
      await pumpDetail(tester, bundleWithExamples());

      expect(find.text('2 jugadores'), findsOneWidget);
      expect(find.text('Jugador Ejemplo Uno'), findsNothing);
    });

    testWidgets('sin desbordes a 320 px con la tabla abierta', (tester) async {
      tester.view.physicalSize = const Size(320, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        StandingsCatalog.prefsKey: 'serie:Honor',
      });

      await pumpDetail(tester, bundleWithExamples());

      expect(tester.takeException(), isNull);
      expect(find.text('Jugador Ejemplo Uno'), findsOneWidget);
    });
  });

  group('Ficha del club: próximos partidos', () {
    testWidgets('sin fechas futuras avisa y muestra la última programada',
        (tester) async {
      tall(tester);
      // La fecha 21 se jugó el 10 y 11 de octubre.
      await pumpDetail(tester, realDataBundle());

      expect(
        find.textContaining('Aún no hay próximas fechas cargadas'),
        findsOneWidget,
      );
      expect(find.text('vs Maestranza'), findsOneWidget);
      expect(find.text('Fecha 21'), findsNWidgets(3));

      await tester.tap(find.text('vs Maestranza'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchupDetailPage), findsOneWidget);
    });

    testWidgets('con una fecha futura la muestra sin aviso', (tester) async {
      tall(tester);
      await pumpDetail(tester, realDataBundle(), today: DateTime(2026, 10, 1));

      expect(
        find.textContaining('Aún no hay próximas fechas cargadas'),
        findsNothing,
      );
      // Sábado y domingo vs Bdo. O'Higgins, y domingo vs Maestranza.
      expect(find.text("vs Bdo. O'Higgins"), findsNWidgets(2));
      expect(find.text('SÁB'), findsOneWidget);
      expect(find.text('DOM'), findsNWidgets(2));
    });

    testWidgets('con una serie elegida muestra solo sus partidos',
        (tester) async {
      tall(tester);
      SharedPreferences.setMockInitialValues({
        StandingsCatalog.prefsKey: 'serie:Honor',
      });
      await pumpDetail(tester, realDataBundle());

      // Cada fila es un solo partido y nombra la serie.
      expect(find.textContaining('· Honor'), findsWidgets);
      expect(find.textContaining(RegExp(r'\d+ partidos')), findsNothing);
    });
  });
}
