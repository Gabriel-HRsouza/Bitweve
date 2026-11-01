import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';

class RelationshipsSheet extends ConsumerWidget {
  const RelationshipsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(lifeEngineProvider);
    final state = stateAsync.value;

    if (state == null) {
      return const SizedBox.shrink();
    }

    final npcs = state.npcs;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Relacionamentos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${npcs.where((n) => n.isAlive).length} Pessoas',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: npcs.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum relacionamento no momento.',
                      style: TextStyle(color: AppColors.textSecondaryDark),
                    ),
                  )
                : ListView.builder(
                    itemCount: npcs.length,
                    itemBuilder: (context, index) {
                      final npc = npcs[index];
                      return _buildNpcTile(context, ref, npc);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNpcTile(BuildContext context, WidgetRef ref, NpcModel npc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: AvatarWidget(config: npc.avatarConfig, size: 48),
        title: Text(
          npc.fullName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: npc.isAlive ? AppColors.textPrimaryDark : AppColors.textMutedDark,
            decoration: npc.isAlive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${npc.relationLabel} • ${npc.age} anos • ${npc.occupation}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 6),
            if (npc.isAlive)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: npc.relationshipLevel / 100.0,
                  minHeight: 6,
                  backgroundColor: Colors.white.withAlpha(20),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    npc.relationshipLevel > 60
                        ? AppColors.statHealth
                        : (npc.relationshipLevel > 30 ? AppColors.accent : AppColors.accentRose),
                  ),
                ),
              ),
          ],
        ),
        trailing: npc.isAlive
            ? const Icon(Icons.chevron_right, color: AppColors.textSecondaryDark)
            : const Icon(Icons.circle, size: 10, color: Colors.grey),
        onTap: npc.isAlive ? () => _showNpcActions(context, ref, npc) : null,
      ),
    );
  }

  void _showNpcActions(BuildContext context, WidgetRef ref, NpcModel npc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AvatarWidget(config: npc.avatarConfig, size: 54),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          npc.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        Text(
                          '${npc.relationLabel} • Relacionamento: ${npc.relationshipLevel}%',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _actionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Conversar',
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(lifeEngineProvider.notifier).interactNpc(npc.id, 'talk');
                },
              ),
              _actionButton(
                icon: Icons.thumb_up_alt_outlined,
                label: 'Elogiar',
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(lifeEngineProvider.notifier).interactNpc(npc.id, 'compliment');
                },
              ),
              _actionButton(
                icon: Icons.card_giftcard,
                label: 'Dar Presente (R\$ 150)',
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(lifeEngineProvider.notifier).interactNpc(npc.id, 'gift');
                },
              ),
              _actionButton(
                icon: Icons.handshake_outlined,
                label: 'Pedir Desculpas',
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(lifeEngineProvider.notifier).interactNpc(npc.id, 'apologize');
                },
              ),
              if (npc.relationshipType == RelationshipType.partner)
                _actionButton(
                  icon: Icons.favorite,
                  label: 'Pedir em Casamento 💍',
                  color: AppColors.accentRose,
                  onTap: () {
                    Navigator.pop(ctx);
                    ref.read(lifeEngineProvider.notifier).interactNpc(npc.id, 'marry');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.cardDark,
        ),
        icon: Icon(icon, color: color ?? AppColors.primaryLight, size: 20),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
