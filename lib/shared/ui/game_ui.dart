import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'motion.dart';

// =============================================================================
// Pressable: escala + som + háptico em qualquer widget
// =============================================================================
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GameSfx sfx;
  final double scale;
  final bool enabled;
  final String? semanticLabel;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.sfx = GameSfx.buttonTap,
    this.scale = 0.95,
    this.enabled = true,
    this.semanticLabel,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _active => widget.enabled && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;
    return Semantics(
      button: true,
      enabled: _active,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: _active ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _active ? (_) => setState(() => _down = true) : null,
          onTapCancel: _active ? () => setState(() => _down = false) : null,
          onTapUp: _active ? (_) => setState(() => _down = false) : null,
          onLongPress: widget.onLongPress,
          onTap: _active
              ? () {
                  AudioService().playSfx(widget.sfx);
                  widget.onTap!();
                }
              : null,
          child: AnimatedScale(
            scale: _down && motion ? widget.scale : 1,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: widget.enabled ? 1 : 0.45,
              duration: const Duration(milliseconds: 150),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Cartão de jogo com profundidade
// =============================================================================
class GameCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? accent;
  final Gradient? gradient;
  final double radius;
  final bool glow;
  final GameSfx sfx;
  final bool enabled;

  const GameCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accent,
    this.gradient,
    this.radius = 22,
    this.glow = false,
    this.sfx = GameSfx.buttonTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final a = accent;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? p.card : null,
        gradient: gradient ??
            (a != null
                ? LinearGradient(
                    colors: [Color.alphaBlend(a.withAlpha(p.isDark ? 38 : 22), p.card), p.card],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: a != null ? a.withAlpha(p.isDark ? 90 : 70) : p.border, width: 1.2),
        boxShadow: [
          BoxShadow(color: p.shadow.withAlpha(p.isDark ? 70 : 18), blurRadius: 18, offset: const Offset(0, 8)),
          if (glow && a != null) BoxShadow(color: a.withAlpha(70), blurRadius: 24, spreadRadius: -4),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Pressable(onTap: onTap, sfx: sfx, scale: 0.97, enabled: enabled, child: card);
  }
}

// =============================================================================
// Ícone ilustrado: quadrado arredondado com gradiente, brilho e sombra
// =============================================================================
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final Color? secondary;
  final double radiusFactor;

  const IconBadge({super.key, required this.icon, required this.color, this.size = 48, this.secondary, this.radiusFactor = 0.32});

  @override
  Widget build(BuildContext context) {
    final c2 = secondary ?? HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness * 0.62).clamp(0, 1)).toColor();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * radiusFactor),
        gradient: LinearGradient(colors: [color, c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: color.withAlpha(90), blurRadius: size * 0.35, offset: Offset(0, size * 0.12))],
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.12,
            top: size * 0.08,
            right: size * 0.12,
            height: size * 0.38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.25),
                gradient: LinearGradient(
                  colors: [Colors.white.withAlpha(70), Colors.white.withAlpha(0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Center(
            child: Icon(icon, color: Colors.white, size: size * 0.52, shadows: [
              Shadow(color: Colors.black.withAlpha(60), blurRadius: 6, offset: const Offset(0, 2)),
            ]),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Botão principal com gradiente
// =============================================================================
class GameButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Color>? colors;
  final bool expand;
  final bool outlined;
  final GameSfx sfx;
  final double height;
  final String? caption;

  const GameButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.colors,
    this.expand = true,
    this.outlined = false,
    this.sfx = GameSfx.buttonTap,
    this.height = 54,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final cs = colors ?? const [GamePalette.violet, Color(0xFF5B7CFF)];
    final fg = outlined ? p.text : Colors.white;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, color: outlined ? cs.first : fg, size: 21), const SizedBox(width: 9)],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 15.5, letterSpacing: 0.2)),
              if (caption != null)
                Text(caption!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg.withAlpha(200), fontSize: 11.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
    return Pressable(
      onTap: onTap,
      sfx: sfx,
      enabled: onTap != null,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: outlined ? null : LinearGradient(colors: cs),
          color: outlined ? p.cardHigh : null,
          borderRadius: BorderRadius.circular(height / 2.6),
          border: outlined ? Border.all(color: p.border, width: 1.4) : null,
          boxShadow: outlined
              ? null
              : [BoxShadow(color: cs.first.withAlpha(110), blurRadius: 18, offset: const Offset(0, 7))],
        ),
        child: content,
      ),
    );
  }
}

// =============================================================================
// Pílula / etiqueta
// =============================================================================
class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool solid;
  const Pill(this.text, {super.key, required this.color, this.icon, this.solid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: solid ? color : color.withAlpha(context.gp.isDark ? 40 : 30),
        borderRadius: BorderRadius.circular(99),
        border: solid ? null : Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: solid ? Colors.white : color), const SizedBox(width: 4)],
          Flexible(
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: solid ? Colors.white : color, fontSize: 11.5, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  const SectionTitle(this.title, {super.key, this.subtitle, this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 19, color: GamePalette.violet), const SizedBox(width: 8)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.display(18, color: p.text, weight: FontWeight.w600)),
                if (subtitle != null) Text(subtitle!, style: TextStyle(color: p.textMuted, fontSize: 12.5)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// =============================================================================
// Medidor de atributo animado (cor muda com o valor)
// =============================================================================
class StatMeter extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final bool inverted;
  final bool compact;
  final int? delta;

  const StatMeter({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.inverted = false,
    this.compact = false,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final color = GamePalette.forValue(value, inverted: inverted);
    final dur = context.dur(700);
    return Semantics(
      label: '$label $value de 100',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: compact ? 13 : 15, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: compact ? 10.5 : 12, color: p.textDim, fontWeight: FontWeight.w600)),
              ),
              if (delta != null && delta != 0)
                Text(Fmt.signed(delta!),
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800,
                        color: (delta! > 0) != inverted ? GamePalette.green : GamePalette.red)),
              const SizedBox(width: 3),
              TweenAnimationBuilder<double>(
                tween: Tween(end: value.toDouble()),
                duration: dur,
                builder: (_, v, _) => Text('${v.round()}',
                    style: TextStyle(fontSize: compact ? 11 : 12.5, fontWeight: FontWeight.w800, color: p.text)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: compact ? 6 : 8,
              color: p.cardHigh,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: value / 100),
                duration: dur,
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: v.clamp(0.0, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color.withAlpha(200), color]),
                      boxShadow: [BoxShadow(color: color.withAlpha(120), blurRadius: 6)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Dinheiro com contagem animada
// =============================================================================
class AnimatedMoney extends StatelessWidget {
  final double value;
  final TextStyle style;
  final bool compact;
  const AnimatedMoney(this.value, {super.key, required this.style, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: context.dur(900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text(compact ? Fmt.compactMoney(v) : Fmt.money(v), style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

// =============================================================================
// Arte vetorial de itens / categorias
// =============================================================================
class ItemArt extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final double height;
  final int tier;
  final double radius;
  final String? badge;

  const ItemArt({super.key, required this.icon, required this.colors, this.height = 110, this.tier = 1, this.radius = 18, this.badge});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors.length >= 2 ? colors : [colors.first, colors.first],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
            ),
            CustomPaint(painter: _ArtPatternPainter(tier: tier, seed: icon.codePoint)),
            Center(
              child: Container(
                padding: EdgeInsets.all(height * 0.12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(36),
                  border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
                ),
                child: Icon(icon, size: height * 0.38, color: Colors.white, shadows: [
                  Shadow(color: Colors.black.withAlpha(90), blurRadius: 12, offset: const Offset(0, 4)),
                ]),
              ),
            ),
            if (tier >= 3)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: List.generate(tier - 2, (_) => const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFE58A))),
                ),
              ),
            if (badge != null)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: Colors.black.withAlpha(90), borderRadius: BorderRadius.circular(8)),
                  child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArtPatternPainter extends CustomPainter {
  final int tier;
  final int seed;
  _ArtPatternPainter({required this.tier, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    final paint = Paint()..color = Colors.white.withAlpha(22);
    // círculos de luz
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
        size.height * (0.15 + r.nextDouble() * 0.45),
        paint,
      );
    }
    // raios diagonais de brilho
    final shine = Paint()
      ..shader = LinearGradient(colors: [Colors.white.withAlpha(0), Colors.white.withAlpha(45), Colors.white.withAlpha(0)])
          .createShader(Offset.zero & size);
    final path = Path()
      ..moveTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.72, 0)
      ..lineTo(size.width * 0.32, size.height)
      ..lineTo(size.width * 0.15, size.height)
      ..close();
    canvas.drawPath(path, shine);
    // brilhos extras para itens raros
    if (tier >= 3) {
      final sp = Paint()..color = Colors.white.withAlpha(150);
      for (var i = 0; i < 6 * (tier - 2); i++) {
        final c = Offset(r.nextDouble() * size.width, r.nextDouble() * size.height);
        final s = 1.0 + r.nextDouble() * 2.2;
        canvas.drawCircle(c, s, sp);
      }
    }
    // vinheta inferior
    final vignette = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black.withAlpha(60)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _ArtPatternPainter old) => old.tier != tier || old.seed != seed;
}

