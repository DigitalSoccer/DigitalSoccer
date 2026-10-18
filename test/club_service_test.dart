import 'package:anfa_chiguayante/models/club.dart';
import 'package:anfa_chiguayante/services/club_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final clubs = [
    Club(id: 'arturo-prat', name: 'Arturo Prat', shortName: 'A. Prat', field: ''),
    Club(id: 'el-valle', name: 'El Valle', shortName: 'El Valle', field: ''),
  ];

  test('sin favorito devuelve null', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await ClubService.getFavoriteClubId(clubs), isNull);
  });

  test('guarda y lee el favorito por id', () async {
    SharedPreferences.setMockInitialValues({});

    await ClubService.setFavoriteClubId('arturo-prat');

    expect(await ClubService.getFavoriteClubId(clubs), 'arturo-prat');
  });

  test('migra el favorito antiguo guardado por nombre', () async {
    SharedPreferences.setMockInitialValues({
      ClubService.legacyFavoriteClubKey: 'Arturo Prat',
    });

    expect(await ClubService.getFavoriteClubId(clubs), 'arturo-prat');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ClubService.favoriteClubIdKey), 'arturo-prat');
    expect(prefs.getString(ClubService.legacyFavoriteClubKey), isNull);
  });

  test('un nombre antiguo desconocido no se convierte en favorito', () async {
    SharedPreferences.setMockInitialValues({
      ClubService.legacyFavoriteClubKey: 'Club Inexistente',
    });

    expect(await ClubService.getFavoriteClubId(clubs), isNull);
  });
}
