import 'package:flutter/material.dart';

/// Tema Liga SUR: amarillo #FFC700 y negro #111111, Montserrat. Todos los
/// colores y tamaños de la app salen de aquí (nada repartido por pantalla).
///
/// Los valores claros son los del mockup aprobado; los oscuros se derivan de
/// la marca (fondo casi negro, acentos amarillos) y están por validar.

abstract final class AppFonts {
  static const String family = 'Montserrat';
}

/// Colores del tema activo: `context.colors.x`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Amarillo de la marca y el texto que va encima.
  final Color brand;
  final Color onBrand;

  /// Amarillo suave: círculos de íconos, etiqueta de fecha.
  final Color brandSoft;

  /// Fondo de la pantalla y superficies (tarjetas).
  final Color background;
  final Color surface;

  /// Superficie apagada: pista del selector segmentado, celdas.
  final Color surfaceMuted;

  final Color border;
  final Color borderStrong;
  final Color divider;

  final Color text;
  final Color textMuted;
  final Color textFaint;

  /// Elemento invertido: chip elegido, botón negro, encabezado de tabla.
  final Color inverse;
  final Color onInverse;

  /// Cabecera negra con franjas amarillas.
  final Color header;
  final Color onHeader;
  final Color onHeaderMuted;
  final Color headerLine;

  /// Fila de mi equipo en tablas.
  final Color ownTeam;

  final Color danger;
  final Color cardYellow;
  final Color cardRed;

  /// Azul y dorado de la insignia ANFA del ingreso.
  final Color anfaBlue;
  final Color anfaGold;

  final Color shadow;

  const AppColors({
    required this.brand,
    required this.onBrand,
    required this.brandSoft,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.inverse,
    required this.onInverse,
    required this.header,
    required this.onHeader,
    required this.onHeaderMuted,
    required this.headerLine,
    required this.ownTeam,
    required this.danger,
    required this.cardYellow,
    required this.cardRed,
    required this.anfaBlue,
    required this.anfaGold,
    required this.shadow,
  });

  static const light = AppColors(
    brand: Color(0xFFFFC700),
    onBrand: Color(0xFF111111),
    brandSoft: Color(0xFFFFF3C2),
    background: Color(0xFFF5F4F0),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFE8E6DF),
    border: Color(0xFFE8E6DF),
    borderStrong: Color(0xFFD2CFC6),
    divider: Color(0xFFF0EEE8),
    text: Color(0xFF111111),
    textMuted: Color(0xFF5C5A53),
    textFaint: Color(0xFF7A776F),
    inverse: Color(0xFF111111),
    onInverse: Color(0xFFFFFFFF),
    header: Color(0xFF111111),
    onHeader: Color(0xFFFFFFFF),
    onHeaderMuted: Color(0xFFD9D6CE),
    headerLine: Color(0xFF3B3A37),
    ownTeam: Color(0xFFFFF3C2),
    danger: Color(0xFFC62828),
    cardYellow: Color(0xFFFFC700),
    cardRed: Color(0xFFC62828),
    anfaBlue: Color(0xFF1B2A7A),
    anfaGold: Color(0xFFFFE27A),
    shadow: Color(0x1A111111),
  );

  static const dark = AppColors(
    brand: Color(0xFFFFC700),
    onBrand: Color(0xFF111111),
    brandSoft: Color(0xFF3A3110),
    background: Color(0xFF0F0F0E),
    surface: Color(0xFF1B1A17),
    surfaceMuted: Color(0xFF2A2925),
    border: Color(0xFF2F2E29),
    borderStrong: Color(0xFF4A4842),
    divider: Color(0xFF262521),
    text: Color(0xFFF5F4F0),
    textMuted: Color(0xFFB4B0A5),
    textFaint: Color(0xFF8E8A80),
    inverse: Color(0xFFF5F4F0),
    onInverse: Color(0xFF111111),
    header: Color(0xFF191815),
    onHeader: Color(0xFFFFFFFF),
    onHeaderMuted: Color(0xFFD9D6CE),
    headerLine: Color(0xFF3B3A37),
    ownTeam: Color(0xFF3A3110),
    danger: Color(0xFFFF7A7A),
    cardYellow: Color(0xFFFFC700),
    cardRed: Color(0xFFE53935),
    anfaBlue: Color(0xFF2A3C9E),
    anfaGold: Color(0xFFFFE27A),
    shadow: Color(0x66000000),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      brand: l(brand, other.brand),
      onBrand: l(onBrand, other.onBrand),
      brandSoft: l(brandSoft, other.brandSoft),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      divider: l(divider, other.divider),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      textFaint: l(textFaint, other.textFaint),
      inverse: l(inverse, other.inverse),
      onInverse: l(onInverse, other.onInverse),
      header: l(header, other.header),
      onHeader: l(onHeader, other.onHeader),
      onHeaderMuted: l(onHeaderMuted, other.onHeaderMuted),
      headerLine: l(headerLine, other.headerLine),
      ownTeam: l(ownTeam, other.ownTeam),
      danger: l(danger, other.danger),
      cardYellow: l(cardYellow, other.cardYellow),
      cardRed: l(cardRed, other.cardRed),
      anfaBlue: l(anfaBlue, other.anfaBlue),
      anfaGold: l(anfaGold, other.anfaGold),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors.of(this);
}

