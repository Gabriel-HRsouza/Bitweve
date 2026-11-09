import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';

/// Avatar vetorial procedural do BitWeve. Reage a idade, roupa, corpo,
/// acessórios e expressão. Renderizado com CustomPainter (leve e nítido).
class AvatarWidget extends StatelessWidget {
  final AvatarConfig config;
  final double size;
  final int age;
  final bool animate;
  final bool showBackground;
  final Color? ringColor;
  final bool deceased;

  const AvatarWidget({
    super.key,
    required this.config,
    this.size = 80,
    this.age = 25,
    this.animate = true,
    this.showBackground = true,
    this.ringColor,
    this.deceased = false,
  });

  @override
  Widget build(BuildContext context) {
    final clothes = hexColor(config.clothesColor);
    Widget avatar = SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: CustomPaint(
          painter: _AvatarPainter(config: config, age: age, background: showBackground),
          size: Size.square(size),
        ),
      ),
    );
    if (deceased) {
      avatar = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.33, 0.33, 0.33, 0, 0,
          0.33, 0.33, 0.33, 0, 0,
          0.33, 0.33, 0.33, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: avatar,
      );
    }
    if (ringColor == null) return RepaintBoundary(child: avatar);
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(size * 0.035),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(colors: [ringColor!, clothes, ringColor!]),
          boxShadow: [BoxShadow(color: ringColor!.withAlpha(110), blurRadius: size * 0.18)],
        ),
        child: avatar,
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  final AvatarConfig config;
  final int age;
  final bool background;

  _AvatarPainter({required this.config, required this.age, required this.background});

  late double w;
  late Canvas c;

  double s(double v) => v * w;
  Offset o(double x, double y) => Offset(x * w, y * w);
  Paint fill(Color color) => Paint()
    ..color = color
    ..isAntiAlias = true;
  Paint stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width * w
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  Color darken(Color col, double amt) {
    final h = HSLColor.fromColor(col);
    return h.withLightness((h.lightness - amt).clamp(0.0, 1.0)).toColor();
  }

  Color lighten(Color col, double amt) {
    final h = HSLColor.fromColor(col);
    return h.withLightness((h.lightness + amt).clamp(0.0, 1.0)).toColor();
  }

  // ------------------------------------------------------------------ estágio de vida
  bool get baby => age <= 2;
  bool get child => age >= 3 && age <= 11;
  bool get teen => age >= 12 && age <= 17;
  bool get elder => age >= 60;

  double get headR => baby ? 0.27 : (child ? 0.245 : (teen ? 0.225 : 0.215));
  double get headY => baby ? 0.47 : (child ? 0.45 : 0.43);

  double get shoulderW {
    if (baby) return 0.5;
    if (child) return 0.58;
    switch (config.bodyType) {
      case BodyType.slim:
        return 0.64;
      case BodyType.average:
        return 0.72;
      case BodyType.athletic:
        return 0.82;
      case BodyType.curvy:
        return 0.74;
      case BodyType.broad:
        return 0.86;
    }
  }

  Color get hairColor {
    final base = hexColor(config.hairColor);
    if (age < 55) return base;
    final t = ((age - 55) / 25).clamp(0.0, 0.85);
    return Color.lerp(base, const Color(0xFFD9DCE3), t)!;
  }

  Color get skin {
    final base = hexColor(config.skinColor, const Color(0xFFE8B48A));
    if (config.expression == AvatarExpression.sick) return Color.lerp(base, const Color(0xFF9AD8A6), 0.32)!;
    return base;
  }

  @override
  void paint(Canvas canvas, Size size) {
    c = canvas;
    w = size.width;
    final clothes = hexColor(config.clothesColor);

    if (background) {
      final bg = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 0.95,
          colors: [lighten(clothes, 0.22).withAlpha(255), darken(clothes, 0.28)],
        ).createShader(Offset.zero & size);
      c.drawRect(Offset.zero & size, bg);
      // brilho
      c.drawCircle(o(0.22, 0.2), s(0.3), fill(Colors.white.withAlpha(28)));
    }

    _hairBack();
    _body(clothes);
    _neck();
    _ears();
    _head();
    _face();
    _beard();
    _hairFront();
    _accessories();
  }

  // ------------------------------------------------------------------ corpo e roupas
  void _neck() {
    final nw = baby ? 0.1 : 0.12;
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: o(0.5, headY + headR * 0.95), width: s(nw), height: s(0.16)),
      Radius.circular(s(0.04)),
    );
    c.drawRRect(r, fill(darken(skin, 0.06)));
  }

  Path _torso(double top) {
    final half = shoulderW / 2;
    final curvy = config.bodyType == BodyType.curvy && !baby && !child;
    final p = Path()
      ..moveTo(0.5 - half - 0.04, 1.05)
      ..quadraticBezierTo(0.5 - half - 0.02, top + 0.06, 0.5 - half + 0.1, top)
      ..lineTo(0.5 + half - 0.1, top)
      ..quadraticBezierTo(0.5 + half + 0.02, top + 0.06, 0.5 + half + 0.04, 1.05)
      ..close();
    if (curvy) {
      // ombros mais arredondados
      return Path()
        ..moveTo(0.5 - half - 0.02, 1.05)
        ..cubicTo(0.5 - half - 0.04, top + 0.1, 0.5 - half + 0.02, top + 0.005, 0.5 - half + 0.14, top)
        ..lineTo(0.5 + half - 0.14, top)
        ..cubicTo(0.5 + half - 0.02, top + 0.005, 0.5 + half + 0.04, top + 0.1, 0.5 + half + 0.02, 1.05)
        ..close();
    }
    return p;
  }

  Path _scaled(Path p) => p.transform(Matrix4.diagonal3Values(w, w, 1).storage);

  void _body(Color clothes) {
    final top = headY + headR + 0.07;
    final torso = _scaled(_torso(top));
    final outfit = config.outfit;
    final shade = darken(clothes, 0.12);

    Paint grad(Color a, Color b) => Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [a, b])
          .createShader(Rect.fromLTWH(0, s(top), w, s(1 - top)));

    if (baby) {
      c.drawPath(torso, grad(lighten(clothes, 0.15), clothes));
      // gola de macacão
      c.drawArc(Rect.fromCenter(center: o(0.5, top + 0.02), width: s(0.22), height: s(0.12)), 0, math.pi, false, stroke(Colors.white.withAlpha(200), 0.02));
      return;
    }

    switch (outfit) {
      case OutfitStyle.casual:
        c.drawPath(torso, grad(clothes, shade));
        _crewNeck(top, darken(clothes, 0.2));
        break;
      case OutfitStyle.sport:
        c.drawPath(torso, grad(clothes, shade));
        // listras nos ombros
        final half = shoulderW / 2;
        for (final dx in [-1, 1]) {
          final x = 0.5 + dx * (half - 0.12);
          c.drawLine(o(x, top + 0.01), o(x + dx * 0.06, 1.0), stroke(Colors.white.withAlpha(220), 0.022));
          c.drawLine(o(x + dx * 0.035, top + 0.015), o(x + dx * 0.095, 1.0), stroke(Colors.white.withAlpha(220), 0.016));
        }
        _vNeck(top, Colors.white);
        // número
        _text('${(config.skinColor.hashCode % 89) + 10}', o(0.5, top + 0.2), s(0.09), Colors.white.withAlpha(210));
        break;
      case OutfitStyle.elegant:
        c.drawPath(torso, grad(clothes, darken(clothes, 0.18)));
        _shirtAndLapels(top, Colors.white, clothes);
        _bowTieOrNecklace(top, darken(clothes, 0.35));
        break;
      case OutfitStyle.alternative:
        c.drawPath(torso, grad(const Color(0xFF26262B), const Color(0xFF0E0E12)));
        // camiseta por baixo
        final tee = Path()
          ..moveTo(s(0.42), s(top))
          ..lineTo(s(0.58), s(top))
          ..lineTo(s(0.55), w * 1.05)
          ..lineTo(s(0.45), w * 1.05)
          ..close();
        c.drawPath(tee, fill(clothes));
        // zíper e tachas
        c.drawLine(o(0.5 + 0.075, top + 0.02), o(0.5 + 0.06, 1.0), stroke(const Color(0xFFB8BCC6), 0.01));
        final half = shoulderW / 2;
        for (var i = 0; i < 4; i++) {
          c.drawCircle(o(0.5 - half + 0.14 + i * 0.035, top + 0.025), s(0.009), fill(const Color(0xFFD4D4D8)));
          c.drawCircle(o(0.5 + half - 0.14 - i * 0.035, top + 0.025), s(0.009), fill(const Color(0xFFD4D4D8)));
        }
        break;
      case OutfitStyle.executive:
        c.drawPath(torso, grad(const Color(0xFF273248), const Color(0xFF111827)));
        _shirtAndLapels(top, Colors.white, const Color(0xFF1E293B));
        _tie(top, clothes);
        break;
      case OutfitStyle.urban:
        c.drawPath(torso, grad(clothes, shade));
        // capuz atrás do pescoço
        c.drawArc(Rect.fromCenter(center: o(0.5, top + 0.01), width: s(0.34), height: s(0.16)), math.pi, math.pi, false,
            stroke(darken(clothes, 0.18), 0.05));
        c.drawArc(Rect.fromCenter(center: o(0.5, top + 0.02), width: s(0.26), height: s(0.1)), 0, math.pi, false,
            stroke(darken(clothes, 0.22), 0.03));
        // cordões
        c.drawLine(o(0.46, top + 0.06), o(0.455, top + 0.2), stroke(Colors.white.withAlpha(220), 0.01));
        c.drawLine(o(0.54, top + 0.06), o(0.545, top + 0.2), stroke(Colors.white.withAlpha(220), 0.01));
        // bolso canguru
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s(0.36), s(top + 0.24), s(0.28), s(0.12)), Radius.circular(s(0.03))),
            stroke(darken(clothes, 0.2), 0.008));
        break;
      case OutfitStyle.luxury:
        c.drawPath(torso, grad(lighten(clothes, 0.05), darken(clothes, 0.25)));
        _shirtAndLapels(top, const Color(0xFF111111), clothes, trim: const Color(0xFFFFD36B));
        // corrente de ouro
        c.drawArc(Rect.fromCenter(center: o(0.5, top + 0.03), width: s(0.2), height: s(0.2)), 0.2, math.pi - 0.4, false,
            stroke(const Color(0xFFFFD36B), 0.016));
        break;
      case OutfitStyle.student:
        c.drawPath(torso, grad(clothes, shade));
        // gola da camisa por baixo
        _collar(top, Colors.white);
        // alças da mochila
        final half = shoulderW / 2;
        for (final dx in [-1, 1]) {
          final x = 0.5 + dx * (half - 0.16);
          c.drawLine(o(x, top - 0.005), o(x - dx * 0.02, 1.0), stroke(const Color(0xFF334155), 0.04));
        }
        // tricô
        for (var i = 1; i < 5; i++) {
          c.drawLine(o(0.5 - half + 0.08, top + i * 0.06), o(0.5 + half - 0.08, top + i * 0.06), stroke(darken(clothes, 0.06), 0.006));
        }
        break;
      case OutfitStyle.celebrity:
        c.drawPath(torso, grad(lighten(clothes, 0.08), darken(clothes, 0.2)));
        final r = math.Random(7);
        final half = shoulderW / 2;
        for (var i = 0; i < 40; i++) {
          final x = 0.5 - half + r.nextDouble() * shoulderW;
          final y = top + 0.02 + r.nextDouble() * (1 - top);
          c.drawCircle(o(x, y), s(0.006 + r.nextDouble() * 0.006), fill(Colors.white.withAlpha(110 + r.nextInt(120))));
        }
        _vNeck(top, darken(clothes, 0.3));
        break;
      case OutfitStyle.artistic:
        c.drawPath(torso, grad(const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)));
        c.save();
        c.clipPath(torso);
        for (var i = 0; i < 9; i++) {
          final y = top + 0.03 + i * 0.05;
          c.drawRect(Rect.fromLTWH(0, s(y), w, s(0.022)), fill(const Color(0xFF1E3A8A)));
        }
        c.restore();
        // cachecol
        final scarf = Path()
          ..moveTo(s(0.36), s(top - 0.01))
          ..quadraticBezierTo(s(0.5), s(top + 0.08), s(0.64), s(top - 0.01))
          ..lineTo(s(0.6), s(top + 0.05))
          ..quadraticBezierTo(s(0.5), s(top + 0.12), s(0.4), s(top + 0.05))
          ..close();
        c.drawPath(scarf, fill(clothes));
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s(0.53), s(top + 0.05), s(0.07), s(0.2)), Radius.circular(s(0.02))), fill(darken(clothes, 0.08)));
        break;
    }
  }

  void _crewNeck(double top, Color color) {
    c.drawArc(Rect.fromCenter(center: o(0.5, top + 0.005), width: s(0.2), height: s(0.11)), 0, math.pi, false, stroke(color, 0.02));
  }

  void _vNeck(double top, Color color) {
    final p = Path()
      ..moveTo(s(0.42), s(top))
      ..lineTo(s(0.5), s(top + 0.09))
      ..lineTo(s(0.58), s(top));
    c.drawPath(p, stroke(color, 0.022));
  }

  void _collar(double top, Color color) {
    final l = Path()
      ..moveTo(s(0.43), s(top - 0.005))
      ..lineTo(s(0.5), s(top + 0.05))
      ..lineTo(s(0.44), s(top + 0.07))
      ..close();
    final r = Path()
      ..moveTo(s(0.57), s(top - 0.005))
      ..lineTo(s(0.5), s(top + 0.05))
      ..lineTo(s(0.56), s(top + 0.07))
      ..close();
    c.drawPath(l, fill(color));
    c.drawPath(r, fill(color));
  }

  void _shirtAndLapels(double top, Color shirt, Color jacket, {Color? trim}) {
    final shirtPath = Path()
      ..moveTo(s(0.41), s(top))
      ..lineTo(s(0.59), s(top))
      ..lineTo(s(0.53), w * 1.05)
      ..lineTo(s(0.47), w * 1.05)
      ..close();
    c.drawPath(shirtPath, fill(shirt));
    _collar(top, shirt == Colors.white ? const Color(0xFFF1F5F9) : lighten(shirt, 0.1));
    final lapelColor = darken(jacket, 0.08);
    final l = Path()
      ..moveTo(s(0.41), s(top))
      ..lineTo(s(0.47), s(top + 0.3))
      ..lineTo(s(0.36), s(top + 0.08))
      ..close();
    final r = Path()
      ..moveTo(s(0.59), s(top))
      ..lineTo(s(0.53), s(top + 0.3))
      ..lineTo(s(0.64), s(top + 0.08))
      ..close();
    c.drawPath(l, fill(lapelColor));
    c.drawPath(r, fill(lapelColor));
    if (trim != null) {
      c.drawPath(l, stroke(trim, 0.008));
      c.drawPath(r, stroke(trim, 0.008));
    }
  }

  void _tie(double top, Color color) {
    final knot = Path()
      ..moveTo(s(0.48), s(top + 0.03))
      ..lineTo(s(0.52), s(top + 0.03))
      ..lineTo(s(0.515), s(top + 0.065))
      ..lineTo(s(0.485), s(top + 0.065))
      ..close();
    final body = Path()
      ..moveTo(s(0.485), s(top + 0.065))
      ..lineTo(s(0.515), s(top + 0.065))
      ..lineTo(s(0.535), s(top + 0.26))
      ..lineTo(s(0.5), s(top + 0.3))
      ..lineTo(s(0.465), s(top + 0.26))
      ..close();
    c.drawPath(knot, fill(darken(color, 0.1)));
    c.drawPath(body, fill(color));
  }

  void _bowTieOrNecklace(double top, Color color) {
    final cy = top + 0.045;
    final l = Path()
      ..moveTo(s(0.5), s(cy))
      ..lineTo(s(0.45), s(cy - 0.025))
      ..lineTo(s(0.45), s(cy + 0.025))
      ..close();
    final r = Path()
      ..moveTo(s(0.5), s(cy))
      ..lineTo(s(0.55), s(cy - 0.025))
      ..lineTo(s(0.55), s(cy + 0.025))
      ..close();
    c.drawPath(l, fill(color));
    c.drawPath(r, fill(color));
    c.drawCircle(o(0.5, cy), s(0.01), fill(darken(color, 0.1)));
  }

  void _text(String t, Offset at, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, at - Offset(tp.width / 2, tp.height / 2));
  }

  // ------------------------------------------------------------------ cabeça
  Rect get _headRect {
    final r = headR;
    switch (config.faceShape) {
      case FaceShape.round:
        return Rect.fromCenter(center: o(0.5, headY), width: s(r * 2), height: s(r * 2.02));
      case FaceShape.oval:
        return Rect.fromCenter(center: o(0.5, headY), width: s(r * 1.86), height: s(r * 2.18));
      case FaceShape.square:
        return Rect.fromCenter(center: o(0.5, headY), width: s(r * 1.98), height: s(r * 2.06));
    }
  }

  void _ears() {
    final rect = _headRect;
    for (final dx in [-1.0, 1.0]) {
      final center = Offset(rect.center.dx + dx * rect.width * 0.49, rect.center.dy + rect.height * 0.04);
      c.drawOval(Rect.fromCenter(center: center, width: s(0.07), height: s(0.1)), fill(darken(skin, 0.04)));
      c.drawOval(Rect.fromCenter(center: center, width: s(0.035), height: s(0.055)), fill(darken(skin, 0.12)));
    }
  }

  void _head() {
    final rect = _headRect;
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 0.95,
        colors: [lighten(skin, 0.05), darken(skin, 0.06)],
      ).createShader(rect);
    if (config.faceShape == FaceShape.square) {
      c.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.36)), paint);
    } else {
      c.drawOval(rect, paint);
    }
  }

  // ------------------------------------------------------------------ rosto
  void _face() {
    final rect = _headRect;
    final cx = rect.center.dx / w;
    final cy = rect.center.dy / w;
    final scale = headR / 0.215;
    final eyeY = cy + 0.005 * scale;
    final eyeDx = 0.075 * scale;
    final eyeR = (baby ? 0.03 : 0.024) * scale;
    final expr = config.expression;
    final eyeColor = hexColor(config.eyeColor, const Color(0xFF4A2A12));
    final browColor = darken(hairColor, 0.12);

    // sobrancelhas
    for (final dx in [-1.0, 1.0]) {
      final x = cx + dx * eyeDx;
      double tilt = 0;
      if (expr == AvatarExpression.angry) tilt = 0.022;
      if (expr == AvatarExpression.sad || expr == AvatarExpression.fear) tilt = -0.018;
      final y = eyeY - 0.05 * scale;
      c.drawLine(o(x - dx * 0.03 * scale, y - tilt * 0.3), o(x + dx * 0.03 * scale, y + tilt), stroke(browColor, baby ? 0.008 : 0.013));
    }

    // olhos
    for (final dx in [-1.0, 1.0]) {
      final center = o(cx + dx * eyeDx, eyeY);
      if (expr == AvatarExpression.happy && !baby) {
        // olhos sorridentes
        c.drawArc(Rect.fromCenter(center: center, width: s(eyeR * 2.4), height: s(eyeR * 1.9)), math.pi * 1.1, math.pi * 0.8, false,
            stroke(const Color(0xFF1F2937), 0.012));
        continue;
      }
      if (expr == AvatarExpression.love) {
        _heart(center, s(eyeR * 1.3), const Color(0xFFFF4F9A));
        continue;
      }
      final open = expr == AvatarExpression.surprised || expr == AvatarExpression.fear ? 1.25 : (expr == AvatarExpression.sick ? 0.6 : 1.0);
      c.drawOval(Rect.fromCenter(center: center, width: s(eyeR * 2.2), height: s(eyeR * 2.2 * open)), fill(Colors.white));
      c.drawCircle(center + Offset(0, s(eyeR * 0.1)), s(eyeR * 0.78), fill(eyeColor));
      c.drawCircle(center + Offset(0, s(eyeR * 0.1)), s(eyeR * 0.38), fill(const Color(0xFF0B0B10)));
      c.drawCircle(center + Offset(s(eyeR * 0.3), -s(eyeR * 0.25)), s(eyeR * 0.24), fill(Colors.white));
      if (expr == AvatarExpression.sick) {
        c.drawLine(center + Offset(-s(eyeR * 1.1), -s(eyeR * 0.3)), center + Offset(s(eyeR * 1.1), -s(eyeR * 0.3)), stroke(darken(skin, 0.18), 0.01));
      }
    }

    // nariz
    final noseY = cy + 0.06 * scale;
    final nose = Path()
      ..moveTo(s(cx - 0.012 * scale), s(noseY))
      ..quadraticBezierTo(s(cx), s(noseY + 0.022 * scale), s(cx + 0.014 * scale), s(noseY));
    c.drawPath(nose, stroke(darken(skin, 0.18), 0.01));

    // bochechas
    if (config.has(AvatarAccessory.blush) || expr == AvatarExpression.love || baby) {
      for (final dx in [-1.0, 1.0]) {
        c.drawOval(Rect.fromCenter(center: o(cx + dx * 0.105 * scale, cy + 0.075 * scale), width: s(0.06 * scale), height: s(0.035 * scale)),
            fill(const Color(0xFFFF7A9A).withAlpha(90)));
      }
    }
    // sardas
    if (config.has(AvatarAccessory.freckles)) {
      final r = math.Random(3);
      for (var i = 0; i < 10; i++) {
        final dx = (i < 5 ? -1 : 1) * (0.06 + r.nextDouble() * 0.06) * scale;
        c.drawCircle(o(cx + dx, cy + (0.045 + r.nextDouble() * 0.04) * scale), s(0.0045), fill(darken(skin, 0.25).withAlpha(170)));
      }
    }

    // boca
    final mouthY = cy + 0.115 * scale;
    final mw = 0.07 * scale;
    final mouthColor = const Color(0xFF7F1D1D);
    switch (expr) {
      case AvatarExpression.happy:
      case AvatarExpression.love:
        final p = Path()
          ..moveTo(s(cx - mw), s(mouthY - 0.008))
          ..quadraticBezierTo(s(cx), s(mouthY + 0.06 * scale), s(cx + mw), s(mouthY - 0.008))
          ..quadraticBezierTo(s(cx), s(mouthY + 0.015), s(cx - mw), s(mouthY - 0.008));
        c.drawPath(p, fill(mouthColor));
        // dentes
        c.save();
        c.clipPath(p);
        c.drawRect(Rect.fromLTWH(s(cx - mw), s(mouthY - 0.01), s(mw * 2), s(0.018)), fill(Colors.white));
        c.restore();
        break;
      case AvatarExpression.sad:
        c.drawArc(Rect.fromCenter(center: o(cx, mouthY + 0.03), width: s(mw * 1.6), height: s(0.06)), math.pi * 1.15, math.pi * 0.7, false, stroke(mouthColor, 0.012));
        // lágrima
        c.drawOval(Rect.fromCenter(center: o(cx + eyeDx + 0.01, eyeY + 0.045), width: s(0.018), height: s(0.03)), fill(const Color(0xFF7DD3FC)));
        break;
      case AvatarExpression.angry:
        c.drawLine(o(cx - mw * 0.8, mouthY + 0.01), o(cx + mw * 0.8, mouthY + 0.005), stroke(mouthColor, 0.014));
        break;
      case AvatarExpression.surprised:
      case AvatarExpression.fear:
        c.drawOval(Rect.fromCenter(center: o(cx, mouthY + 0.01), width: s(0.045 * scale), height: s(0.06 * scale)), fill(mouthColor));
        break;
      case AvatarExpression.sick:
        final p = Path()..moveTo(s(cx - mw * 0.8), s(mouthY + 0.01));
        for (var i = 1; i <= 4; i++) {
          p.lineTo(s(cx - mw * 0.8 + i * mw * 0.4), s(mouthY + (i.isOdd ? -0.004 : 0.016)));
        }
        c.drawPath(p, stroke(mouthColor, 0.01));
        break;
      case AvatarExpression.neutral:
        c.drawLine(o(cx - mw * 0.6, mouthY + 0.01), o(cx + mw * 0.6, mouthY + 0.01), stroke(mouthColor, 0.012));
        break;
    }

    // rugas
    if (elder) {
      final lines = stroke(darken(skin, 0.16).withAlpha(170), 0.006);
      c.drawArc(Rect.fromCenter(center: o(cx, cy - 0.13 * scale), width: s(0.12), height: s(0.02)), math.pi, math.pi, false, lines);
      c.drawArc(Rect.fromCenter(center: o(cx, cy - 0.105 * scale), width: s(0.09), height: s(0.016)), math.pi, math.pi, false, lines);
      for (final dx in [-1.0, 1.0]) {
        c.drawLine(o(cx + dx * (eyeDx + 0.04), eyeY - 0.01), o(cx + dx * (eyeDx + 0.055), eyeY + 0.005), lines);
        c.drawArc(Rect.fromCenter(center: o(cx + dx * 0.07, mouthY - 0.01), width: s(0.04), height: s(0.06)),
            dx < 0 ? math.pi * 0.6 : math.pi * 1.9, math.pi * 0.5, false, lines);
      }
    }
  }

  void _heart(Offset center, double r, Color color) {
    final p = Path()
      ..moveTo(center.dx, center.dy + r * 0.8)
      ..cubicTo(center.dx - r * 1.6, center.dy - r * 0.2, center.dx - r * 0.6, center.dy - r * 1.3, center.dx, center.dy - r * 0.35)
      ..cubicTo(center.dx + r * 0.6, center.dy - r * 1.3, center.dx + r * 1.6, center.dy - r * 0.2, center.dx, center.dy + r * 0.8);
    c.drawPath(p, fill(color));
  }

  // ------------------------------------------------------------------ barba
  void _beard() {
    if (age < 16) return;
    final style = config.effectiveBeard;
    if (style == BeardStyle.none) return;
    final rect = _headRect;
    final cx = rect.center.dx / w;
    final cy = rect.center.dy / w;
    final col = hairColor;
    switch (style) {
      case BeardStyle.stubble:
        final r = math.Random(11);
        final p = fill(col.withAlpha(110));
        for (var i = 0; i < 70; i++) {
          final a = math.pi * (0.1 + r.nextDouble() * 0.8);
          final rr = 0.12 + r.nextDouble() * 0.09;
          c.drawCircle(o(cx + math.cos(a) * rr, cy + 0.03 + math.sin(a) * rr * 0.95), s(0.004), p);
        }
        break;
      case BeardStyle.full:
        final p = Path()
          ..moveTo(rect.left + s(0.01), rect.center.dy - s(0.01))
          ..quadraticBezierTo(rect.left + s(0.02), rect.bottom + s(0.03), rect.center.dx, rect.bottom + s(0.05))
          ..quadraticBezierTo(rect.right - s(0.02), rect.bottom + s(0.03), rect.right - s(0.01), rect.center.dy - s(0.01))
          ..quadraticBezierTo(rect.right - s(0.05), rect.center.dy + s(0.09), rect.center.dx + s(0.05), rect.center.dy + s(0.1))
          ..quadraticBezierTo(rect.center.dx, rect.center.dy + s(0.08), rect.center.dx - s(0.05), rect.center.dy + s(0.1))
          ..quadraticBezierTo(rect.left + s(0.05), rect.center.dy + s(0.09), rect.left + s(0.01), rect.center.dy - s(0.01));
        c.drawPath(p, fill(col));
        _mustache(cx, cy, col);
        break;
      case BeardStyle.goatee:
        c.drawOval(Rect.fromCenter(center: o(cx, cy + 0.175), width: s(0.08), height: s(0.07)), fill(col));
        _mustache(cx, cy, col);
        break;
      case BeardStyle.mustache:
        _mustache(cx, cy, col);
        break;
      case BeardStyle.none:
        break;
    }
  }

  void _mustache(double cx, double cy, Color col) {
    final p = Path()
      ..moveTo(s(cx), s(cy + 0.09))
      ..quadraticBezierTo(s(cx - 0.05), s(cy + 0.08), s(cx - 0.07), s(cy + 0.11))
      ..quadraticBezierTo(s(cx - 0.03), s(cy + 0.1), s(cx), s(cy + 0.105))
      ..quadraticBezierTo(s(cx + 0.03), s(cy + 0.1), s(cx + 0.07), s(cy + 0.11))
      ..quadraticBezierTo(s(cx + 0.05), s(cy + 0.08), s(cx), s(cy + 0.09));
    c.drawPath(p, fill(col));
  }

  // ------------------------------------------------------------------ cabelo
  void _hairBack() {
    if (baby) return;
    final rect = _headRect;
    final col = darken(hairColor, 0.06);
    final paint = fill(col);
    switch (config.hairStyle) {
      case HairStyle.longWavy:
      case HairStyle.longStraight:
        final wavy = config.hairStyle == HairStyle.longWavy;
        final p = Path()
          ..moveTo(rect.left - s(0.03), rect.center.dy - s(0.05))
          ..quadraticBezierTo(rect.left - s(wavy ? 0.08 : 0.04), rect.bottom + s(0.1), rect.left + s(0.02), rect.bottom + s(0.2))
          ..lineTo(rect.right - s(0.02), rect.bottom + s(0.2))
          ..quadraticBezierTo(rect.right + s(wavy ? 0.08 : 0.04), rect.bottom + s(0.1), rect.right + s(0.03), rect.center.dy - s(0.05))
          ..close();
        c.drawPath(p, paint);
        break;
      case HairStyle.ponytail:
        c.drawOval(Rect.fromCenter(center: Offset(rect.right + s(0.02), rect.center.dy + s(0.05)), width: s(0.12), height: s(0.28)), paint);
        break;
      case HairStyle.braids:
        for (final dx in [-1.0, 1.0]) {
          final x = rect.center.dx + dx * rect.width * 0.46;
          for (var i = 0; i < 6; i++) {
            c.drawOval(Rect.fromCenter(center: Offset(x, rect.center.dy + s(0.02 + i * 0.055)), width: s(0.06), height: s(0.065)), paint);
          }
        }
        break;
      case HairStyle.afro:
        c.drawCircle(Offset(rect.center.dx, rect.center.dy - s(0.04)), rect.width * 0.78, paint);
        break;
      case HairStyle.curly:
        final r = math.Random(5);
        for (var i = 0; i < 16; i++) {
          final a = math.pi * (0.85 + i / 15 * 1.3);
          c.drawCircle(Offset(rect.center.dx + math.cos(a) * rect.width * 0.55, rect.center.dy + math.sin(a) * rect.height * 0.5 + s(0.02)),
              s(0.055 + r.nextDouble() * 0.02), paint);
        }
        break;
      case HairStyle.bob:
        final p = Path()
          ..moveTo(rect.left - s(0.035), rect.center.dy - s(0.04))
          ..lineTo(rect.left - s(0.03), rect.bottom - s(0.02))
          ..lineTo(rect.right + s(0.03), rect.bottom - s(0.02))
          ..lineTo(rect.right + s(0.035), rect.center.dy - s(0.04))
          ..close();
        c.drawPath(p, paint);
        break;
      case HairStyle.dreads:
        for (var i = 0; i < 9; i++) {
          final x = rect.left + rect.width * (i / 8);
          c.drawLine(Offset(x, rect.center.dy - s(0.03)), Offset(x + s((i - 4) * 0.006), rect.bottom + s(0.12)), stroke(col, 0.035));
        }
        break;
      default:
        break;
    }
  }

  void _hairFront() {
    final rect = _headRect;
    final col = hairColor;
    final paint = Paint()
      ..shader = LinearGradient(colors: [lighten(col, 0.08), darken(col, 0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight)
          .createShader(rect)
      ..isAntiAlias = true;
    final top = rect.top;
    final l = rect.left;
    final r = rect.right;
    final cx = rect.center.dx;

    if (baby) {
      if (config.hairStyle != HairStyle.bald) {
        final tuft = Path()
          ..moveTo(cx - s(0.02), top + s(0.03))
          ..quadraticBezierTo(cx, top - s(0.04), cx + s(0.04), top + s(0.005))
          ..quadraticBezierTo(cx + s(0.01), top + s(0.0), cx - s(0.02), top + s(0.03));
        c.drawPath(tuft, paint);
      }
      return;
    }

    // Calota base usada pela maioria dos estilos
    Path cap({double depth = 0.42, double fringe = 0.0}) {
      return Path()
        ..moveTo(l - s(0.01), rect.top + rect.height * depth)
        ..quadraticBezierTo(l - s(0.01), top - s(0.03), cx, top - s(0.035))
        ..quadraticBezierTo(r + s(0.01), top - s(0.03), r + s(0.01), rect.top + rect.height * depth)
        ..quadraticBezierTo(r - s(0.04), top + s(0.05 + fringe), cx + s(0.05), top + s(0.07 + fringe))
        ..quadraticBezierTo(cx - s(0.06), top + s(0.06 + fringe), l + s(0.03), top + s(0.1 + fringe))
        ..close();
    }

    switch (config.hairStyle) {
      case HairStyle.bald:
        c.drawArc(Rect.fromCenter(center: Offset(cx - s(0.05), top + s(0.06)), width: s(0.12), height: s(0.06)), math.pi * 1.1, math.pi * 0.6, false,
            stroke(Colors.white.withAlpha(60), 0.012));
        break;
      case HairStyle.buzz:
        c.drawPath(cap(depth: 0.3), fill(col.withAlpha(170)));
        break;
      case HairStyle.short:
        c.drawPath(cap(depth: 0.36), paint);
        break;
      case HairStyle.sidePart:
        final p = Path()
          ..moveTo(l - s(0.015), rect.top + rect.height * 0.42)
          ..quadraticBezierTo(l - s(0.02), top - s(0.04), cx - s(0.02), top - s(0.04))
          ..quadraticBezierTo(r + s(0.02), top - s(0.03), r + s(0.012), rect.top + rect.height * 0.4)
          ..quadraticBezierTo(r - s(0.02), top + s(0.04), cx - s(0.04), top + s(0.04))
          ..quadraticBezierTo(l + s(0.06), top + s(0.08), l + s(0.02), rect.top + rect.height * 0.32)
          ..close();
        c.drawPath(p, paint);
        c.drawLine(Offset(cx - s(0.04), top - s(0.03)), Offset(cx - s(0.06), top + s(0.04)), stroke(darken(col, 0.15), 0.006));
        break;
      case HairStyle.spiky:
        c.drawPath(cap(depth: 0.33), paint);
        for (var i = 0; i < 6; i++) {
          final x = l + rect.width * (0.12 + i * 0.15);
          final spike = Path()
            ..moveTo(x - s(0.035), top + s(0.02))
            ..lineTo(x + s(0.005), top - s(0.075))
            ..lineTo(x + s(0.04), top + s(0.025))
            ..close();
          c.drawPath(spike, paint);
        }
        break;
      case HairStyle.mohawk:
        final p = Path()
          ..moveTo(cx - s(0.04), top + s(0.06))
          ..quadraticBezierTo(cx - s(0.03), top - s(0.12), cx, top - s(0.13))
          ..quadraticBezierTo(cx + s(0.03), top - s(0.12), cx + s(0.04), top + s(0.06))
          ..close();
        c.drawPath(cap(depth: 0.3), fill(col.withAlpha(90)));
        c.drawPath(p, paint);
        break;
      case HairStyle.curly:
        c.drawPath(cap(depth: 0.38), paint);
        final rnd = math.Random(9);
        for (var i = 0; i < 9; i++) {
          c.drawCircle(Offset(l + rect.width * (0.08 + i * 0.105), top + s(0.03 + rnd.nextDouble() * 0.03)), s(0.04), paint);
        }
        break;
      case HairStyle.afro:
        c.drawPath(cap(depth: 0.3), paint);
        break;
      case HairStyle.longWavy:
      case HairStyle.longStraight:
      case HairStyle.braids:
        final p = Path()
          ..moveTo(l - s(0.03), rect.top + rect.height * 0.65)
          ..quadraticBezierTo(l - s(0.03), top - s(0.035), cx, top - s(0.04))
          ..quadraticBezierTo(r + s(0.03), top - s(0.035), r + s(0.03), rect.top + rect.height * 0.65)
          ..quadraticBezierTo(r - s(0.02), top + s(0.12), r - s(0.06), top + s(0.08))
          ..quadraticBezierTo(cx + s(0.02), top + s(0.06), cx, top + s(0.04))
          ..quadraticBezierTo(cx - s(0.04), top + s(0.08), l + s(0.05), top + s(0.11))
          ..quadraticBezierTo(l + s(0.01), top + s(0.14), l - s(0.03), rect.top + rect.height * 0.65)
          ..close();
        c.drawPath(p, paint);
        if (config.hairStyle == HairStyle.braids) {
          c.drawLine(Offset(cx, top - s(0.035)), Offset(cx, top + s(0.04)), stroke(darken(col, 0.2), 0.006));
        }
        break;
      case HairStyle.ponytail:
      case HairStyle.bun:
        final p = Path()
          ..moveTo(l - s(0.01), rect.top + rect.height * 0.38)
          ..quadraticBezierTo(l - s(0.01), top - s(0.03), cx, top - s(0.035))
          ..quadraticBezierTo(r + s(0.01), top - s(0.03), r + s(0.01), rect.top + rect.height * 0.38)
          ..quadraticBezierTo(cx, top + s(0.02), l - s(0.01), rect.top + rect.height * 0.38)
          ..close();
        c.drawPath(p, paint);
        if (config.hairStyle == HairStyle.bun) {
          c.drawCircle(Offset(cx, top - s(0.06)), s(0.065), paint);
        } else {
          c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(r - s(0.01), rect.center.dy - s(0.07)), width: s(0.03), height: s(0.03)), Radius.circular(s(0.01))),
              fill(GamePalette.pink));
        }
        break;
      case HairStyle.bob:
        final p = Path()
          ..moveTo(l - s(0.035), rect.top + rect.height * 0.75)
          ..quadraticBezierTo(l - s(0.04), top - s(0.04), cx, top - s(0.04))
          ..quadraticBezierTo(r + s(0.04), top - s(0.04), r + s(0.035), rect.top + rect.height * 0.75)
          ..lineTo(r - s(0.01), rect.top + rect.height * 0.75)
          ..quadraticBezierTo(r - s(0.02), top + s(0.1), cx, top + s(0.1))
          ..quadraticBezierTo(l + s(0.02), top + s(0.1), l + s(0.01), rect.top + rect.height * 0.75)
          ..close();
        c.drawPath(p, paint);
        break;
      case HairStyle.pixie:
        final p = Path()
          ..moveTo(l - s(0.01), rect.top + rect.height * 0.45)
          ..quadraticBezierTo(l - s(0.02), top - s(0.035), cx, top - s(0.035))
          ..quadraticBezierTo(r + s(0.02), top - s(0.03), r + s(0.01), rect.top + rect.height * 0.35)
          ..quadraticBezierTo(cx + s(0.02), top + s(0.03), l + s(0.05), top + s(0.14))
          ..close();
        c.drawPath(p, paint);
        break;
      case HairStyle.dreads:
        c.drawPath(cap(depth: 0.34), paint);
        for (var i = 0; i < 7; i++) {
          final x = l + rect.width * (0.1 + i * 0.13);
          c.drawLine(Offset(x, top + s(0.02)), Offset(x + s(0.004), top + s(0.1)), stroke(darken(col, 0.05), 0.032));
        }
        break;
    }
  }

  // ------------------------------------------------------------------ acessórios
  void _accessories() {
    final rect = _headRect;
    final cx = rect.center.dx / w;
    final cy = rect.center.dy / w;
    final scale = headR / 0.215;
    final eyeY = cy + 0.005 * scale;
    final eyeDx = 0.075 * scale;

    if (config.has(AvatarAccessory.earrings) && !baby) {
      for (final dx in [-1.0, 1.0]) {
        final center = Offset(rect.center.dx + dx * rect.width * 0.49, rect.center.dy + rect.height * 0.12);
        c.drawCircle(center + Offset(0, s(0.03)), s(0.018), stroke(const Color(0xFFFFD36B), 0.008));
      }
    }
    if (config.has(AvatarAccessory.necklace) && !baby) {
      final top = headY + headR + 0.07;
      c.drawArc(Rect.fromCenter(center: o(0.5, top - 0.005), width: s(0.18), height: s(0.13)), 0.15, math.pi - 0.3, false, stroke(const Color(0xFFE5E7EB), 0.007));
      c.drawCircle(o(0.5, top + 0.06), s(0.014), fill(GamePalette.cyan));
    }
    if (config.has(AvatarAccessory.goldChain) && !baby) {
      final top = headY + headR + 0.07;
      c.drawArc(Rect.fromCenter(center: o(0.5, top), width: s(0.22), height: s(0.17)), 0.15, math.pi - 0.3, false, stroke(const Color(0xFFFFC53D), 0.018));
    }
    if (config.has(AvatarAccessory.glasses)) {
      final frame = stroke(const Color(0xFF1F2937), 0.011);
      for (final dx in [-1.0, 1.0]) {
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o(cx + dx * eyeDx, eyeY), width: s(0.085 * scale), height: s(0.065 * scale)), Radius.circular(s(0.02))), frame);
      }
      c.drawLine(o(cx - eyeDx + 0.043 * scale, eyeY), o(cx + eyeDx - 0.043 * scale, eyeY), frame);
    }
    if (config.has(AvatarAccessory.sunglasses)) {
      for (final dx in [-1.0, 1.0]) {
        final lens = RRect.fromRectAndRadius(Rect.fromCenter(center: o(cx + dx * eyeDx, eyeY + 0.003), width: s(0.095 * scale), height: s(0.07 * scale)), Radius.circular(s(0.025)));
        c.drawRRect(lens, fill(const Color(0xFF0F172A)));
        c.drawLine(lens.outerRect.topLeft + Offset(s(0.015), s(0.015)), lens.outerRect.topLeft + Offset(s(0.035), s(0.008)), stroke(Colors.white.withAlpha(120), 0.007));
      }
      c.drawLine(o(cx - eyeDx + 0.045 * scale, eyeY - 0.005), o(cx + eyeDx - 0.045 * scale, eyeY - 0.005), stroke(const Color(0xFF0F172A), 0.012));
    }
    final l = rect.left;
    final r = rect.right;
    final top = rect.top;
    final hcx = rect.center.dx;
    if (config.has(AvatarAccessory.cap)) {
      final color = hexColor(config.clothesColor);
      final dome = Path()
        ..moveTo(l - s(0.01), top + s(0.08))
        ..quadraticBezierTo(l, top - s(0.06), hcx, top - s(0.06))
        ..quadraticBezierTo(r, top - s(0.06), r + s(0.01), top + s(0.08))
        ..close();
      c.drawPath(dome, fill(darken(color, 0.05)));
      final brim = Path()
        ..moveTo(l - s(0.02), top + s(0.07))
        ..quadraticBezierTo(hcx - s(0.1), top + s(0.04), hcx + s(0.2), top + s(0.1))
        ..quadraticBezierTo(hcx, top + s(0.11), l - s(0.02), top + s(0.07));
      c.drawPath(brim, fill(darken(color, 0.2)));
      c.drawCircle(Offset(hcx, top - s(0.055)), s(0.012), fill(darken(color, 0.25)));
    }
    if (config.has(AvatarAccessory.beanie)) {
      final color = hexColor(config.clothesColor);
      final p = Path()
        ..moveTo(l - s(0.015), top + s(0.09))
        ..quadraticBezierTo(l - s(0.01), top - s(0.08), hcx, top - s(0.08))
        ..quadraticBezierTo(r + s(0.01), top - s(0.08), r + s(0.015), top + s(0.09))
        ..close();
      c.drawPath(p, fill(color));
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(l - s(0.025), top + s(0.04), r + s(0.025), top + s(0.11)), Radius.circular(s(0.03))), fill(darken(color, 0.12)));
      c.drawCircle(Offset(hcx, top - s(0.09)), s(0.035), fill(lighten(color, 0.2)));
    }
    if (config.has(AvatarAccessory.beret)) {
      c.drawOval(Rect.fromLTRB(l - s(0.02), top - s(0.06), r - s(0.02), top + s(0.06)), fill(const Color(0xFF991B1B)));
      c.drawLine(Offset(hcx - s(0.02), top - s(0.06)), Offset(hcx - s(0.01), top - s(0.09)), stroke(const Color(0xFF7F1D1D), 0.012));
    }
    if (config.has(AvatarAccessory.headband)) {
      c.drawArc(Rect.fromLTRB(l - s(0.005), top - s(0.01), r + s(0.005), top + rect.height * 0.7), math.pi * 1.08, math.pi * 0.84, false, stroke(GamePalette.pink, 0.028));
    }
    if (config.has(AvatarAccessory.headphones)) {
      c.drawArc(Rect.fromLTRB(l - s(0.04), top - s(0.05), r + s(0.04), top + rect.height * 0.9), math.pi * 1.02, math.pi * 0.96, false,
          stroke(const Color(0xFF1F2937), 0.03));
      for (final dx in [-1.0, 1.0]) {
        final center = Offset(rect.center.dx + dx * (rect.width * 0.5 + s(0.015)), rect.center.dy + s(0.01));
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: s(0.06), height: s(0.1)), Radius.circular(s(0.025))), fill(const Color(0xFF111827)));
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: s(0.03), height: s(0.06)), Radius.circular(s(0.015))), fill(GamePalette.violet));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) =>
      old.config.toJson() != config.toJson() || old.age != age || old.background != background;
}

/// Expressão do avatar conforme o estado emocional do personagem.
AvatarExpression expressionFor({required int happiness, required int health, required int stress}) {
  if (health < 25) return AvatarExpression.sick;
  if (stress > 82) return AvatarExpression.fear;
  if (happiness < 25) return AvatarExpression.sad;
  if (stress > 70) return AvatarExpression.angry;
  if (happiness > 88) return AvatarExpression.love;
  if (happiness > 55) return AvatarExpression.happy;
  return AvatarExpression.neutral;
}
