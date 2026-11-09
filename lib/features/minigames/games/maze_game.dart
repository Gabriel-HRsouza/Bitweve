import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/features/minigames/minigame_shell.dart';

/// Minigame de labirinto e coleta (inspirado na mecânica clássica de
/// labirintos com perseguidores, com visual e regras próprios do BitWeve).
///
/// * Colete todos os itens marcados (caixas brilhantes).
/// * Pontinhos dão pontos extras.
/// * Com tudo coletado, a saída (porta verde) abre.
/// * Seguranças perseguem você; se encostarem, a missão falha.
class MazeGame extends StatefulWidget {
  final int difficulty;
  final int seed;
  final MinigameFinish onFinish;
  const MazeGame({super.key, required this.difficulty, required this.seed, required this.onFinish});

  @override
  State<MazeGame> createState() => _MazeGameState();
}

class _P {
  final int x, y;
  const _P(this.x, this.y);
  @override
  bool operator ==(Object o) => o is _P && o.x == x && o.y == y;
  @override
  int get hashCode => x * 1000 + y;
  _P operator +(_P o) => _P(x + o.x, y + o.y);
}

const _up = _P(0, -1), _down = _P(0, 1), _left = _P(-1, 0), _right = _P(1, 0), _none = _P(0, 0);

class _Guard {
  _P pos;
  _P prev;
  _P dir = _none;
  _Guard(this.pos) : prev = pos;
}

class _MazeGameState extends State<MazeGame> with SingleTickerProviderStateMixin {
  late final Random _rng = Random(widget.seed + 4242);
  late List<List<bool>> _wall; // [y][x]
  late int _w, _h;
  late _P _player, _playerPrev, _exit;
  _P _dir = _none, _want = _none;
  final Set<_P> _pellets = {};
  final Set<_P> _targets = {};
  int _targetsTotal = 0;
  int _pelletsTotal = 0;
  final List<_Guard> _guards = [];
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _playerAcc = 0, _guardAcc = 0;
  late double _timeTotal, _timeLeft;
  late double _playerStep, _guardStep;
  int _score = 0;
  bool _over = false;
  final FocusNode _focus = FocusNode();
  Offset _pan = Offset.zero;
  double _flash = 0; // brilho ao coletar item

  @override
  void initState() {
    super.initState();
    _build();
    _ticker = createTicker(_tick)..start();
  }

  void _build() {
    final d = widget.difficulty;
    final cw = 6 + d; // células
    final ch = 7 + d;
    _w = cw * 2 + 1;
    _h = ch * 2 + 1;
    _wall = List.generate(_h, (_) => List.filled(_w, true));
    // Backtracker iterativo
    final visited = List.generate(ch, (_) => List.filled(cw, false));
    final stack = <_P>[const _P(0, 0)];
    visited[0][0] = true;
    _wall[1][1] = false;
    while (stack.isNotEmpty) {
      final c = stack.last;
      final opts = <_P>[];
      for (final dd in const [_up, _down, _left, _right]) {
        final n = c + dd;
        if (n.x >= 0 && n.y >= 0 && n.x < cw && n.y < ch && !visited[n.y][n.x]) opts.add(n);
      }
      if (opts.isEmpty) {
        stack.removeLast();
        continue;
      }
      final n = opts[_rng.nextInt(opts.length)];
      visited[n.y][n.x] = true;
      _wall[n.y * 2 + 1][n.x * 2 + 1] = false;
      _wall[c.y + n.y + 1][c.x + n.x + 1] = false;
      stack.add(n);
    }
    // Remove paredes extras para criar circuitos (estilo arena)
    final loops = (cw * ch * 0.28).round();
    var guard = 0;
    for (var i = 0; i < loops && guard < 5000; guard++) {
      final x = 1 + _rng.nextInt(_w - 2);
      final y = 1 + _rng.nextInt(_h - 2);
      if (!_wall[y][x]) continue;
      final horiz = !_wall[y][x - 1] && !_wall[y][x + 1] && _wall[y - 1][x] && _wall[y + 1][x];
      final vert = !_wall[y - 1][x] && !_wall[y + 1][x] && _wall[y][x - 1] && _wall[y][x + 1];
      if (horiz || vert) {
        _wall[y][x] = false;
        i++;
      }
    }
    _player = _P(1, _h - 2);
    _playerPrev = _player;
    _exit = _P(_w - 2, 1);
    final floor = <_P>[];
    for (var y = 0; y < _h; y++) {
      for (var x = 0; x < _w; x++) {
        if (!_wall[y][x]) floor.add(_P(x, y));
      }
    }
    floor.shuffle(_rng);
    final dist = _bfsFrom(_player);
    final nTargets = 3 + d;
    for (final p in floor) {
      if (_targets.length >= nTargets) break;
      if (p == _exit || (dist[p] ?? 0) < 6) continue;
      _targets.add(p);
    }
    _targetsTotal = _targets.length;
    for (final p in floor) {
      if (p == _player || p == _exit || _targets.contains(p)) continue;
      if (_rng.nextDouble() < 0.55) _pellets.add(p);
    }
    _pelletsTotal = _pellets.length;
    final nGuards = d >= 4 ? 3 : (d >= 2 ? 2 : 1);
    final far = floor.where((p) => (dist[p] ?? 0) > (_w + _h) ~/ 2).toList();
    for (var i = 0; i < nGuards && far.isNotEmpty; i++) {
      _guards.add(_Guard(far.removeAt(_rng.nextInt(far.length))));
    }
    _timeTotal = (80 - d * 7).toDouble();
    _timeLeft = _timeTotal;
    _playerStep = 0.14;
    _guardStep = 0.34 - d * 0.035;
  }

