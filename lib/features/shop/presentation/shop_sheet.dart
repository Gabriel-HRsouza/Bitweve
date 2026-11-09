import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/shop/data/shop_catalog.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/motion.dart';

const effectNames = {
  'health': 'Saúde', 'happiness': 'Felicidade', 'smarts': 'Inteligência', 'looks': 'Aparência',
  'stress': 'Estresse', 'charisma': 'Carisma', 'fitness': 'Físico', 'karma': 'Karma', 'fame': 'Fama',
};

List<Widget> effectPills(Map<String, int> fx) => fx.entries.map((e) {
      final good = e.key == 'stress' ? e.value < 0 : e.value > 0;
      return Pill('${effectNames[e.key] ?? e.key} ${e.value > 0 ? '+' : ''}${e.value}', color: good ? GamePalette.green : GamePalette.red);
    }).toList();

class ShopSheet extends ConsumerStatefulWidget {
  const ShopSheet({super.key});

  @override
  ConsumerState<ShopSheet> createState() => _ShopSheetState();
}

class _ShopSheetState extends ConsumerState<ShopSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: ShopCatalog.categories.length + 1, vsync: this);

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
    return GameSheet(
      title: 'Loja',
      subtitle: 'Saldo: ${Fmt.money(s.character.bankBalance)}',
      icon: Icons.shopping_bag_rounded,
      color: GamePalette.teal,
      header: TabBar(
        controller: _tab,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          for (final c in ShopCatalog.categories) Tab(text: c.name, icon: Icon(c.icon, size: 18, color: c.color), height: 52),
          Tab(text: 'Inventário (${s.extras.inventory.length})', icon: Icon(Icons.inventory_2_rounded, size: 18, color: p.textDim), height: 52),
        ],
      ),
      body: TabBarView(controller: _tab, children: [
        for (final c in ShopCatalog.categories) _grid(s, ShopCatalog.items.where((i) => i.category == c.id).toList()),
        _inventory(s),
      ]),
    );
  }

  Widget _grid(LifeEngineState s, List<ShopItem> items) {
    final p = context.gp;
    return LayoutBuilder(builder: (context, box) {
      final cols = (box.maxWidth / 190).floor().clamp(2, 5);
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 228),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final it = items[i];
          final owned = s.extras.inventory.where((o) => o.itemId == it.id).length;
          final afford = s.character.bankBalance >= it.price;
          final card = GameCard(
            onTap: () => showGameSheet(context, ProductSheet(item: it), full: false),
            padding: const EdgeInsets.all(8),
            radius: 20,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Hero(tag: 'item-${it.id}', child: ItemArt(icon: it.icon, colors: it.colors, height: 112, tier: it.tier, badge: owned > 0 ? 'TEM ×$owned' : null)),
              const SizedBox(height: 8),
              Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 13.5)),
              Text(it.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.textMuted, fontSize: 11)),
              const Spacer(),
              Row(children: [
                Expanded(child: Text(Fmt.compactMoney(it.price), style: TextStyle(color: afford ? GamePalette.green : GamePalette.red, fontWeight: FontWeight.w900, fontSize: 14))),
                if (s.character.currentAge < it.minAge) Icon(Icons.lock_rounded, size: 16, color: p.textMuted),
              ]),
            ]),
          );
          if (!context.motion || i > 10) return card;
          return card.animate().fadeIn(delay: (i * 40).ms, duration: 250.ms).scale(begin: const Offset(0.94, 0.94));
        },
      );
    });
  }

  Widget _inventory(LifeEngineState s) {
    final p = context.gp;
    final inv = s.extras.inventory;
    if (inv.isEmpty) {
      return const EmptyState(icon: Icons.inventory_2_rounded, title: 'Inventário vazio', message: 'Tudo o que você comprar aparece aqui.', color: GamePalette.teal);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: inv.length,
      itemBuilder: (_, i) {
        final o = inv[inv.length - 1 - i];
        final it = ShopCatalog.item(o.itemId);
        if (it == null) return const SizedBox.shrink();
        final resale = (o.pricePaid > 0 ? o.pricePaid : it.price) * it.resale;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GameCard(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              SizedBox(width: 86, child: ItemArt(icon: it.icon, colors: it.colors, height: 70, tier: it.tier, radius: 14)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(it.name, style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                  Text('Comprado aos ${o.boughtAtAge} anos · ${o.pricePaid > 0 ? Fmt.money(o.pricePaid) : 'presente'}', style: TextStyle(color: p.textMuted, fontSize: 12)),
                ]),
              ),
              TextButton(
                onPressed: resale > 0
                    ? () async {
                        if (await confirmDialog(context, title: 'Vender ${it.name}?', message: 'Você receberá ${Fmt.money(resale)}.', confirm: 'Vender', color: GamePalette.green, icon: Icons.sell_rounded)) {
                          ref.read(lifeEngineProvider.notifier).act((v, st) => v.sellItem(st, o.id));
                        }
                      }
                    : null,
                child: Text(resale > 0 ? 'Vender\n${Fmt.compactMoney(resale)}' : 'Sem revenda', textAlign: TextAlign.center),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class ProductSheet extends ConsumerWidget {
  final ShopItem item;
  const ProductSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;
    final cat = ShopCatalog.category(item.category);
    final afford = s.character.bankBalance >= item.price;
    final ageOk = s.character.currentAge >= item.minAge;
    return Container(
      decoration: BoxDecoration(color: p.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: p.border, borderRadius: BorderRadius.circular(9)))),
            const SizedBox(height: 12),
            Hero(tag: 'item-${item.id}', child: ItemArt(icon: item.icon, colors: item.colors, height: 190, tier: item.tier, badge: cat.name.toUpperCase())),
            const SizedBox(height: 14),
            Text(item.name, style: AppTheme.display(24, color: p.text)),
            const SizedBox(height: 4),
            Text(item.description, style: TextStyle(color: p.textDim, fontSize: 14.5)),
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: [
              ...effectPills(item.effects),
              if (item.fame > 0) Pill('Fama +${item.fame}', color: const Color(0xFFA855F7)),
            ]),
            const SizedBox(height: 12),
            GameCard(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                _row(context, Icons.sell_rounded, 'Preço', Fmt.money(item.price)),
                _row(context, Icons.cake_rounded, 'Idade mínima', '${item.minAge} anos'),
                _row(context, Icons.replay_rounded, 'Revenda', item.resale > 0 ? '${(item.resale * 100).round()}% do valor' : 'Não revende'),
                if (item.annualCost > 0) _row(context, Icons.event_repeat_rounded, 'Manutenção', '${Fmt.money(item.annualCost)}/ano'),
              ]),
            ),
            const SizedBox(height: 16),
            GameButton(
              label: !ageOk ? 'Disponível aos ${item.minAge} anos' : (afford ? 'Comprar por ${Fmt.money(item.price)}' : 'Saldo insuficiente'),
              icon: Icons.shopping_cart_checkout_rounded,
              colors: item.colors,
              sfx: GameSfx.buttonTap,
              onTap: afford && ageOk
                  ? () async {
                      await ref.read(lifeEngineProvider.notifier).act((v, st) => v.buyItem(st, item.id));
                      if (context.mounted) Navigator.pop(context);
                    }
                  : null,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData i, String l, String v) {
    final p = context.gp;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(i, size: 17, color: GamePalette.teal),
        const SizedBox(width: 10),
        Text(l, style: TextStyle(color: p.textMuted)),
        const Spacer(),
        Text(v, style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
