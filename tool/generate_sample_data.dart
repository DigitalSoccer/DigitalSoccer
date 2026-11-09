// Genera assets/data/sample_data.json: el ÚNICO archivo de datos de muestra
// de la app. Uso (desde la raíz del repositorio):
//
//   C:\flutter\bin\dart.bat run tool/generate_sample_data.dart
//
// Todo lo que produce es DUMMY (ficticio), salvo:
//   - REAL: los 17 clubes (nombre, iniciales y color del mockup aprobado).
//   - REAL: los puntos de Honor, Primera, Segunda y Senior (planilla de la
//     asociación, tal como vienen en el mockup). Los resultados dummy de las
//     fechas jugadas se buscan para que sumen EXACTAMENTE esos puntos.
//
// Es determinista (semilla fija): volver a ejecutarlo da el mismo archivo.
// Al terminar verifica la coherencia (tabla = resultados, un club no juega
// dos veces en la misma fecha, el club en turno descansa).

import 'dart:convert';
import 'dart:io';
import 'dart:math';

const int seed = 2026;

/// Semilla del intento actual: si un sorteo del calendario no permite cuadrar
/// los puntos reales (p. ej. dos clubes con muy pocos puntos que se enfrentan
/// dos veces), se prueba el siguiente.
var attemptSeed = seed;
var rng = Random(seed);

/// Fechas del campeonato: ida y vuelta de 17 clubes = 34 fechas.
const int totalRounds = 34;

/// Fechas ya jugadas y validadas (cuentan en la tabla).
const int validatedRounds = 20;

/// Fecha en carga: se jugó y el turno está subiendo las papeletas.
const int currentRound = 21;

/// Fechas desde esta en adelante no tienen turno asignado (para el panel
/// de la liga). DUMMY.
const int firstRoundWithoutTurno = 31;

/// Sábado de la fecha 1 (DUMMY).
final firstSaturday = DateTime(2026, 6, 20);

// ---------------------------------------------------------------------------
// Clubes: REAL (nombre, iniciales y color del mockup aprobado). La cancha
// viene de la planilla anterior y está por confirmar.
// ---------------------------------------------------------------------------

class ClubSeed {
  final String id, name, fullName, initials, color, field;
  const ClubSeed(
      this.id, this.name, this.fullName, this.initials, this.color, this.field);
}

const clubs = [
  ClubSeed('ap', 'A. Prat', 'Arturo Prat', 'AP', '#0F766E',
      'Cancha Chiguayante Sur'),
  ClubSeed('bo', "Bdo. O'Higgins", "Bernardo O'Higgins", 'BO', '#1E40AF',
      'Cancha Magallanes'),
  ClubSeed('cs', 'Chiguayante Sur', 'Chiguayante Sur', 'CS', '#0E7490',
      'Cancha Chiguayante Sur'),
  ClubSeed('et', 'El Tigre', 'El Tigre', 'ET', '#A16207', 'Cancha Mario Osbén'),
  ClubSeed('ev', 'El Valle', 'El Valle', 'EV', '#4D7C0F',
      'Cancha Chiguayante Sur'),
  ClubSeed('fb', 'Ferrobadminton', 'Ferrobadminton', 'FB', '#4B5563',
      'Cancha Mario Osbén'),
  ClubSeed('in', 'Independiente', 'Independiente', 'IN', '#86198F',
      'Cancha Independiente'),
  ClubSeed('ja', 'Jackson', 'Jackson', 'JA', '#9A3412', 'Cancha Magallanes'),
  ClubSeed('le', 'Leinenweber', 'Leinenweber', 'LE', '#BE185D',
      'Cancha Mario Osbén'),
  ClubSeed('me', 'Maestranza', 'Maestranza', 'ME', '#3730A3',
      'Cancha José Vilches'),
  ClubSeed('mg', 'Magallanes', 'Magallanes', 'MG', '#166534',
      'Cancha Magallanes'),
  ClubSeed('na', 'Nacional', 'Nacional', 'NA', '#92400E', 'Cancha José Vilches'),
  ClubSeed('sp', 'San Pablo', 'San Pablo', 'SP', '#0369A1', 'Cancha Magallanes'),
  ClubSeed('sf', 'Shaub F.C.', 'Shaub F.C.', 'SF', '#6B7280',
      'Cancha Independiente'),
  ClubSeed('ub', 'U.L. Bolzhauser', 'U.L. Bolzhauser', 'UB', '#7E22CE',
      'Cancha Magallanes'),
  ClubSeed('uc', 'U.L. Carrera', 'U.L. Carrera', 'UC', '#475569',
      'Cancha José Vilches'),
  ClubSeed('ua', 'Unión Angamos', 'Unión Angamos', 'UA', '#B45309',
      'Cancha Chiguayante Sur'),
];

