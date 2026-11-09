import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/relationship_system.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/models/npc_traits.dart';
import 'package:bitweve/features/relationships/presentation/relationships_sheet.dart' show relationColor;
import 'package:bitweve/features/relationships/romance_rules.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/motion.dart';

/// Linha de pessoa: avatar, nome, barra de relação, indicadores de amizade e
/// romance e botão de perfil.
class PersonTile extends ConsumerWidget {
  final NpcModel npc;
  final int index;
  final String? subtitle;
  const PersonTile({super.key, required this.npc, this.index = 0, this.subtitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.gp;
    final s = ref.watch(lifeEngineProvider).value;
    final meta = s?.extras.npcMeta[npc.id];
    final color = relationColor(npc);
    final traits = NpcTraits.of(npc);
    final friend = npc.relationshipType == RelationshipType.friend || npc.relationshipLevel >= 70;
    final romance = npc.isRomantic;
    final name = meta?.nickname != null ? '${meta!.nickname} (${npc.firstName})' : npc.fullName;
    final card = GameCard(
      onTap: () => showGameSheet(context, PersonProfileSheet(npcId: npc.id)),
      accent: color,
      padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
      child: Row(children: [
        AvatarWidget(config: npc.avatarConfig, age: npc.age, size: 54, deceased: !npc.isAlive, ringColor: npc.isAlive ? color : null, animate: false),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14.5)),
              ),
              if (meta?.blocked ?? false) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.block_rounded, size: 15, color: Color(0xFF94A3B8))),
              if (friend && !romance) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.handshake_rounded, size: 15, color: GamePalette.orange)),
              if (romance) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.favorite_rounded, size: 15, color: GamePalette.pink)),
            ]),
            Text(
              subtitle ?? (npc.isAlive ? '${npc.relationLabel} · ${npc.age} anos · ${traits.personality.label}' : 'Faleceu aos ${npc.age} anos'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: p.textMuted, fontSize: 11.5),
            ),
            if (npc.isAlive) ...[
              const SizedBox(height: 6),
              _RelBar(value: npc.relationshipLevel),
            ],
          ]),
        ),
        Icon(Icons.chevron_right_rounded, color: p.textMuted),
      ]),
    );
    if (!context.motion || index > 10) return card;
    return card.animate().fadeIn(delay: (index * 35).ms, duration: 240.ms).slideX(begin: 0.04, end: 0);
  }
}

class _RelBar extends StatelessWidget {
  final int value;
  const _RelBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final c = GamePalette.forValue(value);
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: LinearProgressIndicator(value: value / 100, minHeight: 7, color: c, backgroundColor: c.withAlpha(40)),
        ),
      ),
      const SizedBox(width: 6),
      Text('$value%', style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 11)),
    ]);
  }
}

/// Tela de interação com uma pessoa específica.
class PersonProfileSheet extends ConsumerWidget {
  final String npcId;
  const PersonProfileSheet({super.key, required this.npcId});

