class MatchOverride {
  final String matchId;
  final String? newTime;
  final String? newField;
  final String? status; // suspendido, reprogramado

  MatchOverride({
    required this.matchId,
    this.newTime,
    this.newField,
    this.status,
  });
}