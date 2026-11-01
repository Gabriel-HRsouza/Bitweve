import 'package:flutter/material.dart';
import 'package:bitweve/core/audio/audio_service.dart';

/// Interactive wrapper that adds instant audio tap feedback and fluid spring micro-animation
class BwTapFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final GameSfx sfx;
  final double scaleFactor;
  final BorderRadius? borderRadius;

  const BwTapFeedback({
    super.key,
    required this.child,
    required this.onTap,
    this.sfx = GameSfx.buttonTap,
    this.scaleFactor = 0.95,
    this.borderRadius,
  });

  @override
  State<BwTapFeedback> createState() => _BwTapFeedbackState();
}

class _BwTapFeedbackState extends State<BwTapFeedback> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad, reverseCurve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      AudioService().playSfx(widget.sfx);
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
