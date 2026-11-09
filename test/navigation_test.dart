import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

/// Etapa 2: ingreso simulado, visitante con club, barra de 5 pestañas y
/// "Más" según el perfil.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> login(WidgetTester tester, String profile) async {
    final account = testAccount(profile);
    await tester.enterText(find.byType(TextField).at(0), account['rut'] as String);
    await tester.enterText(
        find.byType(TextField).at(1), account['clave'] as String);
    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
  }

  Future<void> openMas(WidgetTester tester) async {
    await tester.tap(find.text('Más').last);
    await tester.pumpAndSettle();
  }

  testWidgets('sin sesión abre el ingreso', (tester) async {
    phone(tester);
    await pumpApp(tester);

    expect(find.text('Ingresa a tu cuenta'), findsOneWidget);
    expect(find.text('Entrar como visitante →'), findsOneWidget);
  });

  testWidgets('RUT o clave incorrectos lo avisa', (tester) async {
    phone(tester);
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).at(0), '1-9');
    await tester.enterText(find.byType(TextField).at(1), 'mala');
    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('RUT o clave incorrectos.'), findsOneWidget);
  });

  testWidgets('el suscriptor entra y ve la barra de 5 pestañas', (tester) async {
    phone(tester);
    await pumpApp(tester);
    await login(tester, 'suscriptor');

    for (final tab in ['Inicio', 'Partidos', 'Tabla', 'Equipos', 'Más']) {
      expect(find.text(tab), findsWidgets, reason: tab);
    }

    await openMas(tester);
    expect(find.text('Diego'), findsOneWidget);
    expect(find.text('VER LA APP COMO'), findsOneWidget);
    expect(find.text('Mi perfil de jugador'), findsOneWidget);
    expect(find.text('Plan de jugador'), findsOneWidget);
    expect(find.text('Noticias y anuncios'), findsOneWidget);
    expect(find.text('Reglamento'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('"Ver la app como" cambia lo que muestra Más', (tester) async {
    phone(tester);
    await pumpApp(tester);
    await login(tester, 'suscriptor');
    await openMas(tester);

    await tester.tap(find.text('Turno'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil Turno'), findsOneWidget);
    expect(find.text('Panel del turno'), findsOneWidget);
    expect(find.text('Papeletas de la fecha 21'), findsOneWidget);
    expect(find.text('Suscripción'), findsNothing);

    await tester.tap(find.text('Administrador').first);
    await tester.pumpAndSettle();
    expect(find.text('Panel de administración'), findsOneWidget);
    expect(find.text('Panel del turno'), findsOneWidget);
  });

  testWidgets('cada cuenta abre con su perfil', (tester) async {
    phone(tester);
    await pumpApp(tester);
    await login(tester, 'admin');
    await openMas(tester);
    expect(find.text('Panel de administración'), findsOneWidget);
    expect(find.text('Mi perfil de jugador'), findsNothing);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa a tu cuenta'), findsOneWidget);

    await login(tester, 'jugador');
    await openMas(tester);
    // Jugador sin suscripción: se le ofrece suscribirse.
    expect(find.text('Jugador'), findsOneWidget);
    expect(find.text(r'Hazte suscriptor por $1.000'), findsOneWidget);
  });

  testWidgets('el visitante elige su club al entrar', (tester) async {
    phone(tester);
    await pumpApp(tester);

    await tester.ensureVisible(find.text('Entrar como visitante →'));
    await tester.tap(find.text('Entrar como visitante →'));
    await tester.pumpAndSettle();
    expect(find.text('Elige tu club'), findsOneWidget);

    await tester.ensureVisible(find.text('Jackson'));
    await tester.tap(find.text('Jackson'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Entrar como visitante'));
    await tester.tap(find.text('Entrar como visitante'));
    await tester.pumpAndSettle();

    await openMas(tester);
    expect(find.text('Visitante'), findsWidgets);
    expect(find.text('Tu club: Jackson'), findsOneWidget);
    expect(find.text('VER LA APP COMO'), findsNothing);
    expect(find.text('Iniciar sesión'), findsOneWidget);

    // Puede cambiar de club desde Más.
    await tester.tap(find.text('Jackson · Cambiar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nacional').last);
    await tester.pumpAndSettle();
    expect(find.text('Tu club: Nacional'), findsOneWidget);
  });

  testWidgets('el visitante puede entrar sin club', (tester) async {
    phone(tester);
    await pumpApp(tester);

    await tester.ensureVisible(find.text('Entrar como visitante →'));
    await tester.tap(find.text('Entrar como visitante →'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ahora no, entrar sin club'));
    await tester.tap(find.text('Ahora no, entrar sin club'));
    await tester.pumpAndSettle();

    await openMas(tester);
    expect(find.text('Sin club elegido'), findsOneWidget);
    expect(find.text('Elige tu club'), findsOneWidget);
  });

  testWidgets('la sesión queda guardada en el teléfono', (tester) async {
    SharedPreferences.setMockInitialValues({
      'session_kind': 'visitor',
      'session_club': 'mg',
    });
    phone(tester);
    await pumpApp(tester);

    expect(find.text('Ingresa a tu cuenta'), findsNothing);
    await openMas(tester);
    expect(find.text('Tu club: Magallanes'), findsOneWidget);
  });

  for (final size in const [Size(320, 640), Size(1280, 800)]) {
    testWidgets('sin desbordes a ${size.width.toInt()} px', (tester) async {
      phone(tester, size);
      await pumpApp(tester);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Entrar como visitante →'));
    await tester.tap(find.text('Entrar como visitante →'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Jackson'));
    await tester.tap(find.text('Jackson'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Entrar como visitante'));
      await tester.tap(find.text('Entrar como visitante'));
      await tester.pumpAndSettle();
      await openMas(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
