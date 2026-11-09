import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/dating/models/dating_state.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/dating_system.dart';
import 'package:bitweve/features/relationships/models/npc_traits.dart';
import 'package:bitweve/features/relationships/presentation/person_profile_sheet.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

const _brand = [Color(0xFFFF5A5F), Color(0xFFFF4F9A)];

/// App de namoro "Faísca" (somente 18+).
class DatingAppSheet extends ConsumerStatefulWidget {
  const DatingAppSheet({super.key});

  @override
  ConsumerState<DatingAppSheet> createState() => _DatingAppSheetState();
}

class _DatingAppSheetState extends ConsumerState<DatingAppSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);
  double _drag = 0;

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final ds = s.extras.dating;
    final adult = s.character.currentAge >= DatingSystem.minAge;
    final active = ds.matches.where((m) => m.active).toList();
    return GameSheet(
      title: DatingSystem.appName,
      subtitle: adult ? '${active.length} match(es) · ${ds.superLikes} super curtida(s)' : 'Exclusivo para maiores de 18 anos',
      icon: Icons.local_fire_department_rounded,
      color: _brand.first,
      header: adult && ds.hasProfile
          ? TabBar(controller: _tab, tabs: [
              const Tab(icon: Icon(Icons.style_rounded, size: 18), text: 'Descobrir'),
              Tab(icon: const Icon(Icons.chat_bubble_rounded, size: 18), text: 'Matches (${active.length})'),
              const Tab(icon: Icon(Icons.person_rounded, size: 18), text: 'Perfil'),
            ])
          : null,
      body: !adult
          ? const EmptyState(
              icon: Icons.no_adult_content_rounded,
              title: 'Acesso restrito',
              message: 'O Faísca só aceita usuários adultos. Até lá, faça amizades na escola e nas atividades!',
              color: Color(0xFFFF5A5F))
          : !ds.hasProfile
              ? _ProfileEditor(onSaved: () => setState(() {}))
              : TabBarView(controller: _tab, children: [_discover(s), _matches(active), _ProfileEditor(onSaved: () => _tab.animateTo(0))]),
    );
  }

  Widget _discover(LifeEngineState s) {
    final deck = DatingSystem.deck(s);
    final p = context.gp;
    if (deck.isEmpty) {
      return const EmptyState(
        icon: Icons.hourglass_empty_rounded,
        title: 'Você viu todos os perfis',
        message: 'Novas pessoas aparecem a cada ano. Envelheça ou converse com seus matches.',
        color: Color(0xFFFF5A5F),
      );
    }
    final prof = deck.first;
    final comp = DatingSystem.compatibility(s, prof);
    final notifier = ref.read(lifeEngineProvider.notifier);

    Future<void> like({bool superLike = false}) async {
      final matched = await notifier.actResult((v, st) => v.datingLike(st, prof.id, superLike: superLike));
      if (!mounted) return;
      if (matched == true) {
        await showDialog(
          context: context,
          builder: (ctx) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Deu match! 🔥', style: AppTheme.display(26, color: _brand.first)),
                const SizedBox(height: 12),
                AvatarWidget(config: prof.avatar, age: prof.age, size: 110, ringColor: _brand.last),
                const SizedBox(height: 10),
                Text('Você e ${prof.firstName} curtiram um ao outro.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                GameButton(label: 'Mandar mensagem', colors: _brand, onTap: () {
                  Navigator.pop(ctx);
                  showGameSheet(context, DatingChatSheet(profileId: prof.id));
                }),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continuar procurando')),
              ]),
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
        );
      } else if (matched == false) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text('${prof.firstName} não curtiu de volta... ainda.'), duration: const Duration(seconds: 2)));
      }
    }

    Future<void> pass() => notifier.act((v, st) => v.datingPass(st, prof.id));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (d) => setState(() => _drag += d.delta.dx),
          onHorizontalDragEnd: (_) {
            final dx = _drag;
            setState(() => _drag = 0);
            if (dx > 90) like();
            if (dx < -90) pass();
          },
          child: Transform.translate(
            offset: Offset(_drag, 0),
            child: Transform.rotate(
              angle: _drag / 1200,
              child: Container(
                key: ValueKey(prof.id),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(colors: [prof.traits.personality.color.withAlpha(200), const Color(0xFF111827)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  AvatarWidget(config: prof.avatar, age: prof.age, size: 170, ringColor: Colors.white70),
                  const SizedBox(height: 12),
                  Text('${prof.firstName}, ${prof.age}', style: AppTheme.display(26, color: Colors.white)),
                  Text('${prof.occupation} · a ${prof.distanceKm} km', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Text('“${prof.bio}”', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
                    Pill(prof.traits.personality.label, color: Colors.white, icon: prof.traits.personality.icon),
                    for (final i in prof.traits.interests)
                      Pill(i.label, color: s.extras.dating.interests.contains(i.id) ? GamePalette.gold : Colors.white70, icon: i.icon),
                    Pill(switch (prof.lookingFor) { 'serious' => 'Algo sério', 'casual' => 'Algo leve', _ => 'Amizade' },
                        color: Colors.white70, icon: Icons.search_rounded),
                  ]),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GameCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.bolt_rounded, color: _brand.first),
              const SizedBox(width: 6),
              Text('Compatibilidade ${comp.total}%', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 8),
            StatMeter(label: 'Interesses', value: comp.interests, icon: Icons.interests_rounded, compact: true),
            const SizedBox(height: 6),
            StatMeter(label: 'Personalidade', value: comp.personality, icon: Icons.psychology_rounded, compact: true),
            const SizedBox(height: 6),
            StatMeter(label: 'Idade', value: comp.age, icon: Icons.cake_rounded, compact: true),
            const SizedBox(height: 6),
            StatMeter(label: 'Status / atração', value: comp.status, icon: Icons.star_rounded, compact: true),
            const SizedBox(height: 6),
            StatMeter(label: 'Objetivos', value: comp.goals, icon: Icons.flag_rounded, compact: true),
          ]),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _RoundBtn(icon: Icons.close_rounded, color: const Color(0xFF94A3B8), label: 'Passar', onTap: pass),
          _RoundBtn(icon: Icons.star_rounded, color: GamePalette.blue, label: 'Super', onTap: () => like(superLike: true)),
          _RoundBtn(icon: Icons.favorite_rounded, color: _brand.first, label: 'Curtir', onTap: like),
        ]),
        const SizedBox(height: 6),
        Text('Deslize para a direita para curtir e para a esquerda para passar. O match só acontece se a outra pessoa também quiser.',
            textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, fontSize: 11.5)),
      ],
    );
  }

  Widget _matches(List<DatingMatch> active) {
    final p = context.gp;
    if (active.isEmpty) {
      return const EmptyState(icon: Icons.favorite_border_rounded, title: 'Nenhum match ainda', message: 'Curta perfis na aba Descobrir.', color: Color(0xFFFF5A5F));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        for (final m in active)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GameCard(
              accent: _brand.first,
              onTap: () => showGameSheet(context, DatingChatSheet(profileId: m.profileId)),
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                AvatarWidget(config: AvatarConfig.fromJson(m.avatarJson), age: m.age, size: 52, animate: false),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${m.firstName}, ${m.age}', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
                    Text(m.chat.isEmpty ? m.bio : m.chat.last.text, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    StatMeter(label: 'Interesse', value: m.interest, icon: Icons.local_fire_department_rounded, compact: true),
                  ]),
                ),
                if (m.npcId != null) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.favorite_rounded, color: GamePalette.pink, size: 18)),
              ]),
            ),
          ),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Column(children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(30), border: Border.all(color: color, width: 2.5)),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: context.gp.textDim, fontSize: 11.5, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _ProfileEditor extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _ProfileEditor({required this.onSaved});

  @override
  ConsumerState<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<_ProfileEditor> {
  late final TextEditingController _bio;
  final Set<String> _interests = {};
  String _looking = 'serious';
  RangeValues _range = const RangeValues(18, 40);

  @override
  void initState() {
    super.initState();
    final ds = ref.read(lifeEngineProvider).value!.extras.dating;
    _bio = TextEditingController(text: ds.bio);
    _interests.addAll(ds.interests);
    _looking = ds.lookingFor;
    _range = RangeValues(ds.minAge.toDouble(), ds.maxAge.toDouble().clamp(ds.minAge.toDouble(), 99));
  }

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text('Seu perfil no ${DatingSystem.appName}', style: AppTheme.display(18, color: p.text)),
        const SizedBox(height: 10),
        TextField(controller: _bio, maxLength: 140, maxLines: 2, decoration: const InputDecoration(labelText: 'Biografia', hintText: 'Conte algo sobre você')),
        const SizedBox(height: 6),
        Text('Interesses (até 5) — aumentam a compatibilidade', style: TextStyle(color: p.textDim, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final i in NpcTraits.interestCatalog)
            FilterChip(
              avatar: Icon(i.icon, size: 16),
              label: Text(i.label),
              selected: _interests.contains(i.id),
              onSelected: (v) => setState(() {
                if (v && _interests.length < 5) {
                  _interests.add(i.id);
                } else {
                  _interests.remove(i.id);
                }
              }),
            ),
        ]),
        const SizedBox(height: 14),
        Text('Procurando', style: TextStyle(color: p.textDim, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'serious', label: Text('Algo sério')),
            ButtonSegment(value: 'casual', label: Text('Algo leve')),
            ButtonSegment(value: 'friendship', label: Text('Amizade')),
          ],
          selected: {_looking},
          onSelectionChanged: (v) => setState(() => _looking = v.first),
        ),
        const SizedBox(height: 14),
        Text('Faixa de idade: ${_range.start.round()} – ${_range.end.round()} anos', style: TextStyle(color: p.textDim, fontWeight: FontWeight.w700)),
        RangeSlider(values: _range, min: 18, max: 80, divisions: 62, onChanged: (v) => setState(() => _range = v)),
        const SizedBox(height: 8),
        GameButton(
          label: 'Salvar perfil',
          icon: Icons.check_rounded,
          colors: _brand,
          onTap: () async {
            await ref.read(lifeEngineProvider.notifier).act((v, st) =>
                v.datingProfile(st, _bio.text, _interests.toList(), _looking, _range.start.round(), _range.end.round()));
            widget.onSaved();
          },
        ),
        const SizedBox(height: 10),
        Text('Seja respeitoso(a): perfis podem recusar, desfazer o match ou bloquear você.',
            textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, fontSize: 11.5)),
      ],
    );
  }
}

