import 'package:anfa_chiguayante/models/club.dart';
import 'package:anfa_chiguayante/models/fixture_round.dart';
import 'package:anfa_chiguayante/models/match.dart';
import 'package:anfa_chiguayante/models/standing.dart';
import 'package:anfa_chiguayante/services/standings_service.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> matchJson({
  String homeId = 'arturo-prat',
  String awayId = 'el-valle',
  String? status,
}) {
  return {
    'time': '15:00',
    'home': 'Arturo Prat',
    'homeId': homeId,
    'away': 'El Valle',
    'awayId': awayId,
    'category': '1° Infantil',
    if (status != null) 'status': status,
  };
}

void main() {
  group('Club', () {
    test('fromJson lee id, nombre, nombre corto y cancha', () {
      final club = Club.fromJson({
        'id': 'arturo-prat',
        'name': 'Arturo Prat',
        'shortName': 'A. Prat',
        'field': 'Cancha Chiguayante Sur',
      });

      expect(club.id, 'arturo-prat');
      expect(club.name, 'Arturo Prat');
      expect(club.shortName, 'A. Prat');
      expect(club.field, 'Cancha Chiguayante Sur');
    });

    test('fromJson falla si falta el id', () {
      expect(
        () => Club.fromJson({
          'name': 'Arturo Prat',
          'shortName': 'A. Prat',
          'field': '',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Match', () {
    test('fromJson lee los ids de local y visita', () {
      final match = Match.fromJson(matchJson());

      expect(match.homeId, 'arturo-prat');
      expect(match.awayId, 'el-valle');
      expect(match.home, 'Arturo Prat');
    });

    test('status por defecto es "normal"', () {
      expect(Match.fromJson(matchJson()).status, 'normal');
      expect(
        Match.fromJson(matchJson(status: 'suspendido')).status,
        'suspendido',
      );
    });

    test('involves compara por id, no por nombre', () {
      final match = Match.fromJson(matchJson());

      expect(match.involves('arturo-prat'), isTrue);
      expect(match.involves('el-valle'), isTrue);
      expect(match.involves('jackson'), isFalse);
      // El nombre o el nombre corto no sirven como identificador.
      expect(match.involves('Arturo Prat'), isFalse);
      expect(match.involves('A. Prat'), isFalse);
    });

    test('copyWith conserva los ids', () {
      final copy = Match.fromJson(matchJson()).copyWith(status: 'suspendido');

      expect(copy.homeId, 'arturo-prat');
      expect(copy.awayId, 'el-valle');
      expect(copy.status, 'suspendido');
    });

    test('fromJson falla si falta un id de equipo', () {
      final json = matchJson()..remove('awayId');

      expect(() => Match.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  group('FixtureRound', () {
    test('fromJson arma días, canchas y partidos', () {
      final round = FixtureRound.fromJson({
        'round': 11,
        'days': [
          {
            'day': 'Sábado',
            'fields': [
              {
                'fieldName': 'Cancha Chiguayante Sur',
                'matches': [matchJson()],
              },
            ],
          },
        ],
      });

      expect(round.round, 11);
      expect(round.days.single.day, 'Sábado');
      expect(round.days.single.fields.single.matches.single.homeId,
          'arturo-prat');
    });
  });

  group('Standing y tabla', () {
    test('fromJson lee clubId, texto original y puntos', () {
      final s = Standing.fromJson({
        'clubId': 'arturo-prat',
        'team': 'A. Prat',
        'points': 42,
      });

      expect(s.clubId, 'arturo-prat');
      expect(s.team, 'A. Prat');
      expect(s.points, 42);
    });

    test('ordena por puntos y conserva el orden de la fuente en empates', () {
      final table = StandingsService.parseStandings([
        {'clubId': 'c', 'team': 'C', 'points': 10},
        {'clubId': 'a', 'team': 'A', 'points': 30},
        {'clubId': 'b1', 'team': 'B1', 'points': 20},
        {'clubId': 'b2', 'team': 'B2', 'points': 20},
      ]);

      expect(table.map((s) => s.clubId), ['a', 'b1', 'b2', 'c']);
    });

    test('positionOf devuelve null si el club no figura', () {
      final table = StandingsService.parseStandings([
        {'clubId': 'a', 'team': 'A', 'points': 3},
      ]);

      expect(StandingsService.positionOf(table, 'a')!.position, 1);
      expect(StandingsService.positionOf(table, 'zz'), isNull);
    });
  });
}
