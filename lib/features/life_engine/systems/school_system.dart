import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/education/data/education_catalog.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/models/npc_traits.dart';
import 'package:bitweve/features/relationships/romance_rules.dart';
import 'package:bitweve/features/school/data/school_catalog.dart';
import 'education_system.dart';
import 'life_draft.dart';

/// Vida escolar e universitária jogável: aulas, provas, faltas, advertências,
/// suspensões, clubes, grupos, baile, professores, estágio, bolsas e TCC.
class SchoolSystem {
  static const _subjects = ['Matemática', 'Português', 'História', 'Ciências', 'Inglês', 'Geografia', 'Educação Física', 'Artes'];

  // ------------------------------------------------------------------ util
  static bool _needSchool(LifeDraft d) {
    if (!d.x.education.inSchool) {
      d.warn('Você não está na escola', 'Esta opção só existe durante o Ensino Fundamental/Médio.');
      return false;
    }
    if (d.x.crime.inPrison) {
      d.warn('Você está preso(a)');
      return false;
    }
    return true;
  }

  static bool _needCollege(LifeDraft d) {
    if (!d.x.education.inHigherEd) {
      d.warn('Você não está na faculdade', 'Matricule-se em um curso superior primeiro.');
      return false;
    }
    if (d.x.crime.inPrison) {
      d.warn('Você está preso(a)');
      return false;
    }
    return true;
  }

  static int _clamp(int v) => v.clamp(0, 100);

  static void _pop(LifeDraft d, int delta, {bool college = false}) {
    final s = d.x.school;
    if (college) {
      s.collegePopularity = _clamp(s.collegePopularity + delta);
    } else {
      s.popularity = _clamp(s.popularity + delta);
    }
  }

  static void _perf(LifeDraft d, int delta) => d.x.school.performance = _clamp(d.x.school.performance + delta);

  static void _hist(LifeDraft d, String text) => d.x.school.addHistory('${d.age} anos: $text');

  // ------------------------------------------------------------------ colegas e professores
  static NpcModel _makeMate(LifeDraft d, {required bool college}) {
    final n = d.makeNpc(
      type: college ? RelationshipType.collegeMate : RelationshipType.classmate,
      age: (d.age + d.ctx.range(college ? -2 : 0, college ? 3 : 0)).clamp(5, 60),
      level: 30 + d.ctx.rng.nextInt(35),
      occupation: college ? 'Universitário(a)' : 'Estudante',
    );
    d.x.meta(n.id).origin = college ? 'college' : 'school';
    return n;
  }

  static NpcModel _makeTeacher(LifeDraft d, {required bool college}) {
    final subject = college
        ? (EducationCatalog.degree(d.x.education.degreeId)?.area ?? 'Metodologia')
        : d.ctx.pick(_subjects);
    final g = d.ctx.gender();
    final n = d.makeNpc(
      type: RelationshipType.teacher,
      gender: g,
      age: d.ctx.range(28, 64),
      level: 40 + d.ctx.rng.nextInt(25),
      occupation: college ? 'Prof. Dr(a). de $subject' : 'Professor(a) de $subject',
      salary: college ? 120000 : 50000,
      netWorth: 80000,
    );
    d.x.meta(n.id).origin = college ? 'college' : 'school';
    return n;
  }

  /// Garante uma turma completa (colegas + professores) para a fase atual.
  static void ensureClass(LifeDraft d) {
    final e = d.x.education;
    final college = e.inHigherEd;
    if (!e.inSchool && !college) return;
    final mateType = college ? RelationshipType.collegeMate : RelationshipType.classmate;
    final origin = college ? 'college' : 'school';
    final mates = d.npcs.where((n) => n.isAlive && n.relationshipType == mateType).length;
    final teachers = d.npcs
        .where((n) => n.isAlive && n.relationshipType == RelationshipType.teacher && (d.x.npcMeta[n.id]?.origin ?? 'school') == origin)
        .length;
    for (var i = mates; i < 7; i++) {
      d.npcs.add(_makeMate(d, college: college));
    }
    for (var i = teachers; i < 3; i++) {
      d.npcs.add(_makeTeacher(d, college: college));
    }
    final s = d.x.school;
    if (!college && s.schoolName.isEmpty) {
      s.schoolType = switch (d.x.familyWealth) { 'elite' => 'elite', 'rich' => 'private', _ => 'public' };
      s.schoolName = SchoolCatalog.randomSchoolName(d.ctx.rng, s.schoolType);
    }
  }

  static void _clearStage(LifeDraft d, String origin) {
    d.npcs.removeWhere((n) {
      if (!n.isAlive) return false;
      final o = d.x.npcMeta[n.id]?.origin;
      final staff = n.relationshipType == RelationshipType.teacher && (o ?? 'school') == origin && n.relationshipLevel < 85;
      final mate = (origin == 'college' ? n.relationshipType == RelationshipType.collegeMate : false) && n.relationshipLevel < 60;
      return staff || mate;
    });
  }

