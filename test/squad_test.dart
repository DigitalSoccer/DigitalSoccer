import 'dart:convert';

import 'package:anfa_chiguayante/models/club.dart';
import 'package:anfa_chiguayante/models/player.dart';
import 'package:anfa_chiguayante/models/series.dart';
import 'package:anfa_chiguayante/pages/club_detail_page.dart';
import 'package:anfa_chiguayante/pages/squad_page.dart';
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

  group('Pantalla Plantel', () {
    testWidgets('sin datos muestra que el plantel no está disponible',
        (tester) async {
      await tester.pumpWidget(wrap(
        SquadPage(
          club: prat,
          categories: const ['Senior', 'Honor'],
          initialCategory: 'Honor',
        ),
        realDataBundle(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Plantel · Arturo Prat'), findsOneWidget);
      expect(
        find.text('El plantel de Honor aún no está disponible.'),
        findsOneWidget,
      );
    });

    testWidgets('con jugadores muestra la tabla con sus estadísticas',
        (tester) async {
      await tester.pumpWidget(wrap(
        SquadPage(
          club: prat,
          categories: const ['Senior', 'Honor'],
          initialCategory: 'Honor',
        ),
        bundleWithExamples(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('JUGADOR'), findsOneWidget);
      expect(find.text('Jugador Ejemplo Uno'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      // Sin número de camiseta se muestra un guion.
      expect(find.text('–'), findsOneWidget);
      expect(find.text('PJ: partidos jugados'), findsOneWidget);

      // La otra serie aún no tiene plantel.
      await tester.tap(find.text('Senior'));
      await tester.pumpAndSettle();

      expect(
        find.text('El plantel de Senior aún no está disponible.'),
        findsOneWidget,
      );
    });

    testWidgets('sin desbordes a 320 px', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(
        SquadPage(
          club: prat,
          categories: const ['Honor'],
          initialCategory: 'Honor',
        ),
        bundleWithExamples(),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Jugador Ejemplo Uno'), findsOneWidget);
    });
  });

  group('Acceso desde la ficha del club', () {
    testWidgets('lista las series del club y abre el plantel elegido',
        (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(
        Scaffold(body: ClubDetailPage(club: prat)),
        realDataBundle(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('PLANTELES POR SERIE'), findsOneWidget);

      // Series de Arturo Prat en las fechas 11 y 21, de menor a mayor.
      final chips = tester
          .widgetList<ActionChip>(find.byType(ActionChip))
          .map((c) => (c.label as Text).data)
          .toList();
      expect(chips, [
        '1° Infantil',
        'Juveniles',
        'S. Senior',
        'Segunda',
        'Primera',
        'Senior',
        'Honor',
      ]);

      await tester.tap(find.widgetWithText(ActionChip, 'Honor'));
      await tester.pumpAndSettle();

      expect(find.byType(SquadPage), findsOneWidget);
      expect(
        find.text('El plantel de Honor aún no está disponible.'),
        findsOneWidget,
      );
    });
  });
}
