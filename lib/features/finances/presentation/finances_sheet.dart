import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/finances/models/investment_model.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/presentation/widgets/lottery_modal.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/finances/presentation/crypto_modal.dart';
import 'package:bitweve/features/properties/presentation/garage_modal.dart';
import 'package:bitweve/features/businesses/presentation/business_sheet.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Finanças & Patrimônio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              BwTapFeedback(
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const LotteryModal(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accent.withAlpha(80)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.casino, size: 14, color: AppColors.accent),
                      SizedBox(width: 4),
                      Text('Mega-Sena', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Balanço e Patrimônio
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withAlpha(45),
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
                    const Text('Saldo em Conta:', style: TextStyle(color: AppColors.textSecondaryDark)),
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
                if (char.debt > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dívidas Pendentes:', style: TextStyle(color: AppColors.accentRose)),
                      Text(
                        'R\$ ${char.debt.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentRose,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Hub Financeiro Especializado (Cripto, Garagem, Empresas, Loteria)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickHubChip(
                  label: 'Criptomoedas 📈',
                  icon: Icons.currency_bitcoin,
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const CryptoModal(),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickHubChip(
                  label: 'Garagem & Veículos 🏎️',
                  icon: Icons.directions_car,
                  color: AppColors.primaryLight,
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const GarageModal(),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickHubChip(
                  label: 'Empresas & Startups 🏢',
                  icon: Icons.business_center,
                  color: Colors.amber,
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const BusinessSheet(),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickHubChip(
                  label: 'Mega-Sena 🎰',
                  icon: Icons.casino,
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const LotteryModal(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Ações de Investimento, Compra e Pagar Dívida
          Row(
            children: [
              Expanded(
                child: BwTapFeedback(
                  onTap: () => _showBuyPropertyDialog(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_home, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Comprar Bens', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BwTapFeedback(
                  onTap: () => _showInvestDialog(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Colors.black),
                        SizedBox(width: 6),
                        Text('Investir', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              if (char.debt > 0) ...[
                const SizedBox(width: 10),
                BwTapFeedback(
                  onTap: () => ref.read(lifeEngineProvider.notifier).payDebt(500),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentRose),
                    ),
                    child: const Icon(Icons.money_off, color: AppColors.accentRose, size: 18),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            'Bens & Investimentos Ativos',
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
                      ...state.properties.map((p) => _buildPropertyTile(context, ref, p)),
                      if (state.investments.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Carteira de Investimentos',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                        ),
                        const SizedBox(height: 8),
                        ...state.investments.map((inv) => _buildInvestmentTile(context, ref, inv)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTile(BuildContext context, WidgetRef ref, PropertyModel p) {
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
                  'Valor: R\$ ${p.currentValue.toStringAsFixed(0)}${p.isFinanced ? " • Dívida: R\$ ${p.remainingDebt.toStringAsFixed(0)}" : ""}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          ),
          BwTapFeedback(
            onTap: () {
              ref.read(lifeEngineProvider.notifier).sellProperty(p.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withAlpha(70)),
              ),
              child: const Text('Vender', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentTile(BuildContext context, WidgetRef ref, InvestmentModel inv) {
    final profit = inv.currentValue - inv.investedAmount;
    final isPositive = profit >= 0;

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
          const Icon(Icons.show_chart, color: AppColors.secondary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark)),
                Text(
                  'Atual: R\$ ${inv.currentValue.toStringAsFixed(2)} (${isPositive ? "+" : ""}R\$ ${profit.toStringAsFixed(2)})',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? AppColors.statHealth : AppColors.accentRose,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          BwTapFeedback(
            onTap: () {
              ref.read(lifeEngineProvider.notifier).sellInvestment(inv.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondary.withAlpha(70)),
              ),
              child: const Text('Resgatar', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyPropertyDialog(BuildContext context, WidgetRef ref) {
    final properties = [
      PropertyModel(id: 'car_1', saveId: '', type: 'car', name: 'Carro Popular Usado', purchasePrice: 28000, currentValue: 28000, annualCost: 2200, condition: 80, purchasedAtAge: 0),
      PropertyModel(id: 'car_2', saveId: '', type: 'car', name: 'Sedan Executivo Premium', purchasePrice: 85000, currentValue: 85000, annualCost: 4500, condition: 95, purchasedAtAge: 0),
      PropertyModel(id: 'house_1', saveId: '', type: 'real_estate', name: 'Apartamento de 2 Quartos', purchasePrice: 220000, currentValue: 220000, annualCost: 3500, condition: 90, purchasedAtAge: 0),
      PropertyModel(id: 'house_2', saveId: '', type: 'real_estate', name: 'Casa em Condomínio Fechado', purchasePrice: 650000, currentValue: 650000, annualCost: 7500, condition: 95, purchasedAtAge: 0),
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
              const Text('Catálogo de Bens Disponíveis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              ...properties.map((p) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('R\$ ${p.purchasePrice.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.secondary, fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(lifeEngineProvider.notifier).buyProperty(p, true);
                            },
                            child: const Text('Financiar', style: TextStyle(fontSize: 12)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(lifeEngineProvider.notifier).buyProperty(p, false);
                            },
                            child: const Text('À Vista', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
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
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Opções de Investimento', style: TextStyle(color: Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                tileColor: AppColors.cardDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.shield, color: AppColors.statHealth),
                title: const Text('Tesouro Selic / Renda Fixa', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Rendimentos seguros de 10.75% a.a.', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(lifeEngineProvider.notifier).invest('fixed_income', 'Tesouro Direto', 'SELIC', 1000);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: AppColors.cardDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.bar_chart, color: AppColors.primaryLight),
                title: const Text('Ações em Bolsa (IBOVESPA)', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Potencial de valorização e dividendos.', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(lifeEngineProvider.notifier).invest('stock', 'Fundo de Ações Brasil', 'BOVA11', 2000);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: AppColors.cardDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.currency_bitcoin, color: AppColors.accent),
                title: const Text('Criptoativos (Bitcoin / Web3)', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Alta volatilidade e grandes retornos.', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(lifeEngineProvider.notifier).invest('crypto', 'Bitcoin ETF', 'BTC', 1500);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondaryDark)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickHubChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BwTapFeedback(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

