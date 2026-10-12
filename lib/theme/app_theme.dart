import 'package:flutter/material.dart';

/// Paleta de la app: gris azulado claro + blanco.
///
/// Es la DIRECCIÓN VISUAL acordada por el equipo, no los colores oficiales
/// del Club Arturo Prat ni de ANFA Chiguayante (pendientes de confirmación).
/// Las pantallas no deben usar colores directos: deben tomarlos de aquí o de
/// `Theme.of(context).colorScheme`.
class AppColors {
  AppColors._();

  /// Gris azulado claro: color de identidad (acentos, indicadores).
  /// No usar como fondo de texto blanco: no tiene contraste suficiente.
  static const Color brand = Color(0xFF8FA3B8);

  /// Gris azulado profundo para elementos interactivos y texto destacado
  /// (contraste ≥ 4.5:1 sobre blanco).
  static const Color primary = Color(0xFF48607A);
  static const Color onPrimary = Colors.white;

  /// Fondo suave gris azulado para cabeceras, insignias y selección.
  static const Color primaryContainer = Color(0xFFE1E8EF);
  static const Color onPrimaryContainer = Color(0xFF1E2B38);

  static const Color background = Colors.white;

  /// Grises suaves para separar superficies.
  static const Color surfaceLow = Color(0xFFF5F7F9);
  static const Color surfaceMid = Color(0xFFEEF2F5);
  static const Color surfaceHigh = Color(0xFFE6EBF0);

  static const Color border = Color(0xFFDCE2E8);
  static const Color outline = Color(0xFF8C98A5);

  /// Texto principal y secundario (gris azulado oscuro).
  static const Color text = Color(0xFF1F2A37);
  static const Color textMuted = Color(0xFF5A6776);

  static const Color error = Color(0xFFB4443C);

  // Semánticos.
  static const Color favorite = Color(0xFFB8860B);
  static const Color statusNormal = brand;
  static const Color statusSuspended = error;
  static const Color statusRescheduled = Color(0xFFA86A12);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.brand,
    onSecondary: AppColors.text,
    secondaryContainer: AppColors.primaryContainer,
    onSecondaryContainer: AppColors.onPrimaryContainer,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.background,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.surfaceLow,
    surfaceContainer: AppColors.surfaceMid,
    surfaceContainerHigh: AppColors.surfaceHigh,
    surfaceContainerHighest: AppColors.surfaceHigh,
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

  final cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    side: const BorderSide(color: AppColors.border),
  );

  return base.copyWith(
    textTheme: text.copyWith(
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: text.labelSmall?.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 0.4,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      // Tamaño explícito: `ThemeData.textTheme` aún no incluye tamaños
      // (Flutter los agrega en Theme.of), y el título quedaba en 14 px.
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      shape: const Border(
        bottom: BorderSide(color: AppColors.border),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primaryContainer,
      elevation: 0,
      height: 68,
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
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textMuted,
        ),
      ),
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textMuted,
      indicatorColor: AppColors.primary,
      dividerColor: AppColors.border,
      labelStyle: TextStyle(fontWeight: FontWeight.w700),
      tabAlignment: TabAlignment.start,
    ),

    cardTheme: CardThemeData(
      color: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs + 2,
      ),
      shape: cardShape,
      clipBehavior: Clip.antiAlias,
    ),

    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: AppColors.background,
      collapsedBackgroundColor: AppColors.background,
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.textMuted,
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
      fillColor: AppColors.surfaceLow,
      prefixIconColor: AppColors.textMuted,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceMid,
      side: BorderSide.none,
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.text,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
  );
}
