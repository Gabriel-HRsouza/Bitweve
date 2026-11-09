import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/careers/models/career_track.dart';
import 'package:bitweve/features/education/data/education_catalog.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'life_draft.dart';
import 'finance_system.dart';
import 'school_system.dart';
import 'package:bitweve/features/school/data/school_catalog.dart';

class EducationSystem {
  static String stageLabel(EducationState e) {
    switch (e.stage) {
      case 'elementary':
        return 'Ensino Fundamental — ${e.yearsDone + 1}º ano';
      case 'high_school':
        return 'Ensino Médio — ${e.yearsDone + 1}º ano';
      case 'hs_graduate':
        return 'Ensino Médio completo';
      case 'university':
        return '${EducationCatalog.degree(e.degreeId)?.name ?? 'Graduação'} — ${e.yearsDone + 1}º de ${e.yearsTotal} anos';
      case 'postgrad':
        return '${EducationCatalog.degree(e.degreeId)?.name ?? 'Pós-graduação'} — ${e.yearsDone + 1}º de ${e.yearsTotal} anos';
      case 'dropout':
        return 'Abandonou os estudos';
      case 'graduated':
        return 'Formado(a)';
      default:
        return 'Ainda não estuda';
    }
  }

  static double _yearGpa(LifeDraft d, int difficulty) {
    final e = d.x.education;
    final base = d.c.smarts / 10.0 * 0.6 + d.c.discipline / 10.0 * 0.25 + 1.5;
    final effort = (e.studyEffort * 0.45).clamp(0.0, 2.0);
    final diff = (difficulty - 50) / 40.0;
    final stress = d.c.stress > 70 ? 0.8 : 0.0;
    final noise = d.ctx.roll() * 1.6 - 0.8;
    final school = SchoolSystem.gpaBonus(d);
    return (base + effort - diff - stress + noise + school).clamp(0.0, 10.0);
  }