/// Espaciados del mockup (márgenes de pantalla de 16 y 20).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double screen = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

/// Radios del mockup.
abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// Estilos de texto del mockup (Montserrat). Los tamaños son los del HTML.
abstract final class AppText {
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  /// Título de pantalla (26/800).
  static TextStyle title(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: AppFonts.family,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        height: 1.15,
        color: color ?? context.colors.text,
      );

  /// Título de sección (18/800).
  static TextStyle section(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: AppFonts.family,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: color ?? context.colors.text,
      );

  /// Etiqueta en mayúsculas espaciadas (11/700), p. ej. "PRÓXIMO PARTIDO".
  static TextStyle eyebrow(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: AppFonts.family,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: color ?? context.colors.textMuted,
      );

  /// Texto destacado de filas (14/700).
  static TextStyle strong(BuildContext context, {double size = 14, Color? color}) =>
      TextStyle(
        fontFamily: AppFonts.family,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.text,
      );

  /// Texto secundario (12/600).
  static TextStyle muted(BuildContext context, {double size = 12, Color? color}) =>
      TextStyle(
        fontFamily: AppFonts.family,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.textMuted,
      );

  /// Cifras grandes (marcadores, posiciones), con números tabulares.
  static TextStyle number(BuildContext context, {double size = 26, Color? color}) =>
      TextStyle(
        fontFamily: AppFonts.family,
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.05,
        color: color ?? context.colors.text,
        fontFeatures: tabular,
      );
}

ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;

  final scheme = ColorScheme.fromSeed(
    seedColor: c.brand,
    brightness: brightness,
  ).copyWith(
    primary: c.inverse,
    onPrimary: c.onInverse,
    secondary: c.brand,
    onSecondary: c.onBrand,
    surface: c.surface,
    onSurface: c.text,
    error: c.danger,
    outline: c.borderStrong,
    outlineVariant: c.border,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: AppFonts.family,
    scaffoldBackgroundColor: c.background,
    extensions: [c],
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: AppFonts.family,
      bodyColor: c.text,
      displayColor: c.text,
    ),
    dividerTheme: DividerThemeData(color: c.divider, space: 1, thickness: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.family,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: c.text,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.brand,
        foregroundColor: c.onBrand,
        disabledBackgroundColor: c.surfaceMuted,
        disabledForegroundColor: c.textFaint,
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(
          fontFamily: AppFonts.family,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.text,
        minimumSize: const Size(64, 52),
        side: BorderSide(color: c.inverse, width: 1.5),
        textStyle: const TextStyle(
          fontFamily: AppFonts.family,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.text,
        minimumSize: const Size(44, 44),
        textStyle: const TextStyle(
          fontFamily: AppFonts.family,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      hintStyle: TextStyle(color: c.textFaint, fontWeight: FontWeight.w500),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c.borderStrong, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c.borderStrong, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c.danger, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c.text, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.inverse,
      contentTextStyle: TextStyle(
        fontFamily: AppFonts.family,
        color: c.onInverse,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
