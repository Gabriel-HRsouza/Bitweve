import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class DeathScreen extends ConsumerWidget {
  const DeathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(lifeEngineProvider);
    final state = stateAsync.value;

    if (state == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final char = state.character;
    final survivingChildren = state.npcs
        .where((n) =>
            n.isAlive &&
            (n.relationshipType == RelationshipType.son ||
                n.relationshipType == RelationshipType.daughter))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Tombstone Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF263345),
                      Color(0xFF141C28),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(120),
                    bottom: Radius.circular(24),
                  ),
                  border: Border.all(color: const Color(0xFF3B485A), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(140),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.nightlight_round,
                      color: Color(0xFF94A3B8),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'AQUI JAZ',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AvatarWidget(
                      config: char.avatarConfig.copyWith(
                        expression: AvatarExpression.sad,
                      ),
                      size: 90,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      char.fullName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${char.birthYear} — ${char.birthYear + char.currentAge}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF334155)),
                    const SizedBox(height: 12),
                    Text(
                      'Viveu até os ${char.currentAge} anos.\nFaleceu de ${char.causeOfDeath ?? "causas naturais"}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(80),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Patrimônio Final: R\$ ${state.netWorth.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Generational Continuity: Continue as Child
              if (survivingChildren.isNotEmpty) ...[
                const Text(
                  'Continuar Dinastia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...survivingChildren.map((child) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: ListTile(
                      leading: AvatarWidget(config: child.avatarConfig, size: 40),
                      title: Text(
                        child.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      subtitle: Text(
                        '${child.relationLabel} • ${child.age} anos',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      trailing: BwTapFeedback(
                        sfx: GameSfx.achievement,
                        onTap: () {
                          ref.read(lifeEngineProvider.notifier).continueAsHeir(child.id);
                          context.go('/game');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Jogar como Herdeiro', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
              // Action Buttons
              BwTapFeedback(
                sfx: GameSfx.buttonTap,
                onTap: () async {
                  await ref.read(lifeEngineProvider.notifier).startRandomLife();
                  if (context.mounted) context.go('/game');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00F2FE)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Iniciar Nova Vida Aleatória', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              BwTapFeedback(
                sfx: GameSfx.buttonTap,
                onTap: () => context.go('/main_menu'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, color: AppColors.textSecondaryDark),
                      SizedBox(width: 8),
                      Text('Voltar ao Menu Principal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
