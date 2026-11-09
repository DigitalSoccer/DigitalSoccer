/// Serie del campeonato (las 10 de la planilla, con sus nombres).
class Serie {
  final String id;
  final String name;

  /// Posición en los chips (de la serie mayor a la menor).
  final int order;

  const Serie({required this.id, required this.name, required this.order});

  factory Serie.fromJson(Map<String, dynamic> json) => Serie(
        id: json['id'] as String,
        name: json['nombre'] as String,
        order: json['orden'] as int,
      );
}

/// Fecha del campeonato: un fin de semana con 8 cruces y un club en turno.
class Round {
  final int number;
  final DateTime saturday;
  final DateTime sunday;

  /// Club que no juega en la fecha.
  final String restingClubId;

  /// Club en turno asignado: descansa y registra los resultados. `null` si
  /// aún no se asigna.
  /// TODO(asociación): confirmar que el turno es el club que descansa.
  final String? turnoClubId;

  const Round({
    required this.number,
    required this.saturday,
    required this.sunday,
    required this.restingClubId,
    this.turnoClubId,
  });

  factory Round.fromJson(Map<String, dynamic> json) => Round(
        number: json['numero'] as int,
        saturday: DateTime.parse(json['sabado'] as String),
        sunday: DateTime.parse(json['domingo'] as String),
        restingClubId: json['libre'] as String,
        turnoClubId: json['turno'] as String?,
      );
}

enum MatchStatus {
  /// Jugado y validado: cuenta en la tabla.
  finished,

  /// Papeleta enviada por el turno, por validar por la asociación.
  pendingValidation,

  /// Se jugó y falta la papeleta del turno.
  pendingReport,

  /// No se jugó (sin resultado).
  suspended,

  /// Aún no se juega.
  scheduled;

  static MatchStatus parse(String value) => switch (value) {
        'finalizado' => finished,
        'por-validar' => pendingValidation,
        'pendiente' => pendingReport,
        'suspendido' => suspended,
        _ => scheduled,
      };
}

enum EventType { goal, yellow, red }

class MatchEvent {
  final int minute;
  final EventType type;
  final String playerId;

  const MatchEvent({
    required this.minute,
    required this.type,
    required this.playerId,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) => MatchEvent(
        minute: json['min'] as int,
        type: switch (json['tipo']) {
          'gol' => EventType.goal,
          'amarilla' => EventType.yellow,
          _ => EventType.red,
        },
        playerId: json['jugador'] as String,
      );
}

/// Partido de una serie en una fecha.
class Match {
  final String id;
  final int round;
  final String serieId;
  final String homeId;
  final String awayId;

  /// true = sábado, false = domingo.
  final bool saturday;
  final String time;
  final String field;
  final MatchStatus status;
  final int? homeGoals;
  final int? awayGoals;
  final String? referee;
  final List<String> homeLineup;
  final List<String> awayLineup;
  final List<MatchEvent> events;

  const Match({
    required this.id,
    required this.round,
    required this.serieId,
    required this.homeId,
    required this.awayId,
    required this.saturday,
    required this.time,
    required this.field,
    required this.status,
    this.homeGoals,
    this.awayGoals,
    this.referee,
    this.homeLineup = const [],
    this.awayLineup = const [],
    this.events = const [],
  });

  bool involves(String clubId) => homeId == clubId || awayId == clubId;

  bool get hasScore => homeGoals != null && awayGoals != null;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'] as String,
        round: json['fecha'] as int,
        serieId: json['serie'] as String,
        homeId: json['local'] as String,
        awayId: json['visita'] as String,
        saturday: json['dia'] == 'sab',
        time: json['hora'] as String,
        field: json['cancha'] as String? ?? '',
        status: MatchStatus.parse(json['estado'] as String),
        homeGoals: json['golesLocal'] as int?,
        awayGoals: json['golesVisita'] as int?,
        referee: json['arbitro'] as String?,
        homeLineup: _ids(json['alineacionLocal']),
        awayLineup: _ids(json['alineacionVisita']),
        events: [
          for (final e in json['eventos'] as List? ?? [])
            MatchEvent.fromJson(e as Map<String, dynamic>),
        ],
      );
}

List<String> _ids(Object? value) =>
    [for (final id in value as List? ?? []) id as String];

/// Jugador (nombres ficticios en los datos de muestra).
class Player {
  final String id;
  final String clubId;
  final String serieId;
  final int number;
  final String name;

  const Player({
    required this.id,
    required this.clubId,
    required this.serieId,
    required this.number,
    required this.name,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        clubId: json['club'] as String,
        serieId: json['serie'] as String,
        number: json['numero'] as int,
        name: json['nombre'] as String,
      );
}