// ---------------------------------------------------------------------------
// Series: las 10 de la planilla, con sus nombres. Orden de los chips: de la
// serie mayor a la menor. `baseTime`: hora del partido de esa serie en un
// cruce (DUMMY).
// ---------------------------------------------------------------------------

class SerieSeed {
  final String id, name, baseTime;
  final bool female;
  const SerieSeed(this.id, this.name, this.baseTime, {this.female = false});
}

const series = [
  SerieSeed('honor', 'Honor', '19:00'),
  SerieSeed('primera', 'Primera', '16:00'),
  SerieSeed('segunda', 'Segunda', '15:00'),
  SerieSeed('senior', 'Senior', '17:00'),
  SerieSeed('s-senior', 'S. Senior', '14:00'),
  SerieSeed('h-ortiz', 'H. Ortiz', '13:00'),
  SerieSeed('femenina', 'Femenina', '12:00', female: true),
  SerieSeed('juveniles', 'Juveniles', '11:00'),
  SerieSeed('infantil-1', '1° Infantil', '10:00'),
  SerieSeed('infantil-2', '2° Infantil', '09:00'),
];

/// Honor es un campeonato propio de 10 equipos (decisión del equipo): los
/// clubes con 0 puntos en Honor no tienen equipo en esa serie.
/// TODO(asociación): confirmar el significado de los 0 en Honor.
const honorSerie = 'honor';

// ---------------------------------------------------------------------------
// Puntos REALES (planilla de la asociación, como en el mockup).
// ---------------------------------------------------------------------------

const realPoints = <String, Map<String, int>>{
  'primera': {
    'ap': 14, 'bo': 36, 'cs': 44, 'et': 19, 'ev': 35, 'fb': 9, 'in': 28,
    'ja': 30, 'le': 10, 'me': 6, 'mg': 34, 'na': 20, 'sp': 35, 'sf': 6,
    'ub': 28, 'uc': 49, 'ua': 37,
  },
  'segunda': {
    'ap': 21, 'bo': 31, 'cs': 29, 'et': 17, 'ev': 24, 'fb': 37, 'in': 28,
    'ja': 23, 'le': 39, 'me': 45, 'mg': 47, 'na': 6, 'sp': 20, 'sf': 17,
    'ub': 8, 'uc': 9, 'ua': 30,
  },
  // En el mockup esta columna se llamaba "Super Senior"; corresponde a la
  // serie "Senior" de la planilla.
  'senior': {
    'ap': 19, 'bo': 43, 'cs': 50, 'et': 0, 'ev': 15, 'fb': 48, 'in': 35,
    'ja': 33, 'le': 38, 'me': 36, 'mg': 15, 'na': 30, 'sp': 31, 'sf': 3,
    'ub': 10, 'uc': 24, 'ua': 12,
  },
  'honor': {
    'ap': 4, 'bo': 34, 'cs': 47, 'et': 0, 'ev': 0, 'fb': 3, 'in': 0,
    'ja': 10, 'le': 0, 'me': 22, 'mg': 37, 'na': 27, 'sp': 34, 'sf': 0,
    'ub': 0, 'uc': 0, 'ua': 33,
  },
};

final honorTeams = [
  for (final c in clubs)
    if (realPoints['honor']![c.id]! > 0) c.id,
];

// ---------------------------------------------------------------------------
// Nombres ficticios (DUMMY): combinaciones al azar de nombres comunes; no
// corresponden a personas reales.
// ---------------------------------------------------------------------------

const maleNames = [
  'Matías', 'Benjamín', 'Vicente', 'Martín', 'Joaquín', 'Agustín', 'Tomás',
  'Diego', 'Felipe', 'Sebastián', 'Nicolás', 'Cristóbal', 'Ignacio', 'Lucas',
  'Maximiliano', 'Bastián', 'Gabriel', 'Javier', 'Rodrigo', 'Francisco',
  'Pablo', 'Andrés', 'Cristian', 'Claudio', 'Mauricio', 'Gonzalo', 'Héctor',
  'Luis', 'Jorge', 'Patricio', 'Esteban', 'Fabián', 'Hugo', 'Iván', 'Raúl',
  'Óscar', 'Marcelo', 'Alexis', 'Renato', 'Emilio',
];

const femaleNames = [
  'Sofía', 'Isidora', 'Florencia', 'Martina', 'Antonia', 'Catalina',
  'Josefa', 'Valentina', 'Fernanda', 'Constanza', 'Javiera', 'Camila',
  'Francisca', 'Daniela', 'Paula', 'Carla', 'Belén', 'Ignacia', 'Trinidad',
  'Amanda', 'Emilia', 'Agustina', 'Renata', 'Macarena', 'Tamara',
];

