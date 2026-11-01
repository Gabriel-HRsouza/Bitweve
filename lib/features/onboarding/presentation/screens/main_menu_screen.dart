import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(lifeEngineProvider);
    final activeLife = stateAsync.value;

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // BitWeve Official Branding Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F2FE).withAlpha(120),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withAlpha(90),
                            blurRadius: 36,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00F2FE), Colors.white, Color(0xFF9D4EDD)],
                      ).createShader(bounds),
                      child: const Text(
                        'BitWeve',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F2FE).withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00F2FE).withAlpha(70)),
                      ),
                      child: const Text(
                        'SIMULADOR DE VIDA • ESCOLHAS & DESTINO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Color(0xFF00F2FE),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    // Card: Continuar Vida Atual
                    if (activeLife != null && activeLife.character.isAlive) ...[
                      BwTapFeedback(
                        sfx: GameSfx.buttonTap,
                        onTap: () => context.go('/game'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withAlpha(50),
                                AppColors.cardDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(50),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              AvatarWidget(config: activeLife.character.avatarConfig, size: 54),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeLife.character.fullName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${activeLife.character.currentAge} anos • R\$ ${activeLife.netWorth.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Continuar',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Botão: Nova Vida Aleatória
                    BwTapFeedback(
                      sfx: GameSfx.buttonTap,
                      onTap: () async {
                        await ref.read(lifeEngineProvider.notifier).startRandomLife();
                        if (context.mounted) {
                          context.go('/game');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFF00F2FE)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withAlpha(100),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shuffle, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Nova Vida Aleatória',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botão: Criar Vida Personalizada
                    BwTapFeedback(
                      sfx: GameSfx.buttonTap,
                      onTap: () => context.push('/create_character'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderDark, width: 1.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.person_add_alt_1, color: AppColors.primaryLight, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Criar Vida Personalizada',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.textSecondaryDark, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botão: Minhas Vidas Salvas
                    BwTapFeedback(
                      sfx: GameSfx.buttonTap,
                      onTap: () => context.push('/saves'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderDark, width: 1.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.save_outlined, color: AppColors.secondary, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Gerenciar Vidas Salvas',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.textSecondaryDark, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botão: Configurações
                    BwTapFeedback(
                      sfx: GameSfx.buttonTap,
                      onTap: () => context.push('/settings'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderDark, width: 1.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.tune, color: AppColors.textSecondaryDark, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Configurações de Áudio & Sistema',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.textSecondaryDark, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
