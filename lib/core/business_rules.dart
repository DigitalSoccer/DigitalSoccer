/// Reglas de negocio del requerimiento de la asociación (dato REAL, ver
/// docs del traspaso: "Modelo de solvencia"). No se cambian sin consultar.
abstract final class BusinessRules {
  /// Inscripción inicial por club (contrato).
  static const int clubInscription = 50000;

  /// Suscripción individual por jugador.
  static const int playerSubscription = 1000;
}

/// Monto en pesos chilenos con separador de miles: 50000 -> "$50.000".
String formatClp(int amount) {
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}\$$buf';
}
