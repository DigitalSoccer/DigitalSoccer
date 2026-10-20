import 'package:flutter/material.dart';

/// Design tokens de la app según `docs/diseno.md` (mockup "ANFA Caupolicán"):
/// rojo de marca sobre fondo crema, con tema claro y oscuro.
///
/// Es la DIRECCIÓN VISUAL acordada por el equipo, no los colores oficiales
/// del Club Arturo Prat ni de la asociación (pendientes de confirmación).
///
/// Regla: ningún widget usa colores escritos a mano. Todos salen del tema
/// activo con `context.colors`, así el cambio claro/oscuro funciona solo.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Marca.
  /// Rojo de marca como FONDO (botones, chips, tarjeta de posición). Igual
  /// en ambos temas; lleva texto blanco encima.
  final Color primary;

  /// Rojo como TEXTO o ÍCONO (enlaces, pestaña activa). En oscuro se aclara
  /// (#FF7A82) porque #B3202A no contrasta sobre fondo oscuro.
  final Color primaryText;

  final Color onPrimary;

  /// Textos secundarios y líneas sobre `primary`.
  final Color onPrimaryMuted;
  final Color onPrimaryLine;

  /// Rojo oscuro (encabezado del panel directiva, panel "MI CLUB").
  final Color primaryDeep;

  /// Acentos rojos sin texto (franjas, bordes).
  final Color primaryBright;

  /// Fondo suave de selección (`primaryTint`).
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primarySoft;

  /// Fondo de miniatura de noticias (`primaryTint2`).
  final Color primaryTint2;

  // Superficies.
  final Color background;
  final Color surface;

  /// Separadores dentro de tarjetas y encabezado de tabla (`lineSoft`).
  final Color surfaceMuted;

  /// Borde de tarjetas (`line`).
  final Color border;

  /// Borde de campos y chips no seleccionados (`border` del mockup).
  final Color borderStrong;

  // Texto.
  /// Texto principal (`ink`).
  final Color text;

  /// Texto secundario (`muted`).
  final Color textSecondary;
  final Color textMuted;

  /// Íconos decorativos.
  final Color outline;

  /// Manilla de las hojas inferiores y perilla de interruptores.
  final Color handle;
  final Color switchThumb;

  // Semánticos.
  final Color error;

  /// Amarillo de acento: posición en la tarjeta roja, estrella de Mi Club.
  final Color accent;
  final Color favorite;

  /// Fila o tarjeta del equipo del usuario.
  final Color ownTeam;
  final Color ownTeamBorder;

  /// Avisos y estado "Suspendido".
  final Color noticeBg;
  final Color noticeText;
  final Color noticeBody;
  final Color noticeMeta;

  /// Estado "Programado".
  final Color tagNeutralBg;
  final Color tagNeutralText;

  final Color statusNormal;
  final Color statusSuspended;
  final Color statusRescheduled;

  // Podio de la tabla (fondo / texto).
  final Color goldBg;
  final Color goldFg;
  final Color silverBg;
  final Color silverFg;
  final Color bronzeBg;
  final Color bronzeFg;

  // Tarjetas disciplinarias.
  final Color cardYellow;
  final Color cardRed;

  /// Tinte de las sombras.
  final Color shadow;

  const AppColors({
    required this.primary,
    required this.primaryText,
    required this.onPrimary,
    required this.onPrimaryMuted,
    required this.onPrimaryLine,
    required this.primaryDeep,
    required this.primaryBright,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primarySoft,
    required this.primaryTint2,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.outline,
    required this.handle,
    required this.switchThumb,
    required this.error,
    required this.accent,
    required this.favorite,
    required this.ownTeam,
    required this.ownTeamBorder,
    required this.noticeBg,
    required this.noticeText,
    required this.noticeBody,
    required this.noticeMeta,
    required this.tagNeutralBg,
    required this.tagNeutralText,
    required this.statusNormal,
    required this.statusSuspended,
    required this.statusRescheduled,
    required this.goldBg,
    required this.goldFg,
    required this.silverBg,
    required this.silverFg,
    required this.bronzeBg,
    required this.bronzeFg,
    required this.cardYellow,
    required this.cardRed,
    required this.shadow,
  });

  /// Tema claro (valores de `docs/diseno.md`, sección 3).
  static const light = AppColors(
    primary: Color(0xFFB3202A),
    primaryText: Color(0xFFB3202A),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryMuted: Color(0xFFF8D4D6),
    onPrimaryLine: Color(0xFFD0505A),
    primaryDeep: Color(0xFF7A1219),
    primaryBright: Color(0xFFB3202A),
    primaryContainer: Color(0xFFFBE9EA),
    onPrimaryContainer: Color(0xFFB3202A),
    primarySoft: Color(0xFFFBE9EA),
    primaryTint2: Color(0xFFF6DADC),
    background: Color(0xFFF6F3F2),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF1ECEB),
    border: Color(0xFFE5DEDD),
    borderStrong: Color(0xFFD2C9C8),
    text: Color(0xFF1A1112),
    textSecondary: Color(0xFF625857),
    textMuted: Color(0xFF625857),
    outline: Color(0xFF625857),
    handle: Color(0xFFD2C9C8),
    switchThumb: Color(0xFFFFFFFF),
    error: Color(0xFF8A3A00),
    accent: Color(0xFFF5C400),
    favorite: Color(0xFFF5C400),
    ownTeam: Color(0xFFFDF3C4),
    ownTeamBorder: Color(0xFFE5CF73),
    noticeBg: Color(0xFFFDEBD9),
    noticeText: Color(0xFF8A3A00),
    noticeBody: Color(0xFF4A3019),
    noticeMeta: Color(0xFF6E4A2B),
    tagNeutralBg: Color(0xFFF1ECEB),
    tagNeutralText: Color(0xFF4A3F3E),
    statusNormal: Color(0xFFD2C9C8),
    statusSuspended: Color(0xFF8A3A00),
    statusRescheduled: Color(0xFF8A3A00),
    goldBg: Color(0xFFFDF3C4),
    goldFg: Color(0xFF7A5A00),
    silverBg: Color(0xFFF1ECEB),
    silverFg: Color(0xFF4A3F3E),
    bronzeBg: Color(0xFFFDEBD9),
    bronzeFg: Color(0xFF8A3A00),
    cardYellow: Color(0xFFF2C200),
    cardRed: Color(0xFFD32F2F),
    shadow: Color(0xFF1A1112),
  );

  /// Tema oscuro (tabla "Modo oscuro" de `docs/diseno.md`).
  static const dark = AppColors(
    primary: Color(0xFFB3202A),
    primaryText: Color(0xFFFF7A82),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryMuted: Color(0xFFF8D4D6),
    onPrimaryLine: Color(0xFFD0505A),
    primaryDeep: Color(0xFF7A1219),
    primaryBright: Color(0xFFB3202A),
    primaryContainer: Color(0xFF3A1A1D),
    onPrimaryContainer: Color(0xFFFF7A82),
    primarySoft: Color(0xFF3A1A1D),
    primaryTint2: Color(0xFF4A2023),
    background: Color(0xFF14100F),
    surface: Color(0xFF1F1918),
    surfaceMuted: Color(0xFF2A2221),
    border: Color(0xFF3A302F),
    borderStrong: Color(0xFF4A3F3E),
    text: Color(0xFFF4ECEA),
    textSecondary: Color(0xFFB3A6A4),
    textMuted: Color(0xFFB3A6A4),
    outline: Color(0xFFB3A6A4),
    handle: Color(0xFF4A3F3E),
    switchThumb: Color(0xFFF4ECEA),
    error: Color(0xFFFFB27A),
    accent: Color(0xFFF5C400),
    favorite: Color(0xFFF5C400),
    ownTeam: Color(0xFF3D3410),
    ownTeamBorder: Color(0xFF7A6A1F),
    noticeBg: Color(0xFF3A2414),
    noticeText: Color(0xFFFFB27A),
    noticeBody: Color(0xFFF2D3BC),
    noticeMeta: Color(0xFFE0B999),
    tagNeutralBg: Color(0xFF2A2221),
    tagNeutralText: Color(0xFFD8CCCA),
    statusNormal: Color(0xFF4A3F3E),
    statusSuspended: Color(0xFFFFB27A),
    statusRescheduled: Color(0xFFFFB27A),
    goldBg: Color(0xFF3D3410),
    goldFg: Color(0xFFF5D76E),
    silverBg: Color(0xFF2A2221),
    silverFg: Color(0xFFD8CCCA),
    bronzeBg: Color(0xFF3A2414),
    bronzeFg: Color(0xFFFFB27A),
    cardYellow: Color(0xFFF2C200),
    cardRed: Color(0xFFE5484D),
    shadow: Color(0xFF000000),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith() => this;

  // Cambio de tema sin animación de colores intermedios.
  @override
  AppColors lerp(covariant AppColors? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

extension AppColorsContext on BuildContext {
  /// Colores del tema activo (claro u oscuro).
  AppColors get colors => AppColors.of(this);
}

/// Familias tipográficas empaquetadas en `assets/fonts` (licencia OFL).
class AppFonts {
  AppFonts._();

  /// Cuerpo, etiquetas y botones.
  static const String body = 'Barlow';

  /// Títulos, números grandes, horas y nombres de sección.
  static const String display = 'BarlowCondensed';
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  /// Margen lateral de pantalla del mockup.
  static const double screen = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;

  /// Campos de texto.
  static const double md = 12;

  /// Tarjetas.
  static const double lg = 16;

  /// Tarjeta de posición y hojas inferiores.
  static const double xl = 20;

  static const double pill = 999;
}

/// Sombras suaves teñidas con el color de texto del tema claro.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D1A1112), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x141A1112),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0F1A1112),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  /// La barra inferior del mockup no tiene sombra: solo borde superior.
  static const List<BoxShadow> navBar = [];
}

/// Estilos de texto que no calzan con un rol de `TextTheme`. Reciben el
/// `context` para tomar el color del tema activo.
class AppText {
  AppText._();

  /// Etiquetas en mayúscula: Barlow 12, w700, espaciado 0.06em, `muted`.
  static TextStyle eyebrow(BuildContext context) => TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.72,
        color: context.colors.textMuted,
      );

  /// Cifras destacadas (posición, puntos): Barlow Condensed.
  static TextStyle metric(BuildContext context) => TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 36,
        height: 1,
        fontWeight: FontWeight.w700,
        color: context.colors.text,
        fontFeatures: tabular,
      );

  /// Títulos de pantalla, sección y horas: Barlow Condensed 700.
  static TextStyle display(
    BuildContext context, {
    double size = 24,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: AppFonts.display,
        fontSize: size,
        height: 1.05,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.text,
        fontFeatures: tabular,
      );

  /// Números de tabla alineados en columnas.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];
}

ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.primaryContainer,
    onPrimaryContainer: c.onPrimaryContainer,
    secondary: c.primaryText,
    onSecondary: c.onPrimary,
    secondaryContainer: c.primaryContainer,
    onSecondaryContainer: c.onPrimaryContainer,
    error: c.error,
    onError: c.onPrimary,
    surface: c.surface,
    onSurface: c.text,
    onSurfaceVariant: c.textMuted,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.background,
    surfaceContainer: c.surfaceMuted,
    surfaceContainerHigh: c.surfaceMuted,
    surfaceContainerHighest: c.borderStrong,
    outline: c.outline,
    outlineVariant: c.border,
  );

  final base = ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: c.background,
    fontFamily: AppFonts.body,
    extensions: [c],
  );

  final text = base.textTheme.apply(
    bodyColor: c.text,
    displayColor: c.text,
  );

  TextStyle? condensed(TextStyle? s) =>
      s?.copyWith(fontFamily: AppFonts.display, fontWeight: FontWeight.w700);

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: c.borderStrong),
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );

  return base.copyWith(
    textTheme: text.copyWith(
      headlineMedium: condensed(text.headlineMedium),
      headlineSmall: condensed(text.headlineSmall),
      titleLarge: condensed(text.titleLarge),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 15),
      labelSmall: text.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.72,
        color: c.textMuted,
      ),
    ),

    // Barra superior como el mockup: mismo fondo de la pantalla y título
    // grande en Barlow Condensed, alineado a la izquierda.
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 64,
      titleSpacing: AppSpacing.screen,
      // Tamaño explícito: `ThemeData.textTheme` aún no incluye tamaños
      // (Flutter los agrega en Theme.of).
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: c.text,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.primaryContainer,
      elevation: 0,
    ),

    // Pestañas píldora (ver `SegmentedTabBar`).
    tabBarTheme: TabBarThemeData(
      labelColor: c.text,
      unselectedLabelColor: c.textSecondary,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.md,
      ),
      labelStyle: const TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: const Color(0x661A1112),
      showDragHandle: true,
      dragHandleColor: c.handle,
      dragHandleSize: const Size(40, 4),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),

    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: c.primaryText,
      collapsedIconColor: c.outline,
      shape: const Border(),
      collapsedShape: const Border(),
    ),

    listTileTheme: ListTileThemeData(
      iconColor: c.textMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    ),

    dividerTheme: DividerThemeData(
      color: c.border,
      thickness: 1,
      space: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      prefixIconColor: c.textMuted,
      hintStyle: TextStyle(color: c.textMuted),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: c.primaryText, width: 1.5),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
        ),
        shape: buttonShape,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.primaryText,
        backgroundColor: c.surface,
        minimumSize: const Size(0, 48),
        side: BorderSide(color: c.borderStrong),
        textStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
        ),
        shape: buttonShape,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primaryText,
        textStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
        ),
        shape: buttonShape,
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? c.primaryText
            : c.borderStrong,
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(c.switchThumb),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? c.primary : c.borderStrong,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primaryText,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.text,
      contentTextStyle: TextStyle(fontFamily: AppFonts.body, color: c.background),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  );
}
