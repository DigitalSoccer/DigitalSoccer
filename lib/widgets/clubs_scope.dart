import 'package:flutter/material.dart';

import '../models/club.dart';
import '../services/club_data_service.dart';

/// Catálogo de clubes disponible en toda la app (sobre el Navigator), para
/// que los escudos encuentren las iniciales y el color de cada club por id.
/// Mientras carga, o si falla, los escudos usan el escudo genérico.
class ClubsScope extends InheritedWidget {
  final Map<String, Club> byId;

  const ClubsScope({super.key, required this.byId, required super.child});

  static Club? clubOf(BuildContext context, String? id) {
    if (id == null) return null;
    return context
        .dependOnInheritedWidgetOfExactType<ClubsScope>()
        ?.byId[id];
  }

  @override
  bool updateShouldNotify(ClubsScope oldWidget) => byId != oldWidget.byId;
}

/// Carga `clubs.json` una vez y entrega el [ClubsScope].
class ClubsLoader extends StatefulWidget {
  final Widget child;

  const ClubsLoader({super.key, required this.child});

  @override
  State<ClubsLoader> createState() => _ClubsLoaderState();
}

class _ClubsLoaderState extends State<ClubsLoader> {
  Map<String, Club> _byId = const {};
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    ClubDataService.loadClubs(DefaultAssetBundle.of(context)).then(
      (clubs) {
        if (!mounted) return;
        setState(() => _byId = {for (final c in clubs) c.id: c});
      },
      onError: (Object e) {
        debugPrint('Catálogo de clubes no disponible para escudos: $e');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClubsScope(byId: _byId, child: widget.child);
  }
}
