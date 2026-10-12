import 'package:anfa_chiguayante/models/fixture_round.dart';
import 'package:anfa_chiguayante/models/match.dart';
import 'package:anfa_chiguayante/utils/fecha_format.dart';
import 'package:flutter_test/flutter_test.dart';

Match m(String time, String home, String away, String category) => Match(
      time: time,
      home: home,
      homeId: home.toLowerCase(),
      away: away,
      awayId: away.toLowerCase(),
      category: category,
    );

void main() {
  MatchDay dayWith(Map<String, List<Match>> fields) => MatchDay(
        day: 'Sábado',
        fields: [
          for (final e in fields.entries)
            FieldSchedule(fieldName: e.key, matches: e.value),
        ],
      );

  group('Matchup.fromDay (un cruce por local y visita)', () {
    test('reúne todas las series del cruce aunque estén separadas', () {
      final matchups = Matchup.fromDay(dayWith({
        'Cancha X': [
          m('13:00', 'A', 'B', '1° Infantil'),
          m('14:10', 'A', 'B', 'Juveniles'),
          m('15:30', 'C', 'D', 'H. Ortiz'),
          m('16:40', 'A', 'B', 'S. Senior'),
        ],
      }));

      expect(matchups, hasLength(2));
      expect(matchups.first.home, 'A');
      expect(matchups.first.categories,
          ['1° Infantil', 'Juveniles', 'S. Senior']);
    });

    test('ordena los cruces por la hora de su primer partido', () {
      final matchups = Matchup.fromDay(dayWith({
        'Cancha X': [m('13:00', 'A', 'B', 'Segunda')],
        'Cancha Y': [m('09:00', 'C', 'D', 'Segunda')],
      }));

      expect(matchups.map((x) => x.home), ['C', 'A']);
      expect(matchups.first.firstTime, '09:00');
    });

    test('un cruce en dos canchas conserva la cancha de cada partido', () {
      final matchup = Matchup.fromDay(dayWith({
        'Cancha X': [m('09:00', 'A', 'B', 'Segunda')],
        'Cancha Y': [m('11:00', 'A', 'B', 'Primera')],
      })).single;

      expect(matchup.fieldNames, ['Cancha X', 'Cancha Y']);
      expect(matchup.entries.map((e) => e.fieldName),
          ['Cancha X', 'Cancha Y']);
    });

    test('local y visita invertidos son cruces distintos', () {
      final matchups = Matchup.fromDay(dayWith({
        'Cancha X': [
          m('09:00', 'A', 'B', 'Segunda'),
          m('10:20', 'B', 'A', 'Primera'),
        ],
      }));

      expect(matchups, hasLength(2));
    });

    test('aplica la transformación y el filtro antes de agrupar', () {
      final matchups = Matchup.fromDay(
        dayWith({
          'Cancha X': [
            m('09:00', 'A', 'B', 'Segunda'),
            m('10:20', 'A', 'B', 'Primera'),
          ],
        }),
        map: (x) => x.copyWith(status: 'suspendido'),
        where: (x) => x.category == 'Primera',
      );

      expect(matchups.single.entries.single.match.category, 'Primera');
      expect(matchups.single.first.status, 'suspendido');
    });

    test('día sin partidos', () {
      expect(Matchup.fromDay(dayWith({})), isEmpty);
    });
  });

  group('Formato de planilla en JSON', () {
    Map<String, dynamic> matchJson(String time) => {
          'time': time,
          'home': 'A',
          'homeId': 'a',
          'away': 'B',
          'awayId': 'b',
          'category': 'Segunda',
        };

    test('lee bloques, turno, fecha y libre', () {
      final day = MatchDay.fromJson({
        'day': 'Domingo',
        'date': '2026-10-11',
        'libre': ['independiente'],
        'fields': [
          {
            'fieldName': 'Cancha X',
            'blocks': [
              {'turno': null, 'matches': [matchJson('09:00')]},
              {'turno': ' Club A ', 'matches': [matchJson('13:30')]},
            ],
          },
        ],
      });

      final field = day.fields.single;

      expect(day.date, DateTime(2026, 10, 11));
      expect(day.byeClubIds, ['independiente']);
      expect(field.blocks, hasLength(2));
      expect(field.blocks[0].turno, isNull);
      expect(field.blocks[1].turno, 'Club A');
      expect(field.matches.map((x) => x.time), ['09:00', '13:30']);
      expect(field.hasTurnos, isTrue);
    });

    test('el formato antiguo con "matches" sigue funcionando', () {
      final day = MatchDay.fromJson({
        'day': 'Sábado',
        'fields': [
          {'fieldName': 'Cancha X', 'matches': [matchJson('10:00')]},
        ],
      });

      expect(day.date, isNull);
      expect(day.byeClubIds, isEmpty);
      expect(day.fields.single.matches, hasLength(1));
      expect(day.fields.single.hasTurnos, isFalse);
    });
  });

  group('Formato de fechas', () {
    MatchDay day(String name, DateTime? date) =>
        MatchDay(day: name, date: date, fields: const []);

    test('etiquetas de día', () {
      final sab = day('Sábado', DateTime(2026, 10, 10));

      expect(dayLabel(sab), 'Sábado 10 oct');
      expect(dayTabLabel(sab), 'Sábado 10');
      expect(dayLabel(day('Sábado', null)), 'Sábado');
    });

    test('rango de la fecha', () {
      FixtureRound round(List<MatchDay> days) =>
          FixtureRound(round: 1, days: days);

      expect(
        roundDateRange(round([
          day('Sábado', DateTime(2026, 10, 10)),
          day('Domingo', DateTime(2026, 10, 11)),
        ])),
        'Sáb 10 – Dom 11 oct 2026',
      );
      expect(
        roundDateRange(round([
          day('Sábado', DateTime(2026, 10, 31)),
          day('Domingo', DateTime(2026, 11, 1)),
        ])),
        'Sáb 31 oct – Dom 1 nov 2026',
      );
      expect(roundDateRange(round([day('Sábado', null)])), '');
    });
  });
}