  Map<_P, int> _bfsFrom(_P start) {
    final dist = <_P, int>{start: 0};
    final q = Queue<_P>()..add(start);
    while (q.isNotEmpty) {
      final c = q.removeFirst();
      for (final dd in const [_up, _down, _left, _right]) {
        final n = c + dd;
        if (_open(n) && !dist.containsKey(n)) {
          dist[n] = dist[c]! + 1;
          q.add(n);
        }
      }
    }
    return dist;
  }

  bool _open(_P p) => p.x >= 0 && p.y >= 0 && p.x < _w && p.y < _h && !_wall[p.y][p.x];

  void _tick(Duration now) {
    if (_over) return;
    final dt = _last == Duration.zero ? 0.0 : (now - _last).inMicroseconds / 1e6;
    _last = now;
    _timeLeft -= dt;
    _flash = (_flash - dt * 2).clamp(0, 1);
    if (_timeLeft <= 0) {
      _timeLeft = 0;
      _end(false);
      return;
    }
    _playerAcc += dt;
    while (_playerAcc >= _playerStep) {
      _playerAcc -= _playerStep;
      _stepPlayer();
      if (_over) return;
    }
    _guardAcc += dt;
    while (_guardAcc >= _guardStep) {
      _guardAcc -= _guardStep;
      _stepGuards();
      if (_over) return;
    }
    setState(() {});
  }

  void _stepPlayer() {
    _playerPrev = _player;
    if (_want != _none && _open(_player + _want)) _dir = _want;
    if (_dir != _none && _open(_player + _dir)) _player = _player + _dir;
    if (_pellets.remove(_player)) {
      _score += 10;
    }
    if (_targets.remove(_player)) {
      _score += 120;
      _flash = 1;
      AudioService().playSfx(GameSfx.pickup);
      if (_targets.isEmpty) AudioService().playSfx(GameSfx.notification);
    }
    if (_player == _exit && _targets.isEmpty) {
      _score += 250 + (_timeLeft * 5).round();
      _end(true);
      return;
    }
    _checkCaught();
  }

  void _stepGuards() {
    final dist = _bfsFrom(_player);
    final chase = 0.5 + widget.difficulty * 0.09;
    for (final g in _guards) {
      g.prev = g.pos;
      final opts = <_P>[];
      for (final dd in const [_up, _down, _left, _right]) {
        if (_open(g.pos + dd)) opts.add(dd);
      }
      if (opts.isEmpty) continue;
      _P choice;
      if (_rng.nextDouble() < chase) {
        opts.sort((a, b) => (dist[g.pos + a] ?? 999).compareTo(dist[g.pos + b] ?? 999));
        choice = opts.first;
      } else {
        final noBack = opts.where((o) => o != _P(-g.dir.x, -g.dir.y)).toList();
        final pool = noBack.isEmpty ? opts : noBack;
        choice = pool[_rng.nextInt(pool.length)];
      }
      g.dir = choice;
      g.pos = g.pos + choice;
    }
    _checkCaught();
  }

  void _checkCaught() {
    for (final g in _guards) {
      final crossed = g.pos == _playerPrev && g.prev == _player;
      if (g.pos == _player || crossed) {
        _end(false);
        return;
      }
    }
  }