  // ------------------------------------------------------------------ ações escolares
  static void attendClass(LifeDraft d) {
    final college = d.x.education.inHigherEd;
    if (college ? !_needCollege(d) : !_needSchool(d)) return;
    if (!d.useAction('attend', 4) || !d.useEnergy(8)) return;
    _perf(d, d.ctx.range(5, 9) + d.c.discipline ~/ 30);
    if (college) {
      d.x.school.professorRel = _clamp(d.x.school.professorRel + 3);
    } else {
      d.x.school.teacherRel = _clamp(d.x.school.teacherRel + 3);
    }
    d.stats({'smarts': 1, 'discipline': 1});
    final text = d.ctx.pick([
      'Você prestou atenção em todas as aulas e fez anotações caprichadas.',
      'Você tirou dúvidas no fim da aula e entendeu a matéria de vez.',
      'Você participou da aula e ganhou um elogio na frente da turma.',
    ]);
    d.log('education', text, icon: 'menu_book', color: '#3B82F6');
    d.notify(NoticeKind.education, Icons.menu_book, 'Aula concluída', message: '+Desempenho');
    d.sfx(GameSfx.positiveEvent);
  }

  static void study(LifeDraft d) {
    final before = d.x.education.studyEffort;
    EducationSystem.study(d);
    if (d.x.education.studyEffort > before && d.x.education.isStudying) _perf(d, d.ctx.range(6, 10));
  }

  /// Prova: [score] 0..1 vem do minigame de questões.
  static void exam(LifeDraft d, double score) {
    final college = d.x.education.inHigherEd;
    if (college ? !_needCollege(d) : !_needSchool(d)) return;
    if (!d.useAction('exam', 3)) return;
    final s = d.x.school;
    final grade = (score * 10).clamp(0, 10).toDouble();
    s.examsThisYear += 1;
    s.bestExam = s.bestExam < (grade * 10).round() ? (grade * 10).round() : s.bestExam;
    final delta = ((grade - 5) * 3).round();
    _perf(d, delta);
    if (grade >= 9) {
      d.stats({'happiness': 6, 'smarts': 2});
      if (college) {
        s.professorRel = _clamp(s.professorRel + 4);
      } else {
        s.teacherRel = _clamp(s.teacherRel + 4);
      }
      d.log('education', 'Nota ${grade.toStringAsFixed(1)} na prova! O professor elogiou seu desempenho.', icon: 'workspace_premium', color: '#FFC53D');
      d.notify(NoticeKind.education, Icons.workspace_premium, 'Nota máxima!', message: 'Prova: ${grade.toStringAsFixed(1)}', celebrate: true);
      d.sfx(GameSfx.achievement);
    } else if (grade >= 6) {
      d.stats({'happiness': 2});
      d.log('education', 'Você tirou ${grade.toStringAsFixed(1)} na prova. Aprovado(a)!', icon: 'check_circle', color: '#22C55E');
      d.notify(NoticeKind.education, Icons.check_circle, 'Prova concluída', message: 'Nota ${grade.toStringAsFixed(1)}');
      d.sfx(GameSfx.positiveEvent);
    } else {
      d.stats({'happiness': -5, 'stress': 5});
      d.log('education', 'Nota ${grade.toStringAsFixed(1)} na prova... vai precisar estudar mais.', icon: 'warning', color: '#EF4444');
      d.notify(NoticeKind.warning, Icons.sentiment_dissatisfied, 'Nota baixa', message: 'Prova: ${grade.toStringAsFixed(1)}');
      d.sfx(GameSfx.negativeEvent);
    }
    _hist(d, 'prova nota ${grade.toStringAsFixed(1)}');
  }

  static void skip(LifeDraft d) {
    final college = d.x.education.inHigherEd;
    if (college ? !_needCollege(d) : !_needSchool(d)) return;
    if (!d.useAction('skip', 4)) return;
    final s = d.x.school;
    final days = d.ctx.range(3, 7);
    s.absences += days;
    _perf(d, -d.ctx.range(3, 7));
    d.stats({'happiness': 5, 'stress': -6, 'discipline': -2});
    var text = 'Você matou aula ($days dias) e foi curtir com a galera.';
    if (!college && d.ctx.chance(0.35)) {
      s.warnings += 1;
      s.teacherRel = _clamp(s.teacherRel - 6);
      for (final p in d.living((n) => n.isParent)) {
        d.updateNpc(p.copyWith(relationshipLevel: p.relationshipLevel - 5));
      }
      text += ' A coordenação descobriu e ligou para seus pais. Advertência!';
      d.notify(NoticeKind.warning, Icons.report_rounded, 'Advertência!', message: 'Você foi pego(a) matando aula.');
      d.sfx(GameSfx.negativeEvent);
      _checkSuspension(d);
    } else {
      d.notify(NoticeKind.education, Icons.directions_run_rounded, 'Aula matada', message: '+$days faltas');
    }
    if (s.absences > 20) {
      d.notify(NoticeKind.warning, Icons.warning_rounded, 'Excesso de faltas', message: 'Com mais de 25 faltas você reprova!');
    }
    d.log('education', text, icon: 'directions_run', color: '#F59E0B');
    _hist(d, 'faltou $days dias');
  }

