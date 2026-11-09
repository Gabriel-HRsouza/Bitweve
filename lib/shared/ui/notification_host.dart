import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/settings/game_settings.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'motion.dart';

Color noticeColor(NoticeKind k) {
  switch (k) {
    case NoticeKind.money:
      return GamePalette.green;
    case NoticeKind.career:
      return GamePalette.blue;
    case NoticeKind.social:
      return GamePalette.pink;
    case NoticeKind.achievement:
      return GamePalette.gold;
    case NoticeKind.mission:
      return GamePalette.orange;
    case NoticeKind.purchase:
      return GamePalette.teal;
    case NoticeKind.health:
      return GamePalette.red;
    case NoticeKind.fame:
      return const Color(0xFFA855F7);
    case NoticeKind.event:
      return GamePalette.cyan;
    case NoticeKind.family:
      return const Color(0xFFFB7185);
    case NoticeKind.education:
      return GamePalette.violet;
    case NoticeKind.warning:
      return const Color(0xFFF59E0B);
    case NoticeKind.info:
      return const Color(0xFF64748B);
  }
}

String noticeCategory(NoticeKind k) => const {
      NoticeKind.money: 'Finanças',
      NoticeKind.career: 'Carreira',
      NoticeKind.social: 'Social',
      NoticeKind.achievement: 'Conquista',
      NoticeKind.mission: 'Missão',
      NoticeKind.purchase: 'Compra',
      NoticeKind.health: 'Saúde',
      NoticeKind.fame: 'Fama',
      NoticeKind.event: 'Evento',
      NoticeKind.family: 'Família',
      NoticeKind.education: 'Educação',
      NoticeKind.warning: 'Atenção',
      NoticeKind.info: 'Vida',
    }[k]!;

class NotificationHost extends ConsumerStatefulWidget {
  final Widget child;
  const NotificationHost({super.key, required this.child});

  @override
  ConsumerState<NotificationHost> createState() => _NotificationHostState();
}

class _Toast {
  final GameNotice notice;
  final int id;
  _Toast(this.notice, this.id);
}

class _NotificationHostState extends ConsumerState<NotificationHost> {
  final List<_Toast> _visible = [];
  final List<(_FloatMoney, int)> _floats = [];
  late final ConfettiController _confetti = ConfettiController(duration: const Duration(milliseconds: 900));
  int _seq = 0;
  Timer? _drain;

  @override
  void dispose() {
    _confetti.dispose();
    _drain?.cancel();
    super.dispose();
  }

  void _pump() {
    final queue = ref.read(noticeQueueProvider.notifier);
    _drain ??= Timer.periodic(const Duration(milliseconds: 380), (_) {
      if (!mounted) return;
      if (_visible.length >= 3) return;
      final n = queue.pop();
      if (n == null) {
        _drain?.cancel();
        _drain = null;
        return;
      }
      _show(n);
    });
  }

  void _show(GameNotice n) {
    final settings = ref.read(settingsProvider);
    final motion = settings.motionOn && !(MediaQuery.maybeOf(context)?.disableAnimations ?? false);
    final important = n.kind == NoticeKind.warning || n.kind == NoticeKind.achievement || n.kind == NoticeKind.mission;
    if (n.celebrate && motion) _confetti.play();
    if (n.moneyDelta != null && n.moneyDelta!.abs() >= 1 && motion) {
      final id = _seq++;
      setState(() => _floats.add((_FloatMoney(n.moneyDelta!), id)));
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _floats.removeWhere((f) => f.$2 == id));
      });
    }
    if (!settings.notificationsEnabled && !important) return;
    final t = _Toast(n, _seq++);
    setState(() => _visible.add(t));
    final ms = n.kind == NoticeKind.achievement ? 4200 : (n.kind == NoticeKind.warning ? 3400 : 2600);
    Future.delayed(Duration(milliseconds: ms), () {
      if (mounted) setState(() => _visible.remove(t));
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<GameNotice>>(noticeQueueProvider, (prev, next) {
      if (next.isNotEmpty) _pump();
    });
    final top = MediaQuery.paddingOf(context).top + 10;
    return Stack(
      children: [
        widget.child,
        // confete
        Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.2,
              numberOfParticles: 18,
              maxBlastForce: 22,
              minBlastForce: 8,
              gravity: 0.25,
              colors: const [GamePalette.violet, GamePalette.cyan, GamePalette.pink, GamePalette.gold, GamePalette.green],
            ),
          ),
        ),
        // dinheiro flutuante
        for (final f in _floats)
          Positioned(
            top: top + 80,
            left: 0,
            right: 0,
            child: IgnorePointer(child: Center(child: f.$1)),
          ),
        // toasts
        Positioned(
          top: top,
          left: 12,
          right: 12,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final t in _visible)
                    Padding(
                      key: ValueKey(t.id),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ToastCard(
                        notice: t.notice,
                        onDismiss: () => setState(() => _visible.remove(t)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  final GameNotice notice;
  final VoidCallback onDismiss;
  const _ToastCard({required this.notice, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final color = noticeColor(notice.kind);
    final card = Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onDismiss,
        onVerticalDragEnd: (_) => onDismiss(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withAlpha(140), width: 1.3),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(p.isDark ? 120 : 40), blurRadius: 20, offset: const Offset(0, 8)),
              BoxShadow(color: color.withAlpha(60), blurRadius: 18),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withAlpha(170)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(notice.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(noticeCategory(notice.kind).toUpperCase(),
                        style: TextStyle(fontSize: 9.5, letterSpacing: 1.1, fontWeight: FontWeight.w800, color: color)),
                    Text(notice.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: p.text)),
                    if (notice.message.isNotEmpty)
                      Text(notice.message, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: p.textDim)),
                  ],
                ),
              ),
              if (notice.moneyDelta != null && notice.moneyDelta!.abs() >= 1) ...[
                const SizedBox(width: 8),
                Text(Fmt.signedMoney(notice.moneyDelta!),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5,
                        color: notice.moneyDelta! >= 0 ? GamePalette.green : GamePalette.red)),
              ],
            ],
          ),
        ),
      ),
    );
    if (!context.motion) return card;
    return card
        .animate()
        .slideY(begin: -0.6, end: 0, duration: 380.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 220.ms)
        .then(delay: 50.ms)
        .shimmer(duration: 900.ms, color: color.withAlpha(60));
  }
}

class _FloatMoney extends StatelessWidget {
  final double amount;
  const _FloatMoney(this.amount);

  @override
  Widget build(BuildContext context) {
    final positive = amount >= 0;
    final color = positive ? GamePalette.green : GamePalette.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withAlpha(150)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(positive ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: color, size: 22),
          const SizedBox(width: 6),
          Text(Fmt.signedMoney(amount), style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, shadows: [
            Shadow(color: Colors.black.withAlpha(80), blurRadius: 6),
          ])),
        ],
      ),
    )
        .animate()
        .scale(begin: const Offset(0.6, 0.6), duration: 260.ms, curve: Curves.easeOutBack)
        .moveY(begin: 20, end: -60, duration: 1400.ms, curve: Curves.easeOut)
        .fadeOut(delay: 900.ms, duration: 500.ms);
  }
}
