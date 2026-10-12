import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
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

        final colors = Theme.of(context).colorScheme;

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: colors.primary,
              child: Text(
                'Mi Club: ${club.name}',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child: FixtureView(
                matchDays: data.fixture.days,
                clubId: club.id,
              ),
            ),
          ],
        );
      },
    );
  }
}
