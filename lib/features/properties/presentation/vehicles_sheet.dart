import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';
import 'package:bitweve/features/shop/data/shop_catalog.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

class VehiclesSheet extends ConsumerStatefulWidget {
  const VehiclesSheet({super.key});

  @override
  ConsumerState<VehiclesSheet> createState() => _VehiclesSheetState();
}

class _VehiclesSheetState extends ConsumerState<VehiclesSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;
    final owned = s.extras.vehicles;

    return GameSheet(
      title: 'Veículos & Garagem',
      subtitle: '${owned.length} veículo(s) • Saldo: ${Fmt.money(s.character.bankBalance)}',
      icon: Icons.directions_car_rounded,
      color: GamePalette.cyan,
      header: TabBar(
        controller: _tab,
        tabs: [
          Tab(text: 'Minha Garagem (${owned.length})', icon: const Icon(Icons.garage_rounded, size: 18)),
          const Tab(text: 'Concessionária', icon: Icon(Icons.storefront_rounded, size: 18)),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // 1. Minha Garagem
          owned.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_car_outlined, size: 56, color: p.textDim),
                        const SizedBox(height: 12),
                        Text(
                          'Sua garagem está vazia.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: p.text, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Visite a Concessionária para comprar carros, motos, iates ou jatos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: p.textDim, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: owned.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final v = owned[i];
                    return GameCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconBadge(icon: _iconForCategory(v.category), color: GamePalette.cyan, size: 42),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(v.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: p.text)),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Ano ${v.year} • Condição: ${v.conditionPercent}% • Manutenção: ${Fmt.money(v.annualMaintenance)}/ano',
                                      style: TextStyle(fontSize: 12, color: p.textDim),
                                    ),
                                  ],
                                ),
                              ),
                              Text(Fmt.money(v.currentValue), style: const TextStyle(fontWeight: FontWeight.bold, color: GamePalette.green, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GameButton(
                                label: 'Revisão',
                                icon: Icons.build_rounded,
                                height: 36,
                                expand: false,
                                onTap: () => ref.read(lifeEngineProvider.notifier).serviceVehicle(v.id),
                              ),
                              const SizedBox(width: 8),
                              GameButton(
                                label: v.hasInsurance ? 'Seguro Ativo' : 'Contratar Seguro',
                                icon: Icons.shield_rounded,
                                height: 36,
                                expand: false,
                                colors: v.hasInsurance ? [GamePalette.green, GamePalette.green.withAlpha(200)] : null,
                                onTap: () => ref.read(lifeEngineProvider.notifier).toggleVehicleInsurance(v.id),
                              ),
                              const SizedBox(width: 8),
                              GameButton(
                                label: 'Vender',
                                icon: Icons.sell_rounded,
                                height: 36,
                                expand: false,
                                colors: const [GamePalette.red, Color(0xFF991B1B)],
                                onTap: () => ref.read(lifeEngineProvider.notifier).sellVehicle(v.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // 2. Concessionária
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ShopCatalog.vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final listing = ShopCatalog.vehicles[i];
              final canAfford = s.character.bankBalance >= listing.model.purchasePrice;
              final hasLicense = !listing.needsLicense || s.character.hasDriversLicense;

              return GameCard(
                child: Row(
                  children: [
                    IconBadge(icon: listing.icon, color: listing.colors.first, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(listing.model.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: p.text)),
                          const SizedBox(height: 2),
                          Text(listing.description, style: TextStyle(fontSize: 12, color: p.textDim)),
                          const SizedBox(height: 4),
                          Text(
                            '${Fmt.money(listing.model.purchasePrice)} • Manut: ${Fmt.money(listing.model.annualMaintenance)}/ano',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: GamePalette.cyan, fontSize: 12),
                          ),
                          if (listing.needsLicense && !s.character.hasDriversLicense)
                            const Text('Requer CNH (Autoescola em Educação)', style: TextStyle(color: GamePalette.gold, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GameButton(
                      label: 'Comprar',
                      icon: Icons.shopping_bag_rounded,
                      height: 38,
                      expand: false,
                      colors: canAfford && hasLicense ? listing.colors : null,
                      onTap: canAfford && hasLicense
                          ? () => ref.read(lifeEngineProvider.notifier).buyVehicleListing(listing.model.id)
                          : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(VehicleCategory cat) {
    switch (cat) {
      case VehicleCategory.motorcycle:
        return Icons.two_wheeler_rounded;
      case VehicleCategory.boat:
        return Icons.sailing_rounded;
      case VehicleCategory.aircraft:
        return Icons.flight_rounded;
      case VehicleCategory.sports:
        return Icons.speed_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }
}
