import 'dart:math';

import 'package:flutter/material.dart';

/// Ilustrações procedurais do BitWeve (vetoriais, sem assets de terceiros).
/// Cada loja, imóvel e foto recebe uma imagem coerente com seu conteúdo.

// =============================================================================
// Fachada de loja
// =============================================================================
class StoreFrontArt extends StatelessWidget {
  final String name;
  final IconData icon;
  final List<Color> colors;
  final int awning;
  final int seed;
  final double height;
  final int difficulty;

  const StoreFrontArt({
    super.key,
    required this.name,
    required this.icon,
    required this.colors,
    this.awning = 0,
    this.seed = 0,
    this.height = 120,
    this.difficulty = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _StorePainter(colors: colors, awning: awning, seed: seed, difficulty: difficulty),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: height * 0.08,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.first.withAlpha(200)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, size: height * 0.11, color: colors.first),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Text(name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: height * 0.085, letterSpacing: 0.8)),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorePainter extends CustomPainter {
  final List<Color> colors;
  final int awning;
  final int seed;
  final int difficulty;
  _StorePainter({required this.colors, required this.awning, required this.seed, required this.difficulty});

  @override
  void paint(Canvas canvas, Size s) {
    final rng = Random(seed);
    // Céu noturno
    canvas.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(colors: [const Color(0xFF0F172A), colors.last.withAlpha(200)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Offset.zero & s));
    for (var i = 0; i < 12; i++) {
      canvas.drawCircle(Offset(rng.nextDouble() * s.width, rng.nextDouble() * s.height * 0.25), 0.8 + rng.nextDouble(), Paint()..color = Colors.white54);
    }
    // Prédio
    final b = Rect.fromLTWH(s.width * 0.06, s.height * 0.05, s.width * 0.88, s.height * 0.95);
    canvas.drawRect(b, Paint()..color = Color.lerp(colors.last, Colors.black, 0.35)!);
    // Toldo listrado
    final awTop = s.height * 0.32, awH = s.height * 0.12;
    final stripes = 10 + awning * 2;
    for (var i = 0; i < stripes; i++) {
      final x = b.left + b.width * i / stripes;
      canvas.drawRect(Rect.fromLTWH(x, awTop, b.width / stripes + 0.5, awH), Paint()..color = i.isEven ? colors.first : Colors.white);
    }
    final scallop = Paint()..color = colors.first;
    for (var i = 0; i < stripes; i++) {
      final x = b.left + b.width * (i + 0.5) / stripes;
      canvas.drawCircle(Offset(x, awTop + awH), b.width / stripes / 2, scallop);
    }
    // Vitrine
    final win = Rect.fromLTWH(b.left + b.width * 0.05, awTop + awH + s.height * 0.08, b.width * 0.55, s.height * 0.4);
    canvas.drawRect(win, Paint()..color = const Color(0xFFFDE68A).withAlpha(200));
    for (var i = 0; i < 4; i++) {
      final px = win.left + win.width * (0.12 + i * 0.22);
      final h = win.height * (0.25 + rng.nextDouble() * 0.35);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px, win.bottom - h - 4, win.width * 0.14, h), const Radius.circular(3)),
          Paint()..color = HSVColor.fromAHSV(1, rng.nextDouble() * 360, 0.6, 0.85).toColor());
    }
    canvas.drawRect(win, Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    // Porta
    final door = Rect.fromLTWH(b.left + b.width * 0.68, awTop + awH + s.height * 0.06, b.width * 0.24, s.height * 0.48);
    canvas.drawRect(door, Paint()..color = const Color(0xFF93C5FD).withAlpha(180));
    canvas.drawLine(Offset(door.center.dx, door.top), Offset(door.center.dx, door.bottom), Paint()
      ..color = Colors.white70
      ..strokeWidth = 2);
    // Câmeras conforme dificuldade
    for (var i = 0; i < difficulty.clamp(1, 5); i++) {
      final cx = b.left + 10 + i * 14.0;
      canvas.drawRect(Rect.fromLTWH(cx, awTop - 10, 9, 6), Paint()..color = Colors.white70);
      canvas.drawCircle(Offset(cx + 2, awTop - 7), 1.6, Paint()..color = Colors.redAccent);
    }
    // Calçada
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.93, s.width, s.height * 0.07), Paint()..color = const Color(0xFF334155));
  }

  @override
  bool shouldRepaint(covariant _StorePainter old) => old.seed != seed || old.colors != colors;
}