  static void nurse(LifeDraft d) {
    if (!_needSchool(d)) return;
    if (!d.useAction('nurse', 3)) return;
    final sick = d.c.health < 70 || d.x.conditions.isNotEmpty;
    if (sick) {
      d.stats({'health': d.ctx.range(4, 8), 'stress': -4});
      d.log('health', 'A enfermeira da escola cuidou de você e mandou repousar.', icon: 'healing', color: '#22C55E');
      d.notify(NoticeKind.health, Icons.healing, 'Enfermaria', message: '+Saúde');
    } else {
      d.x.school.absences += 1;
      if (d.ctx.chance(0.4)) {
        d.x.school.teacherRel = _clamp(d.x.school.teacherRel - 3);
        d.log('education', 'Você fingiu passar mal para sair da aula, mas a enfermeira não caiu nessa.', icon: 'sick', color: '#64748B');
        d.notify(NoticeKind.info, Icons.sick_rounded, 'Desculpa não colou');
      } else {
        d.stats({'stress': -5});
        d.log('education', 'Você descansou na enfermaria e escapou da aula de matemática.', icon: 'bed', color: '#14B8A6');
        d.notify(NoticeKind.info, Icons.bed_rounded, 'Descanso na enfermaria');
      }
    }
  }

  static void misbehave(LifeDraft d) {
    if (!_needSchool(d)) return;
    if (!d.useAction('misbehave', 3)) return;
    final s = d.x.school;
    _pop(d, d.ctx.range(2, 6));
    d.stats({'happiness': 4, 'karma': -2});
    final caught = d.ctx.chance(0.55 - d.c.charisma / 400);
    final prank = d.ctx.pick([
      'Você colocou um alarme escondido na sala dos professores',
      'Você organizou uma guerra de bolinhas de papel',
      'Você trocou todas as cadeiras da sala de lugar',
      'Você fez uma imitação do diretor no intervalo',
    ]);
    if (caught) {
      s.warnings += 1;
      s.teacherRel = _clamp(s.teacherRel - 8);
      d.log('education', '$prank e foi pego(a). Advertência por escrito!', icon: 'report', color: '#EF4444');
      d.notify(NoticeKind.warning, Icons.report_rounded, 'Advertência!', message: '${s.warnings} advertência(s) este ano');
      d.sfx(GameSfx.negativeEvent);
      _checkSuspension(d);
    } else {
      d.log('education', '$prank. A turma toda riu e ninguém descobriu quem foi!', icon: 'mood', color: '#F59E0B');
      d.notify(NoticeKind.social, Icons.mood_rounded, 'Ninguém viu nada', message: '+Popularidade');
    }
    _hist(d, 'aprontou na escola');
  }

  static void _checkSuspension(LifeDraft d) {
    final s = d.x.school;
    if (s.warnings >= 3 && !s.suspended) {
      s.suspended = true;
      s.suspensions += 1;
      _perf(d, -15);
      _pop(d, 3);
      d.stats({'happiness': -8, 'stress': 8, 'reputation': -4});
      for (final p in d.living((n) => n.isParent)) {
        d.updateNpc(p.copyWith(relationshipLevel: p.relationshipLevel - 10));
      }
      d.log('education', 'SUSPENSÃO! Com 3 advertências você foi suspenso(a) por uma semana. Seus pais ficaram furiosos.', icon: 'gavel', color: '#EF4444');
      d.notify(NoticeKind.warning, Icons.gavel_rounded, 'Você foi suspenso(a)!', message: 'Desempenho e relação com os pais caíram.');
      _hist(d, 'suspensão');
      if (s.suspensions >= 3 && d.ctx.chance(0.5)) {
        s.schoolName = SchoolCatalog.randomSchoolName(d.ctx.rng, s.schoolType);
        s.popularity = 25;
        d.log('education', 'Expulsão: depois de tantas suspensões, você foi transferido(a) para ${s.schoolName}.', icon: 'exit_to_app', color: '#EF4444');
        _replaceClass(d, false);
      }
    }
  }

  static void joinClub(LifeDraft d, String clubId) {
    final college = d.x.education.inHigherEd;
    if (college ? !_needCollege(d) : !_needSchool(d)) return;
    final club = SchoolCatalog.club(clubId);
    if (club == null) return;
    final list = college ? d.x.school.collegeClubs : d.x.school.clubs;
    if (list.contains(clubId)) {
      list.remove(clubId);
      d.log('education', 'Você saiu de ${club.name}.', icon: 'logout', color: '#64748B');
      d.notify(NoticeKind.info, Icons.logout_rounded, 'Saiu da atividade', message: club.name);
      return;
    }
    if (d.age < club.minAge) {
      d.warn('Idade mínima: ${club.minAge} anos');
      return;
    }
    if (list.length >= 2) {
      d.warn('Agenda cheia', 'Você só consegue participar de 2 atividades. Saia de uma primeiro.');
      return;
    }
    if (!d.useAction('club', 2)) return;
    // Testes de seleção para esportes exigem forma física
    final needsTryout = club.id == 'soccer' || club.id == 'volley' || club.id == 'atletica';
    if (needsTryout && !d.ctx.chance((0.35 + d.c.fitness / 120).clamp(0.1, 0.95))) {
      d.log('education', 'Você fez a peneira de ${club.name}, mas não foi selecionado(a). Treine mais!', icon: 'sentiment_dissatisfied', color: '#64748B');
      d.notify(NoticeKind.info, Icons.sports_rounded, 'Não passou na seleção', message: club.name);
      d.stats({'happiness': -4});
      return;
    }
    list.add(clubId);
    d.stats(club.effects);
    _pop(d, club.popularity, college: college);
    d.log('education', 'Você entrou em ${club.name}! ${club.description}', icon: 'groups', color: '#22C55E');
    d.notify(NoticeKind.education, club.icon, 'Nova atividade!', message: club.name, celebrate: true);
    d.sfx(GameSfx.positiveEvent);
    _hist(d, 'entrou em ${club.name}');
  }

