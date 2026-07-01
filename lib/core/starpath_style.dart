import 'package:flutter/material.dart';

class StarPathStyle {
  const StarPathStyle._();

  static const Color background = Color(0xFF0A1220);
  static const Color backgroundDeep = Color(0xFF050913);
  static const Color backgroundGlow = Color(0xFF13263A);
  static const Color surface = Color(0xFF121D2C);
  static const Color surfaceRaised = Color(0xFF18263A);
  static const Color surfaceMuted = Color(0xFF0F1724);
  static const Color surfaceStrong = Color(0xFF213145);
  static const Color divider = Color(0x18FFFFFF);
  static const Color dividerStrong = Color(0x28FFFFFF);
  static const Color textPrimary = Color(0xFFF6F8FB);
  static const Color textSecondary = Color(0xFFB8C2D0);
  static const Color textTertiary = Color(0xFF8192A6);
  static const Color accent = Color(0xFF6CE3F6);
  static const Color accentSoft = Color(0xFF9BA7FF);
  static const Color accentWarm = Color(0xFFFFC58F);

  static ThemeData theme() {
    final ColorScheme scheme = ColorScheme.dark(
      primary: accent,
      secondary: accentSoft,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceRaised,
    );

    final ThemeData base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundDeep,
      canvasColor: backgroundDeep,
      visualDensity: VisualDensity.standard,
      splashFactory: NoSplash.splashFactory,
      textTheme: base.textTheme.apply(
        fontFamily: 'NotoSansTC',
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      primaryTextTheme: base.primaryTextTheme.apply(
        fontFamily: 'NotoSansTC',
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textSecondary, size: 20),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: 0.92),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: const Color(0xFF07121C),
          disabledBackgroundColor: accent.withValues(alpha: 0.22),
          disabledForegroundColor: const Color(0x9907121C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansTC',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: dividerStrong),
          backgroundColor: surfaceMuted.withValues(alpha: 0.42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansTC',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansTC',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(color: textTertiary, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: accent.withValues(alpha: 0.40),
            width: 1.2,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background.withValues(alpha: 0.80),
        elevation: 0,
        indicatorColor: accent.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'NotoSansTC',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? accent : textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? accent : textTertiary,
            size: 22,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted.withValues(alpha: 0.86),
        selectedColor: accent.withValues(alpha: 0.14),
        side: BorderSide(color: divider.withValues(alpha: 1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansTC',
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        space: 1,
        thickness: 1,
      ),
    );
  }

  static BoxDecoration glassPanel({
    double radius = 28,
    Color tint = surface,
    double opacity = 0.88,
    double borderOpacity = 0.12,
    double blur = 18,
    Offset shadowOffset = const Offset(0, 16),
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: borderOpacity)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tint.withValues(alpha: opacity),
          tint.withValues(alpha: opacity * 0.94),
          backgroundDeep.withValues(alpha: 0.84),
        ],
        stops: const [0.0, 0.58, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: blur * 1.6,
          offset: shadowOffset,
        ),
        BoxShadow(
          color: accent.withValues(alpha: 0.025),
          blurRadius: blur,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration dockDecoration({
    double radius = 28,
    double opacity = 0.88,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          background.withValues(alpha: opacity),
          backgroundDeep.withValues(alpha: opacity),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.30),
          blurRadius: 28,
          offset: const Offset(0, 18),
        ),
      ],
    );
  }
}
