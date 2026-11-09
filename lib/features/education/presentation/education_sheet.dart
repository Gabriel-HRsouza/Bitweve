import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/careers/models/career_track.dart';
import 'package:bitweve/features/education/data/education_catalog.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/education_system.dart';
import 'package:bitweve/features/life_engine/systems/life_draft.dart';
import 'package:bitweve/features/school/data/school_catalog.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

class EducationSheet extends ConsumerStatefulWidget {
  const EducationSheet({super.key});

  @override
  ConsumerState<EducationSheet> createState() => _EducationSheetState();
}

class _EducationSheetState extends ConsumerState<EducationSheet> with SingleTickerProviderStateMixin {
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
    return GameSheet(
      title: 'Educação',
      subtitle: educationLabel(s.character.educationLevel),
      icon: Icons.school_rounded,
      color: const Color(0xFF6366F1),
      header: TabBar(controller: _tab, isScrollable: true, tabAlignment: TabAlignment.start, tabs: const [
        Tab(text: 'Situação', icon: Icon(Icons.assignment_rounded, size: 18), height: 52),
        Tab(text: 'Graduação', icon: Icon(Icons.account_balance_rounded, size: 18), height: 52),
        Tab(text: 'Pós', icon: Icon(Icons.workspace_premium_rounded, size: 18), height: 52),
        Tab(text: 'Cursos', icon: Icon(Icons.auto_stories_rounded, size: 18), height: 52),
      ]),
      body: TabBarView(controller: _tab, children: [
        _status(s),
        _degrees(s, EducationCatalog.degrees),
        _degrees(s, EducationCatalog.postgrad),
        _courses(s),
      ]),
    );
  }

  Widget _status(LifeEngineState s) {
    final p = context.gp;
    final e = s.extras.education;
    final notifier = ref.read(lifeEngineProvider.notifier);
    final deg = EducationCatalog.degree(e.degreeId);
    final progress = e.yearsTotal > 0 ? e.yearsDone / e.yearsTotal : (e.stage == 'elementary' ? e.yearsDone / 9 : 0.0);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        GameCard(
          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF312E81)]),
          glow: true,
          accent: const Color(0xFF6366F1),
          child: Row(children: [
            IconBadge(icon: deg?.icon ?? Icons.school_rounded, color: Colors.white.withAlpha(60), secondary: Colors.white.withAlpha(20), size: 58),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(EducationSystem.stageLabel(e), style: AppTheme.display(19, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Escolaridade: ${educationLabel(s.character.educationLevel)}', style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12.5)),
                if (e.isStudying) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 8, backgroundColor: Colors.white24, color: Colors.white),
                  ),
                ],
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        if (e.isStudying || e.completedDegrees.isNotEmpty)
          GameCard(
            child: Column(children: [
              StatMeter(label: 'Média (GPA ${e.gpa.toStringAsFixed(1)})', value: (e.gpa * 10).round(), icon: Icons.grade_rounded),
              if (e.scholarshipPct > 0) ...[
                const SizedBox(height: 10),
                Pill('Bolsa de ${(e.scholarshipPct * 100).round()}%', color: GamePalette.gold, icon: Icons.workspace_premium_rounded),
              ],
              if (e.failedYears > 0) ...[
                const SizedBox(height: 8),
                Text('Reprovações: ${e.failedYears}', style: const TextStyle(color: GamePalette.red, fontWeight: FontWeight.w700)),
              ],
            ]),
          ),
        const SectionTitle('Ações', icon: Icons.touch_app_rounded),
        Row(children: [
          Expanded(
            child: GameCard(
              onTap: () => notifier.studyExtra(),
              accent: GamePalette.blue,
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                const IconBadge(icon: Icons.menu_book_rounded, color: GamePalette.blue, size: 44),
                const SizedBox(height: 6),
                Text('Estudar', style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                Text('${s.extras.actionsThisYear['study'] ?? 0}/4 no ano · melhora notas', textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, fontSize: 11)),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GameCard(
              enabled: e.isStudying,
              onTap: e.isStudying
                  ? () async {
                      if (await confirmDialog(context, title: 'Abandonar os estudos?', message: 'Isso afeta suas oportunidades de carreira.', confirm: 'Abandonar')) {
                        notifier.act((v, st) => v.dropOut(st));
                      }
                    }
                  : null,
              accent: GamePalette.red,
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                const IconBadge(icon: Icons.exit_to_app_rounded, color: GamePalette.red, size: 44),
                const SizedBox(height: 6),
                Text('Abandonar', style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                Text('A partir dos 16 anos', style: TextStyle(color: p.textMuted, fontSize: 11)),
              ]),
            ),
          ),
        ]),
        const SectionTitle('Diplomas e certificados', icon: Icons.workspace_premium_rounded),
        if (e.completedDegrees.isEmpty && e.courses.isEmpty)
          Text('Nenhum diploma ainda.', style: TextStyle(color: p.textMuted))
        else
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final d in e.completedDegrees)
              Pill(d == 'high_school' ? 'Ensino Médio' : (EducationCatalog.degree(d)?.name ?? d), color: GamePalette.gold, icon: Icons.workspace_premium_rounded),
            for (final c in e.courses) Pill(EducationCatalog.course(c)?.name ?? c, color: GamePalette.cyan, icon: Icons.verified_rounded),
          ]),
      ],
    );
  }

  Widget _degrees(LifeEngineState s, List<DegreeInfo> list) {
    final p = context.gp;
    final draft = LifeDraft(s, ref.read(lifeEngineServiceProvider).ctx);
    return LayoutBuilder(builder: (context, box) {
      final cols = (box.maxWidth / 230).floor().clamp(1, 4);
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 250),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final d = list[i];
          final blocker = EducationSystem.enrollBlocker(draft, d);
          final done = s.extras.education.completedDegrees.contains(d.id);
          final current = s.extras.education.degreeId == d.id;
          final annual = d.annualCost * draft.ctx.costMult(s.character.country);
          return GameCard(
            onTap: () => _enroll(d, blocker, annual),
            accent: d.color,
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ItemArt(icon: d.icon, colors: [d.color, Color.lerp(d.color, Colors.black, 0.45)!], height: 96, radius: 14, badge: d.area.toUpperCase(), tier: d.difficulty >= 80 ? 3 : 1),
              const SizedBox(height: 8),
              Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14.5)),
              Text('${d.years} anos · ${annual > 0 ? '${Fmt.compactMoney(annual)}/ano' : 'gratuito'}', style: TextStyle(color: p.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              StatMeter(label: 'Dificuldade', value: d.difficulty, icon: Icons.terrain_rounded, inverted: true, compact: true),
              const Spacer(),
              if (done)
                const Pill('Concluído', color: GamePalette.green, icon: Icons.check_circle_rounded)
              else if (current)
                const Pill('Cursando', color: GamePalette.blue, icon: Icons.school_rounded)
              else if (blocker != null)
                Pill(blocker, color: GamePalette.red, icon: Icons.lock_rounded)
              else
                Pill('Inteligência mín. ${d.minSmarts}', color: s.character.smarts >= d.minSmarts ? GamePalette.green : GamePalette.orange, icon: Icons.psychology_rounded),
            ]),
          );
        },
      );
    });
  }

  Future<void> _enroll(DegreeInfo d, String? blocker, double annual) async {
    if (blocker != null) {
      await confirmDialog(context, title: d.name, message: blocker, confirm: 'Ok', color: GamePalette.orange, icon: Icons.lock_rounded);
      return;
    }
    final mode = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final p = ctx.gp;
        Widget opt(String id, IconData icon, Color color, String title, String sub) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GameCard(
                onTap: () => Navigator.pop(ctx, id),
                accent: color,
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  IconBadge(icon: icon, color: color, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                      Text(sub, style: TextStyle(color: p.textMuted, fontSize: 12)),
                    ]),
                  ),
                ]),
              ),
            );
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Prestar vestibular: ${d.name}', textAlign: TextAlign.center, style: AppTheme.display(19, color: p.text)),
                const SizedBox(height: 6),
                Text('Aprovação depende da sua inteligência e notas. Bolsas podem sair para quem tem média alta.',
                    textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, fontSize: 12.5)),
                const SizedBox(height: 14),
                opt('cash', Icons.payments_rounded, GamePalette.green, 'Pagar anualmente', '${Fmt.money(annual)} por ano, debitado ao envelhecer'),
                opt('loan', Icons.account_balance_rounded, GamePalette.blue, 'Financiamento estudantil', 'Paga depois, com juros de 6,5% a.a.'),
                opt('parents', Icons.family_restroom_rounded, GamePalette.pink, 'Pedir aos pais', 'Só se a família tiver condições'),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ]),
            ),
          ),
        );
      },
    );
    if (mode == null || !mounted) return;
    final inst = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final p = ctx.gp;
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460, maxHeight: 620),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Escolha a instituição', style: AppTheme.display(19, color: p.text)),
                const SizedBox(height: 4),
                Text('Públicas são gratuitas e concorridas; as de elite custam mais e abrem portas.',
                    textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, fontSize: 12.5)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(shrinkWrap: true, children: [
                    for (final i in SchoolCatalog.institutions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GameCard(
                          onTap: () => Navigator.pop(ctx, i.id),
                          accent: i.color,
                          padding: const EdgeInsets.all(10),
                          child: Row(children: [
                            IconBadge(icon: i.icon, color: i.color, size: 40),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(i.name, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 13.5)),
                                Text(
                                    '${i.tierLabel} · ${i.city} · prestígio ${i.prestige} · ${i.costMult == 0 ? 'gratuita' : '${Fmt.money(annual * i.costMult)}/ano'}',
                                    style: TextStyle(color: p.textMuted, fontSize: 11.5)),
                              ]),
                            ),
                            Pill(i.entryMod < -0.1 ? 'Difícil' : (i.entryMod > 0.1 ? 'Fácil' : 'Média'),
                                color: i.entryMod < -0.1 ? GamePalette.red : (i.entryMod > 0.1 ? GamePalette.green : GamePalette.gold)),
                          ]),
                        ),
                      ),
                  ]),
                ),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ]),
            ),
          ),
        );
      },
    );
    if (inst != null) await ref.read(lifeEngineProvider.notifier).act((v, st) => v.enroll(st, d.id, mode, inst));
  }

  Widget _courses(LifeEngineState s) {
    final p = context.gp;
    final mult = ref.read(lifeEngineServiceProvider).ctx.costMult(s.character.country);
    return LayoutBuilder(builder: (context, box) {
      final cols = (box.maxWidth / 230).floor().clamp(1, 4);
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 200),
        itemCount: EducationCatalog.courses.length,
        itemBuilder: (_, i) {
          final c = EducationCatalog.courses[i];
          final done = s.extras.education.courses.contains(c.id);
          final young = s.character.currentAge < c.minAge;
          return GameCard(
            onTap: done || young
                ? null
                : () async {
                    if (await confirmDialog(context, title: c.name, message: '${c.description}\n\nCusto: ${Fmt.money(c.cost * mult)} · −15 energia', confirm: 'Fazer curso', color: c.color, icon: c.icon)) {
                      ref.read(lifeEngineProvider.notifier).act((v, st) => v.takeCourse(st, c.id));
                    }
                  },
            enabled: !young,
            accent: c.color,
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                IconBadge(icon: c.icon, color: c.color, size: 44),
                const Spacer(),
                if (done) const Icon(Icons.verified_rounded, color: GamePalette.green),
              ]),
              const SizedBox(height: 8),
              Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.textMuted, fontSize: 12)),
              const Spacer(),
              if (c.unlocks.isNotEmpty) Text(c.unlocks, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.color, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(done ? 'Concluído' : (young ? 'A partir de ${c.minAge} anos' : Fmt.money(c.cost * mult)),
                  style: TextStyle(color: done ? GamePalette.green : p.text, fontWeight: FontWeight.w900)),
            ]),
          );
        },
      );
    });
  }
}
