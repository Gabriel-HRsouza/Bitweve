import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/careers/data/career_catalog.dart';
import 'package:bitweve/features/careers/models/career_track.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/career_system.dart';
import 'package:bitweve/features/life_engine/systems/life_draft.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/motion.dart';

class CareersSheet extends ConsumerStatefulWidget {
  const CareersSheet({super.key});

  @override
  ConsumerState<CareersSheet> createState() => _CareersSheetState();
}

class _CareersSheetState extends ConsumerState<CareersSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _category = 'all';
  bool _onlyEligible = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(lifeEngineProvider).value;
    _tab = TabController(length: 2, vsync: this, initialIndex: s?.character.currentJobTitle != null ? 0 : 1);
  }

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
      title: 'Carreira',
      subtitle: s.character.currentJobTitle ?? 'Procurando oportunidades',
      icon: Icons.work_rounded,
      color: GamePalette.blue,
      header: TabBar(controller: _tab, tabs: const [
        Tab(text: 'Meu emprego', icon: Icon(Icons.badge_rounded, size: 18), height: 52),
        Tab(text: 'Vagas', icon: Icon(Icons.search_rounded, size: 18), height: 52),
      ]),
      body: TabBarView(controller: _tab, children: [_current(s), _jobBoard(s)]),
    );
  }

  // ------------------------------------------------------------------ emprego atual
  Widget _current(LifeEngineState s) {
    final p = context.gp;
    final c = s.character;
    final t = CareerCatalog.byId(c.currentJobId);
    final notifier = ref.read(lifeEngineProvider.notifier);
    if (c.currentJobTitle == null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        EmptyState(
          icon: Icons.work_off_rounded,
          title: s.extras.retired ? 'Você está aposentado(a)' : 'Sem emprego no momento',
          message: c.currentAge < 14 ? 'Empregos de meio período a partir dos 14 anos.' : 'Veja a aba Vagas e candidate-se.',
          color: GamePalette.blue,
          action: c.currentAge >= 14 ? GameButton(label: 'Ver vagas', expand: false, icon: Icons.search_rounded, onTap: () => _tab.animateTo(1)) : null,
        ),
        if (s.extras.experience.isNotEmpty) ...[
          const SectionTitle('Experiência acumulada', icon: Icons.timeline_rounded),
          Wrap(spacing: 8, runSpacing: 8, children: s.extras.experience.entries.map((e) {
            final cat = CareerCatalog.category(e.key);
            return Pill('${cat.name}: ${e.value} ano(s)', color: cat.color, icon: cat.icon);
          }).toList()),
        ],
      ]);
    }
    final cat = t == null ? null : CareerCatalog.category(t.category);
    final color = cat?.color ?? GamePalette.blue;
    final level = s.extras.careerLevel;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        GameCard(
          gradient: LinearGradient(colors: [color, Color.lerp(color, Colors.black, 0.35)!]),
          glow: true,
          accent: color,
          child: Row(children: [
            IconBadge(icon: t?.icon ?? Icons.work_rounded, color: Colors.white.withAlpha(60), secondary: Colors.white.withAlpha(20), size: 60),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.currentJobTitle!, style: AppTheme.display(21, color: Colors.white)),
                Text('${s.extras.company ?? ''} · ${t?.name ?? ''}', style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12.5)),
                const SizedBox(height: 6),
                Text('${Fmt.money(c.currentSalary ?? 0)}/ano', style: AppTheme.display(18, color: Colors.white)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        GameCard(
          child: Column(children: [
            StatMeter(label: 'Desempenho', value: c.jobPerformance, icon: Icons.speed_rounded),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _MiniStat(icon: Icons.event_rounded, label: 'No cargo', value: '${s.extras.yearsAtLevel} ano(s)')),
              Expanded(child: _MiniStat(icon: Icons.schedule_rounded, label: 'Jornada', value: '${t?.hoursPerWeek ?? 40}h/sem')),
              Expanded(child: _MiniStat(icon: Icons.whatshot_rounded, label: 'Estresse', value: '${t?.stress ?? 40}%')),
            ]),
          ]),
        ),
        if (t != null) ...[
          const SectionTitle('Progressão de carreira', icon: Icons.stairs_rounded),
          _Ladder(track: t, level: level, color: color),
        ],
        const SectionTitle('Ações no trabalho', icon: Icons.touch_app_rounded),
        LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth > 560 ? 3 : 2;
          final items = [
            ('Trabalhar duro', 'Desempenho ↑ · Estresse ↑', Icons.speed_rounded, GamePalette.violet, () => notifier.workHard()),
            ('Corpo mole', 'Descansa, mas arrisca', Icons.weekend_rounded, const Color(0xFF64748B), () => notifier.act((v, st) => v.slackOff(st))),
            ('Pedir aumento', '1x por ano', Icons.trending_up_rounded, GamePalette.green, () => notifier.askForRaise()),
            ('Pedir promoção', '1x por ano', Icons.stairs_rounded, GamePalette.gold, () => notifier.act((v, st) => v.askForPromotion(st))),
            if (c.currentAge >= 60) ('Aposentar', 'Pensão anual', Icons.beach_access_rounded, GamePalette.teal, () => notifier.act((v, st) => v.retire(st))),
            ('Pedir demissão', 'Sair do emprego', Icons.exit_to_app_rounded, GamePalette.red, () async {
              if (await confirmDialog(context, title: 'Pedir demissão?', message: 'Você vai sair de ${c.currentJobTitle}.', confirm: 'Sair')) {
                notifier.quitJob();
              }
            }),
          ];
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              for (final it in items)
                GameCard(
                  onTap: it.$5,
                  accent: it.$4,
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    IconBadge(icon: it.$3, color: it.$4, size: 38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(it.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 13)),
                        Text(it.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.textMuted, fontSize: 11)),
                      ]),
                    ),
                  ]),
                ),
            ],
          );
        }),
        if (t != null && t.benefits.isNotEmpty) ...[
          const SectionTitle('Benefícios', icon: Icons.card_giftcard_rounded),
          Wrap(spacing: 8, runSpacing: 8, children: t.benefits.map((b) => Pill(b, color: color, icon: Icons.check_rounded)).toList()),
        ],
      ],
    );
  }

  // ------------------------------------------------------------------ quadro de vagas
  Widget _jobBoard(LifeEngineState s) {
    final p = context.gp;
    final ctx = ref.read(lifeEngineServiceProvider).ctx;
    final draft = LifeDraft(s, ctx);
    var tracks = CareerCatalog.tracks.where((t) => _category == 'all' || t.category == _category).toList();
    final eval = {for (final t in tracks) t.id: CareerSystem.missing(draft, t)};
    if (_onlyEligible) tracks = tracks.where((t) => eval[t.id]!.isEmpty).toList();
    tracks.sort((a, b) => eval[a.id]!.length.compareTo(eval[b.id]!.length));
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            children: [
              _catChip('all', 'Todas', Icons.apps_rounded, GamePalette.violet),
              for (final c in CareerCatalog.categories) _catChip(c.id, c.name, c.icon, c.color),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Text('${tracks.length} carreiras', style: TextStyle(color: p.textMuted, fontSize: 12)),
            const Spacer(),
            Text('Só elegíveis', style: TextStyle(color: p.textDim, fontSize: 12, fontWeight: FontWeight.w700)),
            Switch(value: _onlyEligible, onChanged: (v) => setState(() => _onlyEligible = v)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            itemCount: tracks.length,
            itemBuilder: (context, i) {
              final t = tracks[i];
              final miss = eval[t.id]!;
              final chance = miss.isEmpty ? CareerSystem.hireChance(draft, t) : 0.0;
              final card = Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _JobCard(track: t, missing: miss, chance: chance, current: s.character.currentJobId == t.id,
                    onTap: () => _openJob(t, miss, chance)),
              );
              if (!context.motion || i > 8) return card;
              return card.animate().fadeIn(delay: (i * 35).ms, duration: 240.ms).slideY(begin: 0.08, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _catChip(String id, String label, IconData icon, Color color) {
    final sel = _category == id;
    final p = context.gp;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Pressable(
        onTap: () => setState(() => _category = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: sel ? color : p.card,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: sel ? color : p.border),
          ),
          child: Row(children: [
            Icon(icon, size: 16, color: sel ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: sel ? Colors.white : p.text, fontWeight: FontWeight.w700, fontSize: 12.5)),
          ]),
        ),
      ),
    );
  }

  Future<void> _openJob(CareerTrack t, List<String> miss, double chance) async {
    final apply = await showGameSheet<bool>(context, _JobDetail(track: t, missing: miss, chance: chance));
    if (apply != true || !mounted) return;
    final ctx = ref.read(lifeEngineServiceProvider).ctx;
    final q = CareerSystem.randomQuestion(ctx);
    final answer = await showDialog<int>(context: context, barrierDismissible: false, builder: (_) => _InterviewDialog(track: t, question: q));
    if (answer == null) return;
    await ref.read(lifeEngineProvider.notifier).applyJob(t.id, q.scores[answer]);
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return Column(children: [
      Icon(icon, size: 18, color: p.textDim),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 13)),
      Text(label, style: TextStyle(color: p.textMuted, fontSize: 10.5)),
    ]);
  }
}

