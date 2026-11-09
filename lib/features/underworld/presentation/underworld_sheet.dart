import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/underworld_system.dart';
import 'package:bitweve/features/minigames/minigame_shell.dart';
import 'package:bitweve/features/school/presentation/school_sheet.dart' show ActionTile, actionGrid;
import 'package:bitweve/features/underworld/data/crime_catalog.dart';
import 'package:bitweve/features/underworld/data/store_catalog.dart';
import 'package:bitweve/features/underworld/models/minigame_result.dart';
import 'package:bitweve/features/underworld/presentation/justice_sheets.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/scene_art.dart';

const _crimeColor = Color(0xFF64748B);

/// Submundo fictício: crimes com minigame, 1.000 lojas, organizações,
/// mercado clandestino e ficha criminal.
class UnderworldSheet extends ConsumerStatefulWidget {
  const UnderworldSheet({super.key});

  @override
  ConsumerState<UnderworldSheet> createState() => _UnderworldSheetState();
}

class _UnderworldSheetState extends ConsumerState<UnderworldSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final cs = s.extras.crime;
    if (cs.inPrison) return const PrisonSheet();
    return GameSheet(
      title: 'Submundo',
      subtitle: 'Notoriedade ${cs.notoriety} · Polícia ${cs.heat}/100',
      icon: Icons.local_police_rounded,
      color: _crimeColor,
      header: TabBar(controller: _tab, isScrollable: true, tabAlignment: TabAlignment.start, tabs: const [
        Tab(icon: Icon(Icons.dangerous_rounded, size: 18), text: 'Crimes'),
        Tab(icon: Icon(Icons.storefront_rounded, size: 18), text: 'Lojas (1.000)'),
        Tab(icon: Icon(Icons.groups_rounded, size: 18), text: 'Organizações'),
        Tab(icon: Icon(Icons.gavel_rounded, size: 18), text: 'Ficha & Justiça'),
      ]),
      body: TabBarView(controller: _tab, children: [_crimes(s), const _StoreBrowser(), _gangs(s), _record(s)]),
    );
  }

  Widget _crimes(LifeEngineState s) {
    final p = context.gp;
    final cs = s.extras.crime;
    final age = s.character.currentAge;
    final used = s.extras.actionsThisYear['crime'] ?? 0;
    var i = 0;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
      if (cs.pendingCase != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GameButton(
            label: 'Você tem um julgamento pendente',
            caption: cs.pendingCase!.label,
            icon: Icons.gavel_rounded,
            colors: const [GamePalette.gold, Color(0xFFB45309)],
            onTap: () => showGameSheet(context, const TrialSheet()),
          ),
        ),
      GameCard(
        child: Column(children: [
          StatMeter(label: 'Notoriedade no submundo', value: cs.notoriety, icon: Icons.whatshot_rounded),
          const SizedBox(height: 8),
          StatMeter(label: 'Atenção da polícia', value: cs.heat, icon: Icons.local_police_rounded, inverted: true),
          const SizedBox(height: 8),
          StatMeter(label: 'Habilidade', value: cs.skill, icon: Icons.psychology_rounded),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('Tentativas no ano: $used/4', style: TextStyle(color: p.textMuted, fontSize: 12))),
            Text('Estoque quente: ${Fmt.money(cs.stash)}', style: TextStyle(color: p.textDim, fontSize: 12, fontWeight: FontWeight.w800)),
          ]),
        ]),
      ),
      const SizedBox(height: 6),
      Text('Tudo aqui é fictício e abstrato. Cada crime tem um minigame próprio; o resultado depende dele, da sua habilidade, preparo, estado e sorte.',
          style: TextStyle(color: p.textMuted, fontSize: 11.5)),
      const SizedBox(height: 10),
      actionGrid([
        for (final c in CrimeCatalog.crimes)
          ActionTile(
            index: i++,
            icon: c.icon,
            color: c.color,
            title: c.name,
            description: '${c.description}\n${c.minigame.label} · ${age < c.minAge ? '${c.minAge}+ anos' : (cs.notoriety < c.minNotoriety ? 'notoriedade ${c.minNotoriety}' : 'risco ${'●' * c.difficulty}')}',
            enabled: age >= c.minAge && cs.notoriety >= c.minNotoriety,
            onTap: () => c.id == 'shoplift' ? _tab.animateTo(1) : runCrime(context, ref, c),
          ),
        ActionTile(
          index: i++,
          icon: Icons.storefront_rounded,
          color: GamePalette.orange,
          title: 'Mercado clandestino',
          description: cs.stash > 0 ? 'Negocie ${Fmt.money(cs.stash)} em mercadoria (minigame Lábia)' : 'Nada para vender',
          enabled: cs.stash > 0,
          onTap: () async {
            final r = await playMinigame(context, kind: MinigameKind.bluff, difficulty: 2, title: 'Negociar com o receptador', colors: const [GamePalette.orange, Color(0xFF7C2D12)]);
            if (r.aborted) return;
            await ref.read(lifeEngineProvider.notifier).act((v, st) => v.fence(st, r));
          },
        ),
        ActionTile(
          index: i++,
          icon: Icons.visibility_off_rounded,
          color: const Color(0xFF475569),
          title: 'Ficar na moita',
          description: 'Reduz a atenção da polícia (−25)',
          indicator: '${s.extras.actionsThisYear['lieLow'] ?? 0}/1',
          onTap: () => ref.read(lifeEngineProvider.notifier).act((v, st) => v.lieLow(st)),
        ),
      ]),
    ]);
  }

  Widget _gangs(LifeEngineState s) {
    final p = context.gp;
    final cs = s.extras.crime;
    final mine = CrimeCatalog.gang(cs.gangId);
    var i = 0;
    if (mine != null) {
      final missions = CrimeCatalog.missions.where((m) => m.gangId == mine.id).toList();
      return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
        GameCard(
          accent: mine.color,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconBadge(icon: mine.icon, color: mine.color, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mine.name, style: AppTheme.display(18, color: p.text)),
                  Text('Cargo: ${mine.ranks[cs.gangRank]} · ${cs.missionsDone} missão(ões)', style: TextStyle(color: p.textMuted, fontSize: 12)),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            StatMeter(label: 'Lealdade', value: cs.gangLoyalty, icon: Icons.handshake_rounded),
          ]),
        ),
        const SectionTitle('Missões', icon: Icons.task_alt_rounded),
        for (final m in missions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ActionTile(
              index: i++,
              icon: m.minigame.icon,
              color: mine.color,
              title: m.name,
              description: '${m.description}\n${m.minigame.label} · até ${Fmt.money(m.reward * 1.2)}${cs.gangRank < m.minRank ? ' · exige ${mine.ranks[m.minRank]}' : ''}',
              enabled: cs.gangRank >= m.minRank,
              onTap: () async {
                final r = await playMinigame(context, kind: m.minigame, difficulty: m.difficulty, title: m.name, subtitle: mine.name, colors: [mine.color, const Color(0xFF0F172A)]);
                if (r.aborted) return;
                final rep = await ref.read(lifeEngineProvider.notifier).actResult((v, st) => v.gangMission(st, m.id, r));
                if (rep != null && mounted) await showCrimeReport(context, rep);
              },
            ),
          ),
        const SizedBox(height: 10),
        GameButton(
          label: 'Sair da organização',
          outlined: true,
          icon: Icons.logout_rounded,
          onTap: () async {
            final ok = await confirmDialog(context, title: 'Sair da ${mine.name}?', message: 'Eles podem não aceitar bem a sua saída.', confirm: 'Sair');
            if (ok) await ref.read(lifeEngineProvider.notifier).act((v, st) => v.leaveGang(st));
          },
        ),
      ]);
    }
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
      Text('Organizações fictícias recrutam quem tem notoriedade. A iniciação é um minigame.', style: TextStyle(color: p.textMuted)),
      const SizedBox(height: 10),
      for (final g in CrimeCatalog.gangs)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ActionTile(
            index: i++,
            icon: g.icon,
            color: g.color,
            title: g.name,
            description: '${g.description}\nExige notoriedade ${g.minNotoriety} · 16+ anos',
            enabled: cs.notoriety >= g.minNotoriety && s.character.currentAge >= 16,
            onTap: () async {
              final r = await playMinigame(context, kind: MinigameKind.bluff, difficulty: 2, title: 'Iniciação: ${g.name}', colors: [g.color, const Color(0xFF0F172A)]);
              if (r.aborted) return;
              await ref.read(lifeEngineProvider.notifier).act((v, st) => v.joinGang(st, g.id, r));
            },
          ),
        ),
    ]);
  }

  Widget _record(LifeEngineState s) {
    final p = context.gp;
    final cs = s.extras.crime;
    final c = s.character;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
      GameCard(
        accent: c.criminalRecord ? GamePalette.red : GamePalette.green,
        child: Row(children: [
          IconBadge(icon: c.criminalRecord ? Icons.assignment_late_rounded : Icons.verified_user_rounded, color: c.criminalRecord ? GamePalette.red : GamePalette.green, size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.criminalRecord ? 'Ficha suja' : 'Ficha limpa', style: AppTheme.display(18, color: p.text)),
              Text('${c.timesArrested} prisão(ões) · ${cs.successes} sucesso(s) · ${cs.failures} fracasso(s)', style: TextStyle(color: p.textMuted, fontSize: 12)),
              if (cs.onProbation) Text('Liberdade condicional: ${cs.probationYears} ano(s)', style: const TextStyle(color: GamePalette.gold, fontSize: 12)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      if (cs.pendingCase != null)
        GameButton(label: 'Ir ao julgamento', icon: Icons.gavel_rounded, colors: const [GamePalette.gold, Color(0xFFB45309)], onTap: () => showGameSheet(context, const TrialSheet())),
      if (c.criminalRecord && cs.pendingCase == null) ...[
        const SizedBox(height: 8),
        GameButton(
          label: 'Advogado: limpar a ficha',
          caption: 'R\$ 15.000 · reabilitação judicial',
          icon: Icons.cleaning_services_rounded,
          colors: const [GamePalette.green, Color(0xFF15803D)],
          onTap: () => ref.read(lifeEngineProvider.notifier).appealCriminalRecord(),
        ),
      ],
      const SectionTitle('Histórico criminal', icon: Icons.history_edu_rounded),
      if (cs.record.isEmpty) Text('Nenhum processo.', style: TextStyle(color: p.textMuted)),
      for (final r in cs.record.reversed)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(r.outcome == 'acquitted' ? Icons.check_circle_rounded : Icons.gavel_rounded, color: r.outcome == 'acquitted' ? GamePalette.green : GamePalette.red),
          title: Text(r.crime, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('Aos ${r.age} anos · ${r.outcomeLabel}${r.fine > 0 ? ' · ${Fmt.money(r.fine)}' : ''}'),
        ),
    ]);
  }
}

/// Fluxo padrão de um crime: preparo → minigame → resolução → julgamento.
Future<void> runCrime(BuildContext context, WidgetRef ref, CrimeDef c, {StoreInfo? store}) async {
  final s = ref.read(lifeEngineProvider).value;
  if (s == null) return;
  final block = UnderworldSystem.blockerFor(s.character.currentAge, s.extras.crime, minAge: c.minAge);
  if (block != null) {
    await confirmDialog(context, title: 'Indisponível', message: block, confirm: 'Ok', color: GamePalette.orange, icon: Icons.lock_rounded);
    return;
  }
  final prepared = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(store?.name ?? c.name),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (store != null) StoreFrontArt(name: store.name, icon: store.category.icon, colors: store.category.colors, awning: store.awning, seed: store.seed, difficulty: store.difficulty),
        const SizedBox(height: 10),
        Text(store != null ? '${store.category.name} · ${store.district}\nMercadorias: ${store.products.join(', ')}\nSeguranças: ${store.guards} · Câmeras: ${store.cameras}' : c.description),
        const SizedBox(height: 10),
        const Text('Preparar-se (−15 de energia) reduz a dificuldade e o risco.', style: TextStyle(fontSize: 12)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Ir sem preparo')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Preparar e ir')),
      ],
    ),
  );
  if (prepared == null || !context.mounted) return;
  final cs = s.extras.crime;
  final dif = UnderworldSystem.effectiveDifficulty(cs, store?.difficulty ?? c.difficulty, prepared: prepared && s.character.energy >= 23);
  final r = await playMinigame(
    context,
    kind: c.minigame,
    difficulty: dif,
    title: store?.name ?? c.name,
    subtitle: store != null ? 'Colete ${3 + dif} itens e saia sem ser pego(a)' : c.description,
    seed: store?.seed ?? c.id.hashCode,
    colors: store?.category.colors ?? [c.color, const Color(0xFF0F172A)],
  );
  if (r.aborted || !context.mounted) return;
  final rep = await ref.read(lifeEngineProvider.notifier).actResult((v, st) => v.commitCrime(st, c.id, r, storeId: store?.id, prepared: prepared));
  if (rep == null || rep.title.isEmpty || !context.mounted) return;
  await showCrimeReport(context, rep);
  if (rep.caught && context.mounted) await showGameSheet(context, const TrialSheet());
}

