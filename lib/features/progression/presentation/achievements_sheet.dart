import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/progression/data/progression_catalog.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

class AchievementsSheet extends ConsumerWidget {
  const AchievementsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;

    final achievements = ProgressionCatalog.achievements;
    final unlockedCount = achievements.where((a) => a.progress(s) >= 1.0).length;

    return GameSheet(
      title: 'Conquistas',
      subtitle: '$unlockedCount/${achievements.length} desbloqueadas',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFEAB308),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final a = achievements[i];
          final progress = a.progress(s).clamp(0.0, 1.0);
          final isUnlocked = progress >= 1.0;

          return GameCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(
                      icon: isUnlocked ? a.icon : Icons.lock_outline_rounded,
                      color: isUnlocked ? a.rarity.color : p.textDim,
                      size: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(a.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: p.text)),
                              const SizedBox(width: 8),
                              Pill(a.rarity.label, color: a.rarity.color),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(a.description, style: TextStyle(fontSize: 12, color: p.textDim)),
                        ],
                      ),
                    ),
                    if (isUnlocked)
                      const Icon(Icons.check_circle_rounded, color: GamePalette.green, size: 24)
                    else if (a.reward > 0)
                      Text(Fmt.money(a.reward),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: GamePalette.green, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: p.border,
                    valueColor: AlwaysStoppedAnimation(isUnlocked ? GamePalette.green : a.rarity.color),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
