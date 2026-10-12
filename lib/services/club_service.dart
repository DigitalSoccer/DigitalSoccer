import 'package:shared_preferences/shared_preferences.dart';

import '../models/club.dart';

class ClubService {
  static const String favoriteClubIdKey = 'favorite_club_id';

  /// Clave antigua: guardaba el nombre del club en vez del id.
  static const String legacyFavoriteClubKey = 'favorite_club';

  static Future<void> setFavoriteClubId(String clubId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(favoriteClubIdKey, clubId);
    await prefs.remove(legacyFavoriteClubKey);
  }

  /// Devuelve el id del club favorito.
  ///
  /// Si solo existe el valor antiguo (nombre), lo convierte a id usando
  /// [clubs] y lo guarda en el formato nuevo. Esta es la única comparación
  /// por nombre que queda, y existe solo para esa migración.
  static Future<String?> getFavoriteClubId(List<Club> clubs) async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getString(favoriteClubIdKey);
    if (id != null) return id;

    final legacyName = prefs.getString(legacyFavoriteClubKey);
    if (legacyName == null) return null;

    for (final club in clubs) {
      if (club.name == legacyName) {
        await setFavoriteClubId(club.id);
        return club.id;
      }
    }

    return null;
  }
}
