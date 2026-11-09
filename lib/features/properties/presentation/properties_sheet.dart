import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/shop/data/shop_catalog.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/scene_art.dart';
import 'package:bitweve/features/parties/presentation/party_planner_sheet.dart';
import 'package:bitweve/features/properties/models/property_meta.dart';

class PropertiesSheet extends ConsumerStatefulWidget {
  const PropertiesSheet({super.key});

  @override
  ConsumerState<PropertiesSheet> createState() => _PropertiesSheetState();
}

class _PropertiesSheetState extends ConsumerState<PropertiesSheet> with SingleTickerProviderStateMixin {
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
    final owned = s.properties;

    return GameSheet(
      title: 'Mercado Imobiliário',
      subtitle: '${owned.length} propriedade(s) • Saldo: ${Fmt.money(s.character.bankBalance)}',
      icon: Icons.villa_rounded,
      color: GamePalette.orange,
      header: TabBar(
        controller: _tab,
        tabs: [
          Tab(text: 'Meus Imóveis (${owned.length})', icon: const Icon(Icons.home_work_rounded, size: 18)),
          const Tab(text: 'Imobiliária', icon: Icon(Icons.storefront_rounded, size: 18)),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // 1. Meus Imóveis
          owned.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_work_outlined, size: 56, color: p.textDim),
                        const SizedBox(height: 12),
                        Text(
                          'Você não possui imóveis.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: p.text, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Compre um imóvel na Imobiliária para morar ou alugar e obter renda passiva.',
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
                    final prop = owned[i];
                    final isHome = s.extras.homePropertyId == prop.id;
                    final isRented = s.extras.rentedOut.contains(prop.id);
                    final meta = s.extras.propertyMeta[prop.id];
                    final listing = ShopCatalog.propertyListingByName(prop.name);
                    final colors = listing?.colors ?? const [GamePalette.orange, Color(0xFF9A3412)];

                    return GameCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BuildingArt(
                            type: prop.type,
                            colors: colors,
                            height: 120,
                            decor: meta?.decorLevel ?? 0,
                            badge: prop.isCommercial ? 'Comercial' : (isHome ? 'Moradia' : (isRented ? 'Alugado' : 'Disponível')),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              IconBadge(icon: listing?.icon ?? Icons.home_rounded, color: colors.first, size: 42),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(prop.name,
                                              maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: p.text)),
                                        ),
                                        if (isHome) ...[
                                          const SizedBox(width: 6),
                                          const Pill('Sua Casa', color: GamePalette.blue),
                                        ],
                                        if (isRented) ...[
                                          const SizedBox(width: 6),
                                          const Pill('Alugado', color: GamePalette.green),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Valor atual: ${Fmt.money(prop.currentValue)}${prop.isFinanced ? ' • Dívida: ${Fmt.money(prop.remainingDebt)}' : ''}',
                                      style: TextStyle(fontSize: 12, color: p.textDim),
                                    ),
                                    Text(
                                      '${meta?.district.isNotEmpty == true ? meta!.district : 'Bairro não informado'} · ${meta?.sizeM2 ?? '—'} m² · estado ${prop.condition}% · custo ${Fmt.money(prop.annualCost)}/ano',
                                      style: TextStyle(fontSize: 11.5, color: p.textMuted),
                                    ),
                                    Text(
                                      'Decoração ${meta?.styleLabel ?? 'Básica'} (${meta?.decorLevel ?? 0}/5) · ${meta?.partiesHosted ?? 0} festa(s)${listing != null ? ' · aluguel ~${Fmt.money(listing.rentIncome)}/ano' : ''}',
                                      style: TextStyle(fontSize: 11.5, color: p.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (!isHome)
                                GameButton(
                                  label: 'Mudar para cá',
                                  icon: Icons.move_to_inbox_rounded,
                                  height: 36,
                                  expand: false,
                                  onTap: () => ref.read(lifeEngineProvider.notifier).moveInto(prop.id),
                                ),
                              GameButton(
                                label: isRented ? 'Desocupar' : 'Alugar Imóvel',
                                icon: Icons.vpn_key_rounded,
                                height: 36,
                                expand: false,
                                colors: isRented ? [GamePalette.gold, Colors.amber.shade800] : null,
                                onTap: () => ref.read(lifeEngineProvider.notifier).toggleRent(prop.id),
                              ),
                              GameButton(
                                label: 'Reformar',
                                icon: Icons.handyman_rounded,
                                height: 36,
                                expand: false,
                                onTap: () => ref.read(lifeEngineProvider.notifier).renovate(prop.id),
                              ),
                              if (!prop.isCommercial)
                                GameButton(
                                  label: 'Decorar',
                                  icon: Icons.chair_rounded,
                                  height: 36,
                                  expand: false,
                                  colors: const [GamePalette.gold, Color(0xFFB45309)],
                                  onTap: () => _decorate(context, prop.id, meta?.decorStyle),
                                ),
                              if (!prop.isCommercial)
                                GameButton(
                                  label: 'Dar festa',
                                  icon: Icons.celebration_rounded,
                                  height: 36,
                                  expand: false,
                                  colors: const [GamePalette.pink, Color(0xFF9D174D)],
                                  onTap: () => showGameSheet(context, PartyPlannerSheet(initialType: 'friends', propertyId: prop.id)),
                                ),
                              GameButton(
                                label: 'Vender',
                                icon: Icons.sell_rounded,
                                height: 36,
                                expand: false,
                                colors: const [GamePalette.red, Color(0xFF991B1B)],
                                onTap: () => ref.read(lifeEngineProvider.notifier).sellProperty(prop.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // 2. Imobiliária
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ShopCatalog.properties.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final listing = ShopCatalog.properties[i];
              final canAffordCash = s.character.bankBalance >= listing.price;
              final downPayment = listing.price * 0.2;
              final canAffordFinance = s.character.bankBalance >= downPayment;

              return GameCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BuildingArt(type: listing.type, colors: listing.colors, height: 110, badge: '${listing.bedrooms > 0 ? '${listing.bedrooms} quarto(s)' : 'Comercial'} · tier ${listing.tier}'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconBadge(icon: listing.icon, color: listing.colors.first, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listing.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: p.text)),
                              const SizedBox(height: 2),
                              Text(listing.description, style: TextStyle(fontSize: 12, color: p.textDim)),
                              const SizedBox(height: 4),
                              Text(
                                '${Fmt.money(listing.price)} • Aluguel: ${Fmt.money(listing.rentIncome)}/ano',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: GamePalette.orange, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GameButton(
                            label: 'Financiar (${Fmt.compactMoney(downPayment)})',
                            icon: Icons.account_balance_wallet_rounded,
                            height: 38,
                            onTap: canAffordFinance
                                ? () => ref.read(lifeEngineProvider.notifier).buyPropertyListing(listing.id, true)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GameButton(
                            label: 'À Vista',
                            icon: Icons.check_circle_rounded,
                            height: 38,
                            colors: canAffordCash ? listing.colors : null,
                            onTap: canAffordCash
                                ? () => ref.read(lifeEngineProvider.notifier).buyPropertyListing(listing.id, false)
                                : null,
                          ),
                        ),
                      ],
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

  Future<void> _decorate(BuildContext context, String propertyId, String? current) async {
    final style = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Estilo de decoração'),
        children: [
          for (final e in PropertyMeta.styles.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e.key),
              child: Row(children: [
                Icon(e.key == current ? Icons.check_circle_rounded : Icons.chair_rounded, size: 18),
                const SizedBox(width: 8),
                Text(e.key == current ? '${e.value} (subir nível)' : e.value),
              ]),
            ),
        ],
      ),
    );
    if (style != null) await ref.read(lifeEngineProvider.notifier).act((v, st) => v.decorate(st, propertyId, style));
  }
}
