import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/properties/models/property_model.dart';

class FinancesSheet extends ConsumerWidget {
  const FinancesSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(lifeEngineProvider);
    final state = stateAsync.value;

    if (state == null) return const SizedBox.shrink();

    final char = state.character;
    final netWorth = state.netWorth;

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
            'Finanças & Patrimônio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
          // Balanço e Patrimônio
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withAlpha(40),
                  AppColors.cardDark,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withAlpha(80), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Conta Corrente:', style: TextStyle(color: AppColors.textSecondaryDark)),
                    Text(
                      'R\$ ${char.bankBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Patrimônio Líquido Total:', style: TextStyle(color: AppColors.textSecondaryDark)),
                    Text(
                      'R\$ ${netWorth.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Ações de Investimento e Compra
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.add_home, size: 18),
                  label: const Text('Comprar Bens', style: TextStyle(fontSize: 13)),
                  onPressed: () => _showBuyPropertyDialog(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.trending_up, size: 18),
                  label: const Text('Investir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  onPressed: () => _showInvestDialog(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Seus Bens e Propriedades',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.properties.isEmpty && state.investments.isEmpty
                ? const Center(
                    child: Text(
                      'Você ainda não possui bens ou investimentos cadastrados.',
                      style: TextStyle(color: AppColors.textSecondaryDark),
                    ),
                  )
                : ListView(
                    children: [
                      ...state.properties.map((p) => _buildPropertyTile(p)),
                      if (state.investments.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Carteira de Investimentos',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                        ),
                        const SizedBox(height: 8),
                        ...state.investments.map((inv) => _buildInvestmentTile(inv)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTile(PropertyModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Row(
        children: [
          Icon(p.isRealEstate ? Icons.apartment : Icons.directions_car, color: AppColors.primaryLight, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark)),
                Text(
                  'Valor: R\$ ${p.currentValue.toStringAsFixed(0)} • Custo anual: R\$ ${p.annualCost.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentTile(dynamic inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${inv.name} (${inv.ticker})', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark)),
              Text('Aporte: R\$ ${inv.investedAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
            ],
          ),
          Text(
            'R\$ ${inv.currentValue.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  void _showBuyPropertyDialog(BuildContext context, WidgetRef ref) {
    final sampleProperties = [
      PropertyModel(
        id: 'prop_apt_compact',
        saveId: '',
        type: 'apartment',
        name: 'Apartamento Studio Moderno',
        purchasePrice: 220000,
        currentValue: 220000,
        annualCost: 4000,
        purchasedAtAge: 0,
      ),
      PropertyModel(
        id: 'prop_house_suburb',
        saveId: '',
        type: 'house',
        name: 'Casa em Bairro Nobre',
        purchasePrice: 650000,
        currentValue: 650000,
        annualCost: 8500,
        purchasedAtAge: 0,
      ),
      PropertyModel(
        id: 'prop_car_popular',
        saveId: '',
        type: 'car',
        name: 'Hatch Compacto 0km',
        purchasePrice: 65000,
        currentValue: 65000,
        annualCost: 3500,
        purchasedAtAge: 0,
      ),
      PropertyModel(
        id: 'prop_car_luxury',
        saveId: '',
        type: 'car',
        name: 'Sedan Executivo Alemão',
        purchasePrice: 280000,
        currentValue: 280000,
        annualCost: 12000,
        purchasedAtAge: 0,
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Catálogo de Bens e Veículos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark)),
              const SizedBox(height: 12),
              ...sampleProperties.map((p) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(p.isRealEstate ? Icons.home : Icons.directions_car, color: AppColors.primaryLight),
                  title: Text(p.name, style: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600)),
                  subtitle: Text('R\$ ${p.purchasePrice.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.secondary)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref.read(lifeEngineProvider.notifier).buyProperty(p, false);
                    },
                    child: const Text('Comprar', style: TextStyle(fontSize: 12)),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showInvestDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Oportunidades de Investimento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark)),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Tesouro Renda Fixa (10.5% a.a.)', style: TextStyle(color: AppColors.textPrimaryDark)),
                subtitle: const Text('Baixo risco, rendimento previsível', style: TextStyle(color: AppColors.textSecondaryDark)),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(lifeEngineProvider.notifier).invest('fixed_income', 'Tesouro Direto', 'TD10', 5000);
                  },
                  child: const Text('Aportar R\$ 5k'),
                ),
              ),
              ListTile(
                title: const Text('Ações Tecnológicas', style: TextStyle(color: AppColors.textPrimaryDark)),
                subtitle: const Text('Alto potencial de valorização', style: TextStyle(color: AppColors.textSecondaryDark)),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(lifeEngineProvider.notifier).invest('stock', 'Tech Global', 'TECH4', 10000);
                  },
                  child: const Text('Aportar R\$ 10k'),
                ),
              ),
              ListTile(
                title: const Text('Criptomoedas', style: TextStyle(color: AppColors.textPrimaryDark)),
                subtitle: const Text('Altíssima volatilidade e risco', style: TextStyle(color: AppColors.textSecondaryDark)),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(lifeEngineProvider.notifier).invest('crypto', 'Bitcoin', 'BTC', 2500);
                  },
                  child: const Text('Aportar R\$ 2.5k'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
