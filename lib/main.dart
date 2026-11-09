import 'package:flutter/material.dart';

import 'core/appearance.dart';
import 'core/session.dart';
import 'core/theme.dart';
import 'data/league_repository.dart';
import 'data/league_scope.dart';
import 'features/ingreso/ingreso_page.dart';
import 'features/shell/main_shell.dart';
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
  final _session = SessionController();

  @override
  void initState() {
    super.initState();
    _appearance.load();
  }

  @override
  void dispose() {
    _appearance.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const loading = Scaffold(body: SafeArea(child: SkeletonList(rows: 8)));

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
          child: SessionScope(
            controller: _session,
            child: SampleDataBadge(child: child ?? const SizedBox.shrink()),
          ),
        ),
        home: LeagueLoader(
          repository: widget.repository,
          loading: loading,
          child: _SessionGate(controller: _session, loading: loading),
        ),
      ),
    );
  }
}

/// Muestra el ingreso o la app según la sesión guardada.
class _SessionGate extends StatefulWidget {
  final SessionController controller;
  final Widget loading;

  const _SessionGate({required this.controller, required this.loading});

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  bool _restoring = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_restoring && !widget.controller.loaded) {
      _restoring = true;
      widget.controller.restore(LeagueScope.of(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (!widget.controller.loaded) return widget.loading;
        return widget.controller.session == null
            ? const IngresoPage()
            : const MainShell();
      },
    );
  }
}
