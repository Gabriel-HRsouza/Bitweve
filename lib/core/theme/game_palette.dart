import 'package:flutter/material.dart';

/// Tokens visuais do BitWeve. Todos os widgets de jogo leem cores daqui,
/// o que permite alternar tema claro/escuro de verdade.
@immutable
class GamePalette extends ThemeExtension<GamePalette> {
  final Color bg;
  final Color bgDeep;
  final Color surface;
  final Color card;
  final Color cardHigh;
  final Color border;
  final Color text;
  final Color textDim;
  final Color textMuted;
  final Color shadow;
  final Brightness brightness;

  const GamePalette({
    required this.bg,
    required this.bgDeep,
    required this.surface,
    required this.card,
    required this.cardHigh,
    required this.border,
    required this.text,
    required this.textDim,
    required this.textMuted,
    required this.shadow,
    required this.brightness,
  });

  bool get isDark => brightness == Brightness.dark;

  // Cores de marca (iguais nos dois temas)
  static const Color violet = Color(0xFF7C5CFF);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color pink = Color(0xFFFF4F9A);
  static const Color gold = Color(0xFFFFC53D);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFFF5470);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color blue = Color(0xFF3B82F6);
  static const Color teal = Color(0xFF14B8A6);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [violet, Color(0xFF5B7CFF), cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const GamePalette dark = GamePalette(
    bg: Color(0xFF0B0D1A),
    bgDeep: Color(0xFF060713),
    surface: Color(0xFF141731),
    card: Color(0xFF1B1F3D),
    cardHigh: Color(0xFF262B52),
    border: Color(0xFF2E3463),
    text: Color(0xFFF5F6FF),
    textDim: Color(0xFFB4B8DA),
    textMuted: Color(0xFF7D82AD),
    shadow: Color(0xFF000000),
    brightness: Brightness.dark,
  );

  static const GamePalette light = GamePalette(
    bg: Color(0xFFF2F3FB),
    bgDeep: Color(0xFFE6E8F7),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardHigh: Color(0xFFF0F1FA),
    border: Color(0xFFDCDFF0),
    text: Color(0xFF15172E),
    textDim: Color(0xFF4A4F75),
    textMuted: Color(0xFF8186A8),
    shadow: Color(0xFF3B3F7A),
    brightness: Brightness.light,
  );

  /// Cor de um atributo de 0 a 100 (vermelho → amarelo → verde).
  static Color forValue(int v, {bool inverted = false}) {
    final value = inverted ? 100 - v : v;
    if (value >= 70) return green;
    if (value >= 45) return gold;
    if (value >= 25) return orange;
    return red;
  }

  @override
  GamePalette copyWith({
    Color? bg,
    Color? bgDeep,
    Color? surface,
    Color? card,
    Color? cardHigh,
    Color? border,
    Color? text,
    Color? textDim,
    Color? textMuted,
    Color? shadow,
    Brightness? brightness,
  }) {
    return GamePalette(
      bg: bg ?? this.bg,
      bgDeep: bgDeep ?? this.bgDeep,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardHigh: cardHigh ?? this.cardHigh,
      border: border ?? this.border,
      text: text ?? this.text,
      textDim: textDim ?? this.textDim,
      textMuted: textMuted ?? this.textMuted,
      shadow: shadow ?? this.shadow,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  GamePalette lerp(ThemeExtension<GamePalette>? other, double t) {
    if (other is! GamePalette) return this;
    return GamePalette(
      bg: Color.lerp(bg, other.bg, t)!,
      bgDeep: Color.lerp(bgDeep, other.bgDeep, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardHigh: Color.lerp(cardHigh, other.cardHigh, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}

extension GamePaletteX on BuildContext {
  GamePalette get gp => Theme.of(this).extension<GamePalette>() ?? GamePalette.dark;
}

Color hexColor(String hex, [Color fallback = GamePalette.violet]) {
  try {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse(clean.length == 6 ? 'FF$clean' : clean, radix: 16));
  } catch (_) {
    return fallback;
  }
}
