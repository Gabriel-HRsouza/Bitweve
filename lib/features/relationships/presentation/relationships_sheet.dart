import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/presentation/person_profile_sheet.dart';
import 'package:bitweve/features/dating/presentation/dating_app_sheet.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

Color relationColor(NpcModel n) {
  if (!n.isAlive) return const Color(0xFF64748B);
  if (n.isRomantic) return GamePalette.pink;
  if (n.relationshipType == RelationshipType.rival) return GamePalette.red;
  if (n.isFamily) return const Color(0xFFFB7185);
  if (n.isWork) return GamePalette.blue;
  return GamePalette.orange;
}

class RelationshipsSheet extends ConsumerStatefulWidget {
  final int initialTab;
  const RelationshipsSheet({super.key, this.initialTab = 0});

  @override
  ConsumerState<RelationshipsSheet> createState() => _RelationshipsSheetState();
}

class _RelationshipsSheetState extends ConsumerState<RelationshipsSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 5, vsync: this, initialIndex: widget.initialTab.clamp(0, 4));

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final family = s.npcs.where((n) => n.isFamily && !n.isRomantic || n.relationshipType == RelationshipType.spouse).toList()
      ..sort((a, b) => (b.isAlive ? 1 : 0).compareTo(a.isAlive ? 1 : 0));
    final social = s.npcs.where((n) => n.isSocial && n.relationshipType != RelationshipType.exPartner).toList();
    final love = s.npcs.where((n) => n.isRomantic || n.relationshipType == RelationshipType.exPartner).toList();
    final work = s.npcs.where((n) => n.isWork).toList();
    final age = s.character.currentAge;

    return GameSheet(
      title: 'Relacionamentos',
      subtitle: '${s.npcs.where((n) => n.isAlive).length} pessoas na sua vida',
      icon: Icons.favorite_rounded,
      color: GamePalette.pink,
      header: TabBar(
        controller: _tab,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(icon: Icon(Icons.family_restroom_rounded, size: 18), text: 'Família', height: 52),
          Tab(icon: Icon(Icons.groups_rounded, size: 18), text: 'Social', height: 52),
          Tab(icon: Icon(Icons.favorite_rounded, size: 18), text: 'Amor', height: 52),
          Tab(icon: Icon(Icons.work_rounded, size: 18), text: 'Trabalho', height: 52),
          Tab(icon: Icon(Icons.account_tree_rounded, size: 18), text: 'Legado', height: 52),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _list(family, empty: 'Sua família aparece aqui.'),
          _list(social,
              header: age >= 6
                  ? GameButton(
                      label: 'Sair para conhecer pessoas',
                      caption: '−10 energia · pode surgir uma nova amizade',
                      icon: Icons.nightlife_rounded,
                      colors: const [GamePalette.orange, GamePalette.pink],
                      onTap: () => ref.read(lifeEngineProvider.notifier).act((svc, st) => svc.meetPeople(st)),
                    )
                  : null,
              empty: 'Faça amigos na escola, no trabalho ou saindo.'),
          _list(love,
              header: age >= 16
                  ? Column(children: [
                      if (age >= 18) ...[
                        GameButton(
                          label: 'Abrir o app Faísca',
                          caption: 'App de namoro · perfis, matches e encontros',
                          icon: Icons.local_fire_department_rounded,
                          colors: const [Color(0xFFFF5A5F), Color(0xFFFF4F9A)],
                          onTap: () => showGameSheet(context, const DatingAppSheet()),
                        ),
                        const SizedBox(height: 10),
                      ],
                      GameButton(
                      label: 'Procurar um amor',
                      caption: 'App de encontros · −10 energia',
                      icon: Icons.favorite_border_rounded,
                      colors: const [GamePalette.pink, Color(0xFFA855F7)],
                      onTap: () => ref.read(lifeEngineProvider.notifier).act((svc, st) => svc.findLove(st)),
                    ),
                    ])
                  : null,
              empty: age < 14 ? 'O amor pode esperar. Aproveite a infância!' : 'Paqueras, namoros e casamento aparecem aqui.'),
          _list(work, empty: 'Colegas e chefes aparecem quando você tem um emprego.'),
          _legacy(s),
        ],
      ),
    );
  }

  Widget _list(List<NpcModel> people, {Widget? header, required String empty}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        if (header != null) ...[header, const SizedBox(height: 12)],
        if (people.isEmpty) EmptyState(icon: Icons.person_search_rounded, title: 'Ninguém por aqui', message: empty, color: GamePalette.pink),
        for (var i = 0; i < people.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PersonTile(npc: people[i], index: i),
          ),
      ],
    );
  }

  Widget _legacy(LifeEngineState s) {
    final p = context.gp;
    final x = s.extras;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        SectionTitle('Pets', icon: Icons.pets_rounded, trailing: s.character.currentAge >= 6
            ? TextButton.icon(onPressed: () => _adopt(context), icon: const Icon(Icons.add_rounded), label: const Text('Adotar'))
            : null),
        if (x.pets.isEmpty)
          Text('Nenhum pet ainda. Adoção custa R\$ 150.', style: TextStyle(color: p.textMuted))
        else
          ...x.pets.map((pet) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GameCard(
                  accent: pet.alive ? GamePalette.gold : null,
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    IconBadge(icon: Icons.pets_rounded, color: pet.alive ? GamePalette.gold : const Color(0xFF64748B), size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(pet.name, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 15)),
                        Text('${pet.type} · ${pet.age} anos${pet.alive ? '' : ' · falecido'}', style: TextStyle(color: p.textMuted, fontSize: 12)),
                        if (pet.alive) ...[const SizedBox(height: 6), StatMeter(label: 'Vínculo', value: pet.bond, icon: Icons.favorite_rounded, compact: true)],
                      ]),
                    ),
                    if (pet.alive)
                      IconButton(
                        tooltip: 'Brincar',
                        onPressed: () => ref.read(lifeEngineProvider.notifier).act((svc, st) => svc.playWithPet(st, pet.id)),
                        icon: const Icon(Icons.sports_baseball_rounded, color: GamePalette.gold),
                      ),
                  ]),
                ),
              )),
        SectionTitle('Árvore da dinastia', subtitle: 'Geração ${s.generation}', icon: Icons.account_tree_rounded),
        if (x.ancestors.isEmpty)
          Text('Você é a primeira geração. Tenha filhos para continuar a história depois da morte.', style: TextStyle(color: p.textMuted))
        else
          ...x.ancestors.reversed.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GameCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    AvatarWidget(config: AvatarConfig.fromJson(a.avatarJson), age: a.ageOfDeath, size: 52, deceased: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.name, style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                        Text('Geração ${a.generation} · ${a.birthYear}–${a.birthYear + a.ageOfDeath} · ${a.job ?? 'sem profissão registrada'}',
                            style: TextStyle(color: p.textMuted, fontSize: 12)),
                      ]),
                    ),
                    Text(Fmt.compactMoney(a.netWorth), style: const TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w800)),
                  ]),
                ),
              )),
        GameCard(
          accent: GamePalette.violet,
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            AvatarWidget(config: s.character.avatarConfig, age: s.character.currentAge, size: 52, ringColor: GamePalette.violet),
            const SizedBox(width: 12),
            Expanded(
              child: Text('${s.character.fullName} (você) · Geração ${s.generation}',
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
      ],
    );
  }

  Future<void> _adopt(BuildContext context) async {
    final name = TextEditingController(text: 'Pipoca');
    var type = 'Cachorro';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
        final p = ctx.gp;
        return AlertDialog(
          title: Text('Adotar um pet', style: AppTheme.display(20, color: p.text)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Wrap(spacing: 8, children: [
              for (final t in const ['Cachorro', 'Gato', 'Coelho', 'Papagaio'])
                ChoiceChip(label: Text(t), selected: type == t, onSelected: (_) => setLocal(() => type = t)),
            ]),
            const SizedBox(height: 12),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome do pet')),
            const SizedBox(height: 8),
            Text('Taxa de adoção: R\$ 150', style: TextStyle(color: p.textMuted, fontSize: 12)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Adotar')),
          ],
        );
      }),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      await ref.read(lifeEngineProvider.notifier).adoptPet(type, name.text.trim());
    }
  }
}

/// Compatibilidade: a ficha detalhada agora é a [PersonProfileSheet].
class NpcDetailSheet extends StatelessWidget {
  final String npcId;
  const NpcDetailSheet({super.key, required this.npcId});

  @override
  Widget build(BuildContext context) => PersonProfileSheet(npcId: npcId);
}