/// Conversa com um match.
class DatingChatSheet extends ConsumerWidget {
  final String profileId;
  const DatingChatSheet({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    final m = s?.extras.dating.matches.where((e) => e.profileId == profileId).firstOrNull;
    if (s == null || m == null) return const SizedBox.shrink();
    final p = context.gp;
    final notifier = ref.read(lifeEngineProvider.notifier);
    final used = s.extras.actionsThisYear['chat:$profileId'] ?? 0;
    return GameSheet(
      title: '${m.firstName}, ${m.age}',
      subtitle: 'Compatibilidade ${m.compatibility}% · Interesse ${m.interest}%',
      icon: Icons.chat_bubble_rounded,
      color: _brand.first,
      actions: [
        PopupMenuButton<String>(
          onSelected: (v) async {
            await notifier.act((svc, st) => svc.datingUnmatch(st, profileId, block: v == 'block'));
            if (context.mounted) Navigator.of(context).maybePop();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'unmatch', child: Text('Desfazer match')),
            PopupMenuItem(value: 'block', child: Text('Bloquear')),
          ],
        ),
      ],
      body: Column(children: [
        Expanded(
          child: ListView(
            reverse: true,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            children: [
              for (final line in m.chat.reversed)
                Align(
                  alignment: line.mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: line.mine ? _brand.first : p.card,
                      borderRadius: BorderRadius.circular(16),
                      border: line.mine ? null : Border.all(color: p.border),
                    ),
                    child: Text(line.text, style: TextStyle(color: line.mine ? Colors.white : p.text)),
                  ),
                ),
              Center(child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AvatarWidget(config: AvatarConfig.fromJson(m.avatarJson), age: m.age, size: 80),
              )),
            ],
          ),
        ),
        if (m.active)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border))),
            child: Column(children: [
              Text('Mensagens este ano: $used/4', style: TextStyle(color: p.textMuted, fontSize: 11)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
                for (final e in DatingSystem.messageOptions.entries)
                  ActionChip(
                    label: Text(e.value.$1),
                    onPressed: used >= 4 ? null : () => notifier.act((svc, st) => svc.datingChat(st, profileId, e.key)),
                  ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: GameButton(
                    label: m.npcId == null ? 'Chamar para sair' : 'Novo encontro',
                    icon: Icons.local_bar_rounded,
                    colors: _brand,
                    height: 48,
                    onTap: () => notifier.act((svc, st) => svc.datingAskDate(st, profileId)),
                  ),
                ),
                if (m.npcId != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: GameButton(
                      label: 'Ver perfil',
                      icon: Icons.person_rounded,
                      outlined: true,
                      height: 48,
                      onTap: () => showGameSheet(context, PersonProfileSheet(npcId: m.npcId!)),
                    ),
                  ),
                ],
              ]),
            ]),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(m.blocked ? 'Você bloqueou este perfil.' : 'Este match foi desfeito.', style: TextStyle(color: p.textMuted)),
          ),
      ]),
    );
  }
}