  static void joinClique(LifeDraft d, String cliqueId) {
    if (!_needSchool(d)) return;
    final c = SchoolCatalog.clique(cliqueId);
    if (c == null) return;
    if (d.x.school.clique == cliqueId) {
      d.x.school.clique = null;
      _pop(d, -4);
      d.log('social', 'Você saiu do grupo dos ${c.name}.', icon: 'logout', color: '#64748B');
      d.notify(NoticeKind.social, Icons.logout_rounded, 'Saiu do grupo');
      return;
    }
    if (!d.useAction('clique', 2)) return;
    final stat = d.snapshot()[c.stat] ?? (c.stat == 'fitness' ? d.c.fitness : 50);
    final p = (0.25 + (stat - c.min) / 60 + d.x.school.popularity / 250).clamp(0.05, 0.95);
    if (d.ctx.chance(p)) {
      d.x.school.clique = cliqueId;
      _pop(d, 8);
      d.stats({'happiness': 8});
      d.log('social', 'Você foi aceito(a) no grupo dos ${c.name}! ${c.description}', icon: 'groups', color: '#EC4899');
      d.notify(NoticeKind.social, c.icon, 'Bem-vindo(a) aos ${c.name}!', celebrate: true);
      d.sfx(GameSfx.positiveEvent);
      _hist(d, 'entrou para os ${c.name}');
    } else {
      _pop(d, -3);
      d.stats({'happiness': -6});
      d.log('social', 'Os ${c.name} riram da sua tentativa de entrar no grupo.', icon: 'sentiment_dissatisfied', color: '#64748B');
      d.notify(NoticeKind.info, Icons.do_not_disturb_rounded, 'Rejeitado(a) pelos ${c.name}');
      d.sfx(GameSfx.negativeEvent);
    }
  }

  static void makeFriends(LifeDraft d) {
    final college = d.x.education.inHigherEd;
    if (college ? !_needCollege(d) : !_needSchool(d)) return;
    if (!d.useAction('makeFriends', 3) || !d.useEnergy(6)) return;
    final pop = college ? d.x.school.collegePopularity : d.x.school.popularity;
    final p = (0.35 + d.c.charisma / 220 + pop / 300).clamp(0.15, 0.95);
    if (d.ctx.chance(p)) {
      final n = _makeMate(d, college: college).copyWith(relationshipType: RelationshipType.friend, relationshipLevel: 55 + d.ctx.rng.nextInt(20));
      d.npcs.add(n);
      d.x.bump('friendsMade');
      d.addMemory(n.id, college ? 'Nos conhecemos na faculdade.' : 'Viramos amigos na escola.');
      _pop(d, 3, college: college);
      final t = NpcTraits.of(n);
      d.log('social', 'Você fez amizade com ${n.fullName} (${t.personality.label.toLowerCase()}).', icon: 'person_add', color: '#EC4899');
      d.notify(NoticeKind.social, Icons.person_add, 'Nova amizade!', message: n.fullName);
      d.sfx(GameSfx.positiveEvent);
      d.stats({'happiness': 5});
    } else {
      d.log('social', 'Você tentou puxar assunto no intervalo, mas ninguém deu muita bola.', icon: 'person_off', color: '#64748B');
      d.notify(NoticeKind.info, Icons.person_off, 'Sem novas amizades');
      d.stats({'happiness': -2});
    }
  }

  static void schoolEvent(LifeDraft d, String eventId) {
    if (!_needSchool(d)) return;
    final ev = SchoolCatalog.schoolEvents.firstWhere((e) => e.id == eventId, orElse: () => SchoolCatalog.schoolEvents.first);
    if (d.age < ev.minAge) {
      d.warn('Idade mínima: ${ev.minAge} anos');
      return;
    }
    if (!d.useAction('event:$eventId', 1)) return;
    if (!d.pay(ev.cost, what: ev.name)) {
      d.x.actionsThisYear.remove('event:$eventId');
      return;
    }
    d.stats(ev.effects);
    final great = d.ctx.chance(0.3 + d.c.charisma / 300 + d.c.smarts / 400);
    _pop(d, great ? ev.popularity + 4 : ev.popularity ~/ 2);
    final text = switch (eventId) {
      'science_fair' => great ? 'Seu projeto na Feira de Ciências ganhou o 1º lugar!' : 'Seu projeto na Feira de Ciências foi elogiado.',
      'talent_show' => great ? 'Você arrasou no Show de Talentos e foi aplaudido(a) de pé!' : 'Você se apresentou no Show de Talentos. Deu um friozinho na barriga!',
      'sports_day' => great ? 'Sua turma venceu os Jogos Interclasses com você no time!' : 'Sua turma perdeu nos Jogos Interclasses, mas foi divertido.',
      'field_trip' => 'A excursão da turma foi incrível. Fotos para guardar para sempre!',
      _ => great ? 'Você foi o destaque da Festa Junina!' : 'Você curtiu a Festa Junina com os colegas.',
    };
    if (great) _perf(d, 4);
    d.log('education', text, icon: 'emoji_events', color: great ? '#FFC53D' : '#22C55E');
    d.notify(NoticeKind.education, ev.icon, ev.name, message: great ? 'Destaque!' : '+Popularidade', celebrate: great);
    d.sfx(great ? GameSfx.achievement : GameSfx.positiveEvent);
    _hist(d, ev.name.toLowerCase());
  }

