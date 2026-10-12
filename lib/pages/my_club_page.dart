import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/fixture_view.dart';

class MyClubPage extends StatefulWidget {
  const MyClubPage({super.key});

  @override
  State<MyClubPage> createState() => _MyClubPageState();
}

class _MyClubData {
  final Club? club;
  final FixtureRound fixture;

  _MyClubData(this.club, this.fixture);
}

class _MyClubPageState extends State<MyClubPage> {
  Future<_MyClubData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_MyClubData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    final results = await Future.wait([
      ClubDataService.loadClubs(bundle),
      DataService.loadData(bundle),
    ]);

    final clubs = results[0] as List<Club>;
    final clubId = await ClubService.getFavoriteClubId(clubs);

    return _MyClubData(
      ClubDataService.findById(clubs, clubId),
      results[1] as FixtureRound,
    );
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<_MyClubData>(
      future: _future!,
      onRetry: _retry,
      builder: (context, data) {
        final club = data.club;

        if (club == null) {
          return const EmptyView(
            icon: Icons.star_border,
            message: 'Selecciona un club en la pestaña Clubes',
          );
        }

        final textTheme = Theme.of(context).textTheme;

        return Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primaryContainer,
              child: ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      const ClubAvatar(size: 44),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MI CLUB',
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              club.name,
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              [
                                'Fecha ${data.fixture.round}',
                                roundDateRange(data.fixture),
                              ].where((s) => s.isNotEmpty).join(' · '),
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: FixtureView(
                matchDays: data.fixture.days,
                roundNumber: data.fixture.round,
                clubId: club.id,
              ),
            ),
          ],
        );
      },
    );
  }
}