class _Ladder extends StatelessWidget {
  final CareerTrack track;
  final int level;
  final Color color;
  const _Ladder({required this.track, required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return GameCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(children: [
        for (var i = track.levels.length - 1; i >= 0; i--)
          Row(children: [
            Column(children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= level ? color : p.cardHigh,
                  border: Border.all(color: i == level ? Colors.white : color.withAlpha(120), width: i == level ? 2.5 : 1),
                  boxShadow: i == level ? [BoxShadow(color: color.withAlpha(140), blurRadius: 10)] : null,
                ),
                child: Icon(i < level ? Icons.check_rounded : (i == level ? Icons.person_rounded : Icons.lock_rounded),
                    size: 14, color: i <= level ? Colors.white : p.textMuted),
              ),
              if (i > 0) Container(width: 2.5, height: 16, color: i <= level ? color : p.border),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: i > 0 ? 16 : 0),
                child: Row(children: [
                  Expanded(
                    child: Text(track.levels[i].title,
                        style: TextStyle(color: i == level ? p.text : p.textDim, fontWeight: i == level ? FontWeight.w900 : FontWeight.w600)),
                  ),
                  Text(Fmt.compactMoney(track.levels[i].salary), style: TextStyle(color: i <= level ? GamePalette.green : p.textMuted, fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ),
            ),
          ]),
      ]),
    );
  }
}