  static void yearly(LifeDraft d) {
    final e = d.x.education;
    final age = d.age;

    // Entrada automática na escola
    if (e.stage == 'none' && age >= 6 && age < 18) {
      e.stage = 'elementary';
      e.yearsDone = 0;
      e.yearsTotal = 9;
      d.log('education', 'Primeiro dia de aula! Você começou o Ensino Fundamental.', icon: 'school', color: '#3B82F6');
      d.notify(NoticeKind.education, Icons.backpack, 'Primeiro dia de aula!', message: 'Você entrou no Ensino Fundamental.');
      e.studyEffort = 0;
      return;
    }

    if (e.inSchool) {
      final gpa = _yearGpa(d, e.stage == 'high_school' ? 55 : 40);
      e.gpa = double.parse(((e.gpa * 0.4) + gpa * 0.6).toStringAsFixed(1));
      final byAbsence = d.x.school.absences > 25;
      final failed = byAbsence || (gpa < 4.5 && d.ctx.chance(0.65));
      if (byAbsence) {
        d.log('education', 'Reprovado(a) por faltas: ${d.x.school.absences} faltas no ano.', icon: 'event_busy', color: '#EF4444');
      }
      if (failed) {
        e.failedYears += 1;
        d.stats({'happiness': -10, 'stress': 6});
        d.log('education', 'Reprovação! Sua média foi ${gpa.toStringAsFixed(1)} e você vai repetir o ano.', icon: 'warning', color: '#EF4444');
        d.notify(NoticeKind.warning, Icons.sentiment_dissatisfied, 'Você foi reprovado(a)', message: 'Média ${gpa.toStringAsFixed(1)}. Estude mais este ano!');
      } else {
        e.yearsDone += 1;
        if (gpa >= 9) {
          d.log('education', 'Boletim de ouro: média ${gpa.toStringAsFixed(1)}! Você foi destaque da turma.', icon: 'workspace_premium', color: '#FFC53D');
          d.stats({'happiness': 4, 'reputation': 2});
        }
      }
      if (e.stage == 'elementary' && e.yearsDone >= 9) {
        e.stage = 'high_school';
        e.yearsDone = 0;
        e.yearsTotal = 3;
        d.c = d.c.copyWith(educationLevel: 'elementary');
        d.log('education', 'Você concluiu o Ensino Fundamental e entrou no Ensino Médio!', icon: 'school', color: '#3B82F6');
        d.notify(NoticeKind.education, Icons.school, 'Ensino Médio!', message: 'Nova fase, novas matérias.', celebrate: true);
      } else if (e.stage == 'high_school' && e.yearsDone >= 3) {
        e.stage = 'hs_graduate';
        e.completedDegrees.add('high_school');
        d.c = d.c.copyWith(educationLevel: 'high_school');
        d.log('education', 'FORMATURA! Você concluiu o Ensino Médio com média ${e.gpa.toStringAsFixed(1)}.', icon: 'workspace_premium', color: '#FFC53D');
        d.notify(NoticeKind.education, Icons.workspace_premium, 'Formatura do Ensino Médio!',
            message: 'Agora você pode prestar vestibular.', celebrate: true);
        d.sfx(GameSfx.achievement);
        d.stats({'happiness': 10});
      }
      e.studyEffort = 0;
      return;
    }

    if (e.inHigherEd) {
      final deg = EducationCatalog.degree(e.degreeId);
      if (deg == null) {
        e.stage = 'hs_graduate';
        return;
      }
      // Mensalidade
      final instMult = d.x.school.institutionId == null ? 1.0 : SchoolCatalog.institution(d.x.school.institutionId).costMult;
      final cost = deg.annualCost * instMult * (1 - e.scholarshipPct) * d.ctx.costMult(d.c.country);
      if (cost > 0) FinanceSystem.charge(d, cost, 'a mensalidade de ${deg.name}');
      final gpa = _yearGpa(d, deg.difficulty);
      e.gpa = double.parse(((e.gpa * 0.5) + gpa * 0.5).toStringAsFixed(1));
      d.stats({'smarts': 3, 'stress': deg.difficulty ~/ 15});
      if (gpa < 4 && d.ctx.chance(0.6)) {
        e.failedYears += 1;
        d.log('education', 'Você reprovou em várias matérias de ${deg.name} e terá que refazer o período.', icon: 'warning', color: '#EF4444');
        d.notify(NoticeKind.warning, Icons.sentiment_dissatisfied, 'Período reprovado', message: deg.name);
        if (e.scholarshipPct > 0) {
          e.scholarshipPct = 0;
          d.log('education', 'Você perdeu sua bolsa de estudos por causa das notas.', icon: 'money_off', color: '#EF4444');
        }
      } else {
        e.yearsDone += 1;
        if (gpa >= 9 && e.scholarshipPct < 1 && d.ctx.chance(0.4)) {
          e.scholarshipPct = (e.scholarshipPct + 0.5).clamp(0, 1);
          d.log('education', 'Excelência acadêmica! Você ganhou bolsa de ${(e.scholarshipPct * 100).round()}% em ${deg.name}.', icon: 'workspace_premium', color: '#FFC53D');
          d.notify(NoticeKind.education, Icons.workspace_premium, 'Bolsa de estudos!', message: '${(e.scholarshipPct * 100).round()}% de desconto', celebrate: true);
        }
      }
      if (e.yearsDone >= e.yearsTotal) _graduate(d, deg);
      e.studyEffort = 0;
    }
  }

  static void _graduate(LifeDraft d, DegreeInfo deg) {
    final e = d.x.education;
    e.completedDegrees.add(deg.id);
    final level = switch (deg.level) {
      'master' => 'master',
      'phd' => 'phd',
      _ => null,
    };
    final current = educationRank[d.c.educationLevel] ?? 0;
    String newLevel = d.c.educationLevel;
    if (deg.level == 'college' && current < educationRank['college']!) newLevel = 'college';
    if (level != null && (educationRank[level] ?? 0) > current) newLevel = level;
    d.c = d.c.copyWith(educationLevel: newLevel, currentDegree: deg.level == 'college' ? deg.name : d.c.currentDegree);
    e.stage = 'graduated';
    e.degreeId = null;
    e.yearsDone = 0;
    e.yearsTotal = 0;
    e.scholarshipPct = 0;
    d.stats({'happiness': 15, 'smarts': 4, 'reputation': 4});
    d.log('education', 'FORMATURA! Você concluiu ${deg.name} com média ${e.gpa.toStringAsFixed(1)}. Diploma na mão!', icon: 'workspace_premium', color: '#FFC53D');
    d.notify(NoticeKind.education, Icons.workspace_premium, 'Você se formou!', message: deg.name, celebrate: true);
    d.sfx(GameSfx.achievement);
  }