// =============================================================================
// Imóveis
// =============================================================================
class BuildingArt extends StatelessWidget {
  final String type;
  final List<Color> colors;
  final double height;
  final int decor;
  final String? badge;

  const BuildingArt({super.key, required this.type, required this.colors, this.height = 130, this.decor = 0, this.badge});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _BuildingPainter(type: type, colors: colors, decor: decor))),
          if (badge != null)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.black.withAlpha(150), borderRadius: BorderRadius.circular(99)),
                child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ),
        ]),
      ),
    );
  }
}

class _BuildingPainter extends CustomPainter {
  final String type;
  final List<Color> colors;
  final int decor;
  _BuildingPainter({required this.type, required this.colors, required this.decor});

  void _windows(Canvas c, Rect r, int cols, int rows, Color lit) {
    final gw = r.width / (cols * 2 + 1), gh = r.height / (rows * 2 + 1);
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        c.drawRect(Rect.fromLTWH(r.left + gw * (x * 2 + 1), r.top + gh * (y * 2 + 1), gw, gh),
            Paint()..color = (x + y) % 3 == 0 ? lit : lit.withAlpha(120));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size s) {
    final sky = type == 'beach_house' ? [const Color(0xFF38BDF8), const Color(0xFFFDE68A)] : [colors.first.withAlpha(220), const Color(0xFFE0F2FE)];
    canvas.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(colors: sky, begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Offset.zero & s));
    canvas.drawCircle(Offset(s.width * 0.85, s.height * 0.2), s.height * 0.1, Paint()..color = const Color(0xFFFDE047));
    final ground = type == 'beach_house' ? const Color(0xFFFCD34D) : (type == 'farm' ? const Color(0xFF65A30D) : const Color(0xFF4ADE80));
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.8, s.width, s.height * 0.2), Paint()..color = ground);
    final body = Color.lerp(colors.last, Colors.white, 0.25)!;
    final roof = Color.lerp(colors.last, Colors.black, 0.3)!;
    const lit = Color(0xFFFEF3C7);
    final w = s.width, h = s.height;
    switch (type) {
      case 'apartment':
      case 'studio':
      case 'penthouse':
        for (var i = 0; i < 3; i++) {
          final bw = w * 0.2, bh = h * (0.45 + i * 0.12) + (type == 'penthouse' && i == 1 ? h * 0.1 : 0);
          final r = Rect.fromLTWH(w * (0.15 + i * 0.25), h * 0.8 - bh, bw, bh);
          canvas.drawRect(r, Paint()..color = i == 1 ? body : body.withAlpha(180));
          _windows(canvas, r, 2, (bh / 14).floor().clamp(3, 8), lit);
          if (type == 'penthouse' && i == 1) {
            canvas.drawRect(Rect.fromLTWH(r.left - 4, r.top - 8, r.width + 8, 8), Paint()..color = const Color(0xFF7DD3FC));
          }
        }
      case 'mansion':
      case 'castle':
        final r = Rect.fromLTWH(w * 0.12, h * 0.42, w * 0.76, h * 0.38);
        canvas.drawRect(r, Paint()..color = body);
        _windows(canvas, r, 6, 2, lit);
        if (type == 'castle') {
          for (final x in [0.1, 0.8]) {
            final t = Rect.fromLTWH(w * x, h * 0.2, w * 0.12, h * 0.6);
            canvas.drawRect(t, Paint()..color = body);
            final p = Path()
              ..moveTo(t.left - 4, t.top)
              ..lineTo(t.center.dx, t.top - h * 0.14)
              ..lineTo(t.right + 4, t.top)
              ..close();
            canvas.drawPath(p, Paint()..color = roof);
          }
        } else {
          final p = Path()
            ..moveTo(r.left - 8, r.top)
            ..lineTo(w * 0.5, h * 0.2)
            ..lineTo(r.right + 8, r.top)
            ..close();
          canvas.drawPath(p, Paint()..color = roof);
          for (var i = 0; i < 4; i++) {
            canvas.drawRect(Rect.fromLTWH(r.left + r.width * (0.2 + i * 0.2), r.top, 5, r.height), Paint()..color = Colors.white);
          }
          canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.84, w * 0.3, h * 0.08), Paint()..color = const Color(0xFF38BDF8));
        }
      case 'commercial':
      case 'warehouse':
      case 'store':
        final tall = type == 'commercial';
        final r = Rect.fromLTWH(w * 0.2, tall ? h * 0.1 : h * 0.45, w * 0.6, tall ? h * 0.7 : h * 0.35);
        canvas.drawRect(r, Paint()..color = type == 'warehouse' ? const Color(0xFFA8A29E) : body);
        if (type == 'warehouse') {
          for (var i = 0; i < 6; i++) {
            canvas.drawLine(Offset(r.left, r.top + i * r.height / 6), Offset(r.right, r.top + i * r.height / 6), Paint()
              ..color = Colors.black26
              ..strokeWidth = 2);
          }
          canvas.drawRect(Rect.fromLTWH(r.center.dx - 18, r.bottom - 30, 36, 30), Paint()..color = const Color(0xFF57534E));
        } else {
          _windows(canvas, r, tall ? 4 : 3, tall ? 9 : 2, const Color(0xFF93C5FD));
          if (type == 'store') {
            canvas.drawRect(Rect.fromLTWH(r.left, r.top - 10, r.width, 10), Paint()..color = colors.first);
          }
        }
      case 'farm':
        final r = Rect.fromLTWH(w * 0.15, h * 0.5, w * 0.35, h * 0.3);
        canvas.drawRect(r, Paint()..color = const Color(0xFFB91C1C));
        final p = Path()
          ..moveTo(r.left - 6, r.top)
          ..lineTo(r.center.dx, r.top - h * 0.16)
          ..lineTo(r.right + 6, r.top)
          ..close();
        canvas.drawPath(p, Paint()..color = const Color(0xFF7F1D1D));
        canvas.drawRect(Rect.fromLTWH(r.center.dx - 10, r.bottom - 22, 20, 22), Paint()..color = Colors.white);
        for (var i = 0; i < 5; i++) {
          canvas.drawCircle(Offset(w * (0.6 + i * 0.08), h * 0.74), 10, Paint()..color = const Color(0xFF166534));
        }
      case 'school':
      case 'university':
        final uni = type == 'university';
        final r = Rect.fromLTWH(w * 0.08, h * (uni ? 0.38 : 0.45), w * 0.84, h * (uni ? 0.42 : 0.35));
        canvas.drawRect(r, Paint()..color = uni ? const Color(0xFFE7E5E4) : const Color(0xFFFDE68A));
        _windows(canvas, r, 7, 2, const Color(0xFF93C5FD));
        if (uni) {
          // frontão e colunas
          final p = Path()
            ..moveTo(w * 0.3, r.top)
            ..lineTo(w * 0.5, h * 0.18)
            ..lineTo(w * 0.7, r.top)
            ..close();
          canvas.drawPath(p, Paint()..color = const Color(0xFFD6D3D1));
          for (var i = 0; i < 5; i++) {
            canvas.drawRect(Rect.fromLTWH(w * (0.32 + i * 0.085), r.top, 6, r.height), Paint()..color = Colors.white);
          }
        } else {
          final c = Offset(w * 0.5, r.top - h * 0.08);
          canvas.drawRect(Rect.fromCenter(center: c, width: w * 0.16, height: h * 0.18), Paint()..color = const Color(0xFFF59E0B));
          canvas.drawCircle(c, h * 0.055, Paint()..color = Colors.white);
          canvas.drawLine(c, c + Offset(0, -h * 0.04), Paint()
            ..color = Colors.black
            ..strokeWidth = 2);
          canvas.drawLine(c, c + Offset(h * 0.03, 0), Paint()
            ..color = Colors.black
            ..strokeWidth = 2);
        }
        canvas.drawLine(Offset(w * 0.9, r.top), Offset(w * 0.9, h * 0.12), Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 3);
        canvas.drawRect(Rect.fromLTWH(w * 0.9, h * 0.12, w * 0.07, h * 0.06), Paint()..color = colors.first);
        canvas.drawRect(Rect.fromLTWH(r.center.dx - 14, r.bottom - 26, 28, 26), Paint()..color = const Color(0xFF7C2D12));
      default: // house, beach_house
        final r = Rect.fromLTWH(w * 0.25, h * 0.48, w * 0.5, h * 0.32);
        canvas.drawRect(r, Paint()..color = body);
        final p = Path()
          ..moveTo(r.left - 10, r.top)
          ..lineTo(r.center.dx, r.top - h * 0.2)
          ..lineTo(r.right + 10, r.top)
          ..close();
        canvas.drawPath(p, Paint()..color = roof);
        canvas.drawRect(Rect.fromLTWH(r.center.dx - 10, r.bottom - 26, 20, 26), Paint()..color = const Color(0xFF78350F));
        _windows(canvas, Rect.fromLTWH(r.left, r.top, r.width, r.height * 0.6), 3, 1, lit);
        if (type == 'beach_house') {
          canvas.drawRect(Rect.fromLTWH(0, h * 0.9, w, h * 0.1), Paint()..color = const Color(0xFF0EA5E9));
          canvas.drawLine(Offset(w * 0.12, h * 0.8), Offset(w * 0.15, h * 0.45), Paint()
            ..color = const Color(0xFF78350F)
            ..strokeWidth = 4);
          canvas.drawCircle(Offset(w * 0.15, h * 0.45), 14, Paint()..color = const Color(0xFF16A34A));
        } else {
          canvas.drawCircle(Offset(w * 0.12, h * 0.68), 16, Paint()..color = const Color(0xFF16A34A));
        }
    }
    // Estrelas de decoração
    for (var i = 0; i < decor.clamp(0, 5); i++) {
      _star(canvas, Offset(14.0 + i * 16, s.height - 14), 6, const Color(0xFFFFC53D));
    }
  }

  void _star(Canvas c, Offset o, double r, Color color) {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final rr = i.isEven ? r : r * 0.45;
      final a = -pi / 2 + i * pi / 5;
      final pt = o + Offset(cos(a), sin(a)) * rr;
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    p.close();
    c.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BuildingPainter old) => old.type != type || old.decor != decor;
}

