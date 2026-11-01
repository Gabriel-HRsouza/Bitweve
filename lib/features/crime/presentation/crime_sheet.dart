import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class CrimeSheet extends ConsumerWidget {
  const CrimeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeEngineProvider).value;
    if (state == null) return const SizedBox.shrink();

    final char = state.character;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentRose.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gavel, color: AppColors.accentRose, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Submundo & Justiça Criminal',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        char.criminalRecord
                            ? 'Ficha Criminal: Ativa (${char.timesArrested} condenações)'
                            : 'Ficha Criminal: Limpa',
                        style: TextStyle(
                          fontSize: 12,
                          color: char.criminalRecord ? AppColors.accentRose : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderDark, height: 24),

          // Crimes list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text(
                  'Ações de Risco Narrativo (Delitos Fictícios)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ações ilegais possuem riscos graduais de prisão, julgamento judicial e perda de reputação.',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                ),
                const SizedBox(height: 14),

                _buildCrimeTile(
                  context: context,
                  ref: ref,
                  title: 'Furto Rápido em Loja',
                  description: 'Tentar subtrair itens pequenos sem ser notado.',
                  rewardText: 'Ganho: R\$ 120 ~ R\$ 250',
                  riskText: 'Risco: 25%',
                  crimeId: 'shoplifting',
                ),
                _buildCrimeTile(
                  context: context,
                  ref: ref,
                  title: 'Golpe Digital / Fraude Virtual',
                  description: 'Enganar usuários em sites de compras com anúncios falsos.',
                  rewardText: 'Ganho: R\$ 1.200 ~ R\$ 3.500',
                  riskText: 'Risco: 40%',
                  crimeId: 'digital_fraud',
                ),
                _buildCrimeTile(
                  context: context,
                  ref: ref,
                  title: 'Contrabando de Eletrônicos Fictício',
                  description: 'Transportar carga não declarada para revenda no mercado paralelo.',
                  rewardText: 'Ganho: R\$ 8.000 ~ R\$ 15.000',
                  riskText: 'Risco: 60%',
                  crimeId: 'smuggling',
                ),
                _buildCrimeTile(
                  context: context,
                  ref: ref,
                  title: 'Fraude de Colarinho Branco',
                  description: 'Desviar recursos de contas corporativas em paraíso fiscal.',
                  rewardText: 'Ganho: R\$ 40.000 ~ R\$ 90.000',
                  riskText: 'Risco: 75%',
                  crimeId: 'white_collar',
                ),
                const SizedBox(height: 24),

                // Legal defense section
                if (char.criminalRecord) ...[
                  const Text(
                    'Reabilitação Judicial',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BwTapFeedback(
                    sfx: GameSfx.buttonTap,
                    onTap: () async {
                      await ref.read(lifeEngineProvider.notifier).appealCriminalRecord();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.secondary.withAlpha(60)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.cleaning_services, color: AppColors.secondary, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Limpar Antecedentes (Advogado Emérito)',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('Recurso especial na corte superior (Custo: R\$ 15.000)',
                                    style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrimeTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String description,
    required String rewardText,
    required String riskText,
    required String crimeId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentRose.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(riskText,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentRose)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(rewardText,
                    style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                BwTapFeedback(
                  sfx: GameSfx.buttonTap,
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(lifeEngineProvider.notifier).attemptCrime(crimeId);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentRose.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accentRose),
                    ),
                    child: const Text('Executar Crime',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
