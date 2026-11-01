import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class GodModeModal extends ConsumerStatefulWidget {
  const GodModeModal({super.key});

  @override
  ConsumerState<GodModeModal> createState() => _GodModeModalState();
}

class _GodModeModalState extends ConsumerState<GodModeModal> {
  late double _health;
  late double _happiness;
  late double _smarts;
  late double _looks;

  @override
  void initState() {
    super.initState();
    final char = ref.read(lifeEngineProvider).value?.character;
    _health = (char?.health ?? 90).toDouble();
    _happiness = (char?.happiness ?? 90).toDouble();
    _smarts = (char?.smarts ?? 50).toDouble();
    _looks = (char?.looks ?? 50).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lifeEngineProvider).value;
    if (state == null) return const SizedBox.shrink();

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
                    color: Colors.amber.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt, color: Colors.amber, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BitWeve God Mode (Modo Deus)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                      Text(
                        'Editor livre de realidade • 100% Gratuito',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
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

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.withAlpha(60)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield, color: Colors.amber, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ao utilizar o Modo Deus, este save será identificado com o selo especial de liberdade criativa.',
                          style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Money Cheats
                const Text('Finanças Divinas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: BwTapFeedback(
                        sfx: GameSfx.moneyGain,
                        onTap: () async {
                          await ref.read(lifeEngineProvider.notifier).godModeAddMoney(100000.0);
                        },
                        child: _cheatButton('+ R\$ 100.000'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BwTapFeedback(
                        sfx: GameSfx.moneyGain,
                        onTap: () async {
                          await ref.read(lifeEngineProvider.notifier).godModeAddMoney(10000000.0);
                        },
                        child: _cheatButton('+ R\$ 10.000.000 💰'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sliders for attributes
                const Text('Ajuste Fino de Atributos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 10),
                _buildSlider(
                  label: 'Saúde',
                  value: _health,
                  color: AppColors.accentRose,
                  onChanged: (v) => setState(() => _health = v),
                ),
                _buildSlider(
                  label: 'Felicidade',
                  value: _happiness,
                  color: Colors.amber,
                  onChanged: (v) => setState(() => _happiness = v),
                ),
                _buildSlider(
                  label: 'Intelecto (Smarts)',
                  value: _smarts,
                  color: AppColors.primary,
                  onChanged: (v) => setState(() => _smarts = v),
                ),
                _buildSlider(
                  label: 'Aparência (Looks)',
                  value: _looks,
                  color: Colors.purpleAccent,
                  onChanged: (v) => setState(() => _looks = v),
                ),
                const SizedBox(height: 12),
                BwTapFeedback(
                  sfx: GameSfx.achievement,
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).godModeSetStats(
                          health: _health.toInt(),
                          happiness: _happiness.toInt(),
                          smarts: _smarts.toInt(),
                          looks: _looks.toInt(),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Aplicar Novos Atributos ✨', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Super Miracles
                const Text('Milagres e Intervenções', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 10),
                _buildMiracleTile(
                  icon: Icons.healing,
                  title: 'Cura Divina Total',
                  subtitle: 'Erradicar todas as doenças ativas e restaurar a saúde em 100%.',
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).godModeCureAll();
                  },
                ),
                _buildMiracleTile(
                  icon: Icons.cleaning_services,
                  title: 'Apagar Passado Judicial',
                  subtitle: 'Zerar todas as prisões e limpar completamente a ficha criminal.',
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).godModeClearRecord();
                  },
                ),
                _buildMiracleTile(
                  icon: Icons.casino,
                  title: 'Ganhar Jackpot da Mega-Sena',
                  subtitle: 'Simular acerto de todas as 6 dezenas e creditar R\$ 12.500.000.',
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).godModeJackpot();
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

  Widget _cheatButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withAlpha(60)),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${value.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: color,
          inactiveColor: AppColors.cardHoverDark,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMiracleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BwTapFeedback(
        sfx: GameSfx.achievement,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.amber, size: 22),
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
            ],
          ),
        ),
      ),
    );
  }
}
