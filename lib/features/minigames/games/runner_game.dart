import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/features/minigames/minigame_shell.dart';

/// "Fuga": dirija pelas 3 pistas, desvie dos bloqueios e pegue maletas.
class RunnerGame extends StatefulWidget {
  final int difficulty;
  final int seed;
  final MinigameFinish onFinish;
  const RunnerGame({super.key, required this.difficulty, required this.seed, required this.onFinish});

  @override
  State<RunnerGame> createState() => _RunnerGameState();
}

class _Obj {
  int lane;
  double y; // 0 topo .. 1 base
  final bool bonus;
  bool hit = false;
  _Obj(this.lane, this.y, this.bonus);
}

class _RunnerGameState extends State<RunnerGame> with SingleTickerProviderStateMixin {
  late final Random _rng = Random(widget.seed + 99);
  late final Ticker _ticker;
  final double _total = 28;
  late double _timeLeft = _total;
  int _lane = 1;
  double _laneAnim = 1;
  late int _lives = widget.difficulty >= 4 ? 2 : 3;
  final List<_Obj> _objs = [];
  double _spawn = 0;
  double _road = 0;
  Duration _last = Duration.zero;
  int _score = 0;
  int _bags = 0;
  int _bagsSpawned = 0;
  bool _over = false;
  double _hurt = 0;

