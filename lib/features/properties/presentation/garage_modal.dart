import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class GarageModal extends ConsumerStatefulWidget {
  const GarageModal({super.key});

  @override
  ConsumerState<GarageModal> createState() => _GarageModalState();
}

class _GarageModalState extends ConsumerState<GarageModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<VehicleModel> _dealershipCatalog = [
    VehicleModel(
      id: 'moto_150',
      name: 'Moto Street 160cc',
      category: VehicleCategory.motorcycle,
      year: 2024,
      purchasePrice: 16500.0,
      currentValue: 16500.0,
      annualMaintenance: 800.0,
      annualInsurance: 600.0,
    ),
    VehicleModel(
      id: 'hatch_pop',
      name: 'Hatchback Compacto 1.0',
      category: VehicleCategory.popular,
      year: 2024,
      purchasePrice: 52000.0,
      currentValue: 52000.0,
      annualMaintenance: 2200.0,
      annualInsurance: 1800.0,
    ),
    VehicleModel(
      id: 'sedan_mid',
      name: 'Sedã Executivo Turbo',
      category: VehicleCategory.sedan,
      year: 2024,
      purchasePrice: 115000.0,
      currentValue: 115000.0,
      annualMaintenance: 4500.0,
      annualInsurance: 3400.0,
    ),
    VehicleModel(
      id: 'suv_premium',
      name: 'SUV Híbrido Tecnológico',
      category: VehicleCategory.suv,
      year: 2025,
      purchasePrice: 260000.0,
      currentValue: 260000.0,
      annualMaintenance: 8500.0,
      annualInsurance: 6200.0,
    ),
    VehicleModel(
      id: 'super_sports',
      name: 'Superesportivo V8 Biturbo',
      category: VehicleCategory.sports,
      year: 2025,
      purchasePrice: 850000.0,
      currentValue: 850000.0,
      annualMaintenance: 24000.0,
      annualInsurance: 18000.0,
    ),
    VehicleModel(
      id: 'yacht_luxury',
      name: 'Iate de Luxo 42 Pés',
      category: VehicleCategory.boat,
      year: 2023,
      purchasePrice: 2800000.0,
      currentValue: 2800000.0,
      annualMaintenance: 85000.0,
      annualInsurance: 45000.0,
    ),
    VehicleModel(
      id: 'private_jet',
      name: 'Jato Executivo Continental',
      category: VehicleCategory.aircraft,
      year: 2024,
      purchasePrice: 14500000.0,
      currentValue: 14500000.0,
      annualMaintenance: 450000.0,
      annualInsurance: 280000.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lifeEngineProvider).value;
    if (state == null) return const SizedBox.shrink();

    final ownedVehicles = state.extras.vehicles;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
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
                  child: const Icon(Icons.directions_car, color: AppColors.primaryLight, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Garagem & Concessionária',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Veículos na garagem: ${ownedVehicles.length}',
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
          const SizedBox(height: 10),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primaryLight,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Minha Garagem 🏎️'),
                Tab(text: 'Concessionária 🏪'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Minha Garagem
                ownedVehicles.isEmpty
                    ? const Center(
                        child: Text(
                          'Sua garagem está vazia.\nAdquira um veículo na aba Concessionária!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondaryDark, height: 1.4),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: ownedVehicles.length,
                        itemBuilder: (context, index) {
                          final v = ownedVehicles[index];
                          return _buildOwnedVehicleCard(context, ref, v);
                        },
                      ),

                // 2. Concessionária
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _dealershipCatalog.length,
                  itemBuilder: (context, index) {
                    final v = _dealershipCatalog[index];
                    return _buildDealershipCard(context, ref, v, state.character.bankBalance);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnedVehicleCard(BuildContext context, WidgetRef ref, VehicleModel v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
              Text('R\$ ${v.currentValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Ano ${v.year} • ${v.mileageKm} km • Condição: ${v.conditionPercent}%',
                style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BwTapFeedback(
                sfx: GameSfx.buttonTap,
                onTap: () async {
                  await ref.read(lifeEngineProvider.notifier).serviceVehicle(v.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardHoverDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: const Text('Fazer Revisão (R\$ 600)', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              BwTapFeedback(
                sfx: GameSfx.moneyGain,
                onTap: () async {
                  await ref.read(lifeEngineProvider.notifier).sellVehicle(v.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentRose.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Vender Veículo', style: TextStyle(fontSize: 11, color: AppColors.accentRose, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDealershipCard(BuildContext context, WidgetRef ref, VehicleModel v, double currentBalance) {
    final canAfford = currentBalance >= v.purchasePrice;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIconForCategory(v.category), color: AppColors.primaryLight, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'Manutenção: R\$ ${v.annualMaintenance.toStringAsFixed(0)}/ano',
                  style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                ),
                Text(
                  'R\$ ${v.purchasePrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          BwTapFeedback(
            sfx: GameSfx.moneyLoss,
            onTap: () async {
              if (!canAfford) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saldo bancário insuficiente para adquirir este veículo.')),
                );
                return;
              }
              await ref.read(lifeEngineProvider.notifier).buyVehicle(v);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: canAfford ? AppColors.secondary : AppColors.cardHoverDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Comprar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: canAfford ? Colors.black : Colors.white38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(VehicleCategory cat) {
    switch (cat) {
      case VehicleCategory.motorcycle:
        return Icons.two_wheeler;
      case VehicleCategory.boat:
        return Icons.sailing;
      case VehicleCategory.aircraft:
        return Icons.flight;
      case VehicleCategory.sports:
        return Icons.speed;
      default:
        return Icons.directions_car;
    }
  }
}
