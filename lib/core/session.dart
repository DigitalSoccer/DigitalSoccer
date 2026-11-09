import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/league_data.dart';

/// Sesión del ingreso SIMULADO: no hay autenticación real; las cuentas de
/// prueba vienen de los datos de muestra.
/// TODO(asociación): acceso real con RUT y clave (y acceso del turno).
class Session {
  /// `null` = visitante.
  final UserAccount? account;

  /// Club elegido (el del visitante o el de la cuenta).
  final String? clubId;

  /// "Ver la app como" (modo demostración del mockup); `null` = el perfil
  /// propio de la cuenta.
  final Profile? viewAs;

  const Session({this.account, this.clubId, this.viewAs});

  bool get isVisitor => account == null;

  /// Perfil con el que se arma la app (Más, accesos del turno y admin).
  Profile get profile => viewAs ?? account?.profile ?? Profile.visitor;
}

class SessionController extends ChangeNotifier {
  static const _kind = 'session_kind';
  static const _rut = 'session_rut';
  static const _club = 'session_club';
  static const _view = 'session_view';

  Session? _session;
  bool _loaded = false;

  /// `null` mientras no se ingresa (se muestra la pantalla de ingreso).
  Session? get session => _session;
  bool get loaded => _loaded;

  /// Recupera la sesión guardada en el teléfono.
  Future<void> restore(LeagueData data) async {
    final prefs = await SharedPreferences.getInstance();
    final kind = prefs.getString(_kind);
    final clubId = prefs.getString(_club);
    final view = Profile.values
        .where((p) => p.name == prefs.getString(_view))
        .firstOrNull;

    if (kind == 'visitor') {
      _session = Session(clubId: data.club(clubId)?.id);
    } else if (kind == 'account') {
      final account = data.users
          .where((u) => u.rut == prefs.getString(_rut))
          .firstOrNull;
      if (account != null) {
        _session = Session(
          account: account,
          clubId: data.club(clubId ?? account.clubId)?.id,
          viewAs: view,
        );
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// RUT sin puntos, guion ni espacios, en minúsculas.
  static String normalizeRut(String rut) =>
      rut.replaceAll(RegExp(r'[.\-\s]'), '').toLowerCase();

  /// Ingreso simulado con una cuenta de prueba. Devuelve `false` si el RUT
  /// o la clave no coinciden.
  Future<bool> login(LeagueData data, String rut, String password) async {
    final account = data.users
        .where((u) =>
            normalizeRut(u.rut) == normalizeRut(rut) && u.password == password)
        .firstOrNull;
    if (account == null) return false;

    _session = Session(account: account, clubId: account.clubId);
    await _save();
    notifyListeners();
    return true;
  }

  /// Entra sin cuenta; el visitante puede elegir su club (o ninguno).
  Future<void> enterAsVisitor(String? clubId) async {
    _session = Session(clubId: clubId);
    await _save();
    notifyListeners();
  }

  Future<void> setClub(String? clubId) async {
    final s = _session;
    if (s == null) return;
    _session = Session(account: s.account, clubId: clubId, viewAs: s.viewAs);
    await _save();
    notifyListeners();
  }

  /// "Ver la app como" (solo cuentas): cambia el perfil con que se arma la
  /// app sin cambiar de cuenta.
  Future<void> viewAs(Profile profile) async {
    final s = _session;
    if (s == null || s.isVisitor) return;
    _session = Session(account: s.account, clubId: s.clubId, viewAs: profile);
    await _save();
    notifyListeners();
  }

  Future<void> logout() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_kind, _rut, _club, _view]) {
      await prefs.remove(key);
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final s = _session;
    final prefs = await SharedPreferences.getInstance();
    if (s == null) return;
    await prefs.setString(_kind, s.isVisitor ? 'visitor' : 'account');
    if (s.account != null) {
      await prefs.setString(_rut, s.account!.rut);
    } else {
      await prefs.remove(_rut);
    }
    if (s.clubId != null) {
      await prefs.setString(_club, s.clubId!);
    } else {
      await prefs.remove(_club);
    }
    if (s.viewAs != null) {
      await prefs.setString(_view, s.viewAs!.name);
    } else {
      await prefs.remove(_view);
    }
  }
}

/// Da acceso a la sesión desde cualquier pantalla.
class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    super.key,
    required SessionController controller,
    required super.child,
  }) : super(notifier: controller);

  static SessionController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SessionScope>()!
      .notifier!;
}