  void _end(bool win) {
    if (_over) return;
    _over = true;
    if (!win) AudioService().playSfx(GameSfx.alarm);
    _ticker.stop();
    final collected = _targetsTotal - _targets.length;
    final pelletRatio = _pelletsTotal == 0 ? 0 : (_pelletsTotal - _pellets.length) / _pelletsTotal;
    final perf = win
        ? (0.55 + 0.3 * (_timeLeft / _timeTotal) + 0.15 * pelletRatio)
        : (0.45 * collected / max(1, _targetsTotal));
    setState(() {});
    widget.onFinish(win, perf.clamp(0.0, 1.0), _score);
  }

  void _setDir(_P d) {
    _want = d;
    if (_dir == _none) _dir = d;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowUp || k == LogicalKeyboardKey.keyW) {
      _setDir(_up);
    } else if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.keyS) {
      _setDir(_down);
    } else if (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.keyA) {
      _setDir(_left);
    } else if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.keyD) {
      _setDir(_right);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = (_playerAcc / _playerStep).clamp(0.0, 1.0);
    final gt = (_guardAcc / _guardStep).clamp(0.0, 1.0);
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Column(
        children: [
          GameHud(
            timeLeft: _timeLeft,
            timeTotal: _timeTotal,
            score: _score,
            extra: '📦 ${_targetsTotal - _targets.length}/$_targetsTotal',
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final tile = min(c.maxWidth / _w, c.maxHeight / _h);
              return Center(
                child: GestureDetector(
                  onPanStart: (_) => _pan = Offset.zero,
                  onPanUpdate: (u) {
                    _pan += u.delta;
                    if (_pan.distance > 18) {
                      if (_pan.dx.abs() > _pan.dy.abs()) {
                        _setDir(_pan.dx > 0 ? _right : _left);
                      } else {
                        _setDir(_pan.dy > 0 ? _down : _up);
                      }
                      _pan = Offset.zero;
                    }
                  },
                  onTap: () => _focus.requestFocus(),
                  child: SizedBox(
                    width: tile * _w,
                    height: tile * _h,
                    child: Stack(
                      children: [
                        RepaintBoundary(child: CustomPaint(size: Size(tile * _w, tile * _h), painter: _WallPainter(_wall, tile))),
                        CustomPaint(
                          size: Size(tile * _w, tile * _h),
                          painter: _EntityPainter(
                            tile: tile,
                            player: Offset.lerp(_off(_playerPrev), _off(_player), t)!,
                            dir: _dir,
                            guards: [for (final g in _guards) (Offset.lerp(_off(g.prev), _off(g.pos), gt)!, g.dir)],
                            pellets: _pellets,
                            targets: _targets,
                            exit: _exit,
                            exitOpen: _targets.isEmpty,
                            flash: _flash,
                            pulse: (_timeLeft * 4) % 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PadButton(icon: Icons.arrow_back_rounded, onTap: () => _setDir(_left)),
                const SizedBox(width: 10),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  PadButton(icon: Icons.arrow_upward_rounded, onTap: () => _setDir(_up), size: 52),
                  const SizedBox(height: 8),
                  PadButton(icon: Icons.arrow_downward_rounded, onTap: () => _setDir(_down), size: 52),
                ]),
                const SizedBox(width: 10),
                PadButton(icon: Icons.arrow_forward_rounded, onTap: () => _setDir(_right)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Offset _off(_P p) => Offset(p.x.toDouble(), p.y.toDouble());
}

class _WallPainter extends CustomPainter {
  final List<List<bool>> wall;
  final double tile;
  _WallPainter(this.wall, this.tile);

  @override
  void paint(Canvas canvas, Size size) {
    final floor = Paint()..color = const Color(0xFF0B1226);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)), floor);
    final fill = Paint()..color = const Color(0xFF1E3A8A);
    final edge = Paint()
      ..color = const Color(0xFF60A5FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.0, tile * 0.08);
    for (var y = 0; y < wall.length; y++) {
      for (var x = 0; x < wall[y].length; x++) {
        if (!wall[y][x]) continue;
        final r = RRect.fromRectAndRadius(Rect.fromLTWH(x * tile + 1, y * tile + 1, tile - 2, tile - 2), Radius.circular(tile * 0.25));
        canvas.drawRRect(r, fill);
        canvas.drawRRect(r, edge);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WallPainter old) => old.tile != tile || old.wall != wall;
}

class _EntityPainter extends CustomPainter {
  final double tile;
  final Offset player;
  final _P dir;
  final List<(Offset, _P)> guards;
  final Set<_P> pellets;
  final Set<_P> targets;
  final _P exit;
  final bool exitOpen;
  final double flash;
  final double pulse;

  _EntityPainter({
    required this.tile,
    required this.player,
    required this.dir,
    required this.guards,
    required this.pellets,
    required this.targets,
    required this.exit,
    required this.exitOpen,
    required this.flash,
    required this.pulse,
  });

  Offset _c(Offset grid) => Offset(grid.dx * tile + tile / 2, grid.dy * tile + tile / 2);

  @override
  void paint(Canvas canvas, Size size) {
    // Saída
    final exitRect = Rect.fromLTWH(exit.x * tile + tile * 0.12, exit.y * tile + tile * 0.08, tile * 0.76, tile * 0.84);
    canvas.drawRRect(RRect.fromRectAndRadius(exitRect, Radius.circular(tile * 0.15)),
        Paint()..color = exitOpen ? const Color(0xFF22C55E) : const Color(0xFF7F1D1D));
    canvas.drawCircle(Offset(exitRect.right - tile * 0.18, exitRect.center.dy), tile * 0.06, Paint()..color = Colors.white);
    if (exitOpen) {
      canvas.drawRRect(RRect.fromRectAndRadius(exitRect.inflate(tile * 0.1 * (1 + pulse)), Radius.circular(tile * 0.2)),
          Paint()
            ..color = const Color(0xFF22C55E).withAlpha((120 * (1 - pulse)).round())
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
    // Pontinhos
    final pp = Paint()..color = const Color(0xFFFDE68A);
    for (final p in pellets) {
      canvas.drawCircle(_c(Offset(p.x.toDouble(), p.y.toDouble())), tile * 0.09, pp);
    }
    // Itens-alvo (caixas de presente brilhantes)
    for (final p in targets) {
      final c = _c(Offset(p.x.toDouble(), p.y.toDouble()));
      final s = tile * (0.28 + 0.04 * sin(pulse * pi * 2));
      canvas.drawCircle(c, s * 1.5, Paint()..color = const Color(0xFFF472B6).withAlpha(60));
      final r = Rect.fromCenter(center: c, width: s * 2, height: s * 2);
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.3)), Paint()..color = const Color(0xFFEC4899));
      canvas.drawRect(Rect.fromCenter(center: c, width: s * 0.4, height: s * 2), Paint()..color = const Color(0xFFFDE047));
      canvas.drawRect(Rect.fromCenter(center: c, width: s * 2, height: s * 0.4), Paint()..color = const Color(0xFFFDE047));
    }
    // Seguranças: corpo azul-escuro, quepe e lanterna
    for (final (pos, d) in guards) {
      final c = _c(pos);
      if (d != _none) {
        final ang = atan2(d.y.toDouble(), d.x.toDouble());
        final path = Path()
          ..moveTo(c.dx, c.dy)
          ..arcTo(Rect.fromCircle(center: c, radius: tile * 2.2), ang - 0.45, 0.9, false)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFFDE047).withAlpha(45));
      }
      canvas.drawCircle(c, tile * 0.4, Paint()..color = const Color(0xFF1D4ED8));
      canvas.drawCircle(c, tile * 0.4, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      canvas.drawRect(Rect.fromCenter(center: c.translate(0, -tile * 0.22), width: tile * 0.62, height: tile * 0.16), Paint()..color = const Color(0xFF0F172A));
      canvas.drawCircle(c.translate(-tile * 0.12, 0), tile * 0.06, Paint()..color = Colors.white);
      canvas.drawCircle(c.translate(tile * 0.12, 0), tile * 0.06, Paint()..color = Colors.white);
    }
    // Jogador: figura de capuz roxo com máscara e mochila
    final pc = _c(player);
    if (flash > 0) canvas.drawCircle(pc, tile * (0.6 + flash * 0.5), Paint()..color = const Color(0xFFFDE047).withAlpha((flash * 110).round()));
    canvas.drawCircle(pc.translate(-dir.x * tile * 0.22, -dir.y * tile * 0.22 + tile * 0.05), tile * 0.22, Paint()..color = const Color(0xFF92400E));
    canvas.drawCircle(pc, tile * 0.38, Paint()..color = const Color(0xFF7C3AED));
    canvas.drawCircle(pc.translate(dir.x * tile * 0.06, dir.y * tile * 0.06), tile * 0.25, Paint()..color = const Color(0xFFFDE2C4));
    canvas.drawRect(Rect.fromCenter(center: pc.translate(dir.x * tile * 0.06, -tile * 0.03 + dir.y * tile * 0.06), width: tile * 0.46, height: tile * 0.11),
        Paint()..color = const Color(0xFF111827));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
