import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/progression_system.dart';
import 'package:bitweve/features/progression/data/progression_catalog.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

class MissionsSheet extends ConsumerStatefulWidget {
  const MissionsSheet({super.key});

  @override
  ConsumerState<MissionsSheet> createState() => _MissionsSheetState();
}

class _MissionsSheetState extends ConsumerState<MissionsSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;

    final daily = s.extras.daily;
    final dailyMissions = daily == null
        ? <MissionDef>[]
        : ProgressionCatalog.daily.where((m) => daily.missionIds.contains(m.id)).toList();

    return GameSheet(
      title: 'Missões & Objetivos',
      subtitle: 'Complete desafios e ganhe dinheiro e atributos',
      icon: Icons.flag_rounded,
      color: const Color(0xFFF97316),
      header: TabBar(
        controller: _tab,
        tabs: const [
          Tab(text: 'Missões Diárias', icon: Icon(Icons.today_rounded, size: 18)),
          Tab(text: 'Missões de Vida', icon: Icon(Icons.stars_rounded, size: 18)),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // 1. Missões Diárias
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final m in dailyMissions) ...[
                _buildDailyTile(context, ref, s, m),
                const SizedBox(height: 12),
              ],
            ],
          ),

          // 2. Missões de Vida
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ProgressionCatalog.life.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final m = ProgressionCatalog.life[i];
              final progress = (m.progress?.call(s) ?? 0.0).clamp(0.0, 1.0);
              final isClaimed = s.extras.lifeMissionsClaimed.contains(m.id);
              final canClaim = progress >= 1.0 && !isClaimed;

              return GameCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconBadge(icon: m.icon, color: m.color, size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: p.text)),
                              const SizedBox(height: 2),
                              Text(m.description, style: TextStyle(fontSize: 12, color: p.textDim)),
                            ],
                          ),
                        ),
                        if (isClaimed)
                          const Pill('Concluída', color: GamePalette.green)
                        else
                          Text(Fmt.money(m.rewardMoney),
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
                        valueColor: AlwaysStoppedAnimation(isClaimed ? GamePalette.green : m.color),
                      ),
                    ),
                    if (canClaim) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GameButton(
                          label: 'Resgatar Recompensa',
                          icon: Icons.card_giftcard_rounded,
                          colors: [m.color, m.color.withAlpha(200)],
                          onTap: () => ref.read(lifeEngineProvider.notifier).claimLifeMission(m.id),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTile(BuildContext context, WidgetRef ref, dynamic s, MissionDef m) {
    final p = context.gp;
    final current = ProgressionSystem.dailyProgress(s.extras, m);
    final target = m.target;
    final isClaimed = s.extras.daily?.claimed.contains(m.id) ?? false;
    final canClaim = current >= target && !isClaimed;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: m.icon, color: m.color, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: p.text)),
                    const SizedBox(height: 2),
                    Text(m.description, style: TextStyle(fontSize: 12, color: p.textDim)),
                  ],
                ),
              ),
              if (isClaimed)
                const Pill('Resgatada', color: GamePalette.green)
              else
                Text(Fmt.money(m.rewardMoney),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: GamePalette.green, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: p.border,
                    valueColor: AlwaysStoppedAnimation(isClaimed ? GamePalette.green : m.color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$current/$target', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: p.textDim)),
            ],
          ),
          if (canClaim) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GameButton(
                label: 'Resgatar Recompensa',
                icon: Icons.card_giftcard_rounded,
                colors: [m.color, m.color.withAlpha(200)],
                onTap: () => ref.read(lifeEngineProvider.notifier).claimDailyMission(m.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
