import '../models/match.dart';

class OverrideService {
  static Match apply(Match match) {
    // ejemplo simple
    if (match.home == 'Bdo. O’Higgins' &&
        match.away == 'Arturo Prat' &&
        match.time == '12:00') {
      return match.copyWith(status: 'suspendido');
    }

    return match;
  }
}