import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

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
      height: MediaQuery.of(context).size.height * 0.85,
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
            'Carreira & Profissão',
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
                  AppColors.primary.withAlpha(45),
                  AppColors.cardDark,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(90), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        char.currentJobTitle ?? (char.currentAge < 18 ? 'Estudante' : 'Desempregado(a)'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (char.currentSalary != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.secondary.withAlpha(80)),
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
                        'Desempenho Profissional',
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        char.jobPerformance >= 70 ? AppColors.statHealth : AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: BwTapFeedback(
                          onTap: () => ref.read(lifeEngineProvider.notifier).workHard(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bolt, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text('Trabalhar Duro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BwTapFeedback(
                          onTap: () => ref.read(lifeEngineProvider.notifier).askForRaise(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.secondary.withAlpha(90)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.trending_up, size: 16, color: AppColors.secondary),
                                SizedBox(width: 6),
                                Text('Pedir Aumento', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BwTapFeedback(
                        onTap: () => ref.read(lifeEngineProvider.notifier).quitJob(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.redAccent.withAlpha(80)),
                          ),
                          child: const Icon(Icons.exit_to_app, size: 18, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vagas de Emprego Disponíveis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              BwTapFeedback(
                onTap: () {
                  ref.read(lifeEngineProvider.notifier).studyExtra();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Você completou um curso profissionalizante e seu intelecto subiu!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.school, size: 14, color: AppColors.primaryLight),
                      SizedBox(width: 4),
                      Text('Fazer Curso (+QI)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: char.currentAge < 16
                ? const Center(
                    child: Text(
                      'Você precisa ter pelo menos 16 anos para ingressar no mercado de trabalho.',
                      style: TextStyle(color: AppColors.textSecondaryDark),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: availableCareers.length,
                    itemBuilder: (context, index) {
                      final job = availableCareers[index];
                      final isCurrent = job.id == char.currentJobId;
                      final qualified = char.smarts >= job.minSmarts;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent ? AppColors.secondary : AppColors.borderDark,
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          title: Text(
                            job.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            'Salário: R\$ ${job.entrySalary.toStringAsFixed(0)}/ano • Intelecto mín: ${job.minSmarts}',
                            style: TextStyle(
                              fontSize: 12,
                              color: qualified ? AppColors.textSecondaryDark : AppColors.accentRose,
                            ),
                          ),
                          trailing: isCurrent
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Emprego Atual', style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                )
                              : BwTapFeedback(
                                  onTap: () {
                                    Navigator.pop(context);
                                    ref.read(lifeEngineProvider.notifier).applyJob(job);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: qualified ? AppColors.primary : AppColors.cardHoverDark,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Candidatar-se',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
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
