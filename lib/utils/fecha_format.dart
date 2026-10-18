import '../models/fixture_round.dart';
import '../models/match.dart';

// Formato de fechas en español sin dependencias adicionales.

const _months = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// "10 oct"
String shortDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';

/// "Sábado 10 oct", o solo "Sábado" si la fuente no trae fecha.
String dayLabel(MatchDay day) =>
    day.date == null ? day.day : '${day.day} ${shortDate(day.date!)}';

/// Etiqueta corta para pestañas: "Sábado 10", o "Sábado".
String dayTabLabel(MatchDay day) =>
    day.date == null ? day.day : '${day.day} ${day.date!.day}';

/// "Sáb 10 – Dom 11 oct 2026"; vacío si la fecha no trae días calendario.
String roundDateRange(FixtureRound round) {
  final withDates = round.days.where((d) => d.date != null).toList();

  if (withDates.isEmpty) return '';

  String abbr(MatchDay d) =>
      d.day.length > 3 ? d.day.substring(0, 3) : d.day;

  final first = withDates.first;
  final last = withDates.last;
  final year = last.date!.year;

  if (identical(first, last)) {
    return '${abbr(first)} ${shortDate(first.date!)} $year';
  }

  final sameMonth = first.date!.month == last.date!.month;
  final start = sameMonth
      ? '${abbr(first)} ${first.date!.day}'
      : '${abbr(first)} ${shortDate(first.date!)}';

  return '$start – ${abbr(last)} ${shortDate(last.date!)} $year';
}
