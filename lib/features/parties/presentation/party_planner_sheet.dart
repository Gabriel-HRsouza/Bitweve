import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/party_system.dart';
import 'package:bitweve/features/parties/data/party_catalog.dart';
import 'package:bitweve/features/social_media/presentation/social_app_sheet.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/scene_art.dart';

/// Planejador de festas em etapas: tipo → local → convidados → detalhes.
class PartyPlannerSheet extends ConsumerStatefulWidget {
  final String? initialType;
  final String? propertyId;
  const PartyPlannerSheet({super.key, this.initialType, this.propertyId});

  @override
  ConsumerState<PartyPlannerSheet> createState() => _PartyPlannerSheetState();
}

class _PartyPlannerSheetState extends ConsumerState<PartyPlannerSheet> {
  late String _type = widget.initialType ?? 'house';
  late String? _property = widget.propertyId;
  final Set<String> _guests = {};
  int _budget = 1;
  String _decor = 'balloons';
  String _food = 'pizza';
  String _music = 'playlist';
  String _activity = 'games';
  int _step = 0;

  PartyPlan get _plan => PartyPlan(
        typeId: _type,
        propertyId: _property,
        guestIds: _guests.toList(),
        budget: _budget,
        decor: _decor,
        food: _food,
        music: _music,
        activity: _activity,
      );

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final t = PartyCatalog.type(_type);
    final cost = PartySystem.estimate(s, _plan);
    final blocker = PartySystem.blocker(s, _plan);
    final p = context.gp;
    final steps = ['Tipo', 'Local', 'Convidados', 'Detalhes'];
    return GameSheet(
      title: 'Planejar festa',
      subtitle: '${t.name} · estimativa ${Fmt.money(cost)}',
      icon: Icons.celebration_rounded,
      color: t.colors.first,
      header: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(children: [
          for (var i = 0; i < steps.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _step = i),
                child: Column(children: [
                  Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i <= _step ? t.colors.first : p.border,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(steps[i], style: TextStyle(fontSize: 11, color: i == _step ? p.text : p.textMuted, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(key: ValueKey(_step), child: _stepView(s)),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border))),
          child: Row(children: [
            if (_step > 0)
              Expanded(child: GameButton(label: 'Voltar', outlined: true, height: 50, onTap: () => setState(() => _step--))),
            if (_step > 0) const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _step < 3
                  ? GameButton(label: 'Próximo', icon: Icons.arrow_forward_rounded, height: 50, colors: t.colors, onTap: () => setState(() => _step++))
                  : GameButton(
                      label: blocker == null ? 'Dar a festa · ${Fmt.money(cost)}' : 'Indisponível',
                      caption: blocker,
                      icon: Icons.celebration_rounded,
                      height: 54,
                      colors: t.colors,
                      onTap: blocker == null ? _host : null,
                    ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _stepView(LifeEngineState s) {
    final p = context.gp;
    switch (_step) {
      case 0:
        return ListView(padding: const EdgeInsets.all(16), children: [
          for (final t in PartyCatalog.types)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GameCard(
                accent: t.colors.first,
                onTap: s.character.currentAge >= t.minAge ? () => setState(() => _type = t.id) : null,
                enabled: s.character.currentAge >= t.minAge,
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  IconBadge(icon: t.icon, color: t.colors.first, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t.name, style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
                      Text(t.description, style: TextStyle(color: p.textMuted, fontSize: 12)),
                      Text('A partir de ${Fmt.money(t.baseCost)} · ${t.minAge}+ anos${t.needsProperty ? ' · exige imóvel próprio' : ''}',
                          style: TextStyle(color: p.textDim, fontSize: 11)),
                    ]),
                  ),
                  if (_type == t.id) Icon(Icons.check_circle_rounded, color: t.colors.first),
                ]),
              ),
            ),
        ]);
      case 1:
        final homes = s.properties.where((e) => e.isRealEstate && !e.isCommercial).toList();
        return ListView(padding: const EdgeInsets.all(16), children: [
          GameCard(
            accent: GamePalette.orange,
            onTap: () => setState(() => _property = null),
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const IconBadge(icon: Icons.home_rounded, color: GamePalette.orange, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.character.currentAge < 18 ? 'Casa dos seus pais' : 'Onde você mora (sem imóvel próprio)',
                      style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
                  Text('Capacidade ~${s.character.currentAge < 18 ? 12 : 15} pessoas', style: TextStyle(color: p.textMuted, fontSize: 12)),
                ]),
              ),
              if (_property == null) const Icon(Icons.check_circle_rounded, color: GamePalette.orange),
            ]),
          ),
          const SizedBox(height: 10),
          if (homes.isEmpty)
            Text('Compre um imóvel para dar festas maiores (e festas de luxo/privadas).', style: TextStyle(color: p.textMuted)),
          for (final h in homes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GameCard(
                accent: GamePalette.gold,
                onTap: () => setState(() => _property = h.id),
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  SizedBox(width: 92, child: BuildingArt(type: h.type, colors: const [GamePalette.gold, Color(0xFF92400E)], height: 64, decor: s.extras.propertyMeta[h.id]?.decorLevel ?? 0)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(h.name, style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
                      Text('Decoração ${s.extras.propertyMeta[h.id]?.styleLabel ?? 'Básica'} · ${s.extras.propertyMeta[h.id]?.partiesHosted ?? 0} festa(s)',
                          style: TextStyle(color: p.textMuted, fontSize: 12)),
                    ]),
                  ),
                  if (_property == h.id) const Icon(Icons.check_circle_rounded, color: GamePalette.gold),
                ]),
              ),
            ),
        ]);
      case 2:
        final people = s.npcs.where((n) => n.isAlive && n.age >= 4 && !(s.extras.npcMeta[n.id]?.blocked ?? false)).toList()
          ..sort((a, b) => b.relationshipLevel.compareTo(a.relationshipLevel));
        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(children: [
              Text('${_guests.length} convidado(s)', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _guests
                  ..clear()
                  ..addAll(people.where((n) => n.relationshipLevel >= 50).take(20).map((n) => n.id))),
                child: const Text('Convidar próximos'),
              ),
              TextButton(onPressed: () => setState(_guests.clear), child: const Text('Limpar')),
            ]),
          ),
          Expanded(
            child: people.isEmpty
                ? const EmptyState(icon: Icons.group_off_rounded, title: 'Ninguém para convidar', message: 'Faça amigos primeiro!')
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    children: [
                      for (final n in people)
                        CheckboxListTile(
                          value: _guests.contains(n.id),
                          onChanged: (v) => setState(() => v == true ? _guests.add(n.id) : _guests.remove(n.id)),
                          secondary: AvatarWidget(config: n.avatarConfig, age: n.age, size: 40, animate: false),
                          title: Text(n.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('${n.relationLabel} · relação ${n.relationshipLevel}%'),
                        ),
                    ],
                  ),
          ),
        ]);
      default:
        Widget group(String title, List<PartyOption> opts, String selected, ValueChanged<String> onPick, {bool perGuest = false}) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Text(title, style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
            ),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final o in opts)
                ChoiceChip(
                  avatar: Icon(o.icon, size: 16),
                  label: Text('${o.name}${o.cost > 0 ? ' · ${Fmt.money(o.cost)}${perGuest ? '/pessoa' : ''}' : ''}'),
                  selected: selected == o.id,
                  onSelected: (_) => setState(() => onPick(o.id)),
                ),
            ]),
          ]);
        }
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Text('Orçamento: ${PartyCatalog.budgetLabels[_budget]}', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
          ),
          Slider(value: _budget.toDouble(), min: 0, max: 3, divisions: 3, label: PartyCatalog.budgetLabels[_budget], onChanged: (v) => setState(() => _budget = v.round())),
          group('Decoração', PartyCatalog.decors, _decor, (v) => _decor = v),
          group('Comida', PartyCatalog.foods, _food, (v) => _food = v, perGuest: true),
          group('Música', PartyCatalog.musics, _music, (v) => _music = v),
          group('Atividades', PartyCatalog.activities, _activity, (v) => _activity = v),
          const SizedBox(height: 12),
          Text('Dica: combine opções com o clima da festa (${PartyCatalog.type(_type).vibe}). Cada convidado reage conforme a personalidade.',
              style: TextStyle(color: p.textMuted, fontSize: 12)),
        ]);
    }
  }

  Future<void> _host() async {
    final rep = await ref.read(lifeEngineProvider.notifier).actResult((v, st) => v.hostParty(st, _plan));
    if (!mounted || rep == null || rep.title.isEmpty) return;
    await showGameSheet(context, PartyResultSheet(report: rep, typeId: _type));
    if (mounted) Navigator.of(context).maybePop();
  }
}

