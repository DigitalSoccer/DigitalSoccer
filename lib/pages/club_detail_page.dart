import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../models/match.dart';
import '../models/series.dart';
import '../models/standing.dart';
import '../services/asset_json.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../services/standings_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import 'squad_page.dart';

class ClubDetailPage extends StatefulWidget {
  final Club club;

  const ClubDetailPage({
    super.key,
    required this.club,
  });

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailData {
  final FixtureRound fixture;
  final StandingPosition? position;

  /// Series en que juega el club según todas las fechas cargadas.
  final List<String> categories;

  _ClubDetailData(this.fixture, this.position, this.categories);
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  String? favoriteClubId;
  Future<_ClubDetailData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_ClubDetailData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    final results = await Future.wait([
      DataService.loadRounds(bundle),
      StandingsService.loadStandings(bundle),
      ClubService.getFavoriteClubId([widget.club]),
    ]);

    favoriteClubId = results[2] as String?;

    final rounds = results[0] as List<FixtureRound>;

    if (rounds.isEmpty) {
      throw DataLoadException(DataService.indexPath, 'No hay fechas cargadas');
    }

    return _ClubDetailData(
      rounds.first,
      StandingsService.positionOf(
        results[1] as List<Standing>,
        widget.club.id,
      ),
      sortSeries([
        for (final round in rounds)
          for (final day in round.days)
            for (final field in day.fields)
              for (final match in field.matches)
                if (match.involves(widget.club.id)) match.category,
      ]),
    );
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> setAsMyClub() async {
    await ClubService.setFavoriteClubId(widget.club.id);

    setState(() {
      favoriteClubId = widget.club.id;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.club.name} seleccionado como Mi Club',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.name),
      ),
      body: AsyncBody<_ClubDetailData>(
        future: _future!,
        onRetry: _retry,
        builder: (context, data) {
          final matchDays = data.fixture.days;
          final standing = data.position;

          final clubDays = matchDays.where(
                (day) => day.fields.any(
                  (field) => field.matches.any(
                    (m) => m.involves(widget.club.id),
              ),
            ),
          );

          final textTheme = Theme.of(context).textTheme;
          final isFavorite = favoriteClubId == widget.club.id;
          final isBye = matchDays.any(
                (day) => day.byeClubIds.contains(widget.club.id),
          );

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              ContentWidth(
                child: Card(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        const ClubAvatar(size: 72),

                        const SizedBox(height: AppSpacing.md),

                        Text(
                          widget.club.name,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        if (widget.club.field.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            widget.club.field,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        OutlinedButton.icon(
                          onPressed: setAsMyClub,
                          icon: Icon(
                            isFavorite
                                ? Icons.star
                                : Icons.star_border,
                            color: isFavorite
                                ? AppColors.favorite
                                : null,
                          ),
                          label: const Text(
                            'Establecer como Mi Club',
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        if (standing != null)
                          Row(
                            children: [
                              Expanded(
                                child: StatTile(
                                  label: 'Posición',
                                  value: '${standing.position}',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: StatTile(
                                  label: 'Puntos',
                                  value: '${standing.standing.points}',
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            'Sin información en la tabla de posiciones.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              if (data.categories.isNotEmpty)
                ContentWidth(
                  child: _SquadSection(
                    club: widget.club,
                    categories: data.categories,
                  ),
                ),

              if (clubDays.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    isBye
                        ? 'Libre en la fecha ${data.fixture.round}.'
                        : 'Este club no tiene partidos en la fecha cargada.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),

              ...clubDays.map((day) {
                final matches =
                <({Match match, String field})>[];

                for (final field in day.fields) {
                  for (final match in field.matches) {
                    if (match.involves(widget.club.id)) {
                      matches.add(
                        (match: match, field: field.fieldName),
                      );
                    }
                  }
                }

                return ContentWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        'Fecha ${data.fixture.round} · ${dayLabel(day)}',
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < matches.length; i++)
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: i == 0
                                      ? null
                                      : const Border(
                                    top: BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Text(
                                    matches[i].match.time,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  title: Text(
                                    '${matches[i].match.home} vs ${matches[i].match.away}',
                                    style: textTheme.titleSmall,
                                  ),
                                  subtitle: Text(
                                    '${matches[i].match.category} • ${matches[i].field}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

/// Acceso a los planteles: una opción por serie en que juega el club.
class _SquadSection extends StatelessWidget {
  final Club club;
  final List<String> categories;

  const _SquadSection({
    required this.club,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Planteles por serie'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final category in categories)
                ActionChip(
                  avatar: const Icon(
                    Icons.groups_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text(category),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  backgroundColor: AppColors.primaryContainer,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SquadPage(
                        club: club,
                        categories: categories,
                        initialCategory: category,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
