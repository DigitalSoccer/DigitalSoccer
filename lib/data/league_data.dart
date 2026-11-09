import 'models/club.dart';
import 'models/content.dart';
import 'models/league.dart';

export 'models/club.dart';
export 'models/content.dart';
export 'models/league.dart';

/// Fila de la tabla de posiciones de una serie.
class StandingRow {
  final Club club;
  final int position;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  const StandingRow({
    required this.club,
    required this.position,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
  });

  int get goalDifference => goalsFor - goalsAgainst;
}

/// Estadísticas de un jugador en la temporada.
class PlayerStats {
  final int matches;
  final int goals;
  final int yellows;
  final int reds;

  /// Asistencia en las fechas que jugó su equipo: (fecha, asistió).
  final List<(int, bool)> attendance;

  /// Expulsado en el último partido de su equipo: no juega la próxima fecha.
  final bool suspended;

  const PlayerStats({
    required this.matches,
    required this.goals,
    required this.yellows,
    required this.reds,
    required this.attendance,
    required this.suspended,
  });
}

/// Todos los datos de la liga y las consultas que usan las pantallas. La
/// tabla y las estadísticas se CALCULAN desde los resultados validados, nunca
/// se escriben a mano; así funcionan igual con los datos oficiales.
class LeagueData {
  final int season;

  /// Última fecha validada (cuenta en la tabla).
  final int validatedRounds;

  /// Fecha que el turno está cargando.
  final int currentRound;

  final List<Serie> series;
  final List<Club> clubs;
  final List<Round> rounds;
  final List<Match> matches;
  final List<Player> players;
  final List<NewsItem> news;
  final List<RuleDocument> documents;
  final List<UserAccount> users;

  final Map<String, Club> _clubs;
  final Map<String, Serie> _series;
  final Map<String, Player> _players;
  final Map<String, List<StandingRow>> _standingsCache = {};

  LeagueData({
    required this.season,
    required this.validatedRounds,
    required this.currentRound,
    required this.series,
    required this.clubs,
    required this.rounds,
    required this.matches,
    required this.players,
    required this.news,
    required this.documents,
    required this.users,
  })  : _clubs = {for (final c in clubs) c.id: c},
        _series = {for (final s in series) s.id: s},
        _players = {for (final p in players) p.id: p};

  factory LeagueData.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) => [
          for (final e in json[key] as List? ?? []) f(e as Map<String, dynamic>),
        ];

    return LeagueData(
      season: meta['temporada'] as int,
      validatedRounds: meta['fechasValidadas'] as int,
      currentRound: meta['fechaEnCarga'] as int,
      series: list('series', Serie.fromJson)
        ..sort((a, b) => a.order.compareTo(b.order)),
      clubs: list('clubes', Club.fromJson),
      rounds: list('fechas', Round.fromJson),
      matches: list('partidos', Match.fromJson),
      players: list('jugadores', Player.fromJson),
      news: list('noticias', NewsItem.fromJson)
        ..sort((a, b) => b.date.compareTo(a.date)),
      documents: list('documentos', RuleDocument.fromJson),
      users: list('usuarios', UserAccount.fromJson),
    );
  }

  Club? club(String? id) => id == null ? null : _clubs[id];
  Serie? serie(String? id) => id == null ? null : _series[id];
  Player? player(String? id) => id == null ? null : _players[id];

  Round? round(int number) =>
      rounds.where((r) => r.number == number).firstOrNull;

  /// Próxima fecha a jugarse (la siguiente a la que está en carga).
  int get nextRound => currentRound + 1;

  List<Match> matchesOf({int? round, String? serieId, String? clubId}) => [
        for (final m in matches)
          if ((round == null || m.round == round) &&
              (serieId == null || m.serieId == serieId) &&
              (clubId == null || m.involves(clubId)))
            m,
      ];

  /// Clubes con equipo en la serie.
  List<Club> clubsIn(String serieId) =>
      [for (final c in clubs) if (c.seriesIds.contains(serieId)) c];

  List<Player> squad(String clubId, String serieId) => [
        for (final p in players)
          if (p.clubId == clubId && p.serieId == serieId) p,
      ]..sort((a, b) => a.number.compareTo(b.number));

  /// Tabla de una serie calculada con los partidos finalizados.
  /// TODO(asociación): criterio de desempate. Hoy, con puntos iguales, los
  /// clubes comparten posición y se ordenan por nombre.
  List<StandingRow> standings(String serieId) =>
      _standingsCache.putIfAbsent(serieId, () => _computeStandings(serieId));

  List<StandingRow> _computeStandings(String serieId) {
    final acc = {
      for (final c in clubsIn(serieId)) c.id: [0, 0, 0, 0, 0, 0],
    }; // pj, v, e, d, gf, gc

    for (final m in matches) {
      if (m.serieId != serieId || m.status != MatchStatus.finished) continue;
      final h = acc[m.homeId], a = acc[m.awayId];
      if (h == null || a == null || !m.hasScore) continue;
      final hg = m.homeGoals!, ag = m.awayGoals!;
      void add(List<int> t, int gf, int gc) {
        t[0]++;
        t[gf > gc ? 1 : gf == gc ? 2 : 3]++;
        t[4] += gf;
        t[5] += gc;
      }

      add(h, hg, ag);
      add(a, ag, hg);
    }

    final rows = [
      for (final e in acc.entries)
        (club: _clubs[e.key]!, v: e.value, pts: e.value[1] * 3 + e.value[2]),
    ]..sort((x, y) {
        final byPts = y.pts.compareTo(x.pts);
        return byPts != 0 ? byPts : x.club.name.compareTo(y.club.name);
      });

    return [
      for (final r in rows)
        StandingRow(
          club: r.club,
          position: 1 + rows.where((o) => o.pts > r.pts).length,
          played: r.v[0],
          won: r.v[1],
          drawn: r.v[2],
          lost: r.v[3],
          goalsFor: r.v[4],
          goalsAgainst: r.v[5],
          points: r.pts,
        ),
    ];
  }

  StandingRow? standingOf(String serieId, String clubId) =>
      standings(serieId).where((r) => r.club.id == clubId).firstOrNull;

  /// Próximo partido del club en la serie (en la próxima fecha), o `null`
  /// si ese fin de semana descansa.
  Match? nextMatch(String clubId, String serieId) => matches
      .where((m) =>
          m.round == nextRound && m.serieId == serieId && m.involves(clubId))
      .firstOrNull;

  PlayerStats playerStats(String playerId) {
    final p = _players[playerId]!;
    final teamMatches = [
      for (final m in matches)
        if (m.serieId == p.serieId &&
            m.involves(p.clubId) &&
            m.status == MatchStatus.finished)
          m,
    ]..sort((a, b) => a.round.compareTo(b.round));

    var played = 0, goals = 0, yellows = 0, reds = 0;
    final attendance = <(int, bool)>[];
    for (final m in teamMatches) {
      final lineup = m.homeId == p.clubId ? m.homeLineup : m.awayLineup;
      final present = lineup.contains(playerId);
      attendance.add((m.round, present));
      if (present) played++;
      for (final e in m.events.where((e) => e.playerId == playerId)) {
        switch (e.type) {
          case EventType.goal:
            goals++;
          case EventType.yellow:
            yellows++;
          case EventType.red:
            reds++;
        }
      }
    }

    final last = teamMatches.lastOrNull;
    final suspended = last != null &&
        last.events.any((e) => e.type == EventType.red && e.playerId == playerId);

    return PlayerStats(
      matches: played,
      goals: goals,
      yellows: yellows,
      reds: reds,
      attendance: attendance,
      suspended: suspended,
    );
  }
}
