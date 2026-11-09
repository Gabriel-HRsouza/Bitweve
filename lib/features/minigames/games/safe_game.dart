import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/features/minigames/games/bluff_game.dart';
import 'package:bitweve/features/minigames/minigame_shell.dart';

/// "Cofre": o disco gira; trave quando a marca alinhar com o pino brilhante.
/// Cada erro aumenta o alarme; três erros disparam o alarme.
class SafeGame extends StatefulWidget {
  final int difficulty;
  final int seed;
  final MinigameFinish onFinish;
  const SafeGame({super.key, required this.difficulty, required this.seed, required this.onFinish});

  @override
  State<SafeGame> createState() => _SafeGameState();
}

class _SafeGameState extends State<SafeGame> with SingleTickerProviderStateMixin {
  late final Random _rng = Random(widget.seed + 77);
  late final Ticker _ticker;
  late final int _locks = 3 + (widget.difficulty >= 4 ? 1 : 0);
  late final double _total = 34.0 - widget.difficulty * 2;
  late double _timeLeft = _total;
  int _opened = 0;
  int _misses = 0;
  double _angle = 0;
  double _target = 0;
  double _dirSign = 1;
  Duration _last = Duration.zero;
  bool _over = false;
  int _score = 0;
  double _shake = 0;

  double get _tolerance => (0.30 - widget.difficulty * 0.035).clamp(0.12, 0.3);
  double get _speed => 1.6 + widget.difficulty * 0.35 + _opened * 0.3;

  @override
  void initState() {
    super.initState();
    _target = _rng.nextDouble() * pi * 2;
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    if (_over) return;
    final dt = _last == Duration.zero ? 0.0 : (now - _last).inMicroseconds / 1e6;
    _last = now;
    _angle = (_angle + dt * _speed * _dirSign) % (pi * 2);
    _timeLeft -= dt;
    _shake = (_shake - dt * 3).clamp(0, 1);
    if (_timeLeft <= 0) {
      _timeLeft = 0;
      _finish(false);
      return;
    }
    setState(() {});
  }

  double _diff(double a, double b) {
    var d = (a - b).abs() % (pi * 2);
    if (d > pi) d = pi * 2 - d;
    return d;
  }

  void _lock() {
    if (_over) return;
    final d = _diff(_angle, _target);
    if (d <= _tolerance) {
      _opened++;
      _score += 150 + ((1 - d / _tolerance) * 100).round();
      AudioService().playSfx(GameSfx.positiveEvent);
      if (_opened >= _locks) {
        _score += (_timeLeft * 8).round();
        _finish(true);
        return;
      }
      _target = _rng.nextDouble() * pi * 2;
      _dirSign = -_dirSign;
    } else {
      _misses++;
      _shake = 1;
      AudioService().playSfx(_misses >= 2 ? GameSfx.alarm : GameSfx.error);
      if (_misses >= 3) _finish(false);
    }
  }

  void _finish(bool win) {
    if (_over) return;
    _over = true;
    _ticker.stop();
    final perf = win ? 0.55 + 0.3 * (_timeLeft / _total) + 0.15 * (1 - _misses / 3) : 0.4 * _opened / _locks;
    setState(() {});
    widget.onFinish(win, perf, _score);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is KeyDownEvent && (e.logicalKey == LogicalKeyboardKey.space || e.logicalKey == LogicalKeyboardKey.enter)) {
          _lock();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _lock,
        child: Column(
          children: [
            GameHud(timeLeft: _timeLeft, timeTotal: _total, score: _score, extra: '🔓 $_opened/$_locks'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ALARME ', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w800, fontSize: 12)),
                  for (var i = 0; i < 3; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 26,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i < _misses ? GamePalette.red : Colors.white12,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, c) {
                final s = min(c.maxWidth, c.maxHeight) * 0.85;
                return Center(
                  child: Transform.translate(
                    offset: Offset(sin(_shake * 40) * 8 * _shake, 0),
                    child: CustomPaint(
                      size: Size.square(s),
                      painter: _DialPainter(angle: _angle, target: _target, tolerance: _tolerance, opened: _opened, locks: _locks),
                    ),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GameButton2(label: 'TRAVAR', onTap: _lock, color: const Color(0xFFEF4444)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double angle, target, tolerance;
  final int opened, locks;
  _DialPainter({required this.angle, required this.target, required this.tolerance, required this.opened, required this.locks});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    // Porta do cofre
    canvas.drawCircle(c, r, Paint()..shader = const RadialGradient(colors: [Color(0xFF475569), Color(0xFF1E293B)]).createShader(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(c, r, Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6);
    // Zona alvo
    final zone = Paint()
      ..color = GamePalette.gold.withAlpha(140)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.82), target - tolerance - pi / 2, tolerance * 2, false, zone);
    final pin = c + Offset(cos(target - pi / 2), sin(target - pi / 2)) * r * 0.82;
    canvas.drawCircle(pin, r * 0.07, Paint()..color = GamePalette.gold);
    canvas.drawCircle(pin, r * 0.12, Paint()..color = GamePalette.gold.withAlpha(70));
    // Marcações
    final tick = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2;
    for (var i = 0; i < 40; i++) {
      final a = i / 40 * pi * 2;
      final o = Offset(cos(a), sin(a));
      canvas.drawLine(c + o * r * 0.62, c + o * r * (i % 5 == 0 ? 0.52 : 0.57), tick);
    }
    // Disco
    canvas.drawCircle(c, r * 0.48, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(c, r * 0.48, Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4);
    final needleEnd = c + Offset(cos(angle - pi / 2), sin(angle - pi / 2)) * r * 0.78;
    canvas.drawLine(c, needleEnd, Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(c, r * 0.1, Paint()..color = const Color(0xFFCBD5E1));
    // Travas abertas
    for (var i = 0; i < locks; i++) {
      final x = c.dx + (i - (locks - 1) / 2) * r * 0.22;
      final p = Offset(x, c.dy + r * 0.3);
      canvas.drawCircle(p, r * 0.06, Paint()..color = i < opened ? GamePalette.green : Colors.white24);
    }
    final tp = TextPainter(
      text: TextSpan(text: '$opened/$locks', style: AppTheme.display(r * 0.12, color: Colors.white70)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c + Offset(-tp.width / 2, -r * 0.3));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
