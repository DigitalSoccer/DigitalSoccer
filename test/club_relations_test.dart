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
      // Valores tal como vienen en standings.json (no calculados).
      expect(pos.position, 17);
      expect(pos.standing.points, 42);
    });

    test('fecha 11: se le asignan sus 5 partidos', () {
      final matches =
          matchesOf(round(11)).where((m) => m.involves('arturo-prat')).toList();

      expect(matches, hasLength(5));
      expect(matches.every((m) => m.home == 'Arturo Prat'), isTrue);
    });
  });

  group("Bdo. O'Higgins", () {
    test('la tabla usa apóstrofo tipográfico y el catálogo uno recto', () {
      final club = ClubDataService.findById(clubs, 'bdo-ohiggins')!;
      final pos = StandingsService.positionOf(standings, 'bdo-ohiggins')!;

      expect(club.name, "Bdo. O'Higgins");
      expect(pos.standing.team, 'Bdo. O’Higgins');
      expect(club.name == pos.standing.team, isFalse,
          reason: 'por eso la relación debe ser por id');
    });

    test('se encuentra su posición y puntos por id', () {
      final pos = StandingsService.positionOf(standings, 'bdo-ohiggins')!;

      expect(pos.position, 5);
      expect(pos.standing.points, 90);
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
}