const surnames = [
  'González', 'Muñoz', 'Rojas', 'Díaz', 'Pérez', 'Soto', 'Contreras',
  'Silva', 'Martínez', 'Sepúlveda', 'Morales', 'Rodríguez', 'López',
  'Fuentes', 'Hernández', 'Torres', 'Araya', 'Flores', 'Espinoza',
  'Valenzuela', 'Castillo', 'Tapia', 'Reyes', 'Gutiérrez', 'Castro',
  'Pizarro', 'Álvarez', 'Vásquez', 'Sánchez', 'Fernández', 'Ramírez',
  'Carrasco', 'Gómez', 'Cortés', 'Herrera', 'Núñez', 'Jara', 'Vergara',
  'Rivera', 'Figueroa', 'Riquelme', 'Bravo', 'Vera', 'Molina', 'Vega',
  'Campos', 'Sandoval', 'Olivares', 'Zúñiga', 'Ortiz', 'Gallardo', 'Ortega',
  'Salazar', 'Garrido', 'Saavedra', 'Guzmán', 'Navarro', 'Aguilera',
  'Parra', 'Romero',
];

String fictionalName(bool female) {
  final first = female
      ? femaleNames[rng.nextInt(femaleNames.length)]
      : maleNames[rng.nextInt(maleNames.length)];
  final last1 = surnames[rng.nextInt(surnames.length)];
  final last2 = surnames[rng.nextInt(surnames.length)];
  return '$first $last1 ${last2[0]}.';
}

final referees = [for (var i = 0; i < 14; i++) fictionalName(false)];

// ---------------------------------------------------------------------------
// Modelo interno del generador.
// ---------------------------------------------------------------------------

class Round {
  final int number;
  final List<List<String>> pairs; // [local, visita] de los 8 cruces
  final String bye; // club que descansa (= club en turno)
  final Map<String, String> dayOf = {}; // club local -> 'sab' | 'dom'
  final Map<String, int> slotOf = {}; // club local -> posición en el día
  Round(this.number, this.pairs, this.bye);
}

class GenMatch {
  final String id, serie, home, away, day, time, field;
  final int round;
  String status = 'programado';
  int? homeGoals, awayGoals;
  int result = -1; // 0 gana local, 1 empate, 2 gana visita
  String? referee;
  List<String> homeLineup = [], awayLineup = [];
  List<Map<String, Object>> events = [];

  GenMatch(this.id, this.round, this.serie, this.home, this.away, this.day,
      this.time, this.field);

  bool get played => round <= validatedRounds;
}

final clubById = {for (final c in clubs) c.id: c};
final squads = <String, List<Map<String, Object>>>{}; // 'club|serie' -> jugadores