  /// Requisitos para entrar num curso superior / pós.
  static String? enrollBlocker(LifeDraft d, DegreeInfo deg) {
    final e = d.x.education;
    if (d.age < 17) return 'Você precisa ter pelo menos 17 anos.';
    if (e.inHigherEd) return 'Você já está matriculado(a) em um curso.';
    if (!e.hasHighSchool) return 'É preciso concluir o Ensino Médio (ou o Supletivo).';
    if (deg.level != 'college') {
      if (!['college', 'master', 'phd'].contains(d.c.educationLevel)) return 'É preciso ter uma graduação.';
      if (deg.requires != null && !e.completedDegrees.contains(deg.requires)) {
        return 'Pré-requisito: ${EducationCatalog.degree(deg.requires)?.name ?? deg.requires}.';
      }
    }
    if (e.completedDegrees.contains(deg.id)) return 'Você já concluiu este curso.';
    return null;
  }

  /// Vestibular + matrícula. payMode: cash | loan | parents
  static void enroll(LifeDraft d, String degreeId, String payMode, [String institutionId = 'unibrasil']) {
    final inst = SchoolCatalog.institution(institutionId);
    final deg = EducationCatalog.degree(degreeId);
    if (deg == null) return;
    final blocker = enrollBlocker(d, deg);
    if (blocker != null) {
      d.warn('Matrícula indisponível', blocker);
      return;
    }
    if (!d.useAction('enroll', 2)) return;
    // Vestibular / processo seletivo
    final p = 0.25 + (d.c.smarts - deg.minSmarts) / 40 + d.x.education.gpa / 25 + inst.entryMod;
    if (!d.ctx.chance(p.clamp(0.05, 0.97))) {
      d.log('education', 'Você não passou no processo seletivo de ${deg.name} (${inst.name}). Estude mais e tente de novo!', icon: 'sentiment_dissatisfied', color: '#EF4444');
      d.notify(NoticeKind.warning, Icons.sentiment_dissatisfied, 'Não foi aprovado(a)', message: 'Processo seletivo de ${deg.name}');
      d.stats({'happiness': -8});
      d.sfx(GameSfx.negativeEvent);
      return;
    }
    final e = d.x.education;
    final annual = deg.annualCost * inst.costMult * d.ctx.costMult(d.c.country);
    double scholarship = inst.costMult == 0 ? 1.0 : 0;
    if (e.gpa >= 9.2 && d.ctx.chance(0.5)) scholarship = 1.0;
    if (scholarship == 0 && e.gpa >= 8.3 && d.ctx.chance(0.5)) scholarship = 0.5;
    if (payMode == 'parents') {
      final parents = d.living((n) => n.isParent);
      final rich = parents.fold<double>(0, (s, n) => s + n.netWorth);
      if (rich < annual * deg.years * 1.5) {
        d.warn('Seus pais não podem pagar', 'O patrimônio da família não cobre o curso.');
        return;
      }
      for (final p in parents) {
        d.updateNpc(p.copyWith(netWorth: p.netWorth - annual * deg.years / parents.length));
      }
      scholarship = 1.0; // custo coberto pelos pais
      d.log('family', 'Seus pais vão pagar todo o curso de ${deg.name}!', icon: 'volunteer_activism', color: '#22C55E');
    } else if (payMode == 'loan') {
      final total = annual * deg.years * (1 - scholarship);
      if (total > 0) {
        FinanceSystem.createLoan(d, total, 0.065, deg.years + 6, 'Financiamento estudantil — ${deg.name}');
      }
      scholarship = 1.0;
    }
    e.stage = deg.level == 'college' ? 'university' : 'postgrad';
    e.degreeId = deg.id;
    e.yearsDone = 0;
    e.yearsTotal = deg.years;
    e.scholarshipPct = scholarship;
    e.studyEffort = 0;
    SchoolSystem.onEnroll(d, inst.id);
    d.stats({'happiness': 12});
    d.log('education', 'Aprovado(a)! Você começou ${deg.name} na ${inst.name} (${deg.years} anos).', icon: 'school', color: '#7C5CFF');
    d.notify(NoticeKind.education, deg.icon, 'Aprovado(a) no vestibular!',
        message: '${deg.name}${scholarship > 0 && payMode == 'cash' ? ' · bolsa ${(scholarship * 100).round()}%' : ''}', celebrate: true);
    d.sfx(GameSfx.achievement);
  }

