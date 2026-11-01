import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/health/models/health_condition.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class HealthSheet extends ConsumerWidget {
  const HealthSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeEngineProvider).value;
    if (state == null) return const SizedBox.shrink();

    final char = state.character;
    final conditions = ref.watch(lifeEngineServiceProvider).getActiveConditions(char.saveId);
    final hasInsurance = ref.watch(lifeEngineServiceProvider).hasHealthInsurance(char.saveId);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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
                  child: const Icon(Icons.favorite, color: AppColors.accentRose, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Centro de Saúde e Cuidados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      Text(
                        'Saúde: ${char.health}% • Estresse: ${char.stress}%',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
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

          // Content List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Insurance Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: hasInsurance ? AppColors.secondary.withAlpha(20) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasInsurance ? AppColors.secondary : AppColors.borderDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasInsurance ? Icons.verified_user : Icons.health_and_safety_outlined,
                        color: hasInsurance ? AppColors.secondary : AppColors.textSecondaryDark,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasInsurance ? 'Plano de Saúde Privado Ativo' : 'Cobertura: SUS / Rede Pública',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                            Text(
                              hasInsurance
                                  ? 'Consultas e exames cobertos com coparticipação zero.'
                                  : 'Atendimento gratuito na rede pública ou pague no particular.',
                              style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      BwTapFeedback(
                        sfx: GameSfx.buttonTap,
                        onTap: () async {
                          await ref.read(lifeEngineProvider.notifier).toggleHealthInsurance();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: hasInsurance ? AppColors.accentRose.withAlpha(40) : AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            hasInsurance ? 'Cancelar' : 'Assinar (R\$ 320/ano)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: hasInsurance ? AppColors.accentRose : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Active Conditions Section
                const Text(
                  'Condições Médicas e Neurodesenvolvimento',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                if (conditions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Nenhum diagnóstico crônico ou agudo no momento. Realize exames periódicos!',
                            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...conditions.map((cond) => _buildConditionCard(context, ref, cond)),

                const SizedBox(height: 24),
                const Text(
                  'Atendimentos e Consultas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Medical options
                _buildActionTile(
                  icon: Icons.local_hospital,
                  title: 'Posto de Saúde / Hospital Público (SUS)',
                  subtitle: 'Atendimento médico gratuito com tempo de espera padrão.',
                  costText: 'Gratuito',
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).consultPublicHealth();
                  },
                ),
                _buildActionTile(
                  icon: Icons.medical_services_outlined,
                  title: 'Clínico Geral Particular',
                  subtitle: 'Checkup preventivo, aferição de pressão e exames de rotina.',
                  costText: hasInsurance ? 'Coberto pelo Plano' : 'R\$ 220,00',
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).consultGeneralPractitioner();
                  },
                ),
                _buildActionTile(
                  icon: Icons.psychology,
                  title: 'Psicologia e Psicoterapia (TCC)',
                  subtitle: 'Fortalecimento emocional, redução drástica de estresse (+felicidade).',
                  costText: hasInsurance ? 'Coberto pelo Plano' : 'R\$ 160,00',
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).consultPsychologist();
                  },
                ),
                _buildActionTile(
                  icon: Icons.biotech,
                  title: 'Avaliação Neuropsiquiátrica',
                  subtitle: 'Investigação profunda de neurodesenvolvimento (TDAH, TEA) e humor.',
                  costText: hasInsurance ? 'Coberto pelo Plano' : 'R\$ 380,00',
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).consultPsychiatrist();
                  },
                ),
                _buildActionTile(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Cardiologista / Especialista Clínico',
                  subtitle: 'Eletrocardiograma, exames metabólicos e cuidados preventivos.',
                  costText: hasInsurance ? 'Coberto pelo Plano' : 'R\$ 290,00',
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).consultCardiologist();
                  },
                ),
                _buildActionTile(
                  icon: Icons.medication_outlined,
                  title: 'Farmácia de Medicamentos',
                  subtitle: 'Adquirir remédios prescritos para as suas condições ativas.',
                  costText: 'Valores por receita',
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).buyPrescribedMedicine();
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard(BuildContext context, WidgetRef ref, HealthCondition cond) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.healing, color: AppColors.primaryLight, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cond.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cond.treatmentState == TreatmentState.underControl
                      ? AppColors.secondary.withAlpha(40)
                      : AppColors.accentRose.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  cond.treatmentState == TreatmentState.underControl ? 'Em Controle' : 'Em Tratamento',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: cond.treatmentState == TreatmentState.underControl ? AppColors.secondary : AppColors.accentRose,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cond.description,
            style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Suporte: ${cond.supportNeeds}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          if (cond.medicationName != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medicamento: ${cond.medicationName}',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                ),
                BwTapFeedback(
                  sfx: GameSfx.buttonTap,
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).treatSpecificCondition(cond.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.cardHoverDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: const Text('Tomar Dose', style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String costText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BwTapFeedback(
        sfx: GameSfx.buttonTap,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryLight, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: costText == 'Gratuito' || costText.contains('Plano')
                      ? AppColors.secondary.withAlpha(30)
                      : AppColors.cardHoverDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  costText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: costText == 'Gratuito' || costText.contains('Plano')
                        ? AppColors.secondary
                        : AppColors.textPrimaryDark,
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
