import 'package:flutter/widgets.dart';

/// Disponibiliza a preferência de movimento (animações / reduzir movimento)
/// para toda a árvore, combinando a configuração do jogo com a do sistema.
class MotionScope extends InheritedWidget {
  final bool enabled;
  const MotionScope({super.key, required this.enabled, required super.child});

  static bool of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MotionScope>();
    final system = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return (scope?.enabled ?? true) && !system;
  }

  @override
  bool updateShouldNotify(MotionScope old) => old.enabled != enabled;
}

extension MotionContext on BuildContext {
  bool get motion => MotionScope.of(this);

  /// Duração ajustada: zero quando o movimento está reduzido.
  Duration dur(int ms) => motion ? Duration(milliseconds: ms) : Duration.zero;
}
