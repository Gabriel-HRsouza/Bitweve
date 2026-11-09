import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bitweve/core/i18n/strings.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/shared/ui/motion.dart';

/// Paleta de cada fase da vida para a transição de aniversário.
List<Color> lifeStageColors(int age) {
  if (age <= 3) return const [Color(0xFFFFB4D1), Color(0xFF9B8CFF), Color(0xFF6EE7F9)];
  if (age <= 11) return const [Color(0xFFFFC53D), Color(0xFFFF8A3D), Color(0xFFFF4F9A)];
  if (age <= 17) return const [Color(0xFF22D3EE), Color(0xFF7C5CFF), Color(0xFFFF4F9A)];
  if (age <= 39) return const [Color(0xFF7C5CFF), Color(0xFF3B82F6), Color(0xFF22D3EE)];
  if (age <= 59) return const [Color(0xFF14B8A6), Color(0xFF3B82F6), Color(0xFF6366F1)];
  return const [Color(0xFFFFC53D), Color(0xFFF97316), Color(0xFFB45309)];
}

String lifeStageName(int age) {
  if (age <= 2) return 'BEBÊ';
  if (age <= 11) return 'INFÂNCIA';
  if (age <= 17) return 'ADOLESCÊNCIA';
  if (age <= 29) return 'JUVENTUDE';
  if (age <= 59) return 'VIDA ADULTA';
  return 'MATURIDADE';
}

Future<void> showAgeUpOverlay(
  BuildContext context, {
  required int age,
  required int year,
  required String headline,
  required String subtitle,
  required AvatarConfig avatar,
}) {
  final motion = context.motion;
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: Duration(milliseconds: motion ? 420 : 0),
    pageBuilder: (_, _, _) => _AgeUpOverlay(age: age, year: year, headline: headline, subtitle: subtitle, avatar: avatar),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(scale: Tween(begin: 1.08, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)), child: child),
    ),
  );
}

class _AgeUpOverlay extends StatefulWidget {
  final int age;
  final int year;
  final String headline;
  final String subtitle;
  final AvatarConfig avatar;
  const _AgeUpOverlay({required this.age, required this.year, required this.headline, required this.subtitle, required this.avatar});

  @override
  State<_AgeUpOverlay> createState() => _AgeUpOverlayState();
}

class _AgeUpOverlayState extends State<_AgeUpOverlay> with TickerProviderStateMixin {
  late final AnimationController _rays = AnimationController(vsync: this, duration: const Duration(seconds: 14));
  late final ConfettiController _confetti = ConfettiController(duration: const Duration(milliseconds: 700));
  bool _closing = false;
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final motion = context.motion;
      if (motion) {
        _rays.repeat();
        Future.delayed(const Duration(milliseconds: 650), () {
          if (mounted) _confetti.play();
        });
      }
      Future.delayed(Duration(milliseconds: motion ? 900 : 200), () {
        if (mounted) setState(() => _canSkip = true);
      });
      Future.delayed(Duration(milliseconds: motion ? 3400 : 2200), _close);
    });
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _rays.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = lifeStageColors(widget.age);
    final motion = context.motion;
    final size = MediaQuery.sizeOf(context);
    final avatarSize = math.min(size.width, size.height) * 0.36;

    Widget anim(Widget w, {int delay = 0, double dy = 0.2}) {
      if (!motion) return w;
      return w.animate(delay: delay.ms).fadeIn(duration: 450.ms).slideY(begin: dy, end: 0, duration: 520.ms, curve: Curves.easeOutCubic);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _canSkip ? _close : null,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors[0], colors[1], const Color(0xFF0B0D1A)],
                  stops: const [0, 0.55, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            if (motion)
              AnimatedBuilder(
                animation: _rays,
                builder: (_, _) => CustomPaint(painter: _RaysPainter(_rays.value * 2 * math.pi, colors[2])),
              ),
            Align(
              alignment: const Alignment(0, -0.75),
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 26,
                maxBlastForce: 28,
                minBlastForce: 10,
                gravity: 0.2,
                colors: [...colors, Colors.white],
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      anim(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(99)),
                          child: Text('${lifeStageName(widget.age)}  ·  ${tr('hub.year').toUpperCase()} ${widget.year}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AgeNumber(age: widget.age, motion: motion),
                      const SizedBox(height: 8),
                      anim(
                        AvatarWidget(config: widget.avatar, age: widget.age, size: avatarSize.clamp(120, 220), ringColor: Colors.white),
                        delay: 250,
                        dy: 0.1,
                      ),
                      const SizedBox(height: 22),
                      anim(
                        Text(widget.headline, textAlign: TextAlign.center,
                            style: AppTheme.display(30, color: Colors.white).copyWith(shadows: [
                              Shadow(color: Colors.black.withAlpha(90), blurRadius: 14),
                            ])),
                        delay: 450,
                      ),
                      const SizedBox(height: 10),
                      anim(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Text(widget.subtitle, textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withAlpha(230), fontSize: 16, height: 1.35, fontWeight: FontWeight.w500)),
                        ),
                        delay: 650,
                      ),
                      const SizedBox(height: 26),
                      AnimatedOpacity(
                        opacity: _canSkip ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(tr('age.tapContinue'),
                            style: TextStyle(color: Colors.white.withAlpha(170), fontSize: 13, letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeNumber extends StatelessWidget {
  final int age;
  final bool motion;
  const _AgeNumber({required this.age, required this.motion});

  @override
  Widget build(BuildContext context) {
    final style = AppTheme.display(96, color: Colors.white, weight: FontWeight.w700).copyWith(
      height: 1,
      shadows: [Shadow(color: Colors.white.withAlpha(150), blurRadius: 30), Shadow(color: Colors.black.withAlpha(80), blurRadius: 12, offset: const Offset(0, 6))],
    );
    if (!motion) return Text('$age', style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: (age - 1).toDouble(), end: age.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text('${v.round()}', style: style),
    )
        .animate()
        .scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1), duration: 650.ms, curve: Curves.elasticOut)
        .then(delay: 300.ms)
        .shimmer(duration: 1200.ms, color: Colors.white);
  }
}

class _RaysPainter extends CustomPainter {
  final double angle;
  final Color color;
  _RaysPainter(this.angle, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.36);
    final r = size.longestSide;
    final paint = Paint()
      ..shader = RadialGradient(colors: [Colors.white.withAlpha(46), Colors.white.withAlpha(0)])
          .createShader(Rect.fromCircle(center: center, radius: r * 0.7));
    const rays = 14;
    for (var i = 0; i < rays; i++) {
      final a = angle + i * 2 * math.pi / rays;
      final p = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + math.cos(a - 0.09) * r, center.dy + math.sin(a - 0.09) * r)
        ..lineTo(center.dx + math.cos(a + 0.09) * r, center.dy + math.sin(a + 0.09) * r)
        ..close();
      canvas.drawPath(p, paint);
    }
    canvas.drawCircle(center, size.shortestSide * 0.32, Paint()
      ..shader = RadialGradient(colors: [color.withAlpha(120), color.withAlpha(0)])
          .createShader(Rect.fromCircle(center: center, radius: size.shortestSide * 0.32)));
  }

  @override
  bool shouldRepaint(covariant _RaysPainter old) => old.angle != angle;
}
