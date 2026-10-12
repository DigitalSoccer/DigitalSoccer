class Club {
  final String name;
  final String shortName;
  final String field;

  Club({
    required this.name,
    required this.shortName,
    required this.field,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      name: json['name'],
      shortName: json['shortName'],
      field: json['field'],
    );
  }
}