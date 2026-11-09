import 'package:flutter/material.dart';

import 'core/appearance.dart';
import 'core/theme.dart';
import 'data/league_repository.dart';
import 'data/league_scope.dart';
import 'features/base_preview_page.dart';
import 'shared/sample_data_badge.dart';
import 'shared/skeleton.dart';

void main() {
  runApp(LigaSurApp(repository: SampleLeagueRepository()));
}

class LigaSurApp extends StatefulWidget {
  final LeagueRepository repository;

  const LigaSurApp({super.key, required this.repository});

  @override
  State<LigaSurApp> createState() => _LigaSurAppState();
}

class _LigaSurAppState extends State<LigaSurApp> {
  // Por defecto, automático (sigue el modo del teléfono).
  final _appearance = AppearanceController();

  @override
  void initState() {
    super.initState();
    _appearance.load();
  }

  @override
  void dispose() {
    _appearance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _appearance,
      builder: (context, mode, _) => MaterialApp(
        title: 'Liga SUR',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: mode,
        builder: (context, child) => AppearanceScope(
          controller: _appearance,
          child: SampleDataBadge(child: child ?? const SizedBox.shrink()),
        ),
        home: LeagueLoader(
          repository: widget.repository,
          loading: const Scaffold(
            body: SafeArea(child: SkeletonList(rows: 8)),
          ),
          child: const BasePreviewPage(),
        ),
      ),
    );
  }
}