  static const _groups = {
    'Social': ['talk', 'compliment', 'joke', 'gift', 'hangout', 'inviteParty', 'befriend', 'wakeUp', 'playTogether', 'askMoney'],
    'Romance': ['flirt', 'askOut', 'propose', 'intimacy', 'haveBaby'],
    'Escola': ['askHelp', 'suckUp', 'reviewGrade', 'confront'],
    'Conflito e limites': ['apologize', 'reconcile', 'argue', 'insult', 'breakUp', 'divorce', 'block', 'unblock'],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    final npc = s?.npcs.where((n) => n.id == npcId).firstOrNull;
    if (s == null || npc == null) {
      return const GameSheet(title: 'Pessoa', icon: Icons.person_rounded, color: GamePalette.pink, body: SizedBox.shrink());
    }
    final p = context.gp;
    final color = relationColor(npc);
    final meta = s.extras.npcMeta[npc.id];
    final blocked = meta?.blocked ?? false;
    final traits = NpcTraits.of(npc);
    final myAge = s.character.currentAge;
    final actions = RelationshipSystem.actionsFor(npc, myAge, blocked: blocked);
    final used = s.extras.actionsThisYear['npc:${npc.id}'] ?? 0;
    final popularity = (traits.basePopularity + (meta?.popularityDelta ?? 0)).clamp(0, 100);
    final mood = meta?.lastMood ?? 0;
    final moodLabel = switch (mood) {
      2 => ('Radiante', Icons.sentiment_very_satisfied_rounded, GamePalette.green),
      1 => ('Feliz com você', Icons.sentiment_satisfied_rounded, GamePalette.green),
      -1 => ('Desconfortável', Icons.sentiment_dissatisfied_rounded, GamePalette.orange),
      -2 => ('Irritado(a)', Icons.sentiment_very_dissatisfied_rounded, GamePalette.red),
      _ => ('Neutro', Icons.sentiment_neutral_rounded, const Color(0xFF94A3B8)),
    };
    final notifier = ref.read(lifeEngineProvider.notifier);

    Future<void> run(NpcAction a) async {
      if (a.id == 'intimacy') {
        final ok = await confirmDialog(context,
            title: 'Momento a dois',
            message: 'Convidar ${npc.firstName} para um momento íntimo e reservado? ${npc.firstName} pode aceitar ou recusar — e a resposta será respeitada.',
            confirm: 'Convidar',
            color: const Color(0xFFBE185D),
            icon: Icons.nights_stay_rounded);
        if (!ok) return;
      }
      if (a.id == 'block' || a.id == 'breakUp' || a.id == 'divorce') {
        if (!context.mounted) return;
        final ok = await confirmDialog(context, title: a.label, message: 'Tem certeza? Isso afeta sua relação com ${npc.firstName}.', confirm: a.label);
        if (!ok) return;
      }
      await notifier.interactNpc(npc.id, a.id);
    }

    Future<void> editNick() async {
      final ctl = TextEditingController(text: meta?.nickname ?? '');
      final r = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Editar perfil'),
          content: TextField(controller: ctl, maxLength: 24, decoration: const InputDecoration(labelText: 'Apelido (vazio = nome real)')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, ctl.text), child: const Text('Salvar')),
          ],
        ),
      );
      if (r != null) await notifier.act((v, st) => v.setNickname(st, npc.id, r));
    }

    final grouped = <String, List<NpcAction>>{};
    for (final a in actions) {
      final g = _groups.entries.firstWhere((e) => e.value.contains(a.id), orElse: () => const MapEntry('Social', [])).key;
      grouped.putIfAbsent(g, () => []).add(a);
    }

    return GameSheet(
      title: meta?.nickname ?? npc.fullName,
      subtitle: '${npc.relationLabel} · ${npc.age} anos',
      icon: Icons.person_rounded,
      color: color,
      actions: [
        if (npc.isAlive)
          IconButton(tooltip: 'Editar perfil', onPressed: editNick, icon: Icon(Icons.edit_rounded, color: p.textDim)),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          GameCard(
            accent: color,
            child: Column(children: [
              Row(children: [
                AvatarWidget(config: npc.avatarConfig, age: npc.age, size: 104, deceased: !npc.isAlive, ringColor: npc.isAlive ? color : null),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(npc.fullName, style: TextStyle(color: p.text, fontWeight: FontWeight.w900, fontSize: 17)),
                    Text(npc.occupation, style: TextStyle(color: p.textDim, fontSize: 12.5)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      Pill(traits.personality.label, color: traits.personality.color, icon: traits.personality.icon),
                      Pill(traits.socialStatus, color: GamePalette.blue, icon: Icons.groups_rounded),
                      if (npc.isAlive) Pill(moodLabel.$1, color: moodLabel.$3, icon: moodLabel.$2),
                      if (blocked) const Pill('Bloqueado(a)', color: Color(0xFF64748B), icon: Icons.block_rounded),
                    ]),
                  ]),
                ),
              ]),
              if (npc.isAlive) ...[
                const SizedBox(height: 14),
                StatMeter(label: 'Relacionamento', value: npc.relationshipLevel, icon: Icons.favorite_rounded),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: StatMeter(label: 'Popularidade', value: popularity, icon: Icons.star_rounded, compact: true)),
                  const SizedBox(width: 12),
                  Expanded(child: StatMeter(label: 'Respeito', value: npc.respectLevel, icon: Icons.military_tech_rounded, compact: true)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: StatMeter(label: 'Felicidade', value: npc.happiness, icon: Icons.mood_rounded, compact: true)),
                  const SizedBox(width: 12),
                  Expanded(child: StatMeter(label: 'Saúde', value: npc.health, icon: Icons.health_and_safety_rounded, compact: true)),
                ]),
              ],
            ]),
          ),
          const SizedBox(height: 10),
          GameCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Informações', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(traits.personality.description, style: TextStyle(color: p.textDim, fontSize: 12.5)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final i in traits.interests) Pill(i.label, color: GamePalette.teal, icon: i.icon),
              ]),
              const SizedBox(height: 8),
              for (final q in traits.quirks)
                Row(children: [
                  Icon(Icons.auto_awesome_rounded, size: 13, color: p.textMuted),
                  const SizedBox(width: 6),
                  Expanded(child: Text(q, style: TextStyle(color: p.textDim, fontSize: 12.5))),
                ]),
              if (npc.isAlive) ...[
                const SizedBox(height: 6),
                Text('Patrimônio estimado: ${Fmt.compactMoney(npc.netWorth)}', style: TextStyle(color: p.textMuted, fontSize: 12)),
              ],
              if (npc.isAlive && !RomanceRules.romanceAllowed(myAge, npc.age) && !npc.isFamily)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Relação apenas de amizade (faixa etária).', style: TextStyle(color: p.textMuted, fontSize: 11.5, fontStyle: FontStyle.italic)),
                ),
            ]),
          ),
          if (npc.isAlive) ...[
            SectionTitle('Ações', subtitle: blocked ? 'Pessoa bloqueada' : '$used de 4 interações neste ano', icon: Icons.touch_app_rounded),
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 6, 0, 6),
                child: Text(entry.key.toUpperCase(), style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
              ),
              LayoutBuilder(builder: (context, box) {
                final cols = (box.maxWidth / 150).floor().clamp(2, 5);
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    for (final a in entry.value)
                      Builder(builder: (context) {
                        final limited = used >= 4 && !const {'block', 'unblock', 'askHelp', 'suckUp', 'reviewGrade', 'confront'}.contains(a.id);
                        return GameCard(
                          onTap: limited ? null : () => run(a),
                          enabled: !limited,
                          accent: a.color,
                          padding: const EdgeInsets.all(8),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            IconBadge(icon: a.icon, color: a.color, size: 34),
                            const SizedBox(height: 5),
                            Text(a.label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 12)),
                            if (a.cost > 0) Text(Fmt.money(a.cost), style: TextStyle(color: p.textMuted, fontSize: 10.5)),
                          ]),
                        );
                      }),
                  ],
                );
              }),
            ],
          ],
          SectionTitle('Histórico', icon: Icons.history_rounded),
          if (npc.memories.isEmpty && (meta?.history.isEmpty ?? true))
            Text('Nenhuma lembrança registrada ainda.', style: TextStyle(color: p.textMuted))
          else
            ...{...?meta?.history.reversed, ...npc.memories.reversed}.take(20).map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(padding: const EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 8, color: color)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(m, style: TextStyle(color: p.textDim, fontSize: 13))),
                  ]),
                )),
        ],
      ),
    );
  }
}
