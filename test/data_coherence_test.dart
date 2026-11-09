import 'dart:convert';
import 'dart:io';

import 'package:anfa_chiguayante/data/league_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Coherencia de los datos de muestra (ver tool/generate_sample_data.dart):
/// la tabla cuadra con los resultados y con los puntos reales, un club no
/// juega dos veces en la misma fecha y el club en turno descansa.
void main() {
  late Map<String, dynamic> json;
  late LeagueData data;

  setUpAll(() {
    json = jsonDecode(File('assets/data/sample_data.json').readAsStringSync())
        as Map<String, dynamic>;
    data = LeagueData.fromJson(json);
  });

  test('17 clubes, 10 series y 34 fechas', () {
    expect(data.clubs, hasLength(17));
    expect(data.series.map((s) => s.name), [
      'Honor', 'Primera', 'Segunda', 'Senior', 'S. Senior', 'H. Ortiz',
      'Femenina', 'Juveniles', '1° Infantil', '2° Infantil',
    ]);
    expect(data.rounds, hasLength(34));
  });

  test('cada fecha: 8 partidos por serie, nadie repite y el turno descansa',
      () {
    for (final round in data.rounds) {
      for (final serie in data.series) {
        final list = data.matchesOf(round: round.number, serieId: serie.id);
        final clubs = <String>{};
        for (final m in list) {
          expect(clubs.add(m.homeId), isTrue, reason: 'f${round.number}');
          expect(clubs.add(m.awayId), isTrue, reason: 'f${round.number}');
        }
        expect(clubs, isNot(contains(round.restingClubId)));
        if (serie.id != 'honor') {
          expect(list, hasLength(8), reason: '${serie.id} f${round.number}');
        }
      }
    }
  });

  test('Honor es un campeonato de 10 equipos (los 0 no tienen equipo)', () {
    final honor = data.clubsIn('honor').map((c) => c.id).toSet();
    expect(honor, hasLength(10));
    for (final m in data.matchesOf(serieId: 'honor')) {
      expect(honor, containsAll([m.homeId, m.awayId]));
    }
  });

  test('la tabla calculada cuadra con los puntos REALES de 4 series', () {
    final real = json['puntosReales'] as Map<String, dynamic>;
    for (final entry in real.entries) {
      final table = data.standings(entry.key);
      for (final club in (entry.value as Map<String, dynamic>).entries) {
        final row = table.where((r) => r.club.id == club.key).firstOrNull;
        if (entry.key == 'honor' && club.value == 0) {
          expect(row, isNull, reason: '${club.key} sin equipo en Honor');
        } else {
          expect(row?.points, club.value, reason: '${entry.key} ${club.key}');
        }
      }
    }
  });

  test('cada fila de la tabla es coherente (PJ, V/E/D, puntos y goles)', () {
    for (final serie in data.series) {
      final table = data.standings(serie.id);
      var gf = 0, gc = 0;
      for (final r in table) {
        expect(r.played, r.won + r.drawn + r.lost);
        expect(r.points, r.won * 3 + r.drawn);
        gf += r.goalsFor;
        gc += r.goalsAgainst;
      }
      expect(gf, gc, reason: serie.id);
      // Posiciones compartidas con puntos iguales.
      for (final r in table) {
        expect(r.position,
            1 + table.where((o) => o.points > r.points).length);
      }
    }
  });

  test('los goles de cada partido coinciden con sus eventos', () {
    for (final m in data.matches.where((m) => m.status == MatchStatus.finished)) {
      final goals = m.events.where((e) => e.type == EventType.goal);
      final home = goals.where((e) => m.homeLineup.contains(e.playerId)).length;
      final away = goals.where((e) => m.awayLineup.contains(e.playerId)).length;
      expect(home, m.homeGoals, reason: m.id);
      expect(away, m.awayGoals, reason: m.id);
      // Todo evento es de un jugador presente en el partido.
      for (final e in m.events) {
        expect([...m.homeLineup, ...m.awayLineup], contains(e.playerId));
      }
    }
  });

  test('las alineaciones son de jugadores del club y la serie', () {
    for (final m in data.matches.where((m) => m.status == MatchStatus.finished)) {
      for (final id in m.homeLineup) {
        final p = data.player(id)!;
        expect((p.clubId, p.serieId), (m.homeId, m.serieId));
      }
      for (final id in m.awayLineup) {
        final p = data.player(id)!;
        expect((p.clubId, p.serieId), (m.awayId, m.serieId));
      }
    }
  });

  test('estados: 1–20 jugadas, 21 en carga, 22 en adelante programadas', () {
    for (final m in data.matches) {
      if (m.round <= data.validatedRounds) {
        expect(m.status, anyOf(MatchStatus.finished, MatchStatus.suspended));
      } else if (m.round == data.currentRound) {
        expect(m.status, isNot(MatchStatus.finished));
      } else {
        expect(m.status, MatchStatus.scheduled);
      }
    }
    final current = data.matchesOf(round: data.currentRound);
    expect(current.where((m) => m.status == MatchStatus.pendingValidation),
        hasLength(1));
    expect(current.any((m) => m.status == MatchStatus.suspended), isTrue);
  });

  test('las últimas fechas aún no tienen turno asignado', () {
    expect(data.rounds.where((r) => r.turnoClubId == null).map((r) => r.number),
        [31, 32, 33, 34]);
  });

  test('las estadísticas del jugador salen de los partidos', () {
    final account = data.users.firstWhere((u) => u.profile == Profile.subscriber);
    final stats = data.playerStats(account.playerId!);
    final present = stats.attendance.where((a) => a.$2).length;
    expect(stats.matches, present);
    expect(stats.attendance, isNotEmpty);
  });

  test('cuentas de prueba para los perfiles del ingreso simulado', () {
    expect(data.users.map((u) => u.profile).toSet(),
        {Profile.subscriber, Profile.player, Profile.turno, Profile.admin});
    final turno = data.users.firstWhere((u) => u.profile == Profile.turno);
    expect(turno.clubId, data.round(data.currentRound)!.turnoClubId);
  });
}
