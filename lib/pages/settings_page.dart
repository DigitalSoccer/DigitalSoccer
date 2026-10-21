import 'package:flutter/material.dart';

import '../models/club.dart';
import '../services/appearance_service.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/standings_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import 'choose_team_page.dart';

/// Ajustes (`docs/diseno.md` 6.8): apariencia de la app y "Mi equipo".
/// Devuelve `true` al cerrar si cambió el club elegido.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsData {
  final Club? club;

  /// Serie que sigue (etiqueta del chip, p. ej. "Honor").
  final String serie;

  _SettingsData(this.club, this.serie);
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
    final bundle = DefaultAssetBundle.of(context);
    final results = await Future.wait<Object>([
      ClubDataService.loadClubs(bundle),
      StandingsCatalog.load(bundle),
    ]);
    final clubs = results[0] as List<Club>;
    final catalog = results[1] as StandingsCatalog;
    final id = await ClubService.getFavoriteClubId(clubs);

    return _SettingsData(
      ClubDataService.findById(clubs, id),
      catalog.byKey(await StandingsCatalog.getSelectedKey()).label,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _changeTeam() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ChooseTeamPage()),
    );

    if (saved != true || !mounted) return;
    _teamChanged = true;
    _reload();
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
                      serie: data.serie,
                      onTap: _changeTeam,
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
  final String serie;
  final VoidCallback onTap;

  const _TeamTile({
    required this.club,
    required this.serie,
    required this.onTap,
  });

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
                Text.rich(
                  TextSpan(
                    children: [
                      if (club != null)
                        TextSpan(
                          text: '$serie · ',
                          style: TextStyle(color: c.textMuted),
                        ),
                      TextSpan(
                        text: club == null ? 'Elegir' : 'Cambiar',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.primaryText,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 13),
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
