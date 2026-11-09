import 'package:anfa_chiguayante/core/config.dart';
import 'package:anfa_chiguayante/shared/sample_data_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('la app carga los datos de muestra y muestra la etiqueta',
      (tester) async {
    phone(tester);
    await pumpApp(tester);

    expect(find.text('Ingresa a tu cuenta'), findsOneWidget);
    expect(kUsingSampleData, isTrue);
    expect(find.text('Datos de ejemplo'), findsOneWidget);
  });

  testWidgets('la etiqueta se apaga con la bandera', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SampleDataBadge(enabled: false, child: Text('contenido')),
    ));
    expect(find.text('Datos de ejemplo'), findsNothing);
  });
}