/// Resultado da festa: nota, reações individuais e incidentes.
class PartyResultSheet extends ConsumerWidget {
  final PartyReport report;
  final String typeId;
  const PartyResultSheet({super.key, required this.report, required this.typeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.gp;
    final s = ref.watch(lifeEngineProvider).value;
    final t = PartyCatalog.type(typeId);
    final good = report.rating >= 55;
    return GameSheet(
      title: report.title,
      subtitle: 'Nota ${report.rating}/100 · custo ${Fmt.money(report.cost)}',
      icon: t.icon,
      color: good ? t.colors.first : const Color(0xFF64748B),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
        Center(
          child: Text('${report.rating}', style: AppTheme.display(64, color: good ? t.colors.first : p.textDim))
              .animate()
              .scale(begin: const Offset(0.4, 0.4), curve: Curves.elasticOut, duration: 800.ms),
        ),
        Center(child: Text(report.popularityGain >= 0 ? '+${report.popularityGain} de popularidade' : '${report.popularityGain} de popularidade',
            style: TextStyle(color: p.textDim, fontWeight: FontWeight.w800))),
        if (report.incidents.isNotEmpty) ...[
          const SectionTitle('Acontecimentos', icon: Icons.bolt_rounded),
          for (final i in report.incidents)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.flash_on_rounded, size: 16, color: GamePalette.gold),
                const SizedBox(width: 8),
                Expanded(child: Text(i, style: TextStyle(color: p.textDim))),
              ]),
            ),
        ],
        const SectionTitle('Reação dos convidados', icon: Icons.groups_rounded),
        for (final g in report.guests)
          Builder(builder: (context) {
            final n = s?.npcs.where((e) => e.id == g.npcId).firstOrNull;
            final (icon, color) = switch (g.score) {
              2 => (Icons.sentiment_very_satisfied_rounded, GamePalette.green),
              1 => (Icons.sentiment_satisfied_rounded, GamePalette.teal),
              0 => (Icons.sentiment_neutral_rounded, GamePalette.gold),
              _ => (Icons.sentiment_dissatisfied_rounded, GamePalette.red),
            };
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: n == null ? Icon(icon, color: color) : AvatarWidget(config: n.avatarConfig, age: n.age, size: 40, animate: false),
              title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('“${g.comment}”'),
              trailing: Icon(icon, color: color),
            );
          }),
        const SizedBox(height: 12),
        if (report.canPost)
          GameButton(
            label: 'Postar fotos da festa no Pulso',
            icon: Icons.photo_camera_rounded,
            colors: const [Color(0xFFF472B6), Color(0xFF7C3AED)],
            onTap: () => showGameSheet(context, const ComposePostSheet(initialCategory: 'party')),
          ),
      ]),
    );
  }
}
