import 'package:anfa_chiguayante/main.dart';
import 'package:anfa_chiguayante/services/appearance_service.dart';
import 'package:anfa_chiguayante/services/club_data_service.dart';
import 'package:anfa_chiguayante/services/club_service.dart';
import 'package:anfa_chiguayante/theme/app_theme.dart';
import 'package:anfa_chiguayante/widgets/app_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_asset_bundle.dart';

/// Etapa 1 del mockup (`docs/diseno.md`): apariencia clara/oscura, barra de
/// 5 pestañas, Noticias, Ajustes y escudos provisorios con iniciales.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Ajustes y apariencia'));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes'), findsOneWidget);
  }

  testWidgets('la barra inferior tiene 5 pestañas, con Noticias',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    for (final tab in ['Inicio', 'Fixture', 'Tabla', 'Noticias', 'Clubes']) {
      expect(find.text(tab), findsOneWidget, reason: tab);
    }
  });

  testWidgets('Noticias muestra un estado vacío, sin noticias inventadas',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Noticias'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay noticias publicadas.'), findsOneWidget);

    await tester.tap(find.text('Avisos'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay noticias de tipo "Avisos".'), findsOneWidget);
  });

  testWidgets('por defecto la apariencia es automática y empieza clara',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);

    final context = tester.element(find.byType(Scaffold).first);
    expect(context.colors, AppColors.light);
  });

  testWidgets('elegir Oscuro en Ajustes cambia el tema y se guarda',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      ClubService.favoriteClubIdKey: 'arturo-prat',
    });
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await openSettings(tester);
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Ajustes'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.colors, AppColors.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AppearanceController.prefsKey), 'dark');
  });

  testWidgets('la apariencia guardada se aplica al abrir la app',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      AppearanceController.prefsKey: 'dark',
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cambiar Mi equipo en Ajustes lo guarda y recarga Inicio',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      ClubService.favoriteClubIdKey: 'arturo-prat',
    });
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await openSettings(tester);
    // Muestra el club y la serie que sigue.
    expect(find.text('Arturo Prat'), findsWidgets);
    expect(find.text('General · Cambiar', findRichText: true), findsOneWidget);

    await tester.tap(find.text('General · Cambiar', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('¿Cuál es tu equipo?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'indep');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Independiente'));
    await tester.tap(find.text('Honor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Honor · Cambiar', findRichText: true), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ClubService.favoriteClubIdKey), 'independiente');

    await tester.pageBack();
    await tester.pumpAndSettle();

    // Inicio se recarga con el nuevo equipo y su serie.
    expect(find.text('POSICIÓN · HONOR'), findsOneWidget);
    expect(find.text('Independiente'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  group('Escudos provisorios con iniciales', () {
    Widget withClubs(Widget child) {
      return MaterialApp(
        theme: buildAppTheme(),
        home: DefaultAssetBundle(
          bundle: realDataBundle(),
          child: ClubsLoader(child: Scaffold(body: child)),
        ),
      );
    }

    testWidgets('un club conocido muestra sus iniciales y color',
        (tester) async {
      await tester.pumpWidget(withClubs(const ClubAvatar(clubId: 'arturo-prat')));
      await tester.pumpAndSettle();

      final shield = tester.widget<InitialsShield>(find.byType(InitialsShield));
      expect(shield.initials, 'AP');
      expect(shield.color, const Color(0xFF0F766E));
    });

    testWidgets('sin club conocido se usa el escudo genérico', (tester) async {
      await tester.pumpWidget(withClubs(const ClubCrest(clubId: 'no-existe')));
      await tester.pumpAndSettle();

      expect(find.byType(InitialsShield), findsNothing);
      expect(find.byIcon(Icons.shield_rounded), findsOneWidget);
    });

    test('el texto blanco se lee sobre el color de cada escudo (texto grande)',
        () async {
      final clubs = await ClubDataService.loadClubs(realDataBundle());

      for (final club in clubs) {
        for (final color in [club.color, club.colorDark]) {
          if (color == null) continue;
          final lc = color.computeLuminance();
          final ratio = (1.05) / (lc + 0.05);
          // Iniciales en negrita y grandes: mínimo AA para texto grande.
          expect(ratio, greaterThanOrEqualTo(3.0), reason: club.name);
        }
      }
    });
  });
}
