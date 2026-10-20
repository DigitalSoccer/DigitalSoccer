import 'package:flutter/material.dart';

import '../models/club.dart';
import '../services/appearance_service.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/club_tile.dart';

/// Ajustes (`docs/diseno.md` 6.8): apariencia de la app y "Mi equipo".
/// Devuelve `true` al cerrar si cambió el club elegido.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsData {
  final List<Club> clubs;
  final Club? club;

  _SettingsData(this.clubs, this.club);
}

class _SettingsPageState extends State<SettingsPage> {
  Future<_SettingsData>? _future;
  bool _teamChanged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_SettingsData> _load() async {
    final clubs =
        await ClubDataService.loadClubs(DefaultAssetBundle.of(context));
    final id = await ClubService.getFavoriteClubId(clubs);
    return _SettingsData(clubs, ClubDataService.findById(clubs, id));
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _changeTeam(_SettingsData data) async {
    final chosen = await showAppBottomSheet<Club>(
      context: context,
      title: 'Elegir mi equipo',
      initialSize: 0.8,
      builder: (context) => [
        for (final club in data.clubs)
          ClubTile(
            club: club,
            trailing: club.id == data.club?.id
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: context.colors.primaryText,
                    ),
                  )
                : null,
            onTap: () => Navigator.pop(context, club),
          ),
      ],
    );

    if (chosen == null || chosen.id == data.club?.id) return;

    await ClubService.setFavoriteClubId(chosen.id);
    _teamChanged = true;
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final appearance = AppearanceScope.maybeOf(context);

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _teamChanged);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Ajustes')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xl,
          ),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionTitle(
                    title: 'Apariencia',
                    subtitle: 'Elige cómo quieres ver la app',
                  ),
                  for (final option in _AppearanceOption.all)
                    _AppearanceTile(
                      option: option,
                      selected:
                          (appearance?.value ?? ThemeMode.system) == option.mode,
                      onTap: () => appearance?.select(option.mode),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'Tu elección se guarda en este teléfono.',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionTitle(title: 'Mi equipo'),
                  AsyncBody<_SettingsData>(
                    future: _future!,
                    onRetry: _reload,
                    builder: (context, data) => _TeamTile(
                      club: data.club,
                      onTap: () => _changeTeam(data),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.display(context, size: 24)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppearanceOption {
  final ThemeMode mode;
  final IconData icon;
  final String title;
  final String description;

  const _AppearanceOption(this.mode, this.icon, this.title, this.description);

  static const all = [
    _AppearanceOption(
      ThemeMode.system,
      Icons.brightness_auto_outlined,
      'Automático',
      'Sigue el modo de tu teléfono',
    ),
    _AppearanceOption(
      ThemeMode.light,
      Icons.light_mode_outlined,
      'Claro',
      'Fondo claro, ideal de día y al sol',
    ),
    _AppearanceOption(
      ThemeMode.dark,
      Icons.dark_mode_outlined,
      'Oscuro',
      'Fondo oscuro, más cómodo de noche',
    ),
  ];
}

class _AppearanceTile extends StatelessWidget {
  final _AppearanceOption option;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '${option.title}. ${option.description}',
      excludeSemantics: true,
      child: SurfaceCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        color: selected ? c.primaryContainer : null,
        borderColor: selected ? c.primaryText : null,
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? c.surface : c.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                color: selected ? c.primaryText : c.textMuted,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                  Text(
                    option.description,
                    style: TextStyle(fontSize: 13, color: c.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? c.primaryText : c.borderStrong,
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  final Club? club;
  final VoidCallback onTap;

  const _TeamTile({required this.club, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final club = this.club;

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ClubAvatar(size: 44, clubId: club?.id),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club?.name ?? 'Sin equipo elegido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                Text(
                  club == null ? 'Elegir' : 'Cambiar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.primaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.outline),
        ],
      ),
    );
  }
}