  static void dropOut(LifeDraft d) {
    final e = d.x.education;
    if (e.inSchool && d.age < 16) {
      d.warn('Não permitido', 'A escola é obrigatória até os 16 anos.');
      return;
    }
    if (!e.isStudying) return;
    final what = e.inSchool ? 'a escola' : (EducationCatalog.degree(e.degreeId)?.name ?? 'o curso');
    e.stage = e.inSchool ? 'dropout' : (e.hasHighSchool ? 'hs_graduate' : 'dropout');
    e.degreeId = null;
    e.yearsDone = 0;
    e.yearsTotal = 0;
    d.stats({'stress': -10, 'happiness': 3, 'reputation': -3});
    d.log('education', 'Você abandonou $what.', icon: 'exit_to_app', color: '#64748B');
    d.notify(NoticeKind.education, Icons.exit_to_app, 'Você largou os estudos', message: 'Dá para voltar pelo Supletivo ou vestibular.');
  }

  static void study(LifeDraft d) {
    if (d.age < 5) {
      d.warn('Muito cedo', 'Espere aprender a ler primeiro!');
      return;
    }
    if (!d.useAction('study', 4) || !d.useEnergy(12)) return;
    d.x.education.studyEffort += 1;
    d.x.bump('studySessions');
    d.stats({'smarts': d.ctx.range(2, 5), 'discipline': 2, 'stress': 2});
    d.log('education', d.ctx.pick([
      'Você passou horas na biblioteca estudando.',
      'Você revisou toda a matéria e fez resumos coloridos.',
      'Você assistiu a videoaulas e resolveu listas de exercícios.',
    ]), icon: 'menu_book', color: '#3B82F6');
    d.notify(NoticeKind.education, Icons.menu_book, 'Estudo concluído', message: '+Inteligência');
    d.sfx(GameSfx.positiveEvent);
  }

  static void takeCourse(LifeDraft d, String courseId) {
    final c = EducationCatalog.course(courseId);
    if (c == null) return;
    final e = d.x.education;
    if (d.age < c.minAge) {
      d.warn('Idade mínima: ${c.minAge} anos');
      return;
    }
    if (e.courses.contains(c.id)) {
      d.warn('Curso já concluído');
      return;
    }
    if (c.id == 'eja' && e.hasHighSchool) {
      d.warn('Você já tem Ensino Médio');
      return;
    }
    final cost = c.cost * d.ctx.costMult(d.c.country);
    if (!d.pay(cost, what: c.name)) return;
    if (!d.useEnergy(15)) {
      d.money(cost);
      return;
    }
    e.courses.add(c.id);
    d.stats(c.boosts);
    if (c.id == 'driving') d.c = d.c.copyWith(hasDriversLicense: true);
    if (c.id == 'eja') {
      e.completedDegrees.add('high_school');
      e.stage = 'hs_graduate';
      if ((educationRank[d.c.educationLevel] ?? 0) < 2) d.c = d.c.copyWith(educationLevel: 'high_school');
    }
    d.x.bump('studySessions');
    d.x.bump('purchases');
    d.log('education', 'Você concluiu o curso de ${c.name} (${Fmt.money(cost)}).', icon: 'school', color: '#22D3EE');
    d.notify(NoticeKind.education, c.icon, 'Curso concluído!', message: c.unlocks.isEmpty ? c.name : c.unlocks, celebrate: true);
    d.sfx(GameSfx.achievement);
  }
}