  double get _speed => 0.42 + widget.difficulty * 0.08 + (_total - _timeLeft) * 0.008;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    if (_over) return;
    final dt = _last == Duration.zero ? 0.0 : (now - _last).inMicroseconds / 1e6;
    _last = now;
    _timeLeft -= dt;
    _hurt = (_hurt - dt * 2).clamp(0, 1);
    _laneAnim += (_lane - _laneAnim) * min(1, dt * 14);
    _road = (_road + dt * _speed * 3) % 1;
    _spawn -= dt;
    if (_spawn <= 0) {
      _spawn = (0.95 - widget.difficulty * 0.1).clamp(0.4, 1.0) * (0.7 + _rng.nextDouble() * 0.6);
      final bonus = _rng.nextDouble() < 0.3;
      if (bonus) _bagsSpawned++;
      _objs.add(_Obj(_rng.nextInt(3), -0.1, bonus));
      if (!bonus && widget.difficulty >= 3 && _rng.nextDouble() < 0.35) {
        _objs.add(_Obj((_objs.last.lane + 1 + _rng.nextInt(2)) % 3, -0.1, false));
      }
    }
    for (final o in _objs) {
      o.y += dt * _speed;
      if (!o.hit && o.y > 0.78 && o.y < 0.92 && o.lane == _lane) {
        o.hit = true;
        if (o.bonus) {
          _bags++;
          _score += 80;
          AudioService().playSfx(GameSfx.pickup);
        } else {
          _lives--;
          _hurt = 1;
          AudioService().playSfx(GameSfx.error);
          if (_lives <= 0) {
            _finish(false);
            return;
          }
        }
      }
    }
    _objs.removeWhere((o) => o.y > 1.1 || (o.hit && o.bonus));
    _score += (dt * 10).round();
    if (_timeLeft <= 0) {
      _timeLeft = 0;
      _finish(true);
      return;
    }
    setState(() {});
  }

  void _finish(bool win) {
    if (_over) return;
    _over = true;
    _ticker.stop();
    final survived = 1 - _timeLeft / _total;
    final bagRatio = _bagsSpawned == 0 ? 0.5 : _bags / _bagsSpawned;
    final perf = win ? 0.5 + 0.3 * bagRatio + 0.2 * (_lives / 3) : 0.4 * survived;
    setState(() {});
    widget.onFinish(win, perf, _score);
  }

  void _move(int d) {
    _lane = (_lane + d).clamp(0, 2);
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
        if (e is! KeyDownEvent) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.arrowLeft || e.logicalKey == LogicalKeyboardKey.keyA) {
          _move(-1);
          return KeyEventResult.handled;
        }
        if (e.logicalKey == LogicalKeyboardKey.arrowRight || e.logicalKey == LogicalKeyboardKey.keyD) {
          _move(1);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
          GameHud(timeLeft: _timeLeft, timeTotal: _total, score: _score, extra: '${'❤' * _lives} 💼$_bags'),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final w = min(c.maxWidth, 460.0);
              return Center(
                child: GestureDetector(
                  onHorizontalDragEnd: (d) {
                    final v = d.primaryVelocity ?? 0;
                    if (v.abs() > 80) _move(v > 0 ? 1 : -1);
                  },
                  onTapDown: (d) => _move(d.localPosition.dx < w / 2 ? -1 : 1),
                  child: SizedBox(
                    width: w,
                    height: c.maxHeight,
                    child: CustomPaint(
                      painter: _RoadPainter(objs: _objs, lane: _laneAnim, road: _road, hurt: _hurt),
                    ),
                  ),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PadButton(icon: Icons.chevron_left_rounded, onTap: () => _move(-1), size: 66),
                PadButton(icon: Icons.chevron_right_rounded, onTap: () => _move(1), size: 66),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  final List<_Obj> objs;
  final double lane;
  final double road;
  final double hurt;
  _RoadPainter({required this.objs, required this.lane, required this.road, required this.hurt});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final laneW = w / 3;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)), Paint()..color = const Color(0xFF1F2937));
    final dash = Paint()
      ..color = Colors.white54
      ..strokeWidth = 4;
    for (var i = 1; i < 3; i++) {
      final x = laneW * i;
      for (var y = -1.0; y < 1.0; y += 0.12) {
        final yy = (y + road) * h;
        canvas.drawLine(Offset(x, yy), Offset(x, yy + h * 0.06), dash);
      }
    }
    for (final o in objs) {
      final cx = laneW * o.lane + laneW / 2;
      final cy = o.y * h;
      if (o.bonus) {
        final r = Rect.fromCenter(center: Offset(cx, cy), width: laneW * 0.4, height: laneW * 0.3);
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), Paint()..color = const Color(0xFFB45309));
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - laneW * 0.17), width: laneW * 0.16, height: laneW * 0.06), Paint()..color = const Color(0xFF78350F));
        canvas.drawCircle(Offset(cx, cy), laneW * 0.3, Paint()..color = GamePalette.gold.withAlpha(40));
      } else if (!o.hit) {
        final r = Rect.fromCenter(center: Offset(cx, cy), width: laneW * 0.7, height: laneW * 0.22);
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), Paint()..color = Colors.white);
        for (var k = 0; k < 4; k++) {
          canvas.drawRect(Rect.fromLTWH(r.left + k * r.width / 4, r.top, r.width / 8, r.height), Paint()..color = GamePalette.red);
        }
        canvas.drawCircle(Offset(r.left + 6, r.top - 4), 5, Paint()..color = const Color(0xFF3B82F6));
        canvas.drawCircle(Offset(r.right - 6, r.top - 4), 5, Paint()..color = GamePalette.red);
      }
    }
    // Carro do jogador
    final px = laneW * lane + laneW / 2;
    final py = h * 0.85;
    final car = Rect.fromCenter(center: Offset(px, py), width: laneW * 0.46, height: laneW * 0.78);
    if (hurt > 0) canvas.drawCircle(Offset(px, py), laneW * 0.6, Paint()..color = GamePalette.red.withAlpha((hurt * 120).round()));
    canvas.drawRRect(RRect.fromRectAndRadius(car, Radius.circular(laneW * 0.1)), Paint()..color = const Color(0xFF7C3AED));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(car.left + 6, car.top + car.height * 0.18, car.width - 12, car.height * 0.22), const Radius.circular(5)),
        Paint()..color = const Color(0xFF93C5FD));
    canvas.drawRect(Rect.fromLTWH(car.left + 4, car.bottom - 8, 10, 5), Paint()..color = GamePalette.red);
    canvas.drawRect(Rect.fromLTWH(car.right - 14, car.bottom - 8, 10, 5), Paint()..color = GamePalette.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
