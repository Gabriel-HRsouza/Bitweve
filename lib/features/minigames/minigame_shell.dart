import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/features/minigames/games/bluff_game.dart';
import 'package:bitweve/features/minigames/games/maze_game.dart';
import 'package:bitweve/features/minigames/games/runner_game.dart';
import 'package:bitweve/features/minigames/games/safe_game.dart';
import 'package:bitweve/features/minigames/games/sequence_game.dart';
import 'package:bitweve/features/underworld/data/crime_catalog.dart';
import 'package:bitweve/features/underworld/models/minigame_result.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

typedef MinigameFinish = void Function(bool success, double performance, int score);

/// Abre um minigame em tela cheia e devolve o resultado.
/// Sair antes de começar = desistência (sem consequências).
/// Sair durante a partida = derrota.
Future<MinigameResult> playMinigame(
  BuildContext context, {
  required MinigameKind kind,
  required int difficulty,
  required String title,
  String? subtitle,
  int seed = 0,
  List<Color>? colors,
}) async {
  AudioService().playSfx(GameSfx.screenTransition);
  final r = await Navigator.of(context).push<MinigameResult>(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => MinigameShell(kind: kind, difficulty: difficulty.clamp(1, 5), title: title, subtitle: subtitle, seed: seed, colors: colors),
  ));
  return r ?? MinigameResult.quit;
}

class MinigameShell extends StatefulWidget {
  final MinigameKind kind;
  final int difficulty;
  final String title;
  final String? subtitle;
  final int seed;
  final List<Color>? colors;

  const MinigameShell({super.key, required this.kind, required this.difficulty, required this.title, this.subtitle, this.seed = 0, this.colors});

  @override
  State<MinigameShell> createState() => _MinigameShellState();
}

enum _Phase { intro, playing, done }

class _MinigameShellState extends State<MinigameShell> {
  _Phase _phase = _Phase.intro;
  int _round = 0;
  int _restartsLeft = 1;
  MinigameResult? _result;

  void _start() {
    AudioService().playSfx(GameSfx.buttonTap);
    setState(() {
      _phase = _Phase.playing;
      _round++;
    });
  }

  void _finish(bool success, double performance, int score) {
    if (!mounted || _phase != _Phase.playing) return;
    AudioService().playSfx(success ? GameSfx.achievement : GameSfx.negativeEvent);
    setState(() {
      _phase = _Phase.done;
      _result = MinigameResult(success: success, performance: performance.clamp(0.0, 1.0), score: score);
    });
  }

  Future<void> _exit() async {
    if (_phase == _Phase.intro) {
      Navigator.of(context).pop(MinigameResult.quit);
      return;
    }
    if (_phase == _Phase.playing) {
      final ok = await confirmDialog(context,
          title: 'Abandonar a missão?', message: 'Sair agora conta como fracasso — e você pode ser pego(a).', confirm: 'Abandonar');
      if (!ok || !mounted) return;
      Navigator.of(context).pop(const MinigameResult(success: false, performance: 0));
      return;
    }
    Navigator.of(context).pop(_result ?? MinigameResult.quit);
  }

