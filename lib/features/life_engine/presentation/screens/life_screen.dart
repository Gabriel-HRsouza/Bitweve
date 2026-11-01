import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/careers/presentation/careers_sheet.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/events/presentation/widgets/event_dialog.dart';
import 'package:bitweve/features/finances/presentation/finances_sheet.dart';
import 'package:bitweve/features/relationships/presentation/relationships_sheet.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';
import 'package:bitweve/shared/widgets/stat_bar_widget.dart';
import 'package:bitweve/shared/widgets/timeline_log_tile.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/presentation/widgets/activities_sheet.dart';
import 'package:bitweve/features/life_engine/presentation/widgets/god_mode_modal.dart';
import 'package:bitweve/features/health/presentation/health_sheet.dart';

class LifeScreen extends ConsumerWidget {
  const LifeScreen({super.key});

  AvatarExpression _calculateExpression(int happiness, int health, int stress) {
    if (health < 25) return AvatarExpression.sick;
    if (stress > 80) return AvatarExpression.fear;
    if (happiness > 80) return AvatarExpression.happy;
    if (happiness < 30) return AvatarExpression.sad;
    return AvatarExpression.happy;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(lifeEngineProvider);

    return stateAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(
          child: Text('Erro: $e', style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (state) {
        if (state == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/main_menu');
          });
          return const Scaffold(backgroundColor: AppColors.bgDark);
        }

        final char = state.character;

        // Se o personagem morreu, direciona para tela de morte
        if (!char.isAlive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/death');
          });
          return const Scaffold(backgroundColor: Color(0xFF070B12));
        }

        // Se houver evento pendente, exibir o modal de decisão
        if (state.pendingEvent != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => EventDialog(
                event: state.pendingEvent!,
                onSelectChoice: (choice) {
                  Navigator.pop(ctx);
                  ref.read(lifeEngineProvider.notifier).makeChoice(choice);
                },
              ),
            );
          });
        }

        final expression = _calculateExpression(char.happiness, char.health, char.stress);
        final dynamicAvatar = char.avatarConfig.copyWith(expression: expression);

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
              onPressed: () => context.go('/main_menu'),
              tooltip: 'Menu Principal',
            ),
            title: Text(
              state.slotName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            actions: [
              BwTapFeedback(
                sfx: GameSfx.buttonTap,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const GodModeModal(),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Icon(Icons.bolt, color: Colors.amber, size: 26),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.textSecondaryDark),
                onPressed: () => context.push('/settings'),
                tooltip: 'Configurações',
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 1. Header do Protagonista
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceDark,
                    border: Border(bottom: BorderSide(color: AppColors.borderDark, width: 1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AvatarWidget(config: dynamicAvatar, size: 68),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        char.fullName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimaryDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(35),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.primary.withAlpha(80)),
                                      ),
                                      child: Text(
                                        '${char.currentAge} anos',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📍 ${char.city}, ${char.country} • Ano ${char.birthYear + char.currentAge}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withAlpha(30),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Saldo: R\$ ${char.bankBalance.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Patrimônio: R\$ ${state.netWorth.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMutedDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Barras de Status
                      Row(
                        children: [
                          Expanded(
                            child: StatBarWidget(
                              label: 'Saúde',
                              value: char.health,
                              icon: Icons.favorite,
                              color: AppColors.statHealth,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatBarWidget(
                              label: 'Felicidade',
                              value: char.happiness,
                              icon: Icons.sentiment_satisfied_alt,
                              color: AppColors.statHappiness,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatBarWidget(
                              label: 'Intelecto',
                              value: char.smarts,
                              icon: Icons.psychology,
                              color: AppColors.statSmarts,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatBarWidget(
                              label: 'Aparência',
                              value: char.looks,
                              icon: Icons.face,
                              color: AppColors.statLooks,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 2. Linha de Ocupação e Nível Escolar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.cardDark.withAlpha(120),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.badge, size: 16, color: AppColors.primaryLight),
                          const SizedBox(width: 6),
                          Text(
                            char.currentJobTitle ?? (char.currentAge < 18 ? 'Estudante' : 'Desempregado(a)'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                      if (char.currentSalary != null)
                        Text(
                          'R\$ ${char.currentSalary!.toStringAsFixed(0)}/ano',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                    ],
                  ),
                ),
                // 3. Linha do Tempo / Feed de Histórico da Vida
                Expanded(
                  child: state.logs.isEmpty
                      ? const Center(
                          child: Text(
                            'Sua jornada está apenas começando.',
                            style: TextStyle(color: AppColors.textSecondaryDark),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: state.logs.length,
                          itemBuilder: (context, index) {
                            return TimelineLogTile(log: state.logs[index]);
                          },
                        ),
                ),
                // 4. Painel Inferior de Ações e Avanço de Idade
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceDark,
                    border: Border(top: BorderSide(color: AppColors.borderDark, width: 1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão Principal: Avançar Ano com som marcante e microanimação
                      BwTapFeedback(
                        sfx: GameSfx.ageUp,
                        scaleFactor: 0.96,
                        onTap: () {
                          ref.read(lifeEngineProvider.notifier).advanceYear();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF00F2FE)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C5CE7).withAlpha(120),
                                blurRadius: 18,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cake, size: 22, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                'Avançar para os ${char.currentAge + 1} Anos',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Botões de Ações Rápidas (Relações, Carreira, Finanças, Atividades)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildDockButton(
                              context: context,
                              icon: Icons.people,
                              label: 'Relações',
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const RelationshipsSheet(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildDockButton(
                              context: context,
                              icon: Icons.work,
                              label: 'Carreira',
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const CareersSheet(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildDockButton(
                              context: context,
                              icon: Icons.account_balance,
                              label: 'Finanças',
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const FinancesSheet(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildDockButton(
                              context: context,
                              icon: Icons.favorite,
                              label: 'Saúde',
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const HealthSheet(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildDockButton(
                              context: context,
                              icon: Icons.bolt,
                              label: 'Atividades',
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const ActivitiesSheet(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDockButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return BwTapFeedback(
      sfx: GameSfx.buttonTap,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.primaryLight),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