String addMinutes(String hhmm, int minutes) {
  final parts = hhmm.split(':');
  final total = int.parse(parts[0]) * 60 + int.parse(parts[1]) + minutes;
  final h = (total ~/ 60).toString().padLeft(2, '0');
  final m = (total % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

String isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ---------------------------------------------------------------------------
// Calendario de los 17 clubes (método del círculo, con un "libre").
// ---------------------------------------------------------------------------

List<Round> buildRounds() {
  final order = [for (final c in clubs) c.id]..shuffle(rng);
  final slots = [...order, 'LIBRE']; // 18 posiciones
  final n = slots.length;
  final firstLeg = <Round>[];

  var arr = [...slots];
  for (var r = 0; r < n - 1; r++) {
    final pairs = <List<String>>[];
    String? bye;
    for (var i = 0; i < n ~/ 2; i++) {
      final a = arr[i], b = arr[n - 1 - i];
      if (a == 'LIBRE' || b == 'LIBRE') {
        bye = a == 'LIBRE' ? b : a;
        continue;
      }
      pairs.add((r + i).isEven ? [a, b] : [b, a]);
    }
    firstLeg.add(Round(r + 1, pairs, bye!));
    // Rota todos menos el primero.
    arr = [arr[0], arr[n - 1], ...arr.sublist(1, n - 1)];
  }

  final rounds = [
    ...firstLeg,
    for (final r in firstLeg)
      Round(r.number + firstLeg.length,
          [for (final p in r.pairs) [p[1], p[0]]], r.bye),
  ];

  // Mitad de los cruces el sábado y mitad el domingo; la posición en el día
  // desplaza los horarios para que no coincidan todos.
  for (final round in rounds) {
    final shuffled = [...round.pairs]..shuffle(rng);
    for (var i = 0; i < shuffled.length; i++) {
      final home = shuffled[i][0];
      round.dayOf[home] = i < 4 ? 'sab' : 'dom';
      round.slotOf[home] = i % 4;
    }
  }
  return rounds;
}

const slotShift = [0, 30, -30, 60];

// ---------------------------------------------------------------------------
// Planteles DUMMY.
// ---------------------------------------------------------------------------

void buildSquads() {
  for (final c in clubs) {
    for (final s in series) {
      if (s.id == honorSerie && !honorTeams.contains(c.id)) continue;
      final size = 14 + rng.nextInt(3); // 14 a 16
      final used = <String>{};
      final players = <Map<String, Object>>[];
      for (var n = 1; n <= size; n++) {
        String name;
        do {
          name = fictionalName(s.female);
        } while (!used.add(name));
        players.add({
          'id': '${c.id}-${s.id}-$n',
          'club': c.id,
          'serie': s.id,
          'numero': n,
          'nombre': name,
        });
      }
      squads['${c.id}|${s.id}'] = players;
    }
  }
}

// ---------------------------------------------------------------------------
// Partidos.
// ---------------------------------------------------------------------------

final matches = <GenMatch>[];
var matchCounter = 0;

String nextId() => 'p${(++matchCounter).toString().padLeft(4, '0')}';

void buildMatches(List<Round> rounds) {
  // Series de 17 clubes: se juegan en los cruces del calendario común.
  for (final round in rounds) {
    for (final pair in round.pairs) {
      final home = pair[0], away = pair[1];
      final day = round.dayOf[home]!;
      final shift = slotShift[round.slotOf[home]!];
      for (final s in series) {
        if (s.id == honorSerie) continue;
        matches.add(GenMatch(nextId(), round.number, s.id, home, away, day,
            addMinutes(s.baseTime, shift), clubById[home]!.field));
      }
    }
  }

  // Honor: calendario propio de 10 equipos dentro de las mismas fechas. El
  // club en turno de la fecha también descansa en Honor.
  final meets = <String, int>{};
  final homeCount = {for (final t in honorTeams) t: 0};
  final restCount = {for (final t in honorTeams) t: 0};
  String key(String a, String b) => ([a, b]..sort()).join('|');

  for (final round in rounds) {
    final available = honorTeams.where((t) => t != round.bye).toList();
    if (available.length.isOdd) {
      // Uno más descansa: el que menos haya descansado.
      available.sort((a, b) => restCount[a]!.compareTo(restCount[b]!));
      final rest = available.removeAt(0);
      restCount[rest] = restCount[rest]! + 1;
    }
    if (round.bye != '' && honorTeams.contains(round.bye)) {
      restCount[round.bye] = restCount[round.bye]! + 1;
    }

    // Mejor emparejamiento entre varios al azar: que se repitan poco.
    List<List<String>>? best;
    var bestScore = 1 << 30;
    for (var attempt = 0; attempt < 300; attempt++) {
      final shuffled = [...available]..shuffle(rng);
      final pairs = <List<String>>[];
      var score = 0;
      for (var i = 0; i < shuffled.length; i += 2) {
        final a = shuffled[i], b = shuffled[i + 1];
        final m = meets[key(a, b)] ?? 0;
        score += m * m * 10;
        pairs.add([a, b]);
      }
      if (score < bestScore) {
        bestScore = score;
        best = pairs;
      }
    }

    for (final p in best!) {
      // Es local el que menos veces lo ha sido.
      final home = homeCount[p[0]]! <= homeCount[p[1]]! ? p[0] : p[1];
      final away = home == p[0] ? p[1] : p[0];
      homeCount[home] = homeCount[home]! + 1;
      meets[key(home, away)] = (meets[key(home, away)] ?? 0) + 1;
      // Día y hora: el día del cruce del club local (si jugó de visita en su
      // cruce, el día de ese cruce).
      final crossDay = round.dayOf[home] ??
          round.dayOf[round.pairs.firstWhere((x) => x.contains(home))[0]]!;
      matches.add(GenMatch(nextId(), round.number, honorSerie, home, away,
          crossDay, '19:00', clubById[home]!.field));
    }
  }
}

// ---------------------------------------------------------------------------
// Resultados.
// ---------------------------------------------------------------------------

/// Busca resultados para que cada club sume exactamente sus puntos reales.
/// Primero sin partidos suspendidos; solo si no se puede, permite el mínimo
/// necesario. Si una búsqueda se estanca, vuelve a empezar desde otro punto.
void fitRealPoints(String serie, List<GenMatch> list) {
  for (var allowed = 0; allowed <= maxSuspended; allowed++) {
    for (var attempt = 0; attempt < 4; attempt++) {
      if (tryFit(serie, list, allowed)) return;
    }
  }
  throw StateError('No se pudo cuadrar $serie con los puntos reales.');
}

/// Partidos de las fechas jugadas que pueden quedar suspendidos (sin
/// resultado) si los puntos reales no cuadran de otra forma. Solo se usan
/// si hacen falta (hoy, en Senior).
const int maxSuspended = 3;

/// Resultado 0 = gana local, 1 = empate, 2 = gana visita, 3 = suspendido.
bool tryFit(String serie, List<GenMatch> list, int allowedSuspended) {
  final target = realPoints[serie]!;
  final teams = target.keys.where((t) =>
      list.any((m) => m.home == t || m.away == t)).toList();
  final byTeam = {
    for (final t in teams)
      t: list.where((m) => m.home == t || m.away == t).toList(),
  };
  final pts = {for (final t in teams) t: 0};
  var suspended = 0;

  int ptsFor(GenMatch m, String t, int r) {
    if (r == 3) return 0;
    if (r == 1) return 1;
    return (t == m.home) == (r == 0) ? 3 : 0;
  }

  // Inicio: gana el de más puntos objetivo con más probabilidad.
  for (final m in list) {
    final th = target[m.home]!, ta = target[m.away]!;
    final x = rng.nextDouble();
    m.result = x < 0.2 ? 1 : (rng.nextDouble() < (th + 1) / (th + ta + 2) ? 0 : 2);
    pts[m.home] = pts[m.home]! + ptsFor(m, m.home, m.result);
    pts[m.away] = pts[m.away]! + ptsFor(m, m.away, m.result);
  }

  int errOf(String t) => (pts[t]! - target[t]!).abs();
  var err = teams.fold<int>(0, (a, t) => a + errOf(t));

  const maxIter = 1500000;
  for (var it = 0; it < maxIter && err > 0; it++) {
    // La mayoría de las veces se mueve un partido de un club que no cuadra.
    GenMatch m;
    if (rng.nextDouble() < 0.7) {
      final bad = teams.where((t) => errOf(t) > 0).toList();
      final l = byTeam[bad[rng.nextInt(bad.length)]]!;
      m = l[rng.nextInt(l.length)];
    } else {
      m = list[rng.nextInt(list.length)];
    }

    final options = [0, 1, 2, if (suspended < allowedSuspended || m.result == 3) 3]
      ..remove(m.result);
    final newR = options[rng.nextInt(options.length)];
    final dh = ptsFor(m, m.home, newR) - ptsFor(m, m.home, m.result);
    final da = ptsFor(m, m.away, newR) - ptsFor(m, m.away, m.result);
    final before = errOf(m.home) + errOf(m.away);
    final after = (pts[m.home]! + dh - target[m.home]!).abs() +
        (pts[m.away]! + da - target[m.away]!).abs();
    // Suspender cuesta: se prefiere siempre un resultado.
    final penalty = (newR == 3 ? 2 : 0) - (m.result == 3 ? 2 : 0);
    final delta = after - before + penalty;
    final temp = 1.5 * (1 - it / maxIter) + 0.02;
    if (delta <= 0 || rng.nextDouble() < exp(-delta / temp)) {
      pts[m.home] = pts[m.home]! + dh;
      pts[m.away] = pts[m.away]! + da;
      if (newR == 3) suspended++;
      if (m.result == 3) suspended--;
      m.result = newR;
      err += after - before;
    }
  }

  return err == 0;
}

/// Resultados DUMMY con fuerzas al azar por club, para las demás series.
void randomResults(List<GenMatch> list) {
  final strength = {for (final c in clubs) c.id: rng.nextDouble()};
  for (final m in list) {
    final diff = strength[m.home]! - strength[m.away]! + 0.1;
    final pWin = (0.40 + 0.45 * diff).clamp(0.08, 0.85);
    const pDraw = 0.22;
    final x = rng.nextDouble();
    m.result = x < pWin ? 0 : (x < pWin + pDraw ? 1 : 2);
  }
}

int pick(List<int> values, List<int> weights) {
  final total = weights.fold<int>(0, (a, b) => a + b);
  var x = rng.nextInt(total);
  for (var i = 0; i < values.length; i++) {
    if (x < weights[i]) return values[i];
    x -= weights[i];
  }
  return values.last;
}

/// Marcador, alineaciones, goles y tarjetas coherentes con el resultado.
void fillDetails(GenMatch m) {
  int winner = pick([1, 2, 3, 4, 5], [30, 35, 20, 10, 5]);
  int loser = winner == 1 ? 0 : pick(List.generate(winner, (i) => i),
      List.generate(winner, (i) => winner - i));
  switch (m.result) {
    case 0:
      m.homeGoals = winner;
      m.awayGoals = loser;
    case 2:
      m.homeGoals = loser;
      m.awayGoals = winner;
    default:
      final g = pick([0, 1, 2, 3], [30, 45, 20, 5]);
      m.homeGoals = g;
      m.awayGoals = g;
  }

  List<String> lineup(String club) {
    final squad = [...squads['$club|${m.serie}']!]..shuffle(rng);
    final present = 11 - (rng.nextDouble() < 0.15 ? 1 : 0);
    return [for (final p in squad.take(present)) p['id'] as String]
      ..sort((a, b) => int.parse(a.split('-').last)
          .compareTo(int.parse(b.split('-').last)));
  }

  m.homeLineup = lineup(m.home);
  m.awayLineup = lineup(m.away);
  m.referee = referees[rng.nextInt(referees.length)];

  String scorer(List<String> lineup) {
    final weights = [
      for (final id in lineup)
        switch (int.parse(id.split('-').last)) { 1 => 1, >= 7 => 6, _ => 3 },
    ];
    return lineup[pick(List.generate(lineup.length, (i) => i), weights)];
  }

  final events = <Map<String, Object>>[];
  final usedMinutes = <int>{};
  int minute() {
    int x;
    do {
      x = 1 + rng.nextInt(90);
    } while (!usedMinutes.add(x));
    return x;
  }

  for (var i = 0; i < m.homeGoals!; i++) {
    events.add({'min': minute(), 'tipo': 'gol', 'jugador': scorer(m.homeLineup)});
  }
  for (var i = 0; i < m.awayGoals!; i++) {
    events.add({'min': minute(), 'tipo': 'gol', 'jugador': scorer(m.awayLineup)});
  }
  final yellows = pick([0, 1, 2, 3, 4], [15, 30, 30, 18, 7]);
  final booked = <String>{};
  for (var i = 0; i < yellows; i++) {
    final side = rng.nextBool() ? m.homeLineup : m.awayLineup;
    final p = side[rng.nextInt(side.length)];
    if (!booked.add(p)) continue;
    events.add({'min': minute(), 'tipo': 'amarilla', 'jugador': p});
  }
  if (rng.nextDouble() < 0.12) {
    final side = rng.nextBool() ? m.homeLineup : m.awayLineup;
    final p = side[rng.nextInt(side.length)];
    events.add({'min': minute(), 'tipo': 'roja', 'jugador': p});
  }
  events.sort((a, b) => (a['min'] as int).compareTo(b['min'] as int));
  m.events = events;
}

// ---------------------------------------------------------------------------
// Verificación.
// ---------------------------------------------------------------------------

void verify(List<Round> rounds) {
  // Un club no juega dos veces en la misma fecha y serie; el turno descansa.
  for (final round in rounds) {
    for (final s in series) {
      final seen = <String>{};
      for (final m in matches.where(
          (m) => m.round == round.number && m.serie == s.id)) {
        if (!seen.add(m.home) || !seen.add(m.away)) {
          throw StateError('Club repetido en fecha ${round.number} ${s.id}');
        }
        if (m.home == round.bye || m.away == round.bye) {
          throw StateError('El turno juega en la fecha ${round.number}');
        }
      }
      if (s.id != honorSerie && seen.length != 16) {
        throw StateError('Fecha ${round.number} ${s.id}: no son 8 partidos');
      }
    }
  }

  // La tabla (calculada desde los resultados) cuadra con los puntos reales.
  for (final entry in realPoints.entries) {
    final pts = <String, int>{};
    for (final m in matches.where(
        (m) => m.serie == entry.key && m.status == 'finalizado')) {
      final h = m.homeGoals!, a = m.awayGoals!;
      pts[m.home] = (pts[m.home] ?? 0) + (h > a ? 3 : h == a ? 1 : 0);
      pts[m.away] = (pts[m.away] ?? 0) + (a > h ? 3 : h == a ? 1 : 0);
    }
    for (final t in entry.value.entries) {
      final isHonorAbsent = entry.key == honorSerie && t.value == 0;
      if (isHonorAbsent) {
        if (pts.containsKey(t.key)) throw StateError('${t.key} juega Honor');
        continue;
      }
      if ((pts[t.key] ?? 0) != t.value) {
        throw StateError('${entry.key} ${t.key}: ${pts[t.key]} != ${t.value}');
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Contenido editorial DUMMY.
// ---------------------------------------------------------------------------

final news = [
  {
    'id': 'n1', 'tipo': 'evento', 'tono': 'azul', 'fecha': '2026-11-06',
    'titulo': 'Campeonato Regional de Selecciones',
    'resumen': 'La selección de Chiguayante debuta el domingo en el estadio '
        'municipal. Entrada liberada.',
  },
  {
    'id': 'n2', 'tipo': 'anuncio', 'tono': 'violeta', 'fecha': '2026-11-04',
    'titulo': 'Partido a beneficio',
    'resumen': 'Los clubes de la liga juegan un partido amistoso a beneficio. '
        'El aporte es voluntario.',
  },
  {
    'id': 'n3', 'tipo': 'evento', 'tono': 'oscuro', 'fecha': '2026-11-02',
    'titulo': 'Eliminatorias regionales',
    'resumen': 'La selección juvenil juega las eliminatorias regionales. '
        'Ven a alentar.',
  },
  {
    'id': 'n4', 'tipo': 'noticia', 'tono': 'amarillo', 'fecha': '2026-11-02',
    'titulo': 'Resumen de la fecha 20',
    'resumen': 'Una fecha con muchos goles y cambios en la parte alta de la '
        'tabla en varias series.',
  },
  {
    'id': 'n5', 'tipo': 'anuncio', 'tono': 'oscuro', 'fecha': '2026-10-30',
    'titulo': 'Horario de invierno en canchas',
    'resumen': 'Los partidos de la tarde se adelantan 30 minutos desde la '
        'próxima fecha.',
  },
  {
    'id': 'n6', 'tipo': 'noticia', 'tono': 'azul', 'fecha': '2026-10-26',
    'titulo': 'Taller para turnos y delegados',
    'resumen': 'La directiva capacita a los clubes en el uso de la papeleta '
        'digital.',
  },
];

const documents = [
  ['d1', 'Segunda Infantil', '2019-03-15'],
  ['d2', 'Primera Infantil', '2019-06-23'],
  ['d3', 'Juveniles', '2019-09-12'],
  ['d4', 'Serie Honor', '2019-09-12'],
  ['d5', 'Primera', '2019-09-12'],
  ['d6', 'Segunda', '2019-09-12'],
  ['d7', 'Senior', '2019-09-12'],
  ['d8', 'S. Senior', '2019-09-12'],
  ['d9', 'H. Ortiz', '2019-09-12'],
  ['d10', 'Femenina', '2020-03-02'],
  ['d11', 'Campeonato', '2019-09-12'],
  ['d12', 'Valor del arbitraje', '2019-09-12'],
];

// ---------------------------------------------------------------------------
// Programa principal.
// ---------------------------------------------------------------------------

void main() {
  late List<Round> rounds;
  for (var attempt = 0;; attempt++) {
    attemptSeed = seed + attempt;
    rng = Random(attemptSeed);
    squads.clear();
    matches.clear();
    matchCounter = 0;
    try {
      rounds = buildRounds();
      buildSquads();
      buildMatches(rounds);
      // Fechas jugadas: resultados. Primero las series con puntos reales.
      for (final s in series.where((s) => realPoints.containsKey(s.id))) {
        fitRealPoints(s.id,
            matches.where((m) => m.serie == s.id && m.played).toList());
      }
      break;
    } on StateError catch (e) {
      if (attempt >= 30) rethrow;
      stdout.writeln('Intento $attempt descartado: ${e.message}');
    }
  }

  for (final s in series) {
    final played = matches.where((m) => m.serie == s.id && m.played).toList();
    if (!realPoints.containsKey(s.id)) randomResults(played);
    for (final m in played) {
      if (m.result == 3) {
        m.status = 'suspendido';
        continue;
      }
      m.status = 'finalizado';
      fillDetails(m);
    }
  }

  // Fecha en carga: un cruce suspendido, una papeleta de Primera enviada
  // (por validar) y el resto pendiente de papeleta.
  final current = rounds[currentRound - 1];
  final suspendedHome = current.pairs[5][0];
  final sentHome = current.pairs[0][0];
  for (final m in matches.where((m) => m.round == currentRound)) {
    if (m.home == suspendedHome) {
      m.status = 'suspendido';
    } else if (m.serie == 'primera' && m.home == sentHome) {
      m.status = 'por-validar';
      randomResults([m]);
      fillDetails(m);
    } else {
      m.status = 'pendiente';
    }
  }

  verify(rounds);

  final turnoClub = current.bye;
  final subscriberPlayer = squads['bo|s-senior']![0];
  final freePlayer = squads['ap|femenina']![3];

  final data = <String, Object?>{
    '_nota': 'Datos de MUESTRA de la app Liga SUR, generados por '
        'tool/generate_sample_data.dart (semilla $attemptSeed). Todo es DUMMY salvo '
        'lo indicado en "origen". Reemplazar por los datos oficiales detrás '
        'de la capa de repositorio.',
    'origen': {
      'real': [
        'clubes: nombre, nombreCompleto, iniciales y color (mockup aprobado)',
        'puntosReales: Honor, Primera, Segunda y Senior (planilla ANFA)',
      ],
      'porConfirmar': ['clubes.cancha (planilla anterior)'],
      'dummy': [
        'fechas, partidos, resultados, goles y tarjetas',
        'jugadores (nombres ficticios), alineaciones y asistencia',
        'árbitros, noticias, documentos, usuarios, inscripciones, redes',
      ],
    },
    'meta': {
      'temporada': 2026,
      'fechasTotales': totalRounds,
      'fechasValidadas': validatedRounds,
      'fechaEnCarga': currentRound,
    },
    'series': [
      for (var i = 0; i < series.length; i++)
        {'id': series[i].id, 'nombre': series[i].name, 'orden': i + 1},
    ],
    'clubes': [
      for (final c in clubs)
        {
          'id': c.id,
          'nombre': c.name,
          'nombreCompleto': c.fullName,
          'iniciales': c.initials,
          'color': c.color,
          'cancha': c.field,
          // DUMMY. TODO(decisión): redes sociales opcionales por club.
          'redes': switch (c.id) {
            'bo' || 'cs' || 'mg' || 'ap' => {
                'facebook': '${c.id}.club.ejemplo',
                'instagram': '@${c.id}_club_ejemplo',
              },
            _ => null,
          },
          // DUMMY: estado de la inscripción inicial.
          'inscripcion': (c.id == 'le' || c.id == 'sf') ? 'pendiente' : 'al-dia',
          'series': [
            for (final s in series)
              if (squads.containsKey('${c.id}|${s.id}')) s.id,
          ],
        },
    ],
    'puntosReales': realPoints,
    'fechas': [
      for (final r in rounds)
        {
          'numero': r.number,
          'sabado': isoDate(firstSaturday.add(Duration(days: 7 * (r.number - 1)))),
          'domingo': isoDate(firstSaturday.add(Duration(days: 7 * (r.number - 1) + 1))),
          'libre': r.bye,
          // Club en turno asignado (descansa y registra los resultados).
          'turno': r.number < firstRoundWithoutTurno ? r.bye : null,
        },
    ],
    'jugadores': [for (final list in squads.values) ...list],
    'partidos': [
      for (final m in matches)
        {
          'id': m.id,
          'fecha': m.round,
          'serie': m.serie,
          'local': m.home,
          'visita': m.away,
          'dia': m.day,
          'hora': m.time,
          'cancha': m.field,
          'estado': m.status,
          if (m.homeGoals != null) 'golesLocal': m.homeGoals,
          if (m.awayGoals != null) 'golesVisita': m.awayGoals,
          if (m.referee != null) 'arbitro': m.referee,
          if (m.homeLineup.isNotEmpty) 'alineacionLocal': m.homeLineup,
          if (m.awayLineup.isNotEmpty) 'alineacionVisita': m.awayLineup,
          if (m.events.isNotEmpty) 'eventos': m.events,
        },
    ],
    'noticias': news,
    'documentos': [
      for (final d in documents)
        {'id': d[0], 'titulo': d[1], 'actualizado': d[2]},
    ],
    // Cuentas de PRUEBA para el ingreso simulado (no hay autenticación real).
    'usuarios': [
      {
        'rut': '12.345.678-9', 'clave': 'liga2026', 'nombre': 'Diego',
        'perfil': 'suscriptor', 'jugador': subscriberPlayer['id'],
        'club': 'bo',
      },
      {
        'rut': '11.111.111-1', 'clave': 'liga2026', 'nombre': 'Camila',
        'perfil': 'jugador', 'jugador': freePlayer['id'], 'club': 'ap',
      },
      {
        'rut': '22.222.222-2', 'clave': 'liga2026', 'nombre': 'Delegado',
        'perfil': 'turno', 'club': turnoClub,
      },
      {
        'rut': '9.999.999-9', 'clave': 'liga2026', 'nombre': 'Directiva ANFA',
        'perfil': 'admin',
      },
    ],
  };

  File('assets/data/sample_data.json')
    ..createSync(recursive: true)
    ..writeAsStringSync(encode(data));

  final honorCount = matches.where((m) => m.serie == honorSerie && m.played).length;
  final suspendedPlayed = matches
      .where((m) => m.played && m.status == 'suspendido')
      .map((m) => '${m.serie} f${m.round} ${m.home}-${m.away}')
      .toList();
  stdout.writeln('Suspendidos en fechas jugadas: $suspendedPlayed');
  stdout.writeln('Listo: ${matches.length} partidos, '
      '${squads.values.fold<int>(0, (a, l) => a + l.length)} jugadores, '
      '$honorCount partidos de Honor jugados. Turno fecha $currentRound: '
      '$turnoClub. Verificación OK.');
}

/// JSON legible: un elemento de cada lista por línea (diffs pequeños).
String encode(Map<String, Object?> data) {
  final buf = StringBuffer('{\n');
  final entries = data.entries.toList();
  for (var i = 0; i < entries.length; i++) {
    final e = entries[i];
    buf.write('  ${jsonEncode(e.key)}: ');
    final v = e.value;
    if (v is List) {
      buf.write('[\n');
      for (var j = 0; j < v.length; j++) {
        buf.write('    ${jsonEncode(v[j])}${j < v.length - 1 ? ',' : ''}\n');
      }
      buf.write('  ]');
    } else {
      buf.write(jsonEncode(v));
    }
    buf.write(i < entries.length - 1 ? ',\n' : '\n');
  }
  buf.write('}\n');
  return buf.toString();
}