Future<void> showCrimeReport(BuildContext context, CrimeReport rep) {
  final color = rep.caught ? GamePalette.red : (rep.success ? GamePalette.green : GamePalette.orange);
  return confirmDialog(context,
      title: rep.title,
      message: rep.text,
      confirm: rep.caught ? 'Ir para a delegacia' : 'Ok',
      color: color,
      icon: rep.caught ? Icons.local_police_rounded : (rep.success ? Icons.check_circle_rounded : Icons.error_rounded));
}

/// Navegador de 1.000 lojas com busca e filtros.
class _StoreBrowser extends ConsumerStatefulWidget {
  const _StoreBrowser();

  @override
  ConsumerState<_StoreBrowser> createState() => _StoreBrowserState();
}

class _StoreBrowserState extends ConsumerState<_StoreBrowser> {
  String _q = '';
  String? _cat;
  int _maxDiff = 5;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;
    final list = StoreCatalog.search(query: _q, category: _cat, maxDifficulty: _maxDiff);
    final crime = CrimeCatalog.crime('shoplift');
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: TextField(
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Buscar loja ou bairro', isDense: true),
          onChanged: (v) => setState(() => _q = v),
        ),
      ),
      SizedBox(
        height: 44,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: ChoiceChip(label: const Text('Todas'), selected: _cat == null, onSelected: (_) => setState(() => _cat = null)),
          ),
          for (final c in StoreCatalog.categories)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ChoiceChip(avatar: Icon(c.icon, size: 16), label: Text(c.name), selected: _cat == c.id, onSelected: (_) => setState(() => _cat = c.id)),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Text('Risco máx.: ${'●' * _maxDiff}', style: TextStyle(color: p.textDim, fontSize: 12, fontWeight: FontWeight.w800)),
          Expanded(child: Slider(value: _maxDiff.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) => setState(() => _maxDiff = v.round()))),
          Text('${list.length} lojas', style: TextStyle(color: p.textMuted, fontSize: 12)),
        ]),
      ),
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final cols = (box.maxWidth / 300).floor().clamp(1, 3);
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 196),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final st = list[i];
              final hits = s.extras.crime.storeHits[st.id] ?? 0;
              return GameCard(
                padding: const EdgeInsets.all(8),
                onTap: () => runCrime(context, ref, crime, store: st),
                accent: st.category.colors.first,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  StoreFrontArt(name: st.name, icon: st.category.icon, colors: st.category.colors, awning: st.awning, seed: st.seed, height: 104, difficulty: st.difficulty),
                  const SizedBox(height: 6),
                  Text(st.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
                  Text('${st.category.name} · ${st.district}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.textMuted, fontSize: 11.5)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Pill(st.riskLabel, color: st.difficulty >= 4 ? GamePalette.red : (st.difficulty >= 3 ? GamePalette.orange : GamePalette.green)),
                    const SizedBox(width: 6),
                    Expanded(child: Text('≈ ${Fmt.money(st.lootValue)}', style: TextStyle(color: p.textDim, fontSize: 12, fontWeight: FontWeight.w800))),
                    if (hits > 0) Text('$hits×', style: const TextStyle(color: GamePalette.red, fontWeight: FontWeight.w900, fontSize: 12)),
                  ]),
                ]),
              );
            },
          );
        }),
      ),
    ]);
  }
}