class _JobCard extends StatelessWidget {
  final CareerTrack track;
  final List<String> missing;
  final double chance;
  final bool current;
  final VoidCallback onTap;
  const _JobCard({required this.track, required this.missing, required this.chance, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final cat = CareerCatalog.category(track.category);
    final ok = missing.isEmpty;
    return GameCard(
      onTap: onTap,
      accent: ok ? cat.color : null,
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        IconBadge(icon: track.icon, color: ok ? cat.color : const Color(0xFF64748B), size: 52),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(track.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14.5))),
              if (current) const Pill('Atual', color: GamePalette.green, solid: true),
            ]),
            Text('${track.levels.first.title} → ${track.levels.last.title}', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.textMuted, fontSize: 11.5)),
            const SizedBox(height: 6),
            Row(children: [
              Text('${Fmt.compactMoney(track.entrySalary)} – ${Fmt.compactMoney(track.topSalary)}',
                  style: const TextStyle(color: GamePalette.green, fontWeight: FontWeight.w800, fontSize: 12.5)),
              const Spacer(),
              if (ok)
                Pill('${(chance * 100).round()}% de chance', color: GamePalette.forValue((chance * 100).round()), icon: Icons.how_to_reg_rounded)
              else
                Pill('${missing.length} requisito(s)', color: GamePalette.red, icon: Icons.lock_rounded),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _JobDetail extends StatelessWidget {
  final CareerTrack track;
  final List<String> missing;
  final double chance;
  const _JobDetail({required this.track, required this.missing, required this.chance});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final cat = CareerCatalog.category(track.category);
    final ok = missing.isEmpty;
    Widget info(IconData i, String l, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Icon(i, size: 18, color: cat.color),
            const SizedBox(width: 10),
            Text(l, style: TextStyle(color: p.textMuted)),
            const Spacer(),
            Text(v, style: TextStyle(color: p.text, fontWeight: FontWeight.w700)),
          ]),
        );
    return GameSheet(
      title: track.name,
      subtitle: cat.name,
      icon: track.icon,
      color: cat.color,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
        children: [
          ItemArt(icon: track.icon, colors: [cat.color, Color.lerp(cat.color, Colors.black, 0.45)!], height: 130, tier: track.topSalary > 1000000 ? 4 : (track.topSalary > 300000 ? 3 : 1), badge: cat.name.toUpperCase()),
          const SizedBox(height: 12),
          Text(track.description, style: TextStyle(color: p.textDim, fontSize: 14.5, height: 1.4)),
          const SizedBox(height: 12),
          GameCard(
            child: Column(children: [
              info(Icons.school_rounded, 'Escolaridade', educationLabel(track.minEducation)),
              info(Icons.cake_rounded, 'Idade mínima', '${track.minAge} anos'),
              info(Icons.schedule_rounded, 'Jornada', '${track.hoursPerWeek}h por semana${track.partTime ? ' (meio período)' : ''}'),
              info(Icons.whatshot_rounded, 'Estresse', '${track.stress}%'),
              info(Icons.shield_rounded, 'Risco de demissão', track.risk <= 0.02 ? 'Baixo' : (track.risk <= 0.06 ? 'Médio' : 'Alto')),
              if (track.fameGain > 0) info(Icons.star_rounded, 'Fama', '+${track.fameGain}/ano'),
            ]),
          ),
          const SectionTitle('Requisitos', icon: Icons.checklist_rounded),
          if (ok)
            const Pill('Você atende a todos os requisitos!', color: GamePalette.green, icon: Icons.check_circle_rounded)
          else
            Wrap(spacing: 6, runSpacing: 6, children: missing.map((m) => Pill(m, color: GamePalette.red, icon: Icons.close_rounded)).toList()),
          const SectionTitle('Plano de carreira', icon: Icons.stairs_rounded),
          _Ladder(track: track, level: -1, color: cat.color),
          if (track.benefits.isNotEmpty) ...[
            const SectionTitle('Benefícios', icon: Icons.card_giftcard_rounded),
            Wrap(spacing: 8, runSpacing: 8, children: track.benefits.map((b) => Pill(b, color: cat.color)).toList()),
          ],
          const SizedBox(height: 20),
          GameButton(
            label: ok ? 'Candidatar-se · ${(chance * 100).round()}%' : 'Requisitos pendentes',
            icon: Icons.send_rounded,
            colors: [cat.color, Color.lerp(cat.color, Colors.black, 0.3)!],
            onTap: ok ? () => Navigator.pop(context, true) : null,
          ),
        ],
      ),
    );
  }
}

class _InterviewDialog extends StatelessWidget {
  final CareerTrack track;
  final InterviewQuestion question;
  const _InterviewDialog({required this.track, required this.question});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final cat = CareerCatalog.category(track.category);
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              IconBadge(icon: Icons.record_voice_over_rounded, color: cat.color, size: 46),
              const SizedBox(width: 12),
              Expanded(child: Text('Entrevista de emprego', style: AppTheme.display(19, color: p.text))),
            ]),
            const SizedBox(height: 6),
            Text(track.levels.first.title, style: TextStyle(color: p.textMuted)),
            const SizedBox(height: 14),
            Text('"${question.question}"', style: TextStyle(color: p.text, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            for (var i = 0; i < question.answers.length; i++) ...[
              GameCard(
                onTap: () => Navigator.pop(context, i),
                padding: const EdgeInsets.all(12),
                accent: cat.color,
                child: Text(question.answers[i], style: TextStyle(color: p.text, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            Text('Sua resposta influencia a chance de contratação.', textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, fontSize: 11.5)),
          ]),
        ),
      ),
    );
  }
}
