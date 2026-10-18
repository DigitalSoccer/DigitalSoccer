// Pruebas sobre los datos reales de assets/data: relación entre clubes,
// fixture y tabla de posiciones mediante ids.
import 'package:anfa_chiguayante/models/club.dart';
import 'package:anfa_chiguayante/models/fixture_round.dart';
import 'package:anfa_chiguayante/models/match.dart';
import 'package:anfa_chiguayante/models/standing.dart';
import 'package:anfa_chiguayante/services/club_data_service.dart';
import 'package:anfa_chiguayante/services/data_service.dart';
import 'package:anfa_chiguayante/services/standings_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_asset_bundle.dart';

void main() {
  late List<Club> clubs;
  late List<FixtureRound> rounds;
  late List<Standing> standings;

  setUpAll(() async {
    final bundle = realDataBundle();
    clubs = await ClubDataService.loadClubs(bundle);
    rounds = await DataService.loadRounds(bundle);
    standings = await StandingsService.loadStandings(bundle);
  });

  FixtureRound round(int n) => rounds.firstWhere((r) => r.round == n);

  Iterable<Match> matchesOf(FixtureRound r) => r.days
      .expand((d) => d.fields)
      .expand((f) => f.matches);

  // Todas las fechas cargadas.
  Iterable<Match> allMatches() => rounds
      .expand((r) => r.days)
      .expand((d) => d.fields)
      .expand((f) => f.matches);

  group('Integridad de los datos', () {
    test('los ids de club son únicos', () {
      final ids = clubs.map((c) => c.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('todo partido referencia clubes existentes', () {
      final ids = clubs.map((c) => c.id).toSet();

      for (final m in allMatches()) {
        expect(ids, contains(m.homeId), reason: '${m.home} (${m.time})');
        expect(ids, contains(m.awayId), reason: '${m.away} (${m.time})');
      }
    });

    test('toda fila de la tabla referencia un club existente, sin repetir',
        () {
      final ids = clubs.map((c) => c.id).toSet();
      final tableIds = standings.map((s) => s.clubId).toList();

      for (final s in standings) {
        expect(ids, contains(s.clubId), reason: s.team);
      }
      expect(tableIds.toSet().length, tableIds.length);
    });

    test('los ids del fixture coinciden con el nombre mostrado', () {
      for (final m in allMatches()) {
        expect(ClubDataService.findById(clubs, m.homeId)!.name, m.home);
        expect(ClubDataService.findById(clubs, m.awayId)!.name, m.away);
      }
    });
  });

  group('Arturo Prat', () {
    test('figura en la tabla aunque allí se llame "A. Prat"', () {
      final pos = StandingsService.positionOf(standings, 'arturo-prat');

      expect(pos, isNotNull);
      expect(pos!.standing.team, 'A. Prat');
      // Total acumulado de la planilla oficial 2026 (no calculado por la app).
      expect(pos.position, 17);
      expect(pos.standing.points, 110);
    });

    test('fecha 11: se le asignan sus 5 partidos', () {
      final matches =
          matchesOf(round(11)).where((m) => m.involves('arturo-prat')).toList();

      expect(matches, hasLength(5));
      expect(matches.every((m) => m.home == 'Arturo Prat'), isTrue);
    });
  });

  group("Bdo. O'Higgins", () {
    test('se encuentra su posición y puntos por id', () {
      final pos = StandingsService.positionOf(standings, 'bdo-ohiggins')!;

      expect(pos.position, 5);
      expect(pos.standing.points, 258);
    });

    test('se le asignan sus partidos de la fecha cargada', () {
      final matches =
          allMatches().where((m) => m.involves('bdo-ohiggins')).toList();

      expect(matches, isNotEmpty);
      expect(
        matches.every((m) =>
            m.home == "Bdo. O'Higgins" || m.away == "Bdo. O'Higgins"),
        isTrue,
      );
    });
  });

  group('Fecha 21 (planilla de la asociación)', () {
    test('es la fecha más reciente y tiene fuente', () {
      expect(rounds.first.round, 21);
      expect(round(21).source, contains('Caupolicán'));
      // La fecha 11 no tiene origen verificado.
      expect(round(11).source, isNull);
    });

    test('días con su fecha calendario', () {
      final days = round(21).days;

      expect(days.map((d) => d.day), ['Sábado', 'Domingo']);
      expect(days[0].date, DateTime(2026, 10, 10));
      expect(days[1].date, DateTime(2026, 10, 11));
    });

    test('51 partidos: 25 el sábado y 26 el domingo', () {
      int count(MatchDay d) =>
          d.fields.fold(0, (sum, f) => sum + f.matches.length);

      expect(count(round(21).days[0]), 25);
      expect(count(round(21).days[1]), 26);
    });

    test('Independiente queda libre y no juega', () {
      for (final day in round(21).days) {
        expect(day.byeClubIds, ['independiente']);
      }
      expect(
        matchesOf(round(21)).where((m) => m.involves('independiente')),
        isEmpty,
      );
    });

    test('todo club libre existe en el catálogo', () {
      final ids = clubs.map((c) => c.id).toSet();

      for (final day in rounds.expand((r) => r.days)) {
        for (final id in day.byeClubIds) {
          expect(ids, contains(id));
        }
      }
    });

    test('Arturo Prat: 6 partidos de local, todos en Cancha Chiguayante Sur',
        () {
      final prat = [
        for (final day in round(21).days)
          for (final field in day.fields)
            for (final m in field.matches)
              if (m.involves('arturo-prat'))
                (day: day.day, field: field.fieldName, match: m),
      ];

      expect(prat, hasLength(6));
      expect(prat.every((p) => p.field == 'Cancha Chiguayante Sur'), isTrue);
      expect(prat.every((p) => p.match.home == 'Arturo Prat'), isTrue);
      expect(
        prat.map((p) => '${p.day} ${p.match.time} ${p.match.category}'),
        [
          'Sábado 14:10 Juveniles',
          'Sábado 15:30 S. Senior',
          'Domingo 12:00 Segunda',
          'Domingo 13:20 Primera',
          'Domingo 14:50 Senior',
          'Domingo 19:00 Honor',
        ],
      );
    });

    test('las canchas se dividen en turnos como en la planilla', () {
      final sabado = round(21).days[0];
      final osben =
          sabado.fields.firstWhere((f) => f.fieldName == 'Cancha Mario Osben');
      final magallanes =
          sabado.fields.firstWhere((f) => f.fieldName == 'Cancha Magallanes');

      expect(osben.blocks.map((b) => b.matches.length), [3, 3]);
      expect(magallanes.blocks, hasLength(1));
      // Con un solo bloque la planilla igual muestra la línea "TURNO".
      expect(osben.hasTurnos, isTrue);
      expect(magallanes.hasTurnos, isTrue);
      // La fecha 11 (formato antiguo) no tiene turnos.
      expect(round(11).days.first.fields.first.hasTurnos, isFalse);
    });
  });

  group('Puntaje parcial 2026 (planilla de la asociación)', () {
    late StandingsTable general;
    late SeriesTables tables;

    setUpAll(() async {
      final bundle = realDataBundle();
      general = await StandingsService.loadGeneralTable(bundle);
      tables = await StandingsService.loadSeriesStandings(bundle);
    });

    int pointsOf(List<Standing> table, String clubId) =>
        table.firstWhere((s) => s.clubId == clubId).points;

    const menores = ['2° Infantil', '1° Infantil', 'Juveniles'];
    const adultos = [
      'S. Senior',
      'Segunda',
      'Primera',
      'Senior',
      'Honor',
      'H. Ortiz',
      'Femenina',
    ];

    test('tiene fuente y la advertencia oficial', () {
      expect(general.source, contains('Caupolicán'));
      expect(general.note, contains('sujeta a modificaciones'));
    });

    test('las 10 series y los 2 acumulados tienen a los 17 clubes', () {
      final ids = clubs.map((c) => c.id).toSet();

      expect(tables.series.keys.toSet(), {...menores, ...adultos});
      expect(tables.totals.keys, ['Infantil y juvenil', 'Adultos']);

      for (final table in [
        general.standings,
        ...tables.series.values,
        ...tables.totals.values,
      ]) {
        expect(table.map((s) => s.clubId).toSet(), ids);
      }
    });

    test('en cada club, las series suman sus acumulados y su total', () {
      for (final club in clubs) {
        final menoresSum = menores
            .map((s) => pointsOf(tables.series[s]!, club.id))
            .reduce((a, b) => a + b);
        final adultosSum = adultos
            .map((s) => pointsOf(tables.series[s]!, club.id))
            .reduce((a, b) => a + b);

        expect(
          menoresSum,
          pointsOf(tables.totals['Infantil y juvenil']!, club.id),
          reason: club.name,
        );
        expect(
          adultosSum,
          pointsOf(tables.totals['Adultos']!, club.id),
          reason: club.name,
        );
        expect(
          menoresSum + adultosSum,
          pointsOf(general.standings, club.id),
          reason: club.name,
        );
      }
    });

    test('valores puntuales de la planilla', () {
      expect(general.standings.first.team, 'Chiguayante Sur');
      expect(general.standings.first.points, 394);
      expect(pointsOf(tables.series['Honor']!, 'chiguayante-sur'), 47);
      expect(pointsOf(tables.series['Femenina']!, 'san-pablo'), 48);
      expect(pointsOf(tables.series['2° Infantil']!, 'arturo-prat'), 1);
      expect(pointsOf(tables.totals['Adultos']!, 'arturo-prat'), 82);
    });

    test('los empates comparten posición', () {
      // Serie Honor: varios clubes con 0 puntos.
      final honor = tables.series['Honor']!;
      final zeros = honor.where((s) => s.points == 0).toList();

      expect(zeros.length, greaterThan(1));
      final ranks =
          zeros.map((s) => StandingsService.rankOf(honor, s)).toSet();
      expect(ranks, hasLength(1));
      expect(ranks.single, honor.length - zeros.length + 1);
    });
  });
}
