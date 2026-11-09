import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/education/data/education_catalog.dart';
import 'package:bitweve/features/education/presentation/education_sheet.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/education_system.dart';
import 'package:bitweve/features/minigames/games/exam_quiz.dart';
import 'package:bitweve/features/parties/presentation/party_planner_sheet.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/presentation/person_profile_sheet.dart';
import 'package:bitweve/features/relationships/romance_rules.dart';
import 'package:bitweve/features/school/data/school_catalog.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/motion.dart';
import 'package:bitweve/shared/ui/scene_art.dart';

/// Card de ação com ícone, título, descrição e indicador.
class ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String? indicator;
  final VoidCallback? onTap;
  final bool enabled;
  final int index;

  const ActionTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.indicator,
    this.onTap,
    this.enabled = true,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final card = GameCard(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      accent: color,
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        IconBadge(icon: icon, color: enabled ? color : const Color(0xFF64748B), size: 42),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.text, fontWeight: FontWeight.w900, fontSize: 13.5)),
            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.textMuted, fontSize: 11.5, height: 1.2)),
          ]),
        ),
        if (indicator != null) ...[
          const SizedBox(width: 6),
          Pill(indicator!, color: color),
        ],
        Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 18),
      ]),
    );
    if (!context.motion || index > 14) return card;
    return card.animate().fadeIn(delay: (index * 25).ms, duration: 220.ms).slideY(begin: 0.06, end: 0);
  }
}

Widget actionGrid(List<Widget> tiles) => LayoutBuilder(builder: (context, box) {
      final cols = (box.maxWidth / 300).floor().clamp(1, 3);
      final rows = <Widget>[];
      for (var i = 0; i < tiles.length; i += cols) {
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var j = i; j < i + cols; j++) ...[
              if (j > i) const SizedBox(width: 10),
              Expanded(child: j < tiles.length ? tiles[j] : const SizedBox.shrink()),
            ],
          ]),
        ));
      }
      return Column(children: rows);
    });

/// Escola e faculdade jogáveis.
class SchoolSheet extends ConsumerStatefulWidget {
  const SchoolSheet({super.key});

  @override
  ConsumerState<SchoolSheet> createState() => _SchoolSheetState();
}