// =============================================================================
// Fundo animado com "bolhas de luz"
// =============================================================================
class GlowBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  const GlowBackground({super.key, required this.child, this.colors});

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 18));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.motion) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final colors = widget.colors ?? [GamePalette.violet, GamePalette.cyan, GamePalette.pink];
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: p.bg)),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) => CustomPaint(painter: _BlobPainter(_c.value, colors, p.isDark)),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  final bool dark;
  _BlobPainter(this.t, this.colors, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < colors.length; i++) {
      final a = t * 2 * math.pi + i * 2.1;
      final c = Offset(
        size.width * (0.5 + 0.38 * math.cos(a * (i.isEven ? 1 : -1))),
        size.height * (0.32 + 0.3 * math.sin(a * 0.8)),
      );
      final r = size.shortestSide * (0.55 + 0.1 * i);
      final paint = Paint()
        ..shader = RadialGradient(colors: [colors[i].withAlpha(dark ? 60 : 45), colors[i].withAlpha(0)])
            .createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) => old.t != t || old.dark != dark;
}

// =============================================================================
// Folha modal padrão do jogo
// =============================================================================
Future<T?> showGameSheet<T>(BuildContext context, Widget child, {bool full = true}) {
  AudioService().playSfx(GameSfx.menuOpen);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha(140),
    constraints: const BoxConstraints(maxWidth: 760),
    builder: (_) => FractionallySizedBox(heightFactor: full ? 0.93 : null, child: child),
  );
}

class GameSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Widget body;
  final Widget? header;
  final List<Widget>? actions;
  final bool showStatus;

  /// Construtor da barra de status permanente (injetado no main para manter
  /// a camada de UI desacoplada do estado do jogo).
  static Widget Function()? statusBuilder;

  const GameSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.body,
    this.header,
    this.actions,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: color.withAlpha(60), blurRadius: 40, offset: const Offset(0, -6))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withAlpha(p.isDark ? 70 : 45), p.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(18, 10, 10, 12),
            child: Column(
              children: [
                Container(width: 42, height: 5, decoration: BoxDecoration(color: p.border, borderRadius: BorderRadius.circular(9))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconBadge(icon: icon, color: color, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTheme.display(22, color: p.text)),
                          if (subtitle != null)
                            Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: p.textDim, fontSize: 13)),
                        ],
                      ),
                    ),
                    ...?actions,
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.close_rounded, color: p.textDim),
                    ),
                  ],
                ),
                if (showStatus && statusBuilder != null) statusBuilder!(),
                ?header,
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

// =============================================================================
// Estado vazio ilustrado
// =============================================================================
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Widget? action;
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.color = GamePalette.violet, this.action});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      child: Column(
        children: [
          IconBadge(icon: icon, color: color, size: 64),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: AppTheme.display(17, color: p.text, weight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, fontSize: 13)),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

// =============================================================================
// Diálogo de confirmação
// =============================================================================
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = 'Confirmar',
  Color color = GamePalette.red,
  IconData icon = Icons.warning_amber_rounded,
}) async {
  final p = context.gp;
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(icon: icon, color: color, size: 58),
              const SizedBox(height: 14),
              Text(title, textAlign: TextAlign.center, style: AppTheme.display(20, color: p.text)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: p.textDim)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: GameButton(label: 'Cancelar', outlined: true, height: 48, onTap: () => Navigator.pop(ctx, false))),
                  const SizedBox(width: 10),
                  Expanded(child: GameButton(label: confirm, height: 48, colors: [color, color.withAlpha(200)], onTap: () => Navigator.pop(ctx, true))),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(begin: const Offset(0.9, 0.9), duration: context.dur(220), curve: Curves.easeOutBack).fadeIn(),
  );
  return r ?? false;
}

/// Grade responsiva: número de colunas conforme a largura.
int responsiveColumns(double width, {double min = 150}) => (width / min).floor().clamp(2, 6);
