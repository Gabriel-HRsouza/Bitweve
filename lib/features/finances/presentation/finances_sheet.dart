import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/finances/presentation/crypto_modal.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/finance_system.dart';
import 'package:bitweve/features/life_engine/systems/life_draft.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

class FinancesSheet extends ConsumerStatefulWidget {
  const FinancesSheet({super.key});

  @override
  ConsumerState<FinancesSheet> createState() => _FinancesSheetState();
}

class _FinancesSheetState extends ConsumerState<FinancesSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    return GameSheet(
      title: 'Finanças',
      subtitle: 'Patrimônio ${Fmt.money(s.netWorth)}',
      icon: Icons.account_balance_rounded,
      color: GamePalette.green,
      header: TabBar(controller: _tab, tabs: const [
        Tab(text: 'Visão geral', icon: Icon(Icons.pie_chart_rounded, size: 18), height: 52),
        Tab(text: 'Investir', icon: Icon(Icons.trending_up_rounded, size: 18), height: 52),
        Tab(text: 'Crédito', icon: Icon(Icons.credit_card_rounded, size: 18), height: 52),
      ]),
      body: TabBarView(controller: _tab, children: [_overview(s), _invest(s), _credit(s)]),
    );
  }

  Widget _overview(LifeEngineState s) {
    final p = context.gp;
    final c = s.character;
    final parts = [
      ('Dinheiro em conta', c.bankBalance.clamp(0.0, double.infinity).toDouble(), GamePalette.green, Icons.account_balance_wallet_rounded),
      ('Imóveis (líquido)', s.propertiesEquity, GamePalette.orange, Icons.villa_rounded),
      ('Investimentos', s.investmentsValue, GamePalette.blue, Icons.show_chart_rounded),
      ('Veículos', s.vehiclesValue, GamePalette.cyan, Icons.directions_car_rounded),
      ('Criptomoedas', s.cryptoValue, const Color(0xFFF59E0B), Icons.currency_bitcoin_rounded),
      ('Empresas', s.businessValue, GamePalette.teal, Icons.rocket_launch_rounded),
    ];
    final total = parts.fold<double>(0, (a, b) => a + b.$2.clamp(0, double.infinity));
    final debts = c.debt + s.extras.loansTotal;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        GameCard(
          gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF065F46)]),
          glow: true,
          accent: GamePalette.green,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Patrimônio líquido', style: TextStyle(color: Colors.white.withAlpha(220), fontWeight: FontWeight.w700)),
            AnimatedMoney(s.netWorth, style: AppTheme.display(32, color: Colors.white)),
            const SizedBox(height: 10),
            if (total > 0)
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 12,
                  child: Row(children: [
                    for (final part in parts)
                      if (part.$2 > 0) Expanded(flex: (part.$2 / total * 1000).round().clamp(1, 1000), child: Container(color: part.$3)),
                  ]),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        GameCard(
          child: Column(children: [
            for (final part in parts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  IconBadge(icon: part.$4, color: part.$3, size: 32),
                  const SizedBox(width: 10),
                  Expanded(child: Text(part.$1, style: TextStyle(color: p.textDim, fontWeight: FontWeight.w600))),
                  Text(Fmt.money(part.$2), style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                ]),
              ),
            if (debts > 0) ...[
              const Divider(height: 18),
              Row(children: [
                const IconBadge(icon: Icons.money_off_rounded, color: GamePalette.red, size: 32),
                const SizedBox(width: 10),
                Expanded(child: Text('Dívidas e empréstimos', style: TextStyle(color: p.textDim, fontWeight: FontWeight.w600))),
                Text('-${Fmt.money(debts)}', style: const TextStyle(color: GamePalette.red, fontWeight: FontWeight.w800)),
              ]),
            ],
          ]),
        ),
        const SectionTitle('Fluxo anual', icon: Icons.swap_vert_rounded),
        Row(children: [
          Expanded(child: _FlowCard(label: 'Salário bruto', value: c.currentSalary ?? 0, color: GamePalette.green, icon: Icons.payments_rounded)),
          const SizedBox(width: 10),
          Expanded(child: _FlowCard(label: 'Despesas (último ano)', value: c.annualExpenses, color: GamePalette.red, icon: Icons.receipt_long_rounded)),
        ]),
        const SizedBox(height: 10),
        GameCard(
          child: Row(children: [
            IconBadge(icon: Icons.credit_score_rounded, color: GamePalette.forValue(((c.creditScore - 300) / 5.5).round()), size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Score de crédito: ${c.creditScore}', style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                Text(s.extras.movedOut ? (s.extras.homePropertyId != null ? 'Mora em imóvel próprio' : 'Mora de aluguel') : 'Mora com a família',
                    style: TextStyle(color: p.textMuted, fontSize: 12)),
              ]),
            ),
            if (!s.extras.movedOut && c.currentAge >= 18)
              TextButton(onPressed: () => ref.read(lifeEngineProvider.notifier).act((v, st) => v.moveOut(st)), child: const Text('Sair de casa')),
          ]),
        ),
        const SizedBox(height: 10),
        GameButton(
          label: 'Mercado de criptomoedas',
          icon: Icons.currency_bitcoin_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFB45309)],
          onTap: () => showGameSheet(context, const CryptoModal(), full: false),
        ),
      ],
    );
  }

  Widget _invest(LifeEngineState s) {
    final p = context.gp;
    final notifier = ref.read(lifeEngineProvider.notifier);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        if (s.investments.isNotEmpty) ...[
          const SectionTitle('Sua carteira', icon: Icons.work_history_rounded),
          ...s.investments.map((inv) {
            final opt = FinanceSystem.investmentOptions.where((o) => o.type == inv.type).firstOrNull;
            final up = inv.profitOrLoss >= 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GameCard(
                accent: opt?.color,
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  IconBadge(icon: opt?.icon ?? Icons.show_chart_rounded, color: opt?.color ?? GamePalette.blue, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${inv.name} · ${inv.ticker}', style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                      Text('Investido ${Fmt.money(inv.investedAmount)} · ${up ? '+' : ''}${inv.profitPercent.toStringAsFixed(1)}%',
                          style: TextStyle(color: up ? GamePalette.green : GamePalette.red, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(Fmt.money(inv.currentValue), style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
                    TextButton(onPressed: () => notifier.sellInvestment(inv.id), child: const Text('Resgatar')),
                  ]),
                ]),
              ),
            );
          }),
        ],
        const SectionTitle('Onde investir', subtitle: 'Rendimentos calculados a cada ano', icon: Icons.savings_rounded),
        for (final o in FinanceSystem.investmentOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GameCard(
              accent: o.color,
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconBadge(icon: o.icon, color: o.color, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(o.name, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(o.description, style: TextStyle(color: p.textMuted, fontSize: 12)),
                    ]),
                  ),
                  Pill('Risco: ${o.risk}', color: o.risk == 'Baixo' ? GamePalette.green : (o.risk == 'Médio' ? GamePalette.gold : GamePalette.red)),
                ]),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final amt in const [500.0, 2000.0, 10000.0, 50000.0, 250000.0])
                    ActionChip(
                      label: Text(Fmt.compactMoney(amt)),
                      onPressed: s.character.bankBalance >= amt ? () => notifier.invest(o.type, o.name, o.ticker, amt) : null,
                    ),
                ]),
              ]),
            ),
          ),
      ],
    );
  }

  Widget _credit(LifeEngineState s) {
    final p = context.gp;
    final c = s.character;
    final notifier = ref.read(lifeEngineProvider.notifier);
    final draft = LifeDraft(s, ref.read(lifeEngineServiceProvider).ctx);
    final limit = FinanceSystem.loanLimit(draft);
    final rate = FinanceSystem.loanRate(c.creditScore);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        if (c.debt > 0)
          GameCard(
            accent: GamePalette.red,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const IconBadge(icon: Icons.warning_amber_rounded, color: GamePalette.red, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Cheque especial: ${Fmt.money(c.debt)}', style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                    Text('Juros de 14% ao ano. Pague logo!', style: TextStyle(color: p.textMuted, fontSize: 12)),
                  ]),
                ),
              ]),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                for (final amt in [500.0, 5000.0, c.debt])
                  ActionChip(label: Text(amt == c.debt ? 'Quitar tudo' : Fmt.compactMoney(amt)), onPressed: c.bankBalance >= amt ? () => notifier.payDebt(amt) : null),
              ]),
            ]),
          ),
        const SectionTitle('Empréstimos ativos', icon: Icons.receipt_long_rounded),
        if (s.extras.loans.isEmpty)
          Text('Nenhum empréstimo ativo.', style: TextStyle(color: p.textMuted))
        else
          ...s.extras.loans.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GameCard(
                  accent: GamePalette.orange,
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.label, style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                    Text('Saldo ${Fmt.money(l.remaining)} · ${(l.rate * 100).toStringAsFixed(1)}% a.a. · parcela ${Fmt.money(l.annualPayment)}/ano',
                        style: TextStyle(color: p.textMuted, fontSize: 12)),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: (1 - l.remaining / (l.principal * 1.6)).clamp(0, 1), color: GamePalette.orange, backgroundColor: p.cardHigh),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, children: [
                      ActionChip(label: const Text('Amortizar R\$ 1 mil'), onPressed: c.bankBalance >= 1000 ? () => notifier.act((v, st) => v.payLoan(st, l.id, 1000)) : null),
                      ActionChip(label: const Text('Quitar'), onPressed: c.bankBalance >= l.remaining ? () => notifier.act((v, st) => v.payLoan(st, l.id, l.remaining)) : null),
                    ]),
                  ]),
                ),
              )),
        const SectionTitle('Pedir empréstimo', subtitle: 'Prazo de 5 anos', icon: Icons.account_balance_rounded),
        GameCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.currentAge < 18 ? 'Disponível a partir dos 18 anos.' : 'Limite pré-aprovado: ${Fmt.money(limit)} · juros ${(rate * 100).round()}% a.a.',
                style: TextStyle(color: p.text, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final amt in const [2000.0, 10000.0, 50000.0, 200000.0])
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 16),
                  label: Text(Fmt.compactMoney(amt)),
                  onPressed: c.currentAge >= 18 && amt <= limit
                      ? () async {
                          if (await confirmDialog(context, title: 'Pegar ${Fmt.money(amt)}?', message: 'Juros de ${(rate * 100).round()}% ao ano por 5 anos. Atrasos derrubam seu score.', confirm: 'Contratar', color: GamePalette.orange, icon: Icons.account_balance_rounded)) {
                            notifier.act((v, st) => v.takeLoan(st, amt));
                          }
                        }
                      : null,
                ),
            ]),
          ]),
        ),
      ],
    );
  }
}

class _FlowCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  const _FlowCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return GameCard(
      accent: color,
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        IconBadge(icon: icon, color: color, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.textMuted, fontSize: 11)),
            Text(Fmt.compactMoney(value), style: TextStyle(color: p.text, fontWeight: FontWeight.w900, fontSize: 15)),
          ]),
        ),
      ]),
    );
  }
}
