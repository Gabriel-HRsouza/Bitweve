import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/features/minigames/minigame_shell.dart';

/// "Lábia": um ponteiro oscila; pare-o dentro da faixa verde.
/// Usado em golpes fictícios, negociações e iniciações.
class BluffGame extends StatefulWidget {
  final int difficulty;
  final int seed;
  final MinigameFinish onFinish;
  const BluffGame({super.key, required this.difficulty, required this.seed, required this.onFinish});

  @override
  State<BluffGame> createState() => _BluffGameState();
}

class _BluffGameState extends State<BluffGame> with SingleTickerProviderStateMixin {
  late final Random _rng = Random(widget.seed + 11);
  late final Ticker _ticker;
  late final int _rounds = 4 + (widget.difficulty >= 3 ? 1 : 0) + (widget.difficulty >= 5 ? 1 : 0);
  int _round = 0;
  int _hits = 0;
  double _accuracy = 0;
  double _t = 0;
  double _speed = 1;
  double _zoneCenter = 0.5;
  double _zoneWidth = 0.2;
  double _timeLeft = 0;
  final double _roundTime = 6;
  Duration _last = Duration.zero;
  String _feedback = '';
  Color _feedbackColor = Colors.white;
  bool _over = false;
  bool _pause = false;
  int _score = 0;

  static const _lines = [
    'Parabéns! Você foi sorteado(a)...',
    'É só confirmar um pequeno detalhe...',
    'Essa oferta acaba hoje!',
    'Confia em mim, é garantido.',
    'Todo mundo já aderiu, só falta você.',
    'Assina aqui que eu resolvo o resto.',
  ];

  @override
  void initState() {
    super.initState();
    _newRound();
    _ticker = createTicker(_tick)..start();
  }

  void _newRound() {
    _zoneWidth = (0.26 - widget.difficulty * 0.03 - _round * 0.008).clamp(0.08, 0.3);
    _zoneCenter = _zoneWidth / 2 + 0.05 + _rng.nextDouble() * (0.9 - _zoneWidth);
    _speed = 0.8 + widget.difficulty * 0.22 + _round * 0.12;
    _timeLeft = _roundTime;
  }

  void _tick(Duration now) {
    if (_over) return;
    final dt = _last == Duration.zero ? 0.0 : (now - _last).inMicroseconds / 1e6;
    _last = now;
    if (_pause) return;
    _t += dt * _speed;
    _timeLeft -= dt;
    if (_timeLeft <= 0) _stop(timeout: true);
    setState(() {});
  }

  double get _pos => (sin(_t * pi) + 1) / 2;

  void _stop({bool timeout = false}) {
    if (_over || _pause) return;
    final p = _pos;
    final dist = (p - _zoneCenter).abs();
    final hit = !timeout && dist <= _zoneWidth / 2;
    if (hit) {
      _hits++;
      final acc = 1 - dist / (_zoneWidth / 2);
      _accuracy += acc;
      _score += 100 + (acc * 100).round();
      _feedback = acc > 0.7 ? 'Perfeito! O alvo acreditou.' : 'Convenceu!';
      _feedbackColor = GamePalette.green;
      AudioService().playSfx(GameSfx.positiveEvent);
    } else {
      _feedback = timeout ? 'Hesitou demais...' : 'O alvo desconfiou!';
      _feedbackColor = GamePalette.red;
      AudioService().playSfx(GameSfx.error);
    }
    _round++;
    _pause = true;
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      if (_round >= _rounds) {
        _over = true;
        _ticker.stop();
        final need = (_rounds * 0.6).ceil();
        final perf = (_hits / _rounds) * 0.7 + (_hits == 0 ? 0 : _accuracy / _hits) * 0.3;
        widget.onFinish(_hits >= need, perf, _score);
        return;
      }
      setState(() {
        _pause = false;
        _feedback = '';
        _newRound();
      });
    });
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
          _stop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _stop,
        child: Column(
          children: [
            GameHud(timeLeft: _timeLeft, timeTotal: _roundTime, score: _score, extra: 'Rodada ${min(_round + 1, _rounds)}/$_rounds · ✔ $_hits'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(children: [
                  const CircleAvatar(backgroundColor: Color(0xFF7C3AED), child: Icon(Icons.record_voice_over_rounded, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('“${_lines[_round % _lines.length]}”',
                        style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 16)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(builder: (context, c) {
                final w = c.maxWidth;
                return SizedBox(
                  height: 64,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFF78350F), Color(0xFF7F1D1D)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      Positioned(
                        left: (_zoneCenter - _zoneWidth / 2) * w,
                        width: _zoneWidth * w,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: GamePalette.green,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: GamePalette.green.withAlpha(140), blurRadius: 14)],
                          ),
                        ),
                      ),
                      Positioned(
                        left: _pos * w - 4,
                        top: -10,
                        bottom: -10,
                        child: Container(
                          width: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [BoxShadow(color: Colors.white, blurRadius: 10)],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 28,
              child: Text(_feedback, style: AppTheme.display(18, color: _feedbackColor)),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GameButton2(label: 'PARAR', onTap: _stop),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão grande de ação para minigames (resposta imediata no toque).
class GameButton2 extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const GameButton2({super.key, required this.label, required this.onTap, this.color = const Color(0xFF7C5CFF)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withAlpha(170)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withAlpha(120), blurRadius: 18)],
        ),
        child: Text(label, style: AppTheme.display(22, color: Colors.white)),
      ),
    );
  }
}