  /// Baile escolar. [dateId] opcional: pessoa convidada.
  static void prom(LifeDraft d, String? dateId) {
    if (!_needSchool(d)) return;
    if (d.age < 14) {
      d.warn('O baile é para alunos a partir dos 14 anos');
      return;
    }
    if (!d.useAction('prom', 1)) return;
    if (!d.pay(150, what: 'roupa e ingresso do baile')) {
      d.x.actionsThisYear.remove('prom');
      return;
    }
    var text = 'Você foi ao baile da escola.';
    if (dateId != null) {
      final n = d.npc(dateId);
      if (n != null && RomanceRules.romanceAllowed(d.age, n.age)) {
        final t = NpcTraits.of(n);
        final p = (0.25 + n.relationshipLevel / 160 + d.c.looks / 400 + d.x.school.popularity / 400 + t.modifierFor('party')).clamp(0.05, 0.95);
        if (d.ctx.chance(p)) {
          d.updateNpc(n.copyWith(
            relationshipLevel: n.relationshipLevel + 15,
            relationshipType: n.relationshipType == RelationshipType.partner ? null : RelationshipType.crush,
          ));
          d.addMemory(n.id, 'Fomos juntos ao baile da escola.');
          d.stats({'happiness': 14});
          _pop(d, 8);
          text = 'Você foi ao baile com ${n.fullName}. Dançaram a noite toda!';
          d.sfx(GameSfx.wedding);
        } else {
          d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel - 5));
          d.stats({'happiness': -6});
          text = '${n.fullName} recusou seu convite para o baile. Você foi com os amigos mesmo.';
          d.sfx(GameSfx.negativeEvent);
        }
      }
    } else {
      d.stats({'happiness': 8});
      _pop(d, 4);
    }
    if (d.ctx.chance(0.15 + d.c.looks / 500 + d.x.school.popularity / 400)) {
      _pop(d, 10);
      text += ' E você foi eleito(a) Rei/Rainha do Baile! 👑';
      d.notify(NoticeKind.education, Icons.emoji_events_rounded, 'Rei/Rainha do Baile!', celebrate: true);
    } else {
      d.notify(NoticeKind.social, Icons.nightlife_rounded, 'Baile escolar', message: text);
    }
    d.log('social', text, icon: 'nightlife', color: '#EC4899');
    _hist(d, 'baile escolar');
  }

  static void changeSchool(LifeDraft d, String type) {
    if (!_needSchool(d)) return;
    final s = d.x.school;
    if (s.schoolType == type) {
      d.warn('Você já estuda numa escola deste tipo');
      return;
    }
    if (!d.useAction('changeSchool', 1)) return;
    final cost = SchoolCatalog.schoolYearCost(type);
    if (cost > 0) {
      final parents = d.living((n) => n.isParent);
      final wealth = parents.fold<double>(0, (a, n) => a + n.netWorth);
      if (d.age < 18 && wealth < cost * 4 && d.balance < cost) {
        d.warn('Sua família não pode pagar', 'Mensalidade anual: ${Fmt.money(cost)}');
        d.x.actionsThisYear.remove('changeSchool');
        return;
      }
    }
    s.schoolType = type;
    s.schoolName = SchoolCatalog.randomSchoolName(d.ctx.rng, type);
    s.popularity = 30;
    s.teacherRel = 50;
    s.clique = null;
    s.clubs.clear();
    _replaceClass(d, false);
    d.stats({'stress': 6, 'happiness': -2});
    d.log('education', 'Você mudou para ${s.schoolName} (${SchoolCatalog.schoolTypeLabel(type)}). Novos colegas, novos professores!', icon: 'school', color: '#6366F1');
    d.notify(NoticeKind.education, Icons.school_rounded, 'Nova escola!', message: s.schoolName);
    d.sfx(GameSfx.screenTransition);
    _hist(d, 'mudou para ${s.schoolName}');
  }

  static void _replaceClass(LifeDraft d, bool college) {
    final mateType = college ? RelationshipType.collegeMate : RelationshipType.classmate;
    final origin = college ? 'college' : 'school';
    d.npcs.removeWhere((n) =>
        n.isAlive &&
        (n.relationshipType == mateType ||
            (n.relationshipType == RelationshipType.teacher && (d.x.npcMeta[n.id]?.origin ?? 'school') == origin)));
    ensureClass(d);
  }

  /// Ações com professores (chamadas pelo perfil do NPC).
  static void teacherAction(LifeDraft d, String npcId, String action) {
    final n = d.npc(npcId);
    if (n == null || n.relationshipType != RelationshipType.teacher) return;
    if (!d.useAction('teacher:$npcId', 3)) return;
    final college = (d.x.npcMeta[n.id]?.origin ?? 'school') == 'college';
    final s = d.x.school;
    final t = NpcTraits.of(n);
    switch (action) {
      case 'askHelp':
        final ok = d.ctx.chance((0.55 + n.relationshipLevel / 250 + t.modifierFor('study')).clamp(0.1, 0.95));
        if (ok) {
          _perf(d, 8);
          d.stats({'smarts': 2});
          d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + 6));
          d.log('education', '${n.fullName} tirou suas dúvidas depois da aula. Agora a matéria fez sentido!', icon: 'school', color: '#3B82F6');
          d.notify(NoticeKind.education, Icons.school_rounded, 'Ajuda do professor', message: '+Desempenho');
        } else {
          d.log('education', '${n.fullName} disse que estava sem tempo hoje.', icon: 'schedule', color: '#64748B');
          d.notify(NoticeKind.info, Icons.schedule_rounded, 'Professor ocupado');
        }
      case 'suckUp':
        d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + 8));
        if (college) {
          s.professorRel = _clamp(s.professorRel + 5);
        } else {
          s.teacherRel = _clamp(s.teacherRel + 5);
          _pop(d, -3);
        }
        d.log('education', 'Você levou uma maçã e puxou o saco de ${n.fullName}. Alguns colegas cochicharam.', icon: 'thumb_up', color: '#22C55E');
        d.notify(NoticeKind.education, Icons.thumb_up_rounded, 'Puxa-saco!', message: '+Relação com professor');
      case 'reviewGrade':
        final ok = d.ctx.chance((0.25 + n.relationshipLevel / 200).clamp(0.05, 0.85));
        if (ok) {
          _perf(d, 6);
          d.log('education', '${n.fullName} revisou sua prova e aumentou sua nota.', icon: 'check_circle', color: '#22C55E');
          d.notify(NoticeKind.education, Icons.check_circle_rounded, 'Nota revisada!');
        } else {
          d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel - 6));
          d.log('education', '${n.fullName} manteve a nota e achou o pedido abusado.', icon: 'block', color: '#64748B');
          d.notify(NoticeKind.info, Icons.block_rounded, 'Pedido negado');
        }
      case 'confront':
        d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel - 15));
        _pop(d, 4);
        if (!college) {
          s.warnings += 1;
          d.log('education', 'Você bateu boca com ${n.fullName} na frente da turma. Advertência!', icon: 'report', color: '#EF4444');
          d.notify(NoticeKind.warning, Icons.report_rounded, 'Advertência!');
          _checkSuspension(d);
        } else {
          s.professorRel = _clamp(s.professorRel - 8);
          d.log('education', 'Você discutiu com ${n.fullName} sobre a correção da prova.', icon: 'flash_on', color: '#EF4444');
          d.notify(NoticeKind.warning, Icons.flash_on_rounded, 'Clima tenso com o professor');
        }
        d.sfx(GameSfx.negativeEvent);
    }
  }

  // ------------------------------------------------------------------ faculdade
  static void project(LifeDraft d) {
    if (!_needCollege(d)) return;
    if (!d.useAction('project', 2) || !d.useEnergy(15)) return;
    final s = d.x.school;
    final quality = d.c.smarts / 100 * 0.6 + d.c.discipline / 100 * 0.3 + d.ctx.roll() * 0.3;
    s.projectsDone += 1;
    if (quality > 0.55) {
      _perf(d, 10);
      s.professorRel = _clamp(s.professorRel + 4);
      d.log('education', 'Seu trabalho em grupo foi o melhor da turma. Nota máxima no seminário!', icon: 'groups', color: '#22C55E');
      d.notify(NoticeKind.education, Icons.groups_rounded, 'Trabalho nota 10!', celebrate: true);
    } else {
      _perf(d, 3);
      d.stats({'stress': 4});
      d.log('education', 'O trabalho em grupo deu dor de cabeça: metade do grupo sumiu, mas vocês entregaram.', icon: 'groups', color: '#F59E0B');
      d.notify(NoticeKind.education, Icons.groups_rounded, 'Trabalho entregue');
    }
    // Interação com um colega aleatório
    final mates = d.living((n) => n.relationshipType == RelationshipType.collegeMate);
    if (mates.isNotEmpty) {
      final m = d.ctx.pick(mates);
      d.updateNpc(m.copyWith(relationshipLevel: m.relationshipLevel + (quality > 0.55 ? 8 : -4)));
    }
  }

  static void uniParty(LifeDraft d) {
    if (!_needCollege(d)) return;
    if (!d.useAction('uniParty', 2) || !d.useEnergy(15)) return;
    if (!d.pay(60, what: 'o ingresso da festa')) return;
    _pop(d, d.ctx.range(4, 9), college: true);
    _perf(d, -3);
    d.stats({'happiness': 10, 'stress': -8, 'health': -2});
    var text = d.ctx.pick([
      'A festa da atlética foi lendária. Você dançou até o sol nascer.',
      'Você foi à festa à fantasia do campus e ganhou o concurso de melhor fantasia.',
      'A cervejada do curso lotou e você conheceu metade da faculdade.',
    ]);
    if (d.ctx.chance(0.45)) {
      final n = _makeMate(d, college: true);
      d.npcs.add(n.copyWith(relationshipLevel: 50 + d.ctx.rng.nextInt(20)));
      text += ' Você conheceu ${n.fullName}.';
    }
    d.log('social', text, icon: 'nightlife', color: '#EC4899');
    d.notify(NoticeKind.social, Icons.nightlife_rounded, 'Festa universitária', message: '+Popularidade');
    d.sfx(GameSfx.positiveEvent);
    _hist(d, 'festa universitária');
  }

  static void applyInternship(LifeDraft d, String company, double pay, int selectivity) {
    if (!_needCollege(d)) return;
    final s = d.x.school;
    if (d.x.education.yearsDone < 1) {
      d.warn('Ainda é cedo', 'Estágios aceitam alunos a partir do 2º ano.');
      return;
    }
    if (s.internshipCompany != null) {
      d.warn('Você já faz estágio', 'Saia do estágio atual para trocar.');
      return;
    }
    if (!d.useAction('internship', 2)) return;
    final inst = SchoolCatalog.institution(s.institutionId);
    final p = (0.2 + d.x.education.gpa / 20 + inst.prestige / 300 + d.c.charisma / 400 - selectivity / 150 + s.projectsDone * 0.02)
        .clamp(0.05, 0.95);
    if (d.ctx.chance(p)) {
      s.internshipCompany = company;
      d.money(pay / 4);
      d.stats({'happiness': 8});
      d.x.experience['internship'] = (d.x.experience['internship'] ?? 0) + 0;
      d.log('career', 'Você foi aprovado(a) no estágio da $company! Bolsa de ${Fmt.money(pay)}/ano.', icon: 'work', color: '#22C55E');
      d.notify(NoticeKind.career, Icons.work_rounded, 'Estágio conquistado!', message: company, celebrate: true);
      d.sfx(GameSfx.promotion);
      _hist(d, 'estágio na $company');
    } else {
      d.stats({'happiness': -4});
      d.log('career', 'A $company escolheu outro candidato para o estágio.', icon: 'work_off', color: '#64748B');
      d.notify(NoticeKind.info, Icons.work_off_rounded, 'Estágio negado', message: company);
      d.sfx(GameSfx.negativeEvent);
    }
  }

  static void leaveInternship(LifeDraft d) {
    final s = d.x.school;
    if (s.internshipCompany == null) return;
    d.log('career', 'Você encerrou o estágio na ${s.internshipCompany}.', icon: 'logout', color: '#64748B');
    d.notify(NoticeKind.info, Icons.logout_rounded, 'Estágio encerrado');
    s.internshipCompany = null;
  }

  static void applyScholarship(LifeDraft d) {
    if (!_needCollege(d)) return;
    final e = d.x.education;
    if (e.scholarshipPct >= 1) {
      d.warn('Você já tem bolsa integral');
      return;
    }
    if (!d.useAction('scholarship', 1)) return;
    final p = ((e.gpa - 6.5) / 4 + d.x.school.professorRel / 300 + (d.x.familyWealth == 'poor' ? 0.2 : 0)).clamp(0.03, 0.9);
    if (d.ctx.chance(p)) {
      e.scholarshipPct = (e.scholarshipPct + 0.5).clamp(0, 1);
      d.log('education', 'Bolsa aprovada! Você ganhou ${(e.scholarshipPct * 100).round()}% de desconto na mensalidade.', icon: 'workspace_premium', color: '#FFC53D');
      d.notify(NoticeKind.education, Icons.workspace_premium_rounded, 'Bolsa de estudos!', celebrate: true);
      d.sfx(GameSfx.achievement);
    } else {
      d.log('education', 'Seu pedido de bolsa foi negado. Melhore a média e tente no próximo ano.', icon: 'money_off', color: '#64748B');
      d.notify(NoticeKind.info, Icons.money_off_rounded, 'Bolsa negada');
    }
  }

  static void thesis(LifeDraft d) {
    if (!_needCollege(d)) return;
    final e = d.x.education;
    final s = d.x.school;
    if (e.yearsTotal - e.yearsDone > 1) {
      d.warn('TCC só no último ano');
      return;
    }
    if (s.tccDone) {
      d.warn('TCC já entregue');
      return;
    }
    if (!d.useAction('tcc', 2) || !d.useEnergy(20)) return;
    s.researchPoints += d.ctx.range(20, 45) + d.c.smarts ~/ 5;
    if (s.researchPoints >= 60) {
      s.tccDone = true;
      _perf(d, 12);
      d.stats({'smarts': 3, 'reputation': 2});
      d.log('education', 'Você defendeu seu TCC e a banca aprovou com louvor!', icon: 'workspace_premium', color: '#FFC53D');
      d.notify(NoticeKind.education, Icons.workspace_premium_rounded, 'TCC aprovado!', celebrate: true);
      d.sfx(GameSfx.achievement);
    } else {
      d.stats({'stress': 6});
      d.log('education', 'Você avançou no TCC (${s.researchPoints}/60). Ainda falta pesquisa.', icon: 'biotech', color: '#06B6D4');
      d.notify(NoticeKind.education, Icons.biotech_rounded, 'TCC em andamento', message: '${s.researchPoints}/60');
    }
  }

  static void exchange(LifeDraft d) {
    if (!_needCollege(d)) return;
    if (d.x.counter('exchange') > 0) {
      d.warn('Você já fez intercâmbio');
      return;
    }
    const cost = 35000.0;
    if (!d.pay(cost, what: 'o intercâmbio')) return;
    d.x.bump('exchange');
    d.x.bump('travels');
    d.stats({'smarts': 5, 'charisma': 5, 'happiness': 12});
    _pop(d, 6, college: true);
    d.log('education', 'Intercâmbio de um semestre no exterior! Novo idioma, novas amizades e muita bagagem.', icon: 'flight', color: '#0EA5E9');
    d.notify(NoticeKind.education, Icons.flight_rounded, 'Intercâmbio!', celebrate: true, money: -cost);
    d.sfx(GameSfx.achievement);
  }

  // ------------------------------------------------------------------ anual
  /// Bônus de média vindo do desempenho escolar (usado pelo EducationSystem).
  static double gpaBonus(LifeDraft d) {
    final s = d.x.school;
    var b = (s.performance - 50) / 22.0;
    b -= (s.absences / 12.0).clamp(0.0, 2.5);
    if (s.suspended) b -= 0.8;
    if (d.x.education.inHigherEd) {
      b += (s.professorRel - 50) / 100.0;
      if (s.tccDone) b += 0.5;
    } else {
      b += (s.teacherRel - 50) / 120.0;
    }
    return b;
  }

  static void yearly(LifeDraft d) {
    final e = d.x.education;
    final s = d.x.school;
    if (d.x.crime.inPrison) return;

    if (e.inSchool) {
      ensureClass(d);
      // Mensalidade escolar (paga pelos pais se menor)
      final cost = SchoolCatalog.schoolYearCost(s.schoolType) * d.ctx.costMult(d.c.country);
      if (cost > 0) {
        final parents = d.living((n) => n.isParent);
        if (d.age < 18 && parents.isNotEmpty) {
          for (final p in parents) {
            d.updateNpc(p.copyWith(netWorth: p.netWorth - cost / parents.length));
          }
        } else if (!d.pay(cost, what: 'a mensalidade escolar')) {
          s.schoolType = 'public';
          s.schoolName = SchoolCatalog.randomSchoolName(d.ctx.rng, 'public');
          d.log('education', 'Sem dinheiro para a mensalidade, você foi transferido(a) para a escola pública.', icon: 'school', color: '#64748B');
        }
      }
      for (final id in s.clubs) {
        final c = SchoolCatalog.club(id);
        if (c != null) d.stats(c.effects.map((k, v) => MapEntry(k, (v / 2).ceil())));
      }
      // Popularidade decai com o tempo e varia com a aparência
      s.popularity = _clamp(s.popularity + (d.c.looks - 50) ~/ 25 + (s.clique != null ? 2 : -2) + s.clubs.length);
      // Eventos aleatórios
      if (d.ctx.chance(0.18) && s.popularity < 35) {
        d.stats({'happiness': -8, 'stress': 6});
        d.log('social', 'Alguns colegas pegaram no seu pé este ano. Você contou para a coordenação e para sua família, que te apoiaram.',
            icon: 'sentiment_dissatisfied', color: '#F59E0B');
      } else if (d.ctx.chance(0.15) && s.performance > 75) {
        d.stats({'reputation': 2});
        d.log('education', 'Você recebeu menção honrosa no mural da escola pelo seu desempenho.', icon: 'workspace_premium', color: '#FFC53D');
      }
      s.newYear();
    } else if (e.inHigherEd) {
      ensureClass(d);
      if (s.internshipCompany != null) {
        final list = SchoolCatalog.internships(e.degreeId ?? 'x', d.year - 1);
        final pay = list.isNotEmpty ? list.first.$2 : 15000.0;
        d.money(pay);
        s.internshipYears += 1;
        d.x.experience['internship'] = (d.x.experience['internship'] ?? 0) + 1;
        d.log('career', 'Estágio na ${s.internshipCompany}: +${Fmt.money(pay)} e experiência profissional.', icon: 'work', color: '#22C55E');
        if (d.ctx.chance(0.12)) {
          d.log('career', 'A ${s.internshipCompany} elogiou seu trabalho e prometeu uma vaga efetiva após a formatura.', icon: 'thumb_up', color: '#22C55E');
          d.stats({'happiness': 5, 'reputation': 2});
        }
      }
      for (final id in s.collegeClubs) {
        final c = SchoolCatalog.club(id);
        if (c != null) d.stats(c.effects.map((k, v) => MapEntry(k, (v / 2).ceil())));
      }
      s.collegePopularity = _clamp(s.collegePopularity + s.collegeClubs.length - 1);
      s.newYear();
    } else {
      // Fora da escola: dispensa turma e professores
      _clearStage(d, 'school');
      _clearStage(d, 'college');
      d.npcs.removeWhere((n) => n.isAlive && n.relationshipType == RelationshipType.collegeMate && n.relationshipLevel < 60);
      if (s.internshipCompany != null) s.internshipCompany = null;
    }
  }

  /// Ao entrar na faculdade: escolhe instituição e monta a turma.
  static void onEnroll(LifeDraft d, String institutionId) {
    final s = d.x.school;
    final inst = SchoolCatalog.institution(institutionId);
    s.institutionId = inst.id;
    s.institutionName = inst.name;
    s.collegePopularity = 30 + d.c.charisma ~/ 5;
    s.professorRel = 50;
    s.tccDone = false;
    s.researchPoints = 0;
    s.projectsDone = 0;
    s.collegeClubs.clear();
    s.performance = 50;
    _clearStage(d, 'school');
    _replaceClass(d, true);
  }
}
