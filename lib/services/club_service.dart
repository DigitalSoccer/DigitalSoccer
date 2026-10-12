import 'package:shared_preferences/shared_preferences.dart';

class ClubService {
  static const String favoriteClubKey = 'favorite_club';

  static Future<void> setFavoriteClub(String club) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(favoriteClubKey, club);
  }

  static Future<String?> getFavoriteClub() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(favoriteClubKey);
  }
}