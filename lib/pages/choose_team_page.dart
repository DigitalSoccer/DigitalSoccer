import 'package:flutter/material.dart';

import '../models/club.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/standings_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/search_field.dart';
import '../widgets/serie_chips.dart';

/// Elegir equipo (`docs/diseno.md` 6.1): club con buscador y serie. La
/// serie elegida es el enfoque de la app: con ella abren Inicio, Fixture
/// y Tabla.
///
/// Se usa dentro de Inicio la primera vez ([embedded]) y como pantalla
/// propia al cambiar de equipo; en ese caso devuelve `true` al guardar.
class ChooseTeamPage extends StatefulWidget {
  /// Dentro de Inicio (sin barra superior ni botón de volver).
  final bool embedded;

  /// Se llama al guardar la elección (además de cerrar la pantalla si no
  /// está incrustada).
  final VoidCallback? onSaved;

  /// "Solo quiero mirar": entra a la app sin elegir equipo.
  final VoidCallback? onJustLook;

  const ChooseTeamPage({
    super.key,
    this.embedded = false,
    this.onSaved,
    this.onJustLook,
  });

  @override
  State<ChooseTeamPage> createState() => _ChooseTeamPageState();
}

class _ChooseData {
  final List<Club> clubs;
  final StandingsCatalog catalog;

  _ChooseData(this.clubs, this.catalog);
}

class _ChooseTeamPageState extends State<ChooseTeamPage> {
  Future<_ChooseData>? _future;
  String _query = '';
  String? _clubId;
  String? _tableKey;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_ChooseData> _load() async {
    final bundle = DefaultAssetBundle.of(context);
    final results = await Future.wait<Object>([
      ClubDataService.loadClubs(bundle),
      StandingsCatalog.load(bundle),
    ]);

    final clubs = results[0] as List<Club>;
    final catalog = results[1] as StandingsCatalog;

    // Parte con la elección actual, si hay.
    _clubId = await ClubService.getFavoriteClubId(clubs);
    _tableKey = catalog.byKey(await StandingsCatalog.getSelectedKey()).key;

    return _ChooseData(clubs, catalog);
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _save() async {
    final clubId = _clubId;
    final tableKey = _tableKey;
    if (clubId == null || tableKey == null) return;

    setState(() => _saving = true);
    await ClubService.setFavoriteClubId(clubId);
    await StandingsCatalog.setSelectedKey(tableKey);
    if (!mounted) return;
    setState(() => _saving = false);

    widget.onSaved?.call();
    if (!widget.embedded) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      bottom: false,
      top: widget.embedded,
      child: AsyncBody<_ChooseData>(
        future: _future!,
        onRetry: _retry,
        builder: (context, data) => _buildContent(context, data),
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 48),
      body: body,
    );
  }

  Widget _buildContent(BuildContext context, _ChooseData data) {
    final c = context.colors;
    final query = _query.trim().toLowerCase();
    final clubs = [
      for (final club in data.clubs)
        if (query.isEmpty ||
            club.name.toLowerCase().contains(query) ||
            club.shortName.toLowerCase().contains(query))
          club,
    ];
    final option = data.catalog.byKey(_tableKey);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              ContentWidth(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    widget.embedded ? AppSpacing.xl : AppSpacing.xs,
                    AppSpacing.screen,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ANFA CAUPOLICÁN · CHIGUAYANTE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: c.primaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Semantics(
                        header: true,
                        child: Text(
                          '¿Cuál es tu equipo?',
                          style: AppText.display(context, size: 44),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Elige tu club y la serie que quieres seguir. Puedes '
                        'cambiarlo cuando quieras.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    18,
                    AppSpacing.screen,
                    0,
                  ),
                  child: SearchField(
                    height: 48,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
              ),
              ContentWidth(
                child: SurfaceCard(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.md,
                    AppSpacing.screen,
                    0,
                  ),
                  radius: 14,
                  shadow: const [],
                  child: SizedBox(
                    height: 280,
                    child: clubs.isEmpty
                        ? Center(
                            child: Text(
                              'Ningún club coincide con "${_query.trim()}".',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: c.textMuted),
                            ),
                          )
                        : ListView(
                            children: [
                              for (final club in clubs)
                                _ClubOption(
                                  club: club,
                                  selected: club.id == _clubId,
                                  onTap: () =>
                                      setState(() => _clubId = club.id),
                                ),
                            ],
                          ),
                  ),
                ),
              ),
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    18,
                    AppSpacing.screen,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SERIE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      PillChips(
                        wrap: true,
                        options: [
                          for (final o in data.catalog.options) o.label,
                        ],
                        selected: option.label,
                        onSelected: (label) => setState(
                          () => _tableKey = data.catalog.options
                              .firstWhere((o) => o.label == label)
                              .key,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.screen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _clubId == null || _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      textStyle: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(_clubId == null ? 'Elige un club' : 'Continuar'),
                  ),
                ),
                if (widget.onJustLook != null)
                  TextButton(
                    onPressed: widget.onJustLook,
                    style: TextButton.styleFrom(
                      foregroundColor: c.primaryText,
                      minimumSize: const Size(44, 44),
                      textStyle: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    child: const Text('Solo quiero mirar'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ClubOption extends StatelessWidget {
  final Club club;
  final bool selected;
  final VoidCallback onTap;

  const _ClubOption({
    required this.club,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.primarySoft : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.surfaceMuted)),
            ),
            child: Row(
              children: [
                ClubAvatar(size: 36, clubId: club.id),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    club.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: c.text,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: c.primaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
