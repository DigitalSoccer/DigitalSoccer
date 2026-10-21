import 'package:flutter/material.dart';

import '../models/club.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/search_field.dart';
import 'club_detail_page.dart';

/// Pestaña Clubes (`docs/diseno.md` 6.6): título con conteo, buscador y la
/// lista en una sola tarjeta. Mi equipo va resaltado; tocar un club abre
/// su ficha.
class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  String? _favoriteClubId;
  String _query = '';
  Future<List<Club>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<Club>> _load() async {
    final clubs = await ClubDataService.loadClubs(
      DefaultAssetBundle.of(context),
    );

    _favoriteClubId = await ClubService.getFavoriteClubId(clubs);

    return clubs;
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _open(Club club, List<Club> clubs) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClubDetailPage(club: club)),
    );

    // En la ficha se puede marcar otro club como mi equipo.
    final id = await ClubService.getFavoriteClubId(clubs);
    if (!mounted) return;
    setState(() {
      _favoriteClubId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SafeArea(
      bottom: false,
      child: AsyncBody<List<Club>>(
        future: _future!,
        onRetry: _retry,
        builder: (context, clubs) {
          final query = _query.trim().toLowerCase();
          final visible = [
            for (final club in clubs)
              if (query.isEmpty ||
                  club.name.toLowerCase().contains(query) ||
                  club.shortName.toLowerCase().contains(query))
                club,
          ];

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.lg,
                    AppSpacing.screen,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Clubes',
                          style: AppText.display(context, size: 36),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${clubs.length} clubes · ANFA Caupolicán',
                        style: TextStyle(fontSize: 14, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  child: SearchField(
                    height: 48,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
              ),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: EmptyView(
                    icon: Icons.shield_outlined,
                    message: clubs.isEmpty
                        ? 'No hay clubes registrados.'
                        : 'Ningún club coincide con "${_query.trim()}".',
                  ),
                )
              else
                ContentWidth(
                  child: SurfaceCard(
                    margin: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      14,
                      AppSpacing.screen,
                      0,
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < visible.length; i++)
                          _ClubRow(
                            club: visible[i],
                            isMine: visible[i].id == _favoriteClubId,
                            last: i == visible.length - 1,
                            onTap: () => _open(visible[i], clubs),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ClubRow extends StatelessWidget {
  final Club club;
  final bool isMine;
  final bool last;
  final VoidCallback onTap;

  const _ClubRow({
    required this.club,
    required this.isMine,
    required this.last,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Material(
      color: isMine ? c.ownTeam : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: last
                ? null
                : Border(bottom: BorderSide(color: c.surfaceMuted)),
          ),
          child: Row(
            children: [
              ClubAvatar(size: 44, clubId: club.id),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMine
                          ? 'Tu equipo · Plantel y partidos'
                          : 'Plantel y partidos',
                      style: TextStyle(fontSize: 13, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.outline),
            ],
          ),
        ),
      ),
    );
  }
}
