import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/businesses/models/business_model.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class BusinessSheet extends ConsumerWidget {
  const BusinessSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeEngineProvider).value;
    if (state == null) return const SizedBox.shrink();

    final businesses = ref.watch(lifeEngineServiceProvider).getBusinesses(state.character.saveId);

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
                    color: AppColors.primary.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business_center, color: AppColors.primaryLight, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Empreendedorismo & Negócios',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Empresas ativas: ${businesses.length}',
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

          // Action: Start new Business button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BwTapFeedback(
              sfx: GameSfx.buttonTap,
              onTap: () => _showStartBusinessDialog(context, ref, state.character.bankBalance),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Fundar Nova Empresa 🚀',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Businesses list
          Expanded(
            child: businesses.isEmpty
                ? const Center(
                    child: Text(
                      'Você ainda não possui nenhuma empresa fundada.\nCrie sua primeira startup ou comércio!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondaryDark, height: 1.4),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: businesses.length,
                    itemBuilder: (context, index) {
                      final b = businesses[index];
                      return _buildBusinessCard(context, ref, b);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, WidgetRef ref, BusinessModel b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Valuation: R\$ ${b.valuation.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Faturamento: R\$ ${b.revenue.toStringAsFixed(0)}/ano',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Custos: R\$ ${b.expenses.toStringAsFixed(0)}/ano',
                  style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Funcionários: ${b.employeeCount}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                'Lucro Líquido: R\$ ${b.netProfit.toStringAsFixed(0)}/ano',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: b.netProfit >= 0 ? AppColors.secondary : AppColors.accentRose,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BwTapFeedback(
                  sfx: GameSfx.buttonTap,
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).hireEmployees(b.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardHoverDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: const Center(
                      child: Text('Contratar +2', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BwTapFeedback(
                  sfx: GameSfx.buttonTap,
                  onTap: () async {
                    await ref.read(lifeEngineProvider.notifier).investMarketing(b.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardHoverDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: const Center(
                      child: Text('Marketing (R\$ 2k)', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BwTapFeedback(
                sfx: GameSfx.moneyGain,
                onTap: () async {
                  await ref.read(lifeEngineProvider.notifier).sellBusiness(b.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentRose.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Vender Empresa',
                      style: TextStyle(fontSize: 11, color: AppColors.accentRose, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStartBusinessDialog(BuildContext context, WidgetRef ref, double bankBalance) {
    final nameController = TextEditingController(text: 'Nexus Inovação');
    String selectedIndustry = 'tech_startup';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Fundar Nova Empresa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome da Empresa',
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Ramo de Atuação:', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: selectedIndustry,
                dropdownColor: AppColors.surfaceDark,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'tech_startup', child: Text('Startup de Tecnologia (Investimento R\$ 25.000)')),
                  DropdownMenuItem(value: 'restaurant', child: Text('Restaurante Gourmet (Investimento R\$ 40.000)')),
                  DropdownMenuItem(value: 'digital_agency', child: Text('Agência Digital (Investimento R\$ 12.000)')),
                  DropdownMenuItem(value: 'retail_store', child: Text('Loja / E-commerce (Investimento R\$ 18.000)')),
                ],
                onChanged: (val) {
                  if (val != null) setDlgState(() => selectedIndustry = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final name = nameController.text.trim();
                Navigator.pop(ctx);
                if (name.isNotEmpty) {
                  await ref.read(lifeEngineProvider.notifier).startBusiness(name, selectedIndustry);
                }
              },
              child: const Text('Fundar Empresa', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
