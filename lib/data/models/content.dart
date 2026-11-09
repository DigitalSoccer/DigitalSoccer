enum NewsType { news, announcement, event }

/// Noticia, anuncio o evento (los publica la directiva).
class NewsItem {
  final String id;
  final NewsType type;
  final String title;
  final String summary;
  final DateTime date;

  /// Fondo de la tarjeta: azul, violeta, oscuro o amarillo.
  final String tone;

  const NewsItem({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.date,
    required this.tone,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
        id: json['id'] as String,
        type: switch (json['tipo']) {
          'evento' => NewsType.event,
          'anuncio' => NewsType.announcement,
          _ => NewsType.news,
        },
        title: json['titulo'] as String,
        summary: json['resumen'] as String? ?? '',
        date: DateTime.parse(json['fecha'] as String),
        tone: json['tono'] as String? ?? 'oscuro',
      );
}

/// Documento del reglamento.
class RuleDocument {
  final String id;
  final String title;
  final DateTime updated;

  const RuleDocument({
    required this.id,
    required this.title,
    required this.updated,
  });

  factory RuleDocument.fromJson(Map<String, dynamic> json) => RuleDocument(
        id: json['id'] as String,
        title: json['titulo'] as String,
        updated: DateTime.parse(json['actualizado'] as String),
      );
}

/// Perfiles de la app. El visitante no tiene cuenta.
enum Profile { visitor, player, subscriber, turno, admin }

/// Cuenta de PRUEBA para el ingreso simulado (no hay autenticación real).
/// TODO(asociación): acceso real (RUT y clave) y acceso del turno.
class UserAccount {
  final String rut;
  final String password;
  final String name;
  final Profile profile;
  final String? playerId;
  final String? clubId;

  const UserAccount({
    required this.rut,
    required this.password,
    required this.name,
    required this.profile,
    this.playerId,
    this.clubId,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        rut: json['rut'] as String,
        password: json['clave'] as String,
        name: json['nombre'] as String,
        profile: switch (json['perfil']) {
          'suscriptor' => Profile.subscriber,
          'turno' => Profile.turno,
          'admin' => Profile.admin,
          _ => Profile.player,
        },
        playerId: json['jugador'] as String?,
        clubId: json['club'] as String?,
      );
}
