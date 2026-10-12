import 'package:flutter/material.dart';

import '../models/fixture_round.dart';
import '../services/data_service.dart';
import '../widgets/async_views.dart';
import '../widgets/fixture_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';

  // Se guarda para no recargar el JSON en cada tecla del buscador.
  Future<FixtureRound>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<FixtureRound> _load() {
    return DataService.loadData(DefaultAssetBundle.of(context));
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<FixtureRound>(
      future: _future!,
      onRetry: _retry,
      builder: (context, fixture) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar club...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            Expanded(
              child: FixtureView(
                matchDays: fixture.days,
                searchQuery: searchQuery,
              ),
            ),
          ],
        );
      },
    );
  }
}
