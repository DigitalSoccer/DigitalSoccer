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
  late FixtureRound fixture;
  late List<Standing> standings;

  setUpAll(() async {
    final bundle = realDataBundle();
    clubs = await ClubDataService.loadClubs(bundle);
    fixture = await DataService.loadData(bundle);
    standings = await StandingsService.loadStandings(bundle);
  });

  Iterable<Match> allMatches() => fixture.days
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

    test('se le asignan sus 5 partidos de la fecha cargada', () {
      final matches =
          allMatches().where((m) => m.involves('arturo-prat')).toList();

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
}
