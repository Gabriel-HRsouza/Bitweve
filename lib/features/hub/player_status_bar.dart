import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/education_system.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

/// Situação atual do personagem em uma linha.
String situationOf(LifeEngineState s) {
  final c = s.character;
  final x = s.extras;
  if (!c.isAlive) return 'Falecido(a)';
  if (x.crime.inPrison) return 'Preso(a) · ${x.crime.yearsLeft} ano(s) restantes';
  if (x.crime.pendingCase != null) return 'Aguardando julgamento';
  if (c.currentJobTitle != null) return c.currentJobTitle!;
  if (x.education.isStudying) return EducationSystem.stageLabel(x.education);
  if (x.retired) return 'Aposentado(a)';
  if (c.currentAge < 6) return 'Criança';
  if (c.currentAge < 18) return 'Estudante';
  return 'Desempregado(a)';
}

/// Barra superior permanente: avatar, nome, idade, situação, saldo,
/// patrimônio e indicadores de estado.
class PlayerStatusBar extends ConsumerWidget {
  final bool compact;
  const PlayerStatusBar({super.key, this.compact = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;
    final c = s.character;
    final x = s.extras;
    final indicators = <(IconData, Color, String)>[
      if (c.health < 35) (Icons.favorite_rounded, GamePalette.red, 'Saúde baixa'),
      if (c.stress > 70) (Icons.whatshot_rounded, GamePalette.orange, 'Estresse alto'),
      if (x.crime.inPrison) (Icons.lock_rounded, GamePalette.red, 'Na prisão'),
      if (x.crime.pendingCase != null) (Icons.gavel_rounded, GamePalette.gold, 'Processo pendente'),
      if (x.crime.heat >= 40 && !x.crime.inPrison) (Icons.local_police_rounded, GamePalette.blue, 'Polícia de olho (${x.crime.heat})'),
      if (x.crime.onProbation) (Icons.timelapse_rounded, GamePalette.gold, 'Condicional'),
      if (s.npcs.any((n) => n.isAlive && n.id == c.partnerId)) (Icons.favorite_rounded, GamePalette.pink, 'Em um relacionamento'),
      if (x.social.unread > 0) (Icons.mark_chat_unread_rounded, GamePalette.violet, '${x.social.unread} mensagem(ns)'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 6, 0, 2),
      padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
      decoration: BoxDecoration(
        color: p.card.withAlpha(p.isDark ? 200 : 235),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          AvatarWidget(
            config: c.avatarConfig.copyWith(expression: expressionFor(happiness: c.happiness, health: c.health, stress: c.stress)),
            age: c.currentAge,
            size: compact ? 38 : 48,
            animate: false,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${c.firstName} · ${c.currentAge} anos', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.text, fontWeight: FontWeight.w900, fontSize: 13)),
                Text(situationOf(s), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.textMuted, fontSize: 11)),
              ],
            ),
          ),
          for (final (icon, color, tip) in indicators.take(4))
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(message: tip, child: Icon(icon, size: 16, color: color)),
            ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedMoney(c.bankBalance, compact: true,
                  style: TextStyle(color: c.bankBalance < 0 ? GamePalette.red : GamePalette.green, fontWeight: FontWeight.w900, fontSize: 13)),
              Text('Patrimônio ${Fmt.compactMoney(s.netWorth)}', style: TextStyle(color: p.textMuted, fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }
}
