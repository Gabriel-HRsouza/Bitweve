import 'package:flutter/material.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';

class AvatarWidget extends StatelessWidget {
  final AvatarConfig config;
  final double size;
  final bool animate;

  const AvatarWidget({
    super.key,
    required this.config,
    this.size = 80,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(int.parse(config.clothesColor.replaceAll('#', '0xFF')))
                    .withAlpha(50),
                const Color(0xFF1E293B),
              ],
            ),
          ),
          child: CustomPaint(
            size: Size(size, size),
            painter: _AvatarPainter(config: config),
          ),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  final AvatarConfig config;

  _AvatarPainter({required this.config});

  Color _parseHex(String hex, {int alpha = 255}) {
    final clean = hex.replaceAll('#', '');
    final val = int.parse(clean, radix: 16);
    return Color(val).withAlpha(alpha);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final skinBase = _parseHex(config.skinColor);
    final skin = config.expression == AvatarExpression.sick
        ? Color.lerp(skinBase, const Color(0xFF86EFAC), 0.35)!
        : skinBase;

    final hairColor = _parseHex(config.hairColor);
    final eyeColor = _parseHex(config.eyeColor);
    final clothesColor = _parseHex(config.clothesColor);

    // 1. Draw Clothes / Shoulders
    final clothesPaint = Paint()..color = clothesColor;
    final clothesPath = Path();
    clothesPath.moveTo(w * 0.1, h);
    clothesPath.quadraticBezierTo(w * 0.2, h * 0.72, w * 0.35, h * 0.75);
    clothesPath.lineTo(w * 0.65, h * 0.75);
    clothesPath.quadraticBezierTo(w * 0.8, h * 0.72, w * 0.9, h);
    clothesPath.close();
    canvas.drawPath(clothesPath, clothesPaint);

    // Collar / Shirt V-neck
    final collarPaint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;
    final collarPath = Path();
    collarPath.moveTo(w * 0.42, h * 0.75);
    collarPath.lineTo(w * 0.5, h * 0.83);
    collarPath.lineTo(w * 0.58, h * 0.75);
    canvas.drawPath(collarPath, collarPaint);

    // 2. Neck
    final neckPaint = Paint()..color = Color.lerp(skin, Colors.black, 0.15)!;
    final neckRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.68),
      width: w * 0.22,
      height: h * 0.2,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, Radius.circular(w * 0.05)), neckPaint);

    // 3. Ears
    final earPaint = Paint()..color = skin;
    canvas.drawCircle(Offset(w * 0.25, h * 0.48), w * 0.08, earPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.48), w * 0.08, earPaint);

    // 4. Head / Face Shape
    final headPaint = Paint()..color = skin;
    final headCenter = Offset(w / 2, h * 0.45);
    final headRadiusX = w * 0.27;
    double headRadiusY = h * 0.30;

    if (config.faceShape == FaceShape.round) {
      headRadiusY = h * 0.27;
    } else if (config.faceShape == FaceShape.square) {
      headRadiusY = h * 0.28;
    }

    final headRect = Rect.fromCenter(
      center: headCenter,
      width: headRadiusX * 2,
      height: headRadiusY * 2,
    );
    canvas.drawOval(headRect, headPaint);

    // 5. Beard (if applicable)
    if (config.hasBeard) {
      final beardPaint = Paint()..color = hairColor;
      final beardPath = Path();
      beardPath.moveTo(w * 0.32, h * 0.52);
      beardPath.quadraticBezierTo(w * 0.3, h * 0.74, w * 0.5, h * 0.76);
      beardPath.quadraticBezierTo(w * 0.7, h * 0.74, w * 0.68, h * 0.52);
      beardPath.quadraticBezierTo(w * 0.6, h * 0.65, w * 0.5, h * 0.65);
      beardPath.quadraticBezierTo(w * 0.4, h * 0.65, w * 0.32, h * 0.52);
      canvas.drawPath(beardPath, beardPaint);
    }

    // 6. Eyes & Eyebrows
    _drawEyesAndBrows(canvas, w, h, eyeColor, hairColor);

    // 7. Cheeks / Blush for Love or Happy
    if (config.expression == AvatarExpression.love || config.expression == AvatarExpression.happy) {
      final blushPaint = Paint()..color = const Color(0xFFF43F5E).withAlpha(80);
      canvas.drawCircle(Offset(w * 0.33, h * 0.52), w * 0.05, blushPaint);
      canvas.drawCircle(Offset(w * 0.67, h * 0.52), w * 0.05, blushPaint);
    }

    // 8. Nose
    final nosePaint = Paint()
      ..color = Color.lerp(skin, Colors.black, 0.2)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    final nosePath = Path();
    nosePath.moveTo(w * 0.5, h * 0.46);
    nosePath.lineTo(w * 0.48, h * 0.52);
    nosePath.lineTo(w * 0.53, h * 0.52);
    canvas.drawPath(nosePath, nosePaint);

    // 9. Mouth based on Expression
    _drawMouth(canvas, w, h);

    // 10. Glasses (if applicable)
    if (config.hasGlasses) {
      final glassesPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035;
      final lensPaint = Paint()
        ..color = Colors.cyan.withAlpha(30)
        ..style = PaintingStyle.fill;

      // Left lens
      final leftRect = Rect.fromCircle(center: Offset(w * 0.38, h * 0.44), radius: w * 0.1);
      canvas.drawRRect(RRect.fromRectAndRadius(leftRect, Radius.circular(w * 0.03)), lensPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(leftRect, Radius.circular(w * 0.03)), glassesPaint);

      // Right lens
      final rightRect = Rect.fromCircle(center: Offset(w * 0.62, h * 0.44), radius: w * 0.1);
      canvas.drawRRect(RRect.fromRectAndRadius(rightRect, Radius.circular(w * 0.03)), lensPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rightRect, Radius.circular(w * 0.03)), glassesPaint);

      // Bridge
      canvas.drawLine(Offset(w * 0.48, h * 0.44), Offset(w * 0.52, h * 0.44), glassesPaint);
    }

    // 11. Hair Styles
    _drawHair(canvas, w, h, hairColor);

    // 12. Special Expression Overlays (Sweat drop for fear, tear for sad, hearts for love)
    _drawExpressionExtras(canvas, w, h);
  }

  void _drawEyesAndBrows(Canvas canvas, double w, double h, Color eyeColor, Color hairColor) {
    final browPaint = Paint()
      ..color = hairColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;

    final leftEyeCenter = Offset(w * 0.38, h * 0.44);
    final rightEyeCenter = Offset(w * 0.62, h * 0.44);

    // Eyebrows by Expression
    if (config.expression == AvatarExpression.angry) {
      // Slanted inward down
      canvas.drawLine(Offset(w * 0.28, h * 0.36), Offset(w * 0.44, h * 0.39), browPaint);
      canvas.drawLine(Offset(w * 0.72, h * 0.36), Offset(w * 0.56, h * 0.39), browPaint);
    } else if (config.expression == AvatarExpression.sad || config.expression == AvatarExpression.fear) {
      // Slanted inward up
      canvas.drawLine(Offset(w * 0.28, h * 0.39), Offset(w * 0.44, h * 0.36), browPaint);
      canvas.drawLine(Offset(w * 0.72, h * 0.39), Offset(w * 0.56, h * 0.36), browPaint);
    } else if (config.expression == AvatarExpression.surprised) {
      // Arched high
      canvas.drawLine(Offset(w * 0.29, h * 0.34), Offset(w * 0.44, h * 0.34), browPaint);
      canvas.drawLine(Offset(w * 0.71, h * 0.34), Offset(w * 0.56, h * 0.34), browPaint);
    } else {
      // Normal gentle curve
      canvas.drawLine(Offset(w * 0.30, h * 0.37), Offset(w * 0.44, h * 0.37), browPaint);
      canvas.drawLine(Offset(w * 0.70, h * 0.37), Offset(w * 0.56, h * 0.37), browPaint);
    }

    // Eyes
    if (config.expression == AvatarExpression.love) {
      // Heart eyes!
      _drawHeart(canvas, leftEyeCenter, w * 0.05, const Color(0xFFEF4444));
      _drawHeart(canvas, rightEyeCenter, w * 0.05, const Color(0xFFEF4444));
    } else {
      // Sclera
      final scleraPaint = Paint()..color = Colors.white;
      final eyeRadius = config.expression == AvatarExpression.surprised || config.expression == AvatarExpression.fear
          ? w * 0.055
          : w * 0.045;
      canvas.drawCircle(leftEyeCenter, eyeRadius, scleraPaint);
      canvas.drawCircle(rightEyeCenter, eyeRadius, scleraPaint);

      // Iris
      final irisPaint = Paint()..color = eyeColor;
      final irisRadius = eyeRadius * 0.65;
      canvas.drawCircle(leftEyeCenter, irisRadius, irisPaint);
      canvas.drawCircle(rightEyeCenter, irisRadius, irisPaint);

      // Pupil
      final pupilPaint = Paint()..color = const Color(0xFF0F172A);
      final pupilRadius = irisRadius * 0.5;
      canvas.drawCircle(leftEyeCenter, pupilRadius, pupilPaint);
      canvas.drawCircle(rightEyeCenter, pupilRadius, pupilPaint);

      // Sparkle
      final shinePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(leftEyeCenter.dx - pupilRadius * 0.4, leftEyeCenter.dy - pupilRadius * 0.4), pupilRadius * 0.4, shinePaint);
      canvas.drawCircle(Offset(rightEyeCenter.dx - pupilRadius * 0.4, rightEyeCenter.dy - pupilRadius * 0.4), pupilRadius * 0.4, shinePaint);
    }
  }

  void _drawMouth(Canvas canvas, double w, double h) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF881337)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF4C0519)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;

    final mouthCenter = Offset(w * 0.5, h * 0.59);

    switch (config.expression) {
      case AvatarExpression.happy:
      case AvatarExpression.love:
        final path = Path();
        path.moveTo(w * 0.42, h * 0.57);
        path.quadraticBezierTo(w * 0.5, h * 0.65, w * 0.58, h * 0.57);
        path.close();
        canvas.drawPath(path, mouthPaint);
        break;

      case AvatarExpression.sad:
        final path = Path();
        path.moveTo(w * 0.42, h * 0.62);
        path.quadraticBezierTo(w * 0.5, h * 0.56, w * 0.58, h * 0.62);
        canvas.drawPath(path, strokePaint);
        break;

      case AvatarExpression.angry:
        final path = Path();
        path.moveTo(w * 0.42, h * 0.60);
        path.lineTo(w * 0.58, h * 0.59);
        canvas.drawPath(path, strokePaint);
        break;

      case AvatarExpression.surprised:
        canvas.drawCircle(mouthCenter, w * 0.045, mouthPaint);
        break;

      case AvatarExpression.sick:
        final path = Path();
        path.moveTo(w * 0.42, h * 0.60);
        path.quadraticBezierTo(w * 0.46, h * 0.57, w * 0.50, h * 0.60);
        path.quadraticBezierTo(w * 0.54, h * 0.63, w * 0.58, h * 0.60);
        canvas.drawPath(path, strokePaint);
        break;

      case AvatarExpression.fear:
        final path = Path();
        path.moveTo(w * 0.44, h * 0.61);
        path.quadraticBezierTo(w * 0.5, h * 0.57, w * 0.56, h * 0.61);
        canvas.drawPath(path, strokePaint);
        break;
    }
  }

  void _drawHair(Canvas canvas, double w, double h, Color hairColor) {
    if (config.hairStyle == HairStyle.bald) return;

    final hairPaint = Paint()..color = hairColor;

    switch (config.hairStyle) {
      case HairStyle.short:
        final path = Path();
        path.moveTo(w * 0.22, h * 0.42);
        path.quadraticBezierTo(w * 0.20, h * 0.16, w * 0.50, h * 0.16);
        path.quadraticBezierTo(w * 0.80, h * 0.16, w * 0.78, h * 0.42);
        path.quadraticBezierTo(w * 0.68, h * 0.28, w * 0.50, h * 0.28);
        path.quadraticBezierTo(w * 0.32, h * 0.28, w * 0.22, h * 0.42);
        canvas.drawPath(path, hairPaint);
        break;

      case HairStyle.buzz:
        final path = Path();
        path.moveTo(w * 0.24, h * 0.40);
        path.quadraticBezierTo(w * 0.22, h * 0.22, w * 0.50, h * 0.22);
        path.quadraticBezierTo(w * 0.78, h * 0.22, w * 0.76, h * 0.40);
        path.quadraticBezierTo(w * 0.50, h * 0.30, w * 0.24, h * 0.40);
        canvas.drawPath(path, hairPaint);
        break;

      case HairStyle.longWavy:
        final path = Path();
        // Top hair
        path.moveTo(w * 0.22, h * 0.45);
        path.quadraticBezierTo(w * 0.18, h * 0.14, w * 0.50, h * 0.14);
        path.quadraticBezierTo(w * 0.82, h * 0.14, w * 0.78, h * 0.45);
        // Left wave falling down
        path.quadraticBezierTo(w * 0.85, h * 0.75, w * 0.75, h * 0.85);
        path.quadraticBezierTo(w * 0.68, h * 0.65, w * 0.68, h * 0.45);
        // Forehead
        path.quadraticBezierTo(w * 0.50, h * 0.26, w * 0.32, h * 0.45);
        // Right wave
        path.quadraticBezierTo(w * 0.32, h * 0.65, w * 0.25, h * 0.85);
        path.quadraticBezierTo(w * 0.15, h * 0.75, w * 0.22, h * 0.45);
        canvas.drawPath(path, hairPaint);
        break;

      case HairStyle.curly:
        // Cloud-like curls
        final curlCenters = [
          Offset(w * 0.25, h * 0.30),
          Offset(w * 0.35, h * 0.20),
          Offset(w * 0.50, h * 0.17),
          Offset(w * 0.65, h * 0.20),
          Offset(w * 0.75, h * 0.30),
          Offset(w * 0.22, h * 0.42),
          Offset(w * 0.78, h * 0.42),
        ];
        for (final c in curlCenters) {
          canvas.drawCircle(c, w * 0.13, hairPaint);
        }
        break;

      case HairStyle.afro:
        canvas.drawCircle(Offset(w * 0.5, h * 0.35), w * 0.36, hairPaint);
        break;

      case HairStyle.ponytail:
        // Top and side
        final path = Path();
        path.moveTo(w * 0.24, h * 0.42);
        path.quadraticBezierTo(w * 0.20, h * 0.18, w * 0.50, h * 0.18);
        path.quadraticBezierTo(w * 0.80, h * 0.18, w * 0.76, h * 0.42);
        path.quadraticBezierTo(w * 0.50, h * 0.28, w * 0.24, h * 0.42);
        canvas.drawPath(path, hairPaint);
        // High ponytail puff
        canvas.drawCircle(Offset(w * 0.76, h * 0.20), w * 0.14, hairPaint);
        break;

      case HairStyle.sidePart:
        final path = Path();
        path.moveTo(w * 0.20, h * 0.42);
        path.quadraticBezierTo(w * 0.24, h * 0.16, w * 0.55, h * 0.16);
        path.quadraticBezierTo(w * 0.82, h * 0.18, w * 0.78, h * 0.42);
        path.lineTo(w * 0.65, h * 0.30);
        path.quadraticBezierTo(w * 0.38, h * 0.24, w * 0.20, h * 0.42);
        canvas.drawPath(path, hairPaint);
        break;

      default:
        break;
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.5);
    path.cubicTo(
      center.dx - size,
      center.dy - size * 0.2,
      center.dx - size * 0.8,
      center.dy - size * 0.8,
      center.dx,
      center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.8,
      center.dy - size * 0.8,
      center.dx + size,
      center.dy - size * 0.2,
      center.dx,
      center.dy + size * 0.5,
    );
    canvas.drawPath(path, paint);
  }

  void _drawExpressionExtras(Canvas canvas, double w, double h) {
    if (config.expression == AvatarExpression.fear) {
      // Sweat drop near temple
      final dropPaint = Paint()..color = const Color(0xFF38BDF8);
      canvas.drawCircle(Offset(w * 0.78, h * 0.38), w * 0.035, dropPaint);
    } else if (config.expression == AvatarExpression.sad) {
      // Tear drop
      final tearPaint = Paint()..color = const Color(0xFF60A5FA);
      canvas.drawCircle(Offset(w * 0.64, h * 0.50), w * 0.03, tearPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) {
    return oldDelegate.config != config;
  }
}
