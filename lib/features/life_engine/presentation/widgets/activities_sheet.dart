import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';

class ActivitiesSheet extends ConsumerWidget {
  const ActivitiesSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Text(
            'Atividades de Vida',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildActivityTile(
                  icon: Icons.fitness_center,
                  color: AppColors.statHealth,
                  title: 'Treinar na Academia',
                  subtitle: 'Melhora condicionamento, aparência física e alivia o estresse.',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(lifeEngineProvider.notifier).goToGym();
                  },
                ),
                _buildActivityTile(
                  icon: Icons.casino,
                  color: AppColors.accent,
                  title: 'Apostar na Loteria (R\$ 50)',
                  subtitle: 'Compre um bilhete e teste sua sorte no sorteio anual.',
                  onTap: () {
                    Navigator.pop(context);
                    _playLottery(context, ref);
                  },
                ),
                _buildActivityTile(
                  icon: Icons.local_hospital,
                  color: AppColors.accentRose,
                  title: 'Consulta Médica de Rotina (R\$ 300)',
                  subtitle: 'Visite um clínico geral para recuperar sua saúde física.',
                  onTap: () {
                    Navigator.pop(context);
                    _visitDoctor(context, ref);
                  },
                ),
                _buildActivityTile(
                  icon: Icons.camera_alt,
                  color: AppColors.statFame,
                  title: 'Criar Conteúdo nas Redes Sociais',
                  subtitle: 'Faça postagens, ganhe seguidores e construa sua reputação digital.',
                  onTap: () {
                    Navigator.pop(context);
                    _postOnSocial(context, ref);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondaryDark),
        onTap: onTap,
      ),
    );
  }

  void _playLottery(BuildContext context, WidgetRef ref) {
    final state = ref.read(lifeEngineProvider).value;
    if (state == null) return;
    if (state.character.bankBalance < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo insuficiente para comprar o bilhete.')),
      );
      return;
    }

    final won = Random().nextDouble() < 0.25;
    final prize = won ? 1500.0 + Random().nextInt(5000) : 0.0;

    final updatedChar = state.character.copyWith(
      bankBalance: state.character.bankBalance - 50 + prize,
      happiness: won ? state.character.happiness + 25 : state.character.happiness - 2,
    );

    ref.read(lifeEngineProvider.notifier).updateCharacter(updatedChar);
    ref.read(audioServiceProvider).playSfx(won ? GameSfx.achievement : GameSfx.buttonTap);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: won ? AppColors.secondaryDark : AppColors.cardHoverDark,
        content: Text(
          won
              ? '🎉 Parabéns! Você acertou e ganhou R\$ ${prize.toStringAsFixed(2)}!'
              : 'Não foi dessa vez. Seu bilhete não foi premiado.',
        ),
      ),
    );
  }

  void _visitDoctor(BuildContext context, WidgetRef ref) {
    final state = ref.read(lifeEngineProvider).value;
    if (state == null) return;
    if (state.character.bankBalance < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo insuficiente para a consulta médica.')),
      );
      return;
    }

    final updatedChar = state.character.copyWith(
      bankBalance: state.character.bankBalance - 300,
      health: state.character.health + 15,
      happiness: state.character.happiness + 5,
      stress: (state.character.stress - 10).clamp(0, 100),
    );

    ref.read(lifeEngineProvider.notifier).updateCharacter(updatedChar);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('O médico receitou vitaminas e exames. Sua saúde melhorou!')),
    );
  }

  void _postOnSocial(BuildContext context, WidgetRef ref) {
    final state = ref.read(lifeEngineProvider).value;
    if (state == null) return;

    final viral = Random().nextDouble() < 0.35;
    final fameGain = viral ? 15 : 3;

    final updatedChar = state.character.copyWith(
      fame: state.character.fame + fameGain,
      happiness: state.character.happiness + 10,
    );

    ref.read(lifeEngineProvider.notifier).updateCharacter(updatedChar);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viral
              ? '🔥 Seu post viralizou! Você ganhou milhares de novos seguidores!'
              : 'Seu post recebeu boas curtidas e comentários de amigos.',
        ),
      ),
    );
  }
}
