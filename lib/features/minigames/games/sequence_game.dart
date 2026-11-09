import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/features/minigames/minigame_shell.dart';

/// "Memória": memorize a sequência de células da planilha e repita.
class SequenceGame extends StatefulWidget {
  final int difficulty;
  final int seed;
  final MinigameFinish onFinish;
  const SequenceGame({super.key, required this.difficulty, required this.seed, required this.onFinish});

  @override
  State<SequenceGame> createState() => _SequenceGameState();
}

class _SequenceGameState extends State<SequenceGame> {
  late final Random _rng = Random(widget.seed + 5);
  late final int _side = widget.difficulty >= 4 ? 4 : 3;
  final int _rounds = 3;
  int _round = 0;
  int _passed = 0;
  List<int> _seq = [];
  int _input = 0;
  int? _lit;
  bool _showing = true;
  int _score = 0;
  String _msg = 'Memorize...';
  Color _msgColor = Colors.white;
  bool _over = false;
  int? _wrong;

  static const _colors = [
    Color(0xFF22C55E), Color(0xFF3B82F6), Color(0xFFF59E0B), Color(0xFFEC4899),
    Color(0xFF8B5CF6), Color(0xFF14B8A6), Color(0xFFEF4444), Color(0xFF84CC16),
  ];

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  Future<void> _startRound() async {
    final len = 3 + widget.difficulty ~/ 2 + _round;
    _seq = List.generate(len, (_) => _rng.nextInt(_side * _side));
    _input = 0;
    setState(() {
      _showing = true;
      _msg = 'Memorize a sequência (${_seq.length})';
      _msgColor = Colors.white;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    final on = Duration(milliseconds: 620 - widget.difficulty * 60);
    for (final i in _seq) {
      if (!mounted) return;
      setState(() => _lit = i);
      AudioService().playSfx(GameSfx.buttonTap);
      await Future.delayed(on);
      if (!mounted) return;
      setState(() => _lit = null);
      await Future.delayed(const Duration(milliseconds: 180));
    }
    if (!mounted) return;
    setState(() {
      _showing = false;
      _msg = 'Sua vez! Repita a sequência';
    });
  }

  void _tap(int i) {
    if (_showing || _over) return;
    setState(() => _lit = i);
    Timer(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _lit = null);
    });
    if (_seq[_input] == i) {
      _input++;
      _score += 20;
      AudioService().playSfx(GameSfx.buttonTap);
      if (_input >= _seq.length) {
        _passed++;
        _score += 100;
        _next('Correto!', GamePalette.green);
      }
    } else {
      setState(() => _wrong = i);
      AudioService().playSfx(GameSfx.error);
      _next('Errou a célula!', GamePalette.red);
    }
  }

  void _next(String msg, Color color) {
    setState(() {
      _msg = msg;
      _msgColor = color;
      _showing = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _wrong = null;
      _round++;
      if (_round >= _rounds) {
        _over = true;
        final win = _passed >= 2;
        widget.onFinish(win, _passed / _rounds, _score);
        return;
      }
      _startRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GameHud(timeLeft: (_rounds - _round).toDouble(), timeTotal: _rounds.toDouble(), score: _score, extra: 'Rodada ${min(_round + 1, _rounds)}/$_rounds · ✔ $_passed'),
        const SizedBox(height: 8),
        Text(_msg, style: AppTheme.display(18, color: _msgColor)),
        Text(_showing ? '' : '$_input/${_seq.length}', style: const TextStyle(color: Colors.white54)),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final s = min(c.maxWidth, c.maxHeight) * 0.9;
            return Center(
              child: SizedBox(
                width: s,
                height: s,
                child: GridView.count(
                  crossAxisCount: _side,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  padding: const EdgeInsets.all(10),
                  children: [
                    for (var i = 0; i < _side * _side; i++)
                      GestureDetector(
                        onTapDown: (_) => _tap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          decoration: BoxDecoration(
                            color: _wrong == i
                                ? GamePalette.red
                                : (_lit == i ? _colors[i % _colors.length] : _colors[i % _colors.length].withAlpha(45)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _colors[i % _colors.length].withAlpha(160), width: 2),
                            boxShadow: _lit == i ? [BoxShadow(color: _colors[i % _colors.length], blurRadius: 18)] : null,
                          ),
                          child: Center(
                            child: Text(
                              '${String.fromCharCode(65 + i % _side)}${i ~/ _side + 1}',
                              style: TextStyle(color: Colors.white.withAlpha(_lit == i ? 255 : 120), fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