class _SchoolSheetState extends ConsumerState<SchoolSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);
  bool _ensured = false;

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  LifeEngineNotifier get _n => ref.read(lifeEngineProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final e = s.extras.education;
    // Saves antigos: garante turma/professores ao abrir
    if (!_ensured && e.isStudying && !s.npcs.any((n) => n.isAlive && n.relationshipType == RelationshipType.teacher)) {
      _ensured = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _n.act((v, st) => v.ensureClass(st)));
    }
    if (e.inSchool) return _school(s);
    if (e.inHigherEd) return _college(s);
    return GameSheet(
      title: 'Escola & Faculdade',
      icon: Icons.school_rounded,
      color: const Color(0xFF6366F1),
      body: EmptyState(
        icon: Icons.school_rounded,
        title: s.character.currentAge < 6 ? 'Ainda é cedo' : 'Você não está estudando',
        message: s.character.currentAge < 6
            ? 'A escola começa aos 6 anos.'
            : 'Preste vestibular, faça um curso livre ou o supletivo.',
        color: const Color(0xFF6366F1),
        action: s.character.currentAge >= 6
            ? GameButton(label: 'Vestibular e cursos', expand: false, icon: Icons.menu_book_rounded, onTap: () => showGameSheet(context, const EducationSheet()))
            : null,
      ),
    );
  }

  // =========================================================================
  // ESCOLA
  // =========================================================================
  Widget _school(LifeEngineState s) {
    final sc = s.extras.school;
    return GameSheet(
      title: sc.schoolName.isEmpty ? 'Escola' : sc.schoolName,
      subtitle: EducationSystem.stageLabel(s.extras.education),
      icon: Icons.school_rounded,
      color: const Color(0xFF6366F1),
      header: TabBar(controller: _tab, isScrollable: true, tabAlignment: TabAlignment.start, tabs: const [
        Tab(icon: Icon(Icons.dashboard_rounded, size: 18), text: 'Escola'),
        Tab(icon: Icon(Icons.local_activity_rounded, size: 18), text: 'Atividades'),
        Tab(icon: Icon(Icons.groups_rounded, size: 18), text: 'Colegas'),
        Tab(icon: Icon(Icons.co_present_rounded, size: 18), text: 'Professores'),
      ]),
      body: TabBarView(controller: _tab, children: [
        _schoolOverview(s),
        _schoolActivities(s),
        _people(s, (n) => n.relationshipType == RelationshipType.classmate || (s.extras.npcMeta[n.id]?.origin == 'school' && n.relationshipType == RelationshipType.friend),
            'Seus colegas de turma aparecem aqui.'),
        _people(s, (n) => n.relationshipType == RelationshipType.teacher && (s.extras.npcMeta[n.id]?.origin ?? 'school') == 'school',
            'Seus professores aparecem aqui.'),
      ]),
    );
  }

  Widget _schoolOverview(LifeEngineState s) {
    final p = context.gp;
    final sc = s.extras.school;
    final e = s.extras.education;
    final clique = SchoolCatalog.clique(sc.clique);
    final schedule = e.stage == 'high_school' ? 'Seg–Sex · 7h00–12h30' : 'Seg–Sex · 7h30–12h00';
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
      BuildingArt(type: 'school', colors: const [Color(0xFF6366F1), Color(0xFF312E81)], height: 120,
          badge: SchoolCatalog.schoolTypeLabel(sc.schoolType)),
      const SizedBox(height: 12),
      GameCard(
        child: Column(children: [
          StatMeter(label: 'Desempenho (notas)', value: sc.performance, icon: Icons.grade_rounded),
          const SizedBox(height: 8),
          StatMeter(label: 'Popularidade', value: sc.popularity, icon: Icons.star_rounded),
          const SizedBox(height: 8),
          StatMeter(label: 'Relação com professores', value: sc.teacherRel, icon: Icons.co_present_rounded),
          const SizedBox(height: 8),
          StatMeter(label: 'Estresse', value: s.character.stress, icon: Icons.whatshot_rounded, inverted: true),
        ]),
      ),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        Pill('Média ${e.gpa.toStringAsFixed(1)}', color: GamePalette.blue, icon: Icons.school_rounded),
        Pill('${sc.absences} faltas', color: sc.absences > 20 ? GamePalette.red : GamePalette.teal, icon: Icons.event_busy_rounded),
        Pill('${sc.warnings} advertência(s)', color: sc.warnings >= 2 ? GamePalette.red : GamePalette.gold, icon: Icons.report_rounded),
        Pill('${sc.suspensions} suspensão(ões)', color: sc.suspensions > 0 ? GamePalette.red : const Color(0xFF64748B), icon: Icons.gavel_rounded),
        Pill('${sc.examsThisYear} prova(s) no ano', color: GamePalette.violet, icon: Icons.quiz_rounded),
        Pill(schedule, color: const Color(0xFF64748B), icon: Icons.schedule_rounded),
        if (clique != null) Pill('Grupo: ${clique.name}', color: clique.color, icon: clique.icon),
        for (final id in sc.clubs)
          if (SchoolCatalog.club(id) != null) Pill(SchoolCatalog.club(id)!.name, color: SchoolCatalog.club(id)!.color, icon: SchoolCatalog.club(id)!.icon),
        if (sc.suspended) const Pill('SUSPENSO(A)', color: GamePalette.red, icon: Icons.block_rounded),
      ]),
      if (sc.history.isNotEmpty) ...[
        const SectionTitle('Eventos recentes', icon: Icons.history_rounded),
        for (final h in sc.history.reversed.take(8))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $h', style: TextStyle(color: p.textDim, fontSize: 12.5)),
          ),
      ],
    ]);
  }

  Widget _schoolActivities(LifeEngineState s) {
    final age = s.character.currentAge;
    final a = s.extras.actionsThisYear;
    int u(String k) => a[k] ?? 0;
    var i = 0;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
      actionGrid([
        ActionTile(index: i++, icon: Icons.menu_book_rounded, color: GamePalette.blue, title: 'Aula', description: 'Prestar atenção e participar', indicator: '${u('attend')}/4',
            onTap: () => _n.act((v, st) => v.attendClass(st))),
        ActionTile(index: i++, icon: Icons.local_library_rounded, color: const Color(0xFF6366F1), title: 'Estudar mais', description: 'Biblioteca e listas de exercícios', indicator: '${u('study')}/4',
            onTap: () => _n.act((v, st) => v.schoolStudy(st))),
        ActionTile(index: i++, icon: Icons.quiz_rounded, color: GamePalette.violet, title: 'Fazer prova', description: 'Responda 5 questões valendo nota', indicator: '${u('exam')}/3',
            onTap: () => _exam(s, false)),
        ActionTile(index: i++, icon: Icons.person_add_rounded, color: GamePalette.pink, title: 'Fazer amigos', description: 'Puxar assunto no intervalo', indicator: '${u('makeFriends')}/3',
            onTap: () => _n.act((v, st) => v.makeSchoolFriends(st))),
        ActionTile(index: i++, icon: Icons.groups_2_rounded, color: GamePalette.orange, title: 'Grupos escolares', description: 'Atletas, nerds, populares...',
            onTap: () => _pickClique(s)),
        ActionTile(index: i++, icon: Icons.sports_soccer_rounded, color: GamePalette.green, title: 'Extracurriculares', description: 'Esportes, teatro, robótica...', indicator: '${s.extras.school.clubs.length}/2',
            onTap: () => _pickClub(s, SchoolCatalog.clubs, s.extras.school.clubs)),
        ActionTile(index: i++, icon: Icons.emoji_events_rounded, color: GamePalette.gold, title: 'Eventos da escola', description: 'Feira de ciências, excursão, show...',
            onTap: () => _pickEvent(s)),
        ActionTile(index: i++, icon: Icons.house_rounded, color: const Color(0xFFDB2777), title: 'Festa em casa', description: 'Convide a galera (seus pais ajudam)', enabled: age >= 10,
            onTap: () => showGameSheet(context, const PartyPlannerSheet(initialType: 'house'))),
        ActionTile(index: i++, icon: Icons.nightlife_rounded, color: GamePalette.pink, title: 'Baile escolar', description: age >= 14 ? 'Vá sozinho(a) ou convide alguém' : 'A partir de 14 anos',
            enabled: age >= 14, indicator: '${u('prom')}/1', onTap: () => _prom(s)),
        ActionTile(index: i++, icon: Icons.co_present_rounded, color: GamePalette.teal, title: 'Interagir com professores', description: 'Pedir ajuda, revisar nota...',
            onTap: () => _tab.animateTo(3)),
        ActionTile(index: i++, icon: Icons.local_hospital_rounded, color: GamePalette.red, title: 'Visitar enfermaria', description: 'Cuidar da saúde (ou fingir)', indicator: '${u('nurse')}/3',
            onTap: () => _n.act((v, st) => v.visitNurse(st))),
        ActionTile(index: i++, icon: Icons.directions_run_rounded, color: const Color(0xFFF59E0B), title: 'Faltar à escola', description: 'Diversão agora, faltas depois', indicator: '${u('skip')}/4',
            onTap: () => _n.act((v, st) => v.skipSchool(st))),
        ActionTile(index: i++, icon: Icons.mood_rounded, color: GamePalette.red, title: 'Aprontar', description: 'Pegadinhas podem render advertências', indicator: '${u('misbehave')}/3',
            onTap: () => _n.act((v, st) => v.misbehave(st))),
        ActionTile(index: i++, icon: Icons.swap_horiz_rounded, color: const Color(0xFF64748B), title: 'Mudar de escola', description: 'Pública, particular ou internacional',
            onTap: () => _changeSchool(s)),
        ActionTile(index: i++, icon: Icons.exit_to_app_rounded, color: const Color(0xFF475569), title: 'Abandonar os estudos', description: age >= 16 ? 'Volta só pelo supletivo' : 'Proibido antes dos 16',
            enabled: age >= 16, onTap: () async {
          final ok = await confirmDialog(context, title: 'Largar a escola?', message: 'Você poderá voltar pelo supletivo, mas perde a turma.', confirm: 'Abandonar');
          if (ok) await _n.act((v, st) => v.dropOut(st));
        }),
      ]),
    ]);
  }

  // =========================================================================
  // FACULDADE (FT1 Curso · FT2 Atividades · FT3 Colegas · FT4 Carreira)
  // =========================================================================
  Widget _college(LifeEngineState s) {
    final deg = EducationCatalog.degree(s.extras.education.degreeId);
    final inst = SchoolCatalog.institution(s.extras.school.institutionId);
    return GameSheet(
      title: deg?.name ?? 'Faculdade',
      subtitle: s.extras.school.institutionName ?? inst.name,
      icon: deg?.icon ?? Icons.account_balance_rounded,
      color: deg?.color ?? const Color(0xFF6366F1),
      header: TabBar(controller: _tab, isScrollable: true, tabAlignment: TabAlignment.start, tabs: const [
        Tab(icon: Icon(Icons.menu_book_rounded, size: 18), text: 'Curso'),
        Tab(icon: Icon(Icons.celebration_rounded, size: 18), text: 'Atividades'),
        Tab(icon: Icon(Icons.groups_rounded, size: 18), text: 'Colegas'),
        Tab(icon: Icon(Icons.work_rounded, size: 18), text: 'Carreira'),
      ]),
      body: TabBarView(controller: _tab, children: [
        _collegeCourse(s),
        _collegeActivities(s),
        _people(s, (n) => n.relationshipType == RelationshipType.collegeMate || (n.relationshipType == RelationshipType.teacher && s.extras.npcMeta[n.id]?.origin == 'college'),
            'Colegas e professores da faculdade aparecem aqui.'),
        _collegeCareer(s),
      ]),
    );
  }

  Widget _collegeCourse(LifeEngineState s) {
    final e = s.extras.education;
    final sc = s.extras.school;
    final deg = EducationCatalog.degree(e.degreeId);
    final inst = SchoolCatalog.institution(sc.institutionId);
    final annual = (deg?.annualCost ?? 0) * (sc.institutionId == null ? 1 : inst.costMult) * (1 - e.scholarshipPct);
    final a = s.extras.actionsThisYear;
    int u(String k) => a[k] ?? 0;
    final lastYear = e.yearsTotal - e.yearsDone <= 1;
    var i = 0;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
      BuildingArt(type: 'university', colors: [deg?.color ?? GamePalette.violet, const Color(0xFF1E1B4B)], height: 120, badge: '${inst.tierLabel} · prestígio ${inst.prestige}'),
      const SizedBox(height: 12),
      GameCard(
        child: Column(children: [
          StatMeter(label: 'Progresso do curso', value: e.yearsTotal == 0 ? 0 : (e.yearsDone * 100 ~/ e.yearsTotal), icon: Icons.flag_rounded),
          const SizedBox(height: 8),
          StatMeter(label: 'Desempenho (notas)', value: sc.performance, icon: Icons.grade_rounded),
          const SizedBox(height: 8),
          StatMeter(label: 'Popularidade no campus', value: sc.collegePopularity, icon: Icons.star_rounded),
          const SizedBox(height: 8),
          StatMeter(label: 'Relação com professores', value: sc.professorRel, icon: Icons.co_present_rounded),
        ]),
      ),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        Pill('${e.yearsDone + 1}º de ${e.yearsTotal} anos', color: GamePalette.blue, icon: Icons.calendar_month_rounded),
        Pill('Média ${e.gpa.toStringAsFixed(1)}', color: GamePalette.violet, icon: Icons.school_rounded),
        Pill('Mensalidade ${Fmt.money(annual)}/ano', color: GamePalette.orange, icon: Icons.payments_rounded),
        if (e.scholarshipPct > 0) Pill('Bolsa ${(e.scholarshipPct * 100).round()}%', color: GamePalette.gold, icon: Icons.workspace_premium_rounded),
        Pill('${sc.absences} faltas', color: sc.absences > 20 ? GamePalette.red : GamePalette.teal, icon: Icons.event_busy_rounded),
        if (e.failedYears > 0) Pill('${e.failedYears} reprovação(ões)', color: GamePalette.red, icon: Icons.warning_rounded),
        if (sc.tccDone) const Pill('TCC aprovado', color: GamePalette.green, icon: Icons.verified_rounded),
      ]),
      const SizedBox(height: 12),
      actionGrid([
        ActionTile(index: i++, icon: Icons.menu_book_rounded, color: GamePalette.blue, title: 'Assistir aulas', description: 'Presença e participação', indicator: '${u('attend')}/4',
            onTap: () => _n.act((v, st) => v.attendClass(st))),
        ActionTile(index: i++, icon: Icons.local_library_rounded, color: const Color(0xFF6366F1), title: 'Estudar', description: 'Biblioteca até tarde', indicator: '${u('study')}/4',
            onTap: () => _n.act((v, st) => v.schoolStudy(st))),
        ActionTile(index: i++, icon: Icons.quiz_rounded, color: GamePalette.violet, title: 'Fazer prova', description: 'Questões de nível universitário', indicator: '${u('exam')}/3',
            onTap: () => _exam(s, true)),
        ActionTile(index: i++, icon: Icons.groups_rounded, color: GamePalette.teal, title: 'Trabalho em grupo', description: 'Seminários e projetos', indicator: '${u('project')}/2',
            onTap: () => _n.act((v, st) => v.collegeProject(st))),
        ActionTile(index: i++, icon: Icons.biotech_rounded, color: const Color(0xFF06B6D4), title: 'TCC', description: lastYear ? 'Pesquisa ${sc.researchPoints}/60' : 'Disponível no último ano',
            enabled: lastYear && !sc.tccDone, onTap: () => _n.act((v, st) => v.thesis(st))),
        ActionTile(index: i++, icon: Icons.directions_run_rounded, color: const Color(0xFFF59E0B), title: 'Matar aula', description: 'Cuidado: +25 faltas reprova', indicator: '${u('skip')}/4',
            onTap: () => _n.act((v, st) => v.skipSchool(st))),
      ]),
    ]);
  }

  Widget _collegeActivities(LifeEngineState s) {
    final a = s.extras.actionsThisYear;
    int u(String k) => a[k] ?? 0;
    final sc = s.extras.school;
    var i = 0;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
      actionGrid([
        ActionTile(index: i++, icon: Icons.nightlife_rounded, color: GamePalette.pink, title: 'Festa universitária', description: 'R\$ 60 · conhecer gente nova', indicator: '${u('uniParty')}/2',
            onTap: () => _n.act((v, st) => v.uniParty(st))),
        ActionTile(index: i++, icon: Icons.house_rounded, color: const Color(0xFFDB2777), title: 'Organizar festa', description: 'Open-house para a turma',
            onTap: () => showGameSheet(context, const PartyPlannerSheet(initialType: 'college'))),
        ActionTile(index: i++, icon: Icons.sports_rounded, color: GamePalette.orange, title: 'Clubes e grupos', description: 'Atlética, empresa júnior, pesquisa...', indicator: '${sc.collegeClubs.length}/2',
            onTap: () => _pickClub(s, SchoolCatalog.collegeClubs, sc.collegeClubs)),
        ActionTile(index: i++, icon: Icons.person_add_rounded, color: GamePalette.green, title: 'Fazer amigos', description: 'Integração com a turma', indicator: '${u('makeFriends')}/3',
            onTap: () => _n.act((v, st) => v.makeSchoolFriends(st))),
        ActionTile(index: i++, icon: Icons.flight_rounded, color: const Color(0xFF0EA5E9), title: 'Intercâmbio', description: 'R\$ 35.000 · um semestre fora', enabled: s.extras.counter('exchange') == 0,
            onTap: () => _n.act((v, st) => v.exchange(st))),
        ActionTile(index: i++, icon: Icons.co_present_rounded, color: GamePalette.teal, title: 'Professores', description: 'Orientação, revisão de nota...', onTap: () => _tab.animateTo(2)),
      ]),
    ]);
  }

  Widget _collegeCareer(LifeEngineState s) {
    final p = context.gp;
    final e = s.extras.education;
    final sc = s.extras.school;
    final year = s.character.birthYear + s.character.currentAge;
    final jobs = SchoolCatalog.internships(e.degreeId ?? 'x', year);
    var i = 0;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
      if (sc.internshipCompany != null)
        GameCard(
          accent: GamePalette.green,
          child: Row(children: [
            const IconBadge(icon: Icons.badge_rounded, color: GamePalette.green, size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estagiário(a) na ${sc.internshipCompany}', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
                Text('${sc.internshipYears} ano(s) de experiência', style: TextStyle(color: p.textMuted, fontSize: 12)),
              ]),
            ),
            TextButton(onPressed: () => _n.act((v, st) => v.leaveInternship(st)), child: const Text('Sair')),
          ]),
        )
      else ...[
        SectionTitle('Vagas de estágio', subtitle: e.yearsDone < 1 ? 'Disponível a partir do 2º ano' : 'Bolsa anual', icon: Icons.work_outline_rounded),
        for (final j in jobs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ActionTile(
              index: i++,
              icon: Icons.business_rounded,
              color: GamePalette.blue,
              title: j.$1,
              description: '${Fmt.money(j.$2)}/ano · seletividade ${j.$3}%',
              enabled: e.yearsDone >= 1,
              onTap: () => _n.act((v, st) => v.applyInternship(st, j.$1, j.$2, j.$3)),
            ),
          ),
      ],
      const SectionTitle('Vida acadêmica', icon: Icons.account_balance_rounded),
      actionGrid([
        ActionTile(index: i++, icon: Icons.workspace_premium_rounded, color: GamePalette.gold, title: 'Pedir bolsa', description: 'Depende da média e dos professores',
            indicator: '${s.extras.actionsThisYear['scholarship'] ?? 0}/1', onTap: () => _n.act((v, st) => v.applyScholarship(st))),
        ActionTile(index: i++, icon: Icons.swap_horiz_rounded, color: const Color(0xFF64748B), title: 'Trocar de curso', description: 'Abandona este e presta outro vestibular',
            onTap: () async {
          final ok = await confirmDialog(context, title: 'Trocar de curso?', message: 'Você vai trancar este curso e poderá prestar outro vestibular.', confirm: 'Trancar');
          if (!ok) return;
          await _n.act((v, st) => v.dropOut(st));
          if (mounted) showGameSheet(context, const EducationSheet());
        }),
        ActionTile(index: i++, icon: Icons.exit_to_app_rounded, color: GamePalette.red, title: 'Abandonar a faculdade', description: 'Sem diploma, mas sem mensalidade',
            onTap: () async {
          final ok = await confirmDialog(context, title: 'Abandonar o curso?', message: 'Você perde o progresso acumulado.', confirm: 'Abandonar');
          if (ok) await _n.act((v, st) => v.dropOut(st));
        }),
      ]),
      const SizedBox(height: 6),
      Text('Formatura: conclua os ${e.yearsTotal} anos sem reprovar. Reprovação acontece com média abaixo de 4 ou mais de 25 faltas.',
          style: TextStyle(color: p.textMuted, fontSize: 12)),
    ]);
  }

  // =========================================================================
  // helpers
  // =========================================================================
  Widget _people(LifeEngineState s, bool Function(NpcModel) test, String empty) {
    final list = s.npcs.where((n) => n.isAlive && test(n)).toList()..sort((a, b) => b.relationshipLevel.compareTo(a.relationshipLevel));
    if (list.isEmpty) return EmptyState(icon: Icons.groups_rounded, title: 'Ninguém aqui', message: empty);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
      for (var i = 0; i < list.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PersonTile(
            npc: list[i],
            index: i,
            subtitle: list[i].relationshipType == RelationshipType.teacher ? list[i].occupation : null,
          ),
        ),
    ]);
  }

  Future<void> _exam(LifeEngineState s, bool college) async {
    if ((s.extras.actionsThisYear['exam'] ?? 0) >= 3) {
      await _n.act((v, st) => v.takeExam(st, 0)); // dispara o aviso de limite
      return;
    }
    final score = await showExamQuiz(context, age: s.character.currentAge, college: college);
    if (score != null) await _n.act((v, st) => v.takeExam(st, score));
  }

  Future<void> _sheetPicker(String title, List<Widget> Function(BuildContext ctx) build) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (ctx, ctl) => ListView(controller: ctl, padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
          Text(title, style: TextStyle(color: ctx.gp.text, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 10),
          ...build(ctx),
        ]),
      ),
    );
  }

  Future<void> _pickClub(LifeEngineState s, List<SchoolActivity> clubs, List<String> mine) => _sheetPicker('Atividades', (ctx) => [
        for (final c in clubs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ActionTile(
              icon: c.icon,
              color: c.color,
              title: c.name,
              description: c.description,
              indicator: mine.contains(c.id) ? 'Sair' : 'Entrar',
              enabled: s.character.currentAge >= c.minAge,
              onTap: () {
                Navigator.pop(ctx);
                _n.act((v, st) => v.joinClub(st, c.id));
              },
            ),
          ),
      ]);

  Future<void> _pickClique(LifeEngineState s) => _sheetPicker('Grupos escolares', (ctx) => [
        for (final c in SchoolCatalog.cliques)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ActionTile(
              icon: c.icon,
              color: c.color,
              title: c.name,
              description: c.description,
              indicator: s.extras.school.clique == c.id ? 'Sair' : 'Tentar',
              onTap: () {
                Navigator.pop(ctx);
                _n.act((v, st) => v.joinClique(st, c.id));
              },
            ),
          ),
      ]);

  Future<void> _pickEvent(LifeEngineState s) => _sheetPicker('Eventos da escola', (ctx) => [
        for (final ev in SchoolCatalog.schoolEvents)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ActionTile(
              icon: ev.icon,
              color: ev.color,
              title: ev.name,
              description: '${ev.description}${ev.cost > 0 ? ' · ${Fmt.money(ev.cost)}' : ''}',
              indicator: '${s.extras.actionsThisYear['event:${ev.id}'] ?? 0}/1',
              enabled: s.character.currentAge >= ev.minAge,
              onTap: () {
                Navigator.pop(ctx);
                _n.act((v, st) => v.schoolEvent(st, ev.id));
              },
            ),
          ),
      ]);

  Future<void> _changeSchool(LifeEngineState s) => _sheetPicker('Mudar de escola', (ctx) => [
        for (final t in const ['public', 'private', 'elite'])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ActionTile(
              icon: t == 'public' ? Icons.account_balance_rounded : (t == 'private' ? Icons.apartment_rounded : Icons.public_rounded),
              color: t == 'elite' ? GamePalette.gold : GamePalette.blue,
              title: SchoolCatalog.schoolTypeLabel(t),
              description: SchoolCatalog.schoolYearCost(t) == 0 ? 'Gratuita' : '${Fmt.money(SchoolCatalog.schoolYearCost(t))}/ano',
              enabled: s.extras.school.schoolType != t,
              onTap: () {
                Navigator.pop(ctx);
                _n.act((v, st) => v.changeSchool(st, t));
              },
            ),
          ),
      ]);

  Future<void> _prom(LifeEngineState s) async {
    final age = s.character.currentAge;
    final options = s.npcs
        .where((n) => n.isAlive && !n.isFamily && RomanceRules.romanceAllowed(age, n.age) && n.relationshipType != RelationshipType.teacher)
        .toList()
      ..sort((a, b) => b.relationshipLevel.compareTo(a.relationshipLevel));
    final pick = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(title: const Text('Baile escolar · R\$ 150'), children: [
        SimpleDialogOption(onPressed: () => Navigator.pop(ctx, ''), child: const Text('Ir com os amigos (sem par)')),
        for (final n in options.take(10))
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, n.id),
            child: Row(children: [
              AvatarWidget(config: n.avatarConfig, age: n.age, size: 32, animate: false),
              const SizedBox(width: 8),
              Expanded(child: Text('Convidar ${n.fullName} (${n.relationshipLevel}%)')),
            ]),
          ),
      ]),
    );
    if (pick == null) return;
    await _n.act((v, st) => v.prom(st, pick.isEmpty ? null : pick));
  }
}