  Widget _game() {
    final key = ValueKey('${widget.kind}-$_round');
    final seed = widget.seed + _round * 97;
    return switch (widget.kind) {
      MinigameKind.maze => MazeGame(key: key, difficulty: widget.difficulty, seed: seed, onFinish: _finish),
      MinigameKind.bluff => BluffGame(key: key, difficulty: widget.difficulty, seed: seed, onFinish: _finish),
      MinigameKind.safe => SafeGame(key: key, difficulty: widget.difficulty, seed: seed, onFinish: _finish),
      MinigameKind.sequence => SequenceGame(key: key, difficulty: widget.difficulty, seed: seed, onFinish: _finish),
      MinigameKind.runner => RunnerGame(key: key, difficulty: widget.difficulty, seed: seed, onFinish: _finish),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? const [Color(0xFF7C5CFF), Color(0xFF0F172A)];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070B18),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.first.withAlpha(90), const Color(0xFF070B18), const Color(0xFF070B18)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Sair',
                        onPressed: _exit,
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      ),
                      Icon(widget.kind.icon, color: colors.first),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: AppTheme.display(17, color: Colors.white)),
                            Text('${widget.kind.label} · Dificuldade ${'★' * widget.difficulty}${'☆' * (5 - widget.difficulty)}',
                                style: const TextStyle(color: Colors.white60, fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      if (_phase != _Phase.intro) Positioned.fill(child: _game()),
                      if (_phase == _Phase.intro) Positioned.fill(child: _intro(colors)),
                      if (_phase == _Phase.done && _result != null) Positioned.fill(child: _resultView(_result!)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _intro(List<Color> colors) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(icon: widget.kind.icon, color: colors.first, size: 84)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 900.ms),
              const SizedBox(height: 18),
              Text(widget.title, textAlign: TextAlign.center, style: AppTheme.display(24, color: Colors.white)),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 6),
                Text(widget.subtitle!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(widget.kind.howTo, style: const TextStyle(color: Colors.white, height: 1.35))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Teclado: setas/WASD e Espaço · Celular: toque, deslize ou use os botões',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11.5)),
              const SizedBox(height: 20),
              GameButton(label: 'Começar', icon: Icons.play_arrow_rounded, colors: [colors.first, colors.last], onTap: _start),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(MinigameResult.quit),
                child: const Text('Desistir (sem consequências)', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultView(MinigameResult r) {
    final color = r.success ? GamePalette.green : GamePalette.red;
    return Container(
      color: Colors.black.withAlpha(170),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: color.withAlpha(150), width: 2),
            boxShadow: [BoxShadow(color: color.withAlpha(90), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(icon: r.success ? Icons.emoji_events_rounded : Icons.cancel_rounded, color: color, size: 70),
              const SizedBox(height: 12),
              Text(r.success ? 'VITÓRIA!' : 'DERROTA', style: AppTheme.display(28, color: color)),
              const SizedBox(height: 6),
              Text('Desempenho ${(r.performance * 100).round()}% · ${r.score} pts',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              GameButton(
                label: 'Confirmar resultado',
                icon: Icons.check_rounded,
                colors: [color, color.withAlpha(180)],
                onTap: () => Navigator.of(context).pop(r),
              ),
              if (_restartsLeft > 0) ...[
                const SizedBox(height: 10),
                GameButton(
                  label: 'Reiniciar ($_restartsLeft restante)',
                  icon: Icons.replay_rounded,
                  outlined: true,
                  onTap: () {
                    setState(() {
                      _restartsLeft--;
                      _result = null;
                    });
                    _start();
                  },
                ),
              ],
            ],
          ),
        ).animate().scale(begin: const Offset(0.85, 0.85), duration: 300.ms, curve: Curves.easeOutBack).fadeIn(),
      ),
    );
  }
}

/// Botão grande de controle touch usado pelos minigames.
class PadButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  const PadButton({super.key, required this.icon, required this.onTap, this.size = 58, this.color = const Color(0xFF7C5CFF)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withAlpha(60),
          borderRadius: BorderRadius.circular(size * 0.3),
          border: Border.all(color: color.withAlpha(170), width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.55),
      ),
    );
  }
}

/// Barra de HUD (tempo / pontos / extra).
class GameHud extends StatelessWidget {
  final double timeLeft;
  final double timeTotal;
  final int score;
  final String? extra;
  const GameHud({super.key, required this.timeLeft, required this.timeTotal, required this.score, this.extra});

  @override
  Widget build(BuildContext context) {
    final ratio = (timeLeft / timeTotal).clamp(0.0, 1.0);
    final c = ratio > 0.5 ? GamePalette.green : (ratio > 0.25 ? GamePalette.gold : GamePalette.red);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: Row(
        children: [
          Icon(Icons.timer_rounded, color: c, size: 18),
          const SizedBox(width: 6),
          SizedBox(
            width: 42,
            child: Text('${timeLeft.ceil()}s', style: TextStyle(color: c, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: LinearProgressIndicator(value: ratio, minHeight: 8, color: c, backgroundColor: Colors.white12),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.star_rounded, color: GamePalette.gold, size: 18),
          const SizedBox(width: 4),
          Text('$score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          if (extra != null) ...[
            const SizedBox(width: 12),
            Text(extra!, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 12.5)),
          ],
        ],
      ),
    );
  }
}
