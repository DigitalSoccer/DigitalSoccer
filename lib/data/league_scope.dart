import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'league_data.dart';
import 'league_repository.dart';

/// Carga los datos de la liga una vez y los entrega a toda la app con
/// `LeagueScope.of(context)`. Mientras carga muestra [loading].
class LeagueLoader extends StatefulWidget {
  final LeagueRepository repository;
  final Widget child;
  final Widget loading;

  const LeagueLoader({
    super.key,
    required this.repository,
    required this.child,
    required this.loading,
  });

  @override
  State<LeagueLoader> createState() => _LeagueLoaderState();
}

class _LeagueLoaderState extends State<LeagueLoader> {
  late Future<LeagueData> _future = widget.repository.load();

  void _retry() => setState(() {
        _future = widget.repository.load();
      });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LeagueData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _LoadError(onRetry: _retry);
        }
        final data = snapshot.data;
        if (data == null) return widget.loading;
        return LeagueScope(data: data, child: widget.child);
      },
    );
  }
}

class LeagueScope extends InheritedWidget {
  final LeagueData data;

  const LeagueScope({super.key, required this.data, required super.child});

  static LeagueData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LeagueScope>()!.data;

  @override
  bool updateShouldNotify(LeagueScope oldWidget) => data != oldWidget.data;
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 40, color: c.textMuted),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No pudimos cargar los datos de la liga.',
                textAlign: TextAlign.center,
                style: AppText.strong(context, size: 15),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}
