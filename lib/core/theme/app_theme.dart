import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_palette.dart';

class AppTheme {
  static ThemeData darkTheme() => _build(GamePalette.dark);
  static ThemeData lightTheme() => _build(GamePalette.light);

  /// Fonte de títulos/números (arredondada, estilo jogo).
  static TextStyle display(double size, {Color? color, FontWeight weight = FontWeight.w700}) {
    return GoogleFonts.fredoka(fontSize: size, fontWeight: weight, color: color, height: 1.1);
  }

  static ThemeData _build(GamePalette p) {
    final isDark = p.isDark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      fontFamily: GoogleFonts.outfit().fontFamily,
    );
    final textTheme = base.textTheme.apply(bodyColor: p.text, displayColor: p.text);

    final scheme = (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
      primary: GamePalette.violet,
      onPrimary: Colors.white,
      secondary: GamePalette.cyan,
      onSecondary: Colors.black,
      surface: p.surface,
      onSurface: p.text,
      error: GamePalette.red,
    );

    return base.copyWith(
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      textTheme: textTheme,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: p.text,
        titleTextStyle: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600, color: p.text),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surface,
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.cardHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GamePalette.violet, width: 2),
        ),
        labelStyle: TextStyle(color: p.textDim),
        hintStyle: TextStyle(color: p.textMuted),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: GamePalette.violet,
        inactiveTrackColor: p.border,
        thumbColor: Colors.white,
        overlayColor: GamePalette.violet.withAlpha(40),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? GamePalette.violet : p.cardHigh,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.text,
        unselectedLabelColor: p.textMuted,
        indicatorColor: GamePalette.violet,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.cardHigh,
        contentTextStyle: TextStyle(color: p.text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GamePalette.violet,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: GamePalette.violet),
      ),
    );
  }
}