// =============================================================================
// "Foto" de publicação
// =============================================================================
class PhotoArt extends StatelessWidget {
  final IconData motif;
  final List<Color> colors;
  final int seed;
  final double? height;
  final double radius;

  const PhotoArt({super.key, required this.motif, required this.colors, this.seed = 0, this.height, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        child: LayoutBuilder(builder: (context, c) {
          final size = c.maxHeight.isFinite ? c.maxHeight : c.maxWidth;
          return Stack(fit: StackFit.expand, children: [
            CustomPaint(painter: _PhotoPainter(colors: colors, seed: seed)),
            Center(
              child: Icon(motif, size: size * 0.42, color: Colors.white, shadows: const [Shadow(color: Colors.black38, blurRadius: 12)]),
            ),
          ]);
        }),
      ),
    );
  }
}

class _PhotoPainter extends CustomPainter {
  final List<Color> colors;
  final int seed;
  _PhotoPainter({required this.colors, required this.seed});

  @override
  void paint(Canvas canvas, Size s) {
    final rng = Random(seed);
    final a = Alignment(rng.nextDouble() * 2 - 1, -1);
    canvas.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(colors: colors, begin: a, end: -a).createShader(Offset.zero & s));
    for (var i = 0; i < 7; i++) {
      final c = Offset(rng.nextDouble() * s.width, rng.nextDouble() * s.height);
      canvas.drawCircle(c, s.shortestSide * (0.08 + rng.nextDouble() * 0.25), Paint()..color = Colors.white.withAlpha(18 + rng.nextInt(30)));
    }
    // horizonte
    final path = Path()..moveTo(0, s.height * 0.78);
    for (var x = 0.0; x <= s.width; x += s.width / 8) {
      path.lineTo(x, s.height * (0.7 + rng.nextDouble() * 0.12));
    }
    path
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black.withAlpha(50));
  }

  @override
  bool shouldRepaint(covariant _PhotoPainter old) => old.seed != seed || old.colors != colors;
}
