import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';

class CareersSheet extends ConsumerWidget {
  const CareersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(lifeEngineProvider);
    final state = stateAsync.value;
    final service = ref.watch(lifeEngineServiceProvider);

    if (state == null) return const SizedBox.shrink();

    final char = state.character;
    final availableCareers = service.availableCareers;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
            'Carreira & Ocupação',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
          // Emprego Atual ou Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(40),
                  AppColors.cardDark,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      char.currentJobTitle ?? (char.currentAge < 18 ? 'Estudante' : 'Desempregado(a)'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    if (char.currentSalary != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'R\$ ${char.currentSalary!.toStringAsFixed(0)}/ano',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
                if (char.currentJobTitle != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Desempenho no Trabalho',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                      ),
                      Text(
                        '${char.jobPerformance}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: char.jobPerformance / 100.0,
                      minHeight: 6,
                      backgroundColor: Colors.white.withAlpha(20),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.bolt, size: 16),
                          label: const Text('Trabalhar Duro', style: TextStyle(fontSize: 13)),
                          onPressed: () {
                            ref.read(lifeEngineProvider.notifier).workHard();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Vagas de Emprego Disponíveis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: char.currentAge < 16
                ? const Center(
                    child: Text(
                      'Você precisa ter pelo menos 16 anos para trabalhar.',
                      style: TextStyle(color: AppColors.textSecondaryDark),
                    ),
                  )
                : ListView.builder(
                    itemCount: availableCareers.length,
                    itemBuilder: (context, index) {
                      final job = availableCareers[index];
                      final isCurrent = job.id == char.currentJobId;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderDark, width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          title: Text(
                            job.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          subtitle: Text(
                            '${job.field} • Inicial: R\$ ${job.entrySalary.toStringAsFixed(0)}/ano\nExige Intelecto ${job.minSmarts}%',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          ),
                          trailing: isCurrent
                              ? const Chip(
                                  label: Text('Atual', style: TextStyle(fontSize: 11)),
                                  backgroundColor: AppColors.secondaryDark,
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    backgroundColor: AppColors.cardHoverDark,
                                  ),
                                  onPressed: () {
                                    ref.read(lifeEngineProvider.notifier).applyJob(job);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Candidatar-se', style: TextStyle(fontSize: 12)),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
