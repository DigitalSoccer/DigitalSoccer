import 'package:flutter/material.dart';

/// Design tokens de la app: rojo deportivo sobre superficies blancas y un
/// fondo slate neutro (equivalentes a la escala de Tailwind).
///
/// Es la DIRECCIÓN VISUAL acordada por el equipo, no los colores oficiales
/// del Club Arturo Prat ni de ANFA Chiguayante (pendientes de confirmación).
/// Las pantallas no deben usar colores directos: deben tomarlos de aquí o de
/// `Theme.of(context).colorScheme`.
class AppColors {
  AppColors._();

  // Marca. El rojo se usa de forma puntual: navegación activa, acciones,
  // Mi Club y la etiqueta de la fecha. No se usa como fondo de pantallas.

  /// Rojo profundo (red-700): elementos interactivos y texto destacado.
  /// Contraste 6.5:1 con blanco.
  static const Color primary = Color(0xFFB91C1C);
  static const Color onPrimary = Colors.white;

  /// Rojo oscuro (red-800): panel "MI CLUB" sobre el encabezado rojo.
  /// Contraste 8.4:1 con blanco.
  static const Color primaryDeep = Color(0xFF991B1B);

  /// Rojo vivo (red-600): solo acentos sin texto (franjas, bordes).
  static const Color primaryBright = Color(0xFFDC2626);

  /// Rojo muy suave (red-100): insignias y fondos de íconos.
  static const Color primaryContainer = Color(0xFFFEE2E2);
  static const Color onPrimaryContainer = Color(0xFF7F1D1D);

  /// Rojo casi blanco (red-50): fila o tarjeta de Mi Club.
  static const Color primarySoft = Color(0xFFFEF2F2);

  /// Píldora translúcida del ítem activo de la barra inferior (12 %).
  static const Color navIndicator = Color(0x1FB91C1C);

  // Superficies.

  /// Fondo global (slate-50): da contraste a las tarjetas blancas.
  static const Color background = Color(0xFFF8FAFC);

  /// Tarjetas, hojas inferiores y barras (blanco puro).
  static const Color surface = Colors.white;

  /// Pistas de pestañas, avatares y chips (slate-100).
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  /// Borde suave de tarjetas y separadores de filas (slate-100).
  static const Color border = Color(0xFFF1F5F9);

  /// Borde de campos de texto y divisores visibles (slate-200).
  static const Color borderStrong = Color(0xFFE2E8F0);

  // Texto.

  /// Títulos y texto principal (slate-900).
  static const Color text = Color(0xFF0F172A);

  /// Subtítulos y texto sobre `surfaceMuted` (slate-600).
  static const Color textSecondary = Color(0xFF475569);

  /// Etiquetas y metadatos (slate-500). Solo sobre blanco o `background`:
  /// sobre `surfaceMuted` no alcanza 4.5:1.
  static const Color textMuted = Color(0xFF64748B);

  /// Íconos decorativos y controles deshabilitados (slate-400).
  static const Color outline = Color(0xFF94A3B8);

  /// Manilla de las hojas inferiores (slate-300).
  static const Color handle = Color(0xFFCBD5E1);

  // Semánticos.
  static const Color error = Color(0xFFB4443C);
  static const Color favorite = Color(0xFFF59E0B);
  static const Color statusNormal = handle;
  static const Color statusSuspended = error;
  static const Color statusRescheduled = Color(0xFFB45309);

  // Podio de la tabla: píldoras oro, plata y bronce (fondo / texto).
  static const Color goldBg = Color(0xFFFEF3C7);
  static const Color goldFg = Color(0xFF92400E);
  static const Color silverBg = Color(0xFFE2E8F0);
  static const Color silverFg = Color(0xFF334155);
  static const Color bronzeBg = Color(0xFFFFEDD5);
  static const Color bronzeFg = Color(0xFF9A3412);

  // Tarjetas disciplinarias (íconos de la tabla de jugadores).
  static const Color cardYellow = Color(0xFFF2C200);
  static const Color cardRed = Color(0xFFD32F2F);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;

  /// `rounded-xl`: campos, botones y selectores.
  static const double md = 12;

  /// `rounded-2xl`: tarjetas.
  static const double lg = 16;

  /// Esquinas superiores de las hojas inferiores.
  static const double xl = 24;

  static const double pill = 999;
}

/// Sombras difusas equivalentes a `shadow-sm` y `shadow-md` de Tailwind,
/// teñidas con slate-900 en vez de negro puro.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D0F172A), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x140F172A),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0F0F172A),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  /// Sombra hacia arriba de la barra de navegación inferior.
  static const List<BoxShadow> navBar = [
    BoxShadow(color: Color(0x0F0F172A), offset: Offset(0, -1), blurRadius: 8),
  ];
}

/// Estilos de texto que no calzan con un rol de `TextTheme`.
class AppText {
  AppText._();

  /// Etiquetas y metadatos: `font-medium text-xs text-slate-500
  /// tracking-wider`. Se usa con el texto en mayúsculas.
  static const TextStyle eyebrow = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  /// Cifras destacadas (posición, puntos).
  static const TextStyle metric = TextStyle(
    fontSize: 28,
    height: 1.1,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Números de tabla alineados en columnas.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];
}

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.primaryBright,
    onSecondary: AppColors.onPrimary,
    secondaryContainer: AppColors.primaryContainer,
    onSecondaryContainer: AppColors.onPrimaryContainer,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.background,
    surfaceContainer: AppColors.surfaceMuted,
    surfaceContainerHigh: AppColors.surfaceMuted,
    surfaceContainerHighest: AppColors.borderStrong,
    outline: AppColors.outline,
    outlineVariant: AppColors.border,
  );

  final base = ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
  );

  final text = base.textTheme.apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  );

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: const BorderSide(color: AppColors.borderStrong),
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
  );

  return base.copyWith(
    textTheme: text.copyWith(
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: AppText.eyebrow,
    ),

    // Barra superior compacta y blanca. Se integra con los encabezados
    // blancos de cada pantalla y muestra una sombra al desplazar.
    // Barra superior roja (encabezado de marca, como la maqueta de Inicio).
    // Blanco sobre red-700: contraste 6.5:1.
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: 56,
      // Tamaño explícito: `ThemeData.textTheme` aún no incluye tamaños
      // (Flutter los agrega en Theme.of), y el título quedaba en 14 px.
      titleTextStyle: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: AppColors.onPrimary,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.navIndicator,
      indicatorShape: const StadiumBorder(),
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textMuted,
        ),
      ),
    ),

    // Estilo por defecto de las pestañas: píldora blanca sobre pista gris
    // (ver `SegmentedTabBar`).
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.text,
      unselectedLabelColor: AppColors.textSecondary,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.md,
      ),
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Color(0x660F172A),
      showDragHandle: true,
      dragHandleColor: AppColors.handle,
      dragHandleSize: Size(40, 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),

    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.outline,
      shape: Border(),
      collapsedShape: Border(),
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textMuted,
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      prefixIconColor: AppColors.textMuted,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: buttonShape,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.borderStrong),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: buttonShape,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: buttonShape,
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.text,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  );
}
