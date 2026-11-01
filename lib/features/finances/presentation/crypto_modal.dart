import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/finances/models/crypto_asset.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class CryptoModal extends ConsumerStatefulWidget {
  const CryptoModal({super.key});

  @override
  ConsumerState<CryptoModal> createState() => _CryptoModalState();
}

class _CryptoModalState extends ConsumerState<CryptoModal> {
  String _selectedSymbol = 'BTC';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lifeEngineProvider).value;
    if (state == null) return const SizedBox.shrink();

    final service = ref.watch(lifeEngineServiceProvider);
    final wallet = service.getCryptoWallet(state.character.saveId);
    final currentAsset = wallet.firstWhere(
      (a) => a.symbol == _selectedSymbol,
      orElse: () => wallet.first,
    );

    final totalPortfolio = wallet.fold<double>(0.0, (acc, a) => acc + a.totalValue);

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
                    color: AppColors.secondary.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.currency_bitcoin, color: AppColors.secondary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mercado Cripto BitWeve',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Patrimônio em Cripto: R\$ ${totalPortfolio.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
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

          // Asset Selector Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: wallet.map((asset) {
                final isSelected = asset.symbol == _selectedSymbol;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: BwTapFeedback(
                      sfx: GameSfx.buttonTap,
                      onTap: () => setState(() => _selectedSymbol = asset.symbol),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withAlpha(50) : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.borderDark,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              asset.symbol,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primaryLight : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${asset.change24hPercent >= 0 ? '+' : ''}${asset.change24hPercent.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: asset.change24hPercent >= 0 ? AppColors.secondary : AppColors.accentRose,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Main Asset Display
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Price Banner
                Container(
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
                          Text(
                            currentAsset.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: currentAsset.change24hPercent >= 0
                                  ? AppColors.secondary.withAlpha(30)
                                  : AppColors.accentRose.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${currentAsset.change24hPercent >= 0 ? '+' : ''}${currentAsset.change24hPercent.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: currentAsset.change24hPercent >= 0 ? AppColors.secondary : AppColors.accentRose,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'R\$ ${currentAsset.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chart
                      SizedBox(
                        height: 140,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: currentAsset.priceHistory.asMap().entries.map((e) {
                                  return FlSpot(e.key.toDouble(), e.value);
                                }).toList(),
                                isCurved: true,
                                color: currentAsset.change24hPercent >= 0 ? AppColors.secondary : AppColors.accentRose,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: (currentAsset.change24hPercent >= 0 ? AppColors.secondary : AppColors.accentRose)
                                      .withAlpha(35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // User Holdings Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Suas Unidades', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${currentAsset.ownedUnits.toStringAsFixed(4)} ${currentAsset.symbol}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Valor em Reais', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            'R\$ ${currentAsset.totalValue.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Trade Actions
                Row(
                  children: [
                    Expanded(
                      child: BwTapFeedback(
                        sfx: GameSfx.moneyLoss,
                        onTap: () => _showBuyDialog(context, currentAsset),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withAlpha(60),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Comprar Cripto 📈',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BwTapFeedback(
                        sfx: GameSfx.moneyGain,
                        onTap: () => _showSellDialog(context, currentAsset),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.cardHoverDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: const Center(
                            child: Text(
                              'Vender Cripto 📉',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog(BuildContext context, CryptoAsset asset) {
    final controller = TextEditingController(text: '500');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Comprar ${asset.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cotação atual: R\$ ${asset.currentPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Valor em R\$ para investir',
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim()) ?? 0.0;
              Navigator.pop(ctx);
              if (amount > 0) {
                await ref.read(lifeEngineProvider.notifier).buyCrypto(asset.symbol, amount);
              }
            },
            child: const Text('Confirmar Compra', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSellDialog(BuildContext context, CryptoAsset asset) {
    if (asset.ownedUnits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você não possui unidades de ${asset.symbol} para vender.')),
      );
      return;
    }

    final controller = TextEditingController(text: (asset.totalValue / 2).toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Vender ${asset.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seu saldo: ${asset.ownedUnits.toStringAsFixed(4)} ${asset.symbol} (R\$ ${asset.totalValue.toStringAsFixed(2)})'),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Valor em R\$ para resgatar',
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim()) ?? 0.0;
              Navigator.pop(ctx);
              if (amount > 0) {
                await ref.read(lifeEngineProvider.notifier).sellCrypto(asset.symbol, amount);
              }
            },
            child: const Text('Confirmar Venda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
