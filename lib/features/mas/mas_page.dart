import 'package:flutter/material.dart';

import '../../core/business_rules.dart';
import '../../core/session.dart';
import '../../core/theme.dart';
import '../../data/league_data.dart';
import '../../data/league_scope.dart';
import '../../shared/club_picker.dart';
import '../../shared/coming_soon.dart';
import '../../shared/segmented.dart';
import '../../shared/striped_header.dart';

/// Pestaña Más (mockup "Más"). Cambio pedido: la pantalla varía según el
/// perfil (visitante, jugador, suscriptor, turno, administrador). "Ver la
/// app como" es el modo demostración del mockup (solo con cuenta).
class MasPage extends StatelessWidget {
  const MasPage({super.key});

  static String profileLabel(Profile p) => switch (p) {
        Profile.visitor => 'Visitante',
        Profile.player => 'Jugador',
        Profile.subscriber => 'Suscriptor',
        Profile.turno => 'Perfil Turno',
        Profile.admin => 'Administrador',
      };

  @override
  Widget build(BuildContext context) {
    final controller = SessionScope.of(context);
    final session = controller.session!;
    final data = LeagueScope.of(context);
    final c = context.colors;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(session: session, data: data),
        if (!session.isVisitor)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VER LA APP COMO', style: AppText.eyebrow(context)),
                const SizedBox(height: 8),
                SegmentedChoice<Profile>(
                  options: const [
                    (Profile.subscriber, 'Suscriptor'),
                    (Profile.turno, 'Turno'),
                    (Profile.admin, 'Administrador'),
                  ],
                  selected: session.profile,
                  onSelected: controller.viewAs,
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _Menu(items: _items(context, session, data)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: controller.logout,
                child: Text(
                    session.isVisitor ? 'Iniciar sesión' : 'Cerrar sesión'),
              ),
              const SizedBox(height: 14),
              Text(
                'Liga SUR · Asociación de Fútbol Caupolicán – Chiguayante',
                textAlign: TextAlign.center,
                style: AppText.muted(context, size: 11, color: c.textMuted)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_MenuItem> _items(BuildContext context, Session session, LeagueData data) {
    void open(String title, int stage) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ComingSoon(title: title, stage: stage, pushed: true),
          ),
        );

    final news = _MenuItem(
      Icons.newspaper_outlined,
      'Noticias y anuncios',
      'Avisos y eventos de la liga',
      () => open('Noticias y anuncios', 3),
    );
    final rules = _MenuItem(
      Icons.menu_book_outlined,
      'Reglamento',
      'Normas por serie y del campeonato',
      () => open('Reglamento', 3),
    );
    final hasPlayer = session.account?.playerId != null;
    final me = _MenuItem(
      Icons.person_outline_rounded,
      'Mi perfil de jugador',
      session.profile == Profile.player
          ? 'Tus partidos y tu asistencia'
          : 'Estadísticas, asistencia y beneficios',
      () => open('Mi perfil de jugador', 3),
    );
    final subscription = _MenuItem(
      Icons.star_outline_rounded,
      'Suscripción',
      session.profile == Profile.player
          ? 'Hazte suscriptor por ${formatClp(BusinessRules.playerSubscription)}'
          : 'Plan de jugador',
      () => open('Suscripción', 3),
    );
    final turno = _MenuItem(
      Icons.assignment_outlined,
      'Panel del turno',
      'Papeletas de la fecha ${data.currentRound}',
      () => open('Papeletas de la fecha', 4),
    );
    final admin = _MenuItem(
      Icons.verified_user_outlined,
      'Panel de administración',
      'Supervisión, usuarios y clubes',
      () => open('Panel de la liga', 5),
    );
    final club = data.club(session.clubId);
    final myClub = _MenuItem(
      Icons.shield_outlined,
      'Mi club',
      club == null ? 'Elige tu club' : '${club.name} · Cambiar',
      () => _pickClub(context, session.clubId),
    );

    return switch (session.profile) {
      Profile.admin => [admin, turno, news, rules],
      Profile.turno => [turno, if (hasPlayer) me, news, rules],
      Profile.subscriber || Profile.player => [
          if (hasPlayer) me,
          subscription,
          news,
          rules,
        ],
      Profile.visitor => [myClub, news, rules],
    };
  }

  Future<void> _pickClub(BuildContext context, String? current) async {
    final data = LeagueScope.of(context);
    final controller = SessionScope.of(context);
    final clubs = [...data.clubs]..sort((a, b) => a.name.compareTo(b.name));

    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Elige tu club', style: AppText.section(context)),
              const SizedBox(height: 12),
              ClubPicker(
                clubs: clubs,
                selectedId: current,
                onSelected: (id) => Navigator.pop(context, id),
              ),
            ],
          ),
        ),
      ),
    );
    if (chosen != null) await controller.setClub(chosen);
  }
}

class _Header extends StatelessWidget {
  final Session session;
  final LeagueData data;

  const _Header({required this.session, required this.data});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final account = session.account;
    final club = data.club(session.clubId);
    final name = account?.name ?? 'Visitante';
    final subtitle = account != null
        ? 'RUT ${account.rut}'
        : club == null
            ? 'Sin club elegido'
            : 'Tu club: ${club.name}';

    return StripedHeader(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.paddingOf(context).top + 20, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Más', style: AppText.title(context, color: c.onHeader)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: c.brand, shape: BoxShape.circle),
                child: account == null
                    ? Icon(Icons.person_outline_rounded,
                        size: 30, color: c.onBrand)
                    : Text(
                        name.characters.first.toUpperCase(),
                        style: AppText.number(context,
                            size: 22, color: c.onBrand),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppText.section(context, color: c.onHeader)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppText.muted(context, color: c.onHeaderMuted)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: c.brand,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        MasPage.profileLabel(session.profile),
                        style: AppText.strong(context,
                                size: 11, color: c.onBrand)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem(this.icon, this.title, this.subtitle, this.onTap);
}

class _Menu extends StatelessWidget {
  final List<_MenuItem> items;

  const _Menu({required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) Divider(height: 1, color: c.divider),
              InkWell(
                onTap: items[i].onTap,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 68),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: c.brandSoft, shape: BoxShape.circle),
                          child: Icon(items[i].icon, size: 20, color: c.text),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(items[i].title,
                                  style: AppText.strong(context, size: 15)),
                              const SizedBox(height: 2),
                              Text(
                                items[i].subtitle,
                                style: AppText.muted(context)
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: c.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
