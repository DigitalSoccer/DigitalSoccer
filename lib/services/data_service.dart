import 'package:flutter/services.dart';

import '../models/fixture_round.dart';
import 'asset_json.dart';

class DataService {
  static Future<FixtureRound> loadData([AssetBundle? bundle]) {
    return loadJsonAsset(
      'assets/data/fixture.json',
      (data) => FixtureRound.fromJson(data as Map<String, dynamic>),
      bundle: bundle,
    );
  }
}
