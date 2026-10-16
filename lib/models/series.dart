/// Orden de las series de menor a mayor, como las programa la asociación.
const List<String> seriesOrder = [
  '2° Infantil',
  '1° Infantil',
  'Juveniles',
  'H. Ortiz',
  'S. Senior',
  'Segunda',
  'Primera',
  'Senior',
  'Honor',
];

/// Ordena series según [seriesOrder]; las desconocidas van al final en el
/// orden en que aparecen.
List<String> sortSeries(Iterable<String> series) {
  final unique = series.toSet();

  return [
    ...seriesOrder.where(unique.contains),
    ...unique.where((s) => !seriesOrder.contains(s)),
  ];
}
