import 'dart:async';

import 'package:anfa_chiguayante/services/asset_json.dart';
import 'package:anfa_chiguayante/services/standings_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_asset_bundle.dart';

class _HangingBundle extends FakeAssetBundle {
  _HangingBundle() : super({});

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return Completer<String>().future; // nunca responde
  }
}

void main() {
  const path = 'assets/data/standings.json';

  test('archivo ausente -> DataLoadException', () {
    expect(
      StandingsService.loadStandings(FakeAssetBundle({})),
      throwsA(isA<DataLoadException>()),
    );
  });

  test('JSON mal formado -> DataLoadException', () {
    expect(
      StandingsService.loadStandings(FakeAssetBundle({path: '[{'})),
      throwsA(isA<DataLoadException>()),
    );
  });

  test('campo con tipo incorrecto -> DataLoadException', () {
    final bundle = FakeAssetBundle({
      path: '[{"clubId": "a", "team": "A", "points": "muchos"}]',
    });

    expect(
      StandingsService.loadStandings(bundle),
      throwsA(isA<DataLoadException>()),
    );
  });

  test('lectura que no termina -> DataLoadException por tiempo límite', () {
    final AssetBundle bundle = _HangingBundle();

    expect(
      loadJsonAsset(
        path,
        (data) => data,
        bundle: bundle,
        timeout: const Duration(milliseconds: 50),
      ),
      throwsA(
        isA<DataLoadException>()
            .having((e) => e.cause, 'cause', isA<TimeoutException>()),
      ),
    );
  });
}
