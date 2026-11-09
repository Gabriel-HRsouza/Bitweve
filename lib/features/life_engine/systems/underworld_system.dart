import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/underworld/data/crime_catalog.dart';
import 'package:bitweve/features/underworld/data/store_catalog.dart';
import 'package:bitweve/features/underworld/models/crime_state.dart';
import 'package:bitweve/features/underworld/models/minigame_result.dart';
import 'life_draft.dart';

/// Submundo fictício: crimes com minigame, organizações, mercado clandestino,
/// polícia, julgamento, prisão e reabilitação.
class UnderworldSystem {
  static int _c(int v) => v.clamp(0, 100);

  /// Motivo que impede cometer crimes agora (ou null).
  static String? blocker(LifeDraft d, {int minAge = 12}) => blockerFor(d.age, d.x.crime, minAge: minAge);

  static String? blockerFor(int age, CrimeState cs, {int minAge = 12}) {
    if (age < minAge) return 'Idade mínima: $minAge anos.';
    if (cs.inPrison) return 'Você está cumprindo pena.';
    if (cs.pendingCase != null) return 'Você tem um processo pendente. Resolva o julgamento primeiro.';
    return null;
  }

  /// Dificuldade efetiva do minigame (1..5) considerando preparo e habilidade.
  static int effectiveDifficulty(CrimeState cs, int base, {bool prepared = false}) {
    var dif = base;
    if (prepared) dif -= 1;
    if (cs.skill >= 60) dif -= 1;
    return dif.clamp(1, 5);
  }

  // ------------------------------------------------------------------ crimes
  /// Resolve um crime após o minigame.
  static CrimeReport commit(LifeDraft d, String crimeId, MinigameResult r, {String? storeId, bool prepared = false}) {
    final crime = CrimeCatalog.crime(crimeId);
    final b = blocker(d, minAge: crime.minAge);
    if (b != null) {
      d.warn('Não é possível', b);
      return CrimeReport.none;
    }
    final cs = d.x.crime;
    if (cs.notoriety < crime.minNotoriety) {
      d.warn('Reputação insuficiente', 'Você precisa de ${crime.minNotoriety} de notoriedade no submundo.');
      return CrimeReport.none;
    }
    if (!d.useAction('crime', 4)) return CrimeReport.none;
    if (prepared) {
      if (!d.useEnergy(15)) {
        prepared = false;
      }
    }
    if (!d.useEnergy(8)) return CrimeReport.none;

    final store = storeId != null ? StoreCatalog.byId(storeId) : null;
    final label = store != null ? 'furto na ${store.name}' : crime.name.toLowerCase();
    final difficulty = store?.difficulty ?? crime.difficulty;
    final baseLoot = store?.lootValue ?? crime.baseLoot;
    final hits = store != null ? (cs.storeHits[store.id] ?? 0) : 0;

    // Sorte + estado do personagem
    final luck = d.ctx.roll() * 0.2 - 0.1;
    final condition = (d.c.energy - 50) / 500 - d.c.stress / 600;
    final skillBonus = cs.skill / 250;
    final quality = (r.performance + luck + condition + skillBonus + (prepared ? 0.08 : 0)).clamp(0.0, 1.2);

    if (r.success && quality > 0.35) {
      final loot = (baseLoot * (0.5 + quality * 0.7) * (1 + cs.notoriety / 200)).roundToDouble();
      // Mesmo vencendo, há chance de ser identificado depois (câmeras, testemunhas)
      final identified = d.ctx.chance(((difficulty * 0.03) + cs.heat / 600 + hits * 0.05 - quality * 0.08).clamp(0.0, 0.35));
      cs.successes += 1;
      cs.skill = _c(cs.skill + 3);
      cs.notoriety = _c(cs.notoriety + crime.severity + (difficulty > 3 ? 2 : 0));
      cs.heat = _c(cs.heat + 4 + difficulty * 2);
      cs.totalLoot += loot;
      if (store != null) cs.storeHits[store.id] = hits + 1;
      d.x.bump('crimesCommitted');
      // Produtos de lojas viram "estoque quente"; dinheiro direto para golpes
      if (store != null || crime.category == 'smuggling') {
        cs.stash += loot;
      } else {
        d.money(loot);
      }
      d.stats({'karma': -6 - crime.severity, 'stress': 6, 'happiness': 3});
      final goods = store != null ? d.ctx.pick(store.products).toLowerCase() : null;
      var text = store != null
          ? 'Você saiu da ${store.name} com $goods (≈ ${Fmt.money(loot)} em mercadoria). Venda no mercado clandestino.'
          : 'Deu certo: $label rendeu ${Fmt.money(loot)}.';
      if (identified) {
        text += ' Mas uma câmera registrou seu rosto...';
        _arrest(d, crime, label, evidence: 0.45 + d.ctx.roll() * 0.25);
        return CrimeReport(success: true, caught: true, loot: loot, title: 'Identificado(a)!', text: text);
      }
      d.log('crime', text, icon: 'vpn_key', color: '#F59E0B');
      d.notify(NoticeKind.money, Icons.vpn_key, 'Missão concluída', message: crime.name, money: store == null ? loot : null);
      d.sfx(GameSfx.moneyGain);
      return CrimeReport(success: true, caught: false, loot: loot, title: 'Sucesso!', text: text);
    }

    // Falhou
    cs.failures += 1;
    cs.skill = _c(cs.skill + 1);
    final caughtP = (crime.risk + cs.heat / 250 + difficulty * 0.04 - cs.skill / 400 + (1 - r.performance) * 0.2 - (prepared ? 0.08 : 0) +
            (cs.onProbation ? 0.1 : 0))
        .clamp(0.08, 0.95);
    if (d.ctx.chance(caughtP)) {
      final text = 'A tentativa de $label deu errado e você foi detido(a)!';
      _arrest(d, crime, label, evidence: 0.6 + d.ctx.roll() * 0.35);
      return CrimeReport(success: false, caught: true, loot: 0, title: 'Detido(a)!', text: text);
    }
    final lost = (crime.difficulty * 80.0).clamp(0.0, d.c.bankBalance.clamp(0.0, double.infinity)).toDouble();
    d.money(-lost);
    cs.heat = _c(cs.heat + 6);
    d.stats({'stress': 8, 'happiness': -4});
    final text = 'A tentativa de $label falhou, mas você escapou sem ser identificado(a).${lost > 0 ? ' Prejuízo de ${Fmt.money(lost)}.' : ''}';
    d.log('crime', text, icon: 'directions_run', color: '#64748B');
    d.notify(NoticeKind.warning, Icons.directions_run, 'Fracasso', message: 'Você escapou por pouco.', money: lost > 0 ? -lost : null);
    d.sfx(GameSfx.negativeEvent);
    return CrimeReport(success: false, caught: false, loot: 0, title: 'Não deu certo', text: text);
  }

  static void _arrest(LifeDraft d, CrimeDef crime, String label, {required double evidence}) {
    final cs = d.x.crime;
    d.c = d.c.copyWith(criminalRecord: true, timesArrested: d.c.timesArrested + 1);
    final bail = (crime.severity * crime.severity * 1500.0 + cs.heat * 40).roundToDouble();
    cs.pendingCase = PendingCase(crimeId: crime.id, label: label, severity: crime.severity, evidence: evidence.clamp(0.1, 1.0), bail: bail);
    cs.heat = _c(cs.heat + 15);
    d.x.bump('arrests');
    d.stats({'stress': 25, 'happiness': -15, 'reputation': -12, 'karma': -6});
    for (final p in d.living((n) => n.isParent || n.relationshipType == RelationshipType.spouse || n.relationshipType == RelationshipType.partner)) {
      d.updateNpc(p.copyWith(relationshipLevel: p.relationshipLevel - 10));
    }
    d.log('justice', 'PRISÃO EM FLAGRANTE: $label. Você aguarda julgamento (fiança: ${Fmt.money(bail)}).', icon: 'local_police', color: '#EF4444');
    d.notify(NoticeKind.warning, Icons.local_police, 'Você foi preso(a)!', message: 'Aguardando julgamento');
    d.sfx(GameSfx.alarm);
  }

  // ------------------------------------------------------------------ mercado clandestino
  static void fence(LifeDraft d, MinigameResult r) {
    final cs = d.x.crime;
    if (cs.stash <= 0) {
      d.warn('Nada para vender', 'Seu estoque está vazio.');
      return;
    }
    if (blocker(d) != null) {
      d.warn('Não é possível', blocker(d)!);
      return;
    }
    if (!d.useAction('fence', 3)) return;
    if (r.performance < 0.25 && d.ctx.chance(0.25 + cs.heat / 300)) {
      // Comprador era policial disfarçado
      final value = cs.stash;
      cs.stash = 0;
      d.log('crime', 'O comprador era um policial disfarçado! A mercadoria (${Fmt.money(value)}) foi apreendida.', icon: 'local_police', color: '#EF4444');
      _arrest(d, CrimeCatalog.crime('shoplift'), 'receptação', evidence: 0.8);
      return;
    }
    final pct = (0.35 + r.performance * 0.3 + cs.notoriety / 500).clamp(0.3, 0.75);
    final cash = (cs.stash * pct).roundToDouble();
    cs.stash = 0;
    cs.notoriety = _c(cs.notoriety + 1);
    d.money(cash);
    d.log('crime', 'Você vendeu o estoque no mercado clandestino por ${Fmt.money(cash)} (${(pct * 100).round()}% do valor).', icon: 'storefront', color: '#F59E0B');
    d.notify(NoticeKind.money, Icons.storefront, 'Mercadoria vendida', money: cash);
    d.sfx(GameSfx.moneyGain);
  }

  static void lieLow(LifeDraft d) {
    final cs = d.x.crime;
    if (!d.useAction('lieLow', 1)) return;
    cs.heat = _c(cs.heat - 25);
    d.stats({'stress': -6});
    d.log('crime', 'Você ficou na moita por um tempo. A polícia perdeu seu rastro.', icon: 'visibility_off', color: '#64748B');
    d.notify(NoticeKind.info, Icons.visibility_off, 'Discrição', message: '−25 de atenção policial');
  }

  // ------------------------------------------------------------------ organizações
  static void joinGang(LifeDraft d, String gangId, MinigameResult r) {
    final g = CrimeCatalog.gang(gangId);
    final cs = d.x.crime;
    if (g == null) return;
    final b = blocker(d, minAge: 16);
    if (b != null) {
      d.warn('Não é possível', b);
      return;
    }
    if (cs.notoriety < g.minNotoriety) {
      d.warn('Ninguém te conhece ainda', 'A ${g.name} exige notoriedade ${g.minNotoriety}.');
      return;
    }
    if (!d.useAction('gangJoin', 1)) return;
    if (r.success && r.performance >= 0.45) {
      cs.gangId = g.id;
      cs.gangRank = 0;
      cs.gangLoyalty = 50;
      cs.notoriety = _c(cs.notoriety + 5);
      d.stats({'karma': -8, 'stress': 6});
      d.log('crime', 'Você passou no teste de iniciação e entrou para a ${g.name} como ${g.ranks.first}.', icon: 'groups', color: '#EF4444');
      d.notify(NoticeKind.warning, g.icon, 'Bem-vindo(a) à ${g.name}', message: g.ranks.first);
      d.sfx(GameSfx.mission);
    } else {
      d.stats({'happiness': -5});
      d.log('crime', 'Você falhou no teste de iniciação da ${g.name}. Talvez no ano que vem.', icon: 'block', color: '#64748B');
      d.notify(NoticeKind.info, Icons.block, 'Iniciação reprovada');
    }
  }

  static void leaveGang(LifeDraft d) {
    final cs = d.x.crime;
    final g = CrimeCatalog.gang(cs.gangId);
    if (g == null) return;
    cs.gangId = null;
    cs.gangRank = 0;
    final punished = d.ctx.chance(0.35);
    if (punished) d.stats({'health': -15, 'stress': 15});
    d.log('crime', 'Você deixou a ${g.name}.${punished ? ' Eles não gostaram nada disso e você levou uma surra.' : ''}', icon: 'logout', color: '#64748B');
    d.notify(NoticeKind.info, Icons.logout, 'Você saiu da organização');
  }

  static CrimeReport gangMission(LifeDraft d, String missionId, MinigameResult r) {
    final m = CrimeCatalog.mission(missionId);
    final cs = d.x.crime;
    if (m == null || cs.gangId != m.gangId) return CrimeReport.none;
    final b = blocker(d, minAge: 16);
    if (b != null) {
      d.warn('Não é possível', b);
      return CrimeReport.none;
    }
    if (cs.gangRank < m.minRank) {
      d.warn('Cargo insuficiente');
      return CrimeReport.none;
    }
    if (!d.useAction('gangMission', 3) || !d.useEnergy(12)) return CrimeReport.none;
    final g = CrimeCatalog.gang(m.gangId)!;
    if (r.success) {
      final reward = (m.reward * (0.6 + r.performance * 0.6)).roundToDouble();
      d.money(reward);
      cs.missionsDone += 1;
      cs.gangLoyalty = _c(cs.gangLoyalty + 8);
      cs.notoriety = _c(cs.notoriety + m.difficulty);
      cs.heat = _c(cs.heat + m.difficulty * 3);
      cs.skill = _c(cs.skill + 2);
      d.stats({'karma': -5, 'stress': 5});
      var text = 'Missão "${m.name}" concluída para a ${g.name}: ${Fmt.money(reward)}.';
      if (cs.gangLoyalty >= 80 && cs.gangRank < g.ranks.length - 1 && cs.missionsDone >= (cs.gangRank + 1) * 2) {
        cs.gangRank += 1;
        cs.gangLoyalty = 55;
        text += ' Você foi promovido(a) a ${g.ranks[cs.gangRank]}!';
        d.notify(NoticeKind.career, Icons.military_tech, 'Promoção no submundo', message: g.ranks[cs.gangRank], celebrate: true);
      }
      d.log('crime', text, icon: 'task_alt', color: '#F59E0B');
      d.notify(NoticeKind.money, Icons.task_alt, 'Missão cumprida', message: m.name, money: reward);
      d.sfx(GameSfx.mission);
      return CrimeReport(success: true, caught: false, loot: reward, title: 'Missão cumprida', text: text);
    }
    cs.gangLoyalty = _c(cs.gangLoyalty - 12);
    if (d.ctx.chance((0.3 + cs.heat / 300 + m.difficulty * 0.05).clamp(0.1, 0.8))) {
      _arrest(d, CrimeDef(
        id: 'gang_${m.id}', name: m.name, description: '', icon: Icons.groups, color: g.color, minigame: m.minigame,
        minAge: 16, difficulty: m.difficulty, baseLoot: 0, risk: 0.5, severity: (m.difficulty).clamp(1, 5), category: 'gang',
      ), 'missão "${m.name}"', evidence: 0.7);
      return CrimeReport(success: false, caught: true, loot: 0, title: 'Detido(a)!', text: 'A missão "${m.name}" fracassou e a polícia te pegou.');
    }
    d.stats({'stress': 8});
    final text = 'A missão "${m.name}" fracassou. A ${g.name} ficou decepcionada.';
    d.log('crime', text, icon: 'error', color: '#64748B');
    d.notify(NoticeKind.warning, Icons.error, 'Missão fracassada', message: '−Lealdade');
    d.sfx(GameSfx.negativeEvent);
    return CrimeReport(success: false, caught: false, loot: 0, title: 'Fracasso', text: text);
  }

  // ------------------------------------------------------------------ justiça
  static void payBail(LifeDraft d) {
    final pc = d.x.crime.pendingCase;
    if (pc == null || pc.bailPaid) return;
    if (!d.pay(pc.bail, what: 'a fiança')) return;
    pc.bailPaid = true;
    d.stats({'stress': -8});
    d.log('justice', 'Você pagou fiança de ${Fmt.money(pc.bail)} e responde ao processo em liberdade.', icon: 'gavel', color: '#F59E0B');
    d.notify(NoticeKind.info, Icons.gavel, 'Fiança paga', money: -pc.bail);
  }

  static double lawyerCost(String tier, int severity) => switch (tier) {
        'private' => 4000.0 * severity,
        'elite' => 25000.0 * severity,
        _ => 0,
      };

  /// Julgamento. lawyer: public | private | elite · plea: guilty | innocent
  static String trial(LifeDraft d, String lawyer, String plea) {
    final cs = d.x.crime;
    final pc = cs.pendingCase;
    if (pc == null) return '';
    final cost = lawyerCost(lawyer, pc.severity);
    if (cost > 0 && !d.pay(cost, what: 'o advogado')) return '';
    final skill = switch (lawyer) { 'elite' => 0.38, 'private' => 0.2, _ => 0.05 };
    final priors = cs.record.length;
    final guilty = plea == 'guilty';
    String outcome;
    int years = 0;
    double fine = 0;
    if (!guilty) {
      final acquitP = (0.75 - pc.evidence * 0.7 + skill + (pc.bailPaid ? 0.05 : 0) - priors * 0.05 + d.c.charisma / 800).clamp(0.03, 0.9);
      if (d.ctx.chance(acquitP)) {
        outcome = 'acquitted';
      } else {
        years = (pc.severity + priors ~/ 2 + d.ctx.range(0, pc.severity)).clamp(1, 25);
        outcome = pc.severity <= 1 && priors == 0 ? 'fine' : 'prison';
      }
    } else {
      // Confissão: pena reduzida
      years = ((pc.severity + priors ~/ 2) * (1 - skill)).round().clamp(0, 20);
      outcome = years <= 1 && priors <= 1 ? (pc.severity <= 2 ? 'probation' : 'prison') : 'prison';
      if (pc.severity <= 1 && priors == 0) outcome = 'fine';
      if (outcome == 'prison' && years == 0) years = 1;
    }
    if (outcome == 'fine') {
      fine = 800.0 * pc.severity + priors * 500;
      d.money(-fine);
    }
    final rec = CrimeRecord(crime: pc.label, age: d.age, outcome: outcome, years: outcome == 'prison' ? years : 0, fine: fine);
    cs.record.add(rec);
    cs.pendingCase = null;
    String text;
    switch (outcome) {
      case 'acquitted':
        if (cs.record.where((r) => r.outcome != 'acquitted').isEmpty && d.c.timesArrested <= 1) {
          d.c = d.c.copyWith(criminalRecord: false);
        }
        d.stats({'happiness': 15, 'stress': -15});
        text = 'ABSOLVIDO(A)! O júri não se convenceu das provas sobre ${pc.label}.';
        d.notify(NoticeKind.info, Icons.gavel, 'Absolvido(a)!', celebrate: true);
        d.sfx(GameSfx.achievement);
      case 'fine':
        text = 'Condenado(a) a pagar multa de ${Fmt.money(fine)} por ${pc.label}.';
        d.notify(NoticeKind.warning, Icons.gavel, 'Multa aplicada', money: -fine);
        d.sfx(GameSfx.moneyLoss);
      case 'probation':
        cs.probationYears = 2;
        text = 'Condenado(a) a 2 anos de liberdade condicional por ${pc.label}. Qualquer deslize agrava a pena.';
        d.notify(NoticeKind.warning, Icons.gavel, 'Liberdade condicional');
        d.sfx(GameSfx.negativeEvent);
      default:
        text = 'Condenado(a) a $years ano${years == 1 ? '' : 's'} de prisão por ${pc.label}.';
        _imprison(d, years);
    }
    d.log('justice', text, icon: 'gavel', color: outcome == 'acquitted' ? '#22C55E' : '#EF4444');
    return text;
  }

  static const _prisons = ['Penitenciária Estadual Horizonte', 'Presídio Central da Serra', 'Complexo Penal Vale Verde', 'Casa de Detenção Aurora'];

  static void _imprison(LifeDraft d, int years) {
    final cs = d.x.crime;
    cs.inPrison = true;
    cs.sentence = years;
    cs.served = 0;
    cs.behavior = 50;
    cs.paroleDenials = 0;
    cs.prisonName = d.ctx.pick(_prisons);
    cs.heat = 0;
    d.x.bump('prisonTerms');
    d.stats({'happiness': -25, 'stress': 20, 'reputation': -15});
    d.notify(NoticeKind.warning, Icons.lock, 'Você foi para a prisão', message: '$years ano(s) — ${cs.prisonName}');
    d.sfx(GameSfx.cellDoor);
    // Consequências profissionais e acadêmicas
    if (d.c.currentJobTitle != null) {
      d.log('career', 'Você perdeu o emprego de ${d.c.currentJobTitle} por causa da condenação.', icon: 'work_off', color: '#EF4444');
      d.c = d.c.copyWith(clearJob: true);
      d.x.careerLevel = 0;
      d.x.company = null;
    }
    final e = d.x.education;
    if (e.isStudying) {
      e.stage = e.hasHighSchool ? 'hs_graduate' : 'dropout';
      e.degreeId = null;
      d.log('education', 'Sua matrícula foi cancelada por causa da prisão.', icon: 'school', color: '#EF4444');
    }
    // Consequências familiares
    final p = d.partner;
    if (p != null && years >= 3 && d.ctx.chance(0.35 + years * 0.05)) {
      d.updateNpc(p.copyWith(relationshipType: RelationshipType.exPartner, relationshipLevel: p.relationshipLevel - 30));
      d.c = d.c.copyWith(isMarried: false, clearPartner: true);
      d.log('family', '${p.fullName} não suportou a distância e terminou com você.', icon: 'heart_broken', color: '#64748B');
    }
    // Colegas de cela
    for (var i = 0; i < 3; i++) {
      final n = d.makeNpc(type: RelationshipType.inmate, age: d.ctx.range(20, 60), level: 30 + d.ctx.rng.nextInt(30), occupation: 'Detento(a)');
      d.npcs.add(n);
      d.x.meta(n.id).origin = 'prison';
    }
  }

  // ------------------------------------------------------------------ prisão
  static void prisonAction(LifeDraft d, String action) {
    final cs = d.x.crime;
    if (!cs.inPrison) return;
    if (!d.useAction('prison:$action', action == 'lawyer' || action == 'parole' ? 1 : 2)) return;
    switch (action) {
      case 'workout':
        if (!d.useEnergy(10)) return;
        d.stats({'fitness': 4, 'health': 3, 'stress': -4});
        d.log('prison', 'Você treinou no pátio da prisão. Corpo e mente mais fortes.', icon: 'fitness_center', color: '#14B8A6');
        d.notify(NoticeKind.health, Icons.fitness_center, 'Treino no pátio');
      case 'study':
        if (!d.useEnergy(10)) return;
        d.stats({'smarts': 4, 'discipline': 2});
        cs.behavior = _c(cs.behavior + 4);
        var text = 'Você estudou na biblioteca da prisão.';
        if (!d.x.education.hasHighSchool && d.ctx.chance(0.35)) {
          d.x.education.completedDegrees.add('high_school');
          d.x.education.stage = 'hs_graduate';
          d.c = d.c.copyWith(educationLevel: 'high_school');
          text += ' Você concluiu o Ensino Médio pelo supletivo prisional!';
          d.notify(NoticeKind.education, Icons.workspace_premium, 'Supletivo concluído!', celebrate: true);
        }
        d.log('prison', text, icon: 'menu_book', color: '#3B82F6');
        d.notify(NoticeKind.education, Icons.menu_book, 'Estudo na prisão', message: '+Comportamento');
      case 'work':
        if (!d.useEnergy(12)) return;
        final pay = 900.0 + d.ctx.range(0, 600);
        cs.prisonSavings += pay;
        cs.behavior = _c(cs.behavior + 6);
        d.log('prison', 'Você trabalhou na oficina da prisão e juntou ${Fmt.money(pay)} (liberados na soltura). Cada ano trabalhado conta para remição.',
            icon: 'handyman', color: '#F59E0B');
        d.notify(NoticeKind.career, Icons.handyman, 'Trabalho prisional', message: '+${Fmt.money(pay)} · +Comportamento');
      case 'program':
        cs.behavior = _c(cs.behavior + 10);
        d.stats({'karma': 5, 'happiness': 2});
        d.log('prison', 'Você participou de um programa de reabilitação e terapia em grupo.', icon: 'self_improvement', color: '#22C55E');
        d.notify(NoticeKind.info, Icons.self_improvement, 'Reabilitação', message: '+10 comportamento');
      case 'fight':
        cs.behavior = _c(cs.behavior - 20);
        final won = d.ctx.chance(0.3 + d.c.fitness / 200);
        d.stats({'health': won ? -5 : -18, 'stress': 10});
        cs.sentence += won ? 0 : (d.ctx.chance(0.3) ? 1 : 0);
        d.log('prison', won ? 'Você entrou numa briga no pátio e saiu por cima, mas foi para a solitária.' : 'Você apanhou feio numa briga no pátio. Os guardas anotaram tudo.',
            icon: 'sports_mma', color: '#EF4444');
        d.notify(NoticeKind.warning, Icons.sports_mma, 'Briga na prisão', message: '−20 comportamento');
        d.sfx(GameSfx.negativeEvent);
      case 'lawyer':
        const cost = 12000.0;
        if (!d.pay(cost, what: 'o recurso')) return;
        if (d.ctx.chance(0.3 + cs.behavior / 300) && cs.yearsLeft > 1) {
          final cut = (cs.yearsLeft / 3).ceil();
          cs.sentence -= cut;
          d.log('justice', 'Seu advogado ganhou o recurso: pena reduzida em $cut ano(s)!', icon: 'gavel', color: '#22C55E');
          d.notify(NoticeKind.info, Icons.gavel, 'Recurso aceito!', message: '−$cut ano(s)', celebrate: true, money: -cost);
          d.sfx(GameSfx.achievement);
        } else {
          d.log('justice', 'O recurso foi negado pelo tribunal.', icon: 'gavel', color: '#64748B');
          d.notify(NoticeKind.info, Icons.gavel, 'Recurso negado', money: -cost);
        }
      case 'parole':
        if (cs.served * 2 < cs.sentence) {
          d.warn('Ainda não', 'A condicional exige ter cumprido metade da pena.');
          d.x.actionsThisYear.remove('prison:parole');
          return;
        }
        if (cs.behavior >= 65 && d.ctx.chance(0.35 + cs.behavior / 250 - cs.paroleDenials * 0.05)) {
          _release(d, parole: true);
        } else {
          cs.paroleDenials += 1;
          d.log('justice', 'A audiência de condicional negou seu pedido. Comportamento: ${cs.behavior}/100.', icon: 'gavel', color: '#64748B');
          d.notify(NoticeKind.info, Icons.gavel, 'Condicional negada');
          d.sfx(GameSfx.negativeEvent);
        }
      case 'socialize':
        final inmates = d.living((n) => n.relationshipType == RelationshipType.inmate);
        if (inmates.length < 6 && d.ctx.chance(0.6)) {
          final n = d.makeNpc(type: RelationshipType.inmate, age: d.ctx.range(20, 60), level: 45, occupation: 'Detento(a)');
          d.npcs.add(n);
          d.x.meta(n.id).origin = 'prison';
          d.log('prison', 'Você conheceu ${n.fullName} no pátio.', icon: 'person_add', color: '#64748B');
          d.notify(NoticeKind.social, Icons.person_add, 'Novo contato', message: n.fullName);
        } else if (inmates.isNotEmpty) {
          final n = d.ctx.pick(inmates);
          d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + 8));
          d.log('prison', 'Você jogou cartas com ${n.fullName} e ganhou um aliado.', icon: 'style', color: '#64748B');
          d.notify(NoticeKind.social, Icons.style, 'Aliança na prisão', message: n.fullName);
        }
        d.stats({'happiness': 3});
    }
  }

  static void _release(LifeDraft d, {bool parole = false}) {
    final cs = d.x.crime;
    cs.inPrison = false;
    cs.probationYears = parole ? (cs.yearsLeft + 1).clamp(1, 5) : 0;
    final savings = cs.prisonSavings;
    cs.prisonSavings = 0;
    if (savings > 0) d.money(savings);
    cs.sentence = 0;
    cs.served = 0;
    d.npcs.removeWhere((n) => n.isAlive && n.relationshipType == RelationshipType.inmate && n.relationshipLevel < 60);
    for (final n in d.npcs.where((n) => n.isAlive && n.relationshipType == RelationshipType.inmate).toList()) {
      d.updateNpc(n.copyWith(relationshipType: RelationshipType.friend));
    }
    d.stats({'happiness': 25, 'stress': -15});
    d.log('justice', parole ? 'LIBERDADE CONDICIONAL concedida! Você deixou ${cs.prisonName}.' : 'Pena cumprida! Você saiu de ${cs.prisonName} e recomeça a vida.',
        icon: 'lock_open', color: '#22C55E');
    d.notify(NoticeKind.info, Icons.lock_open, parole ? 'Condicional!' : 'Você está livre!',
        message: savings > 0 ? 'Pecúlio de ${Fmt.money(savings)} liberado' : '', celebrate: true, money: savings > 0 ? savings : null);
    d.sfx(GameSfx.achievement);
  }

  // ------------------------------------------------------------------ anual
  static void yearly(LifeDraft d) {
    final cs = d.x.crime;
    if (cs.pendingCase != null) {
      d.log('justice', 'O processo foi a julgamento com um defensor público.', icon: 'gavel', color: '#F59E0B');
      trial(d, 'public', 'innocent');
    }
    if (cs.inPrison) {
      cs.served += 1;
      // Remição: trabalho e estudo com bom comportamento podem abater pena
      if (cs.behavior >= 80 && d.ctx.chance(0.3) && cs.yearsLeft > 1) cs.served += 1;
      cs.behavior = _c(cs.behavior + (cs.behavior > 60 ? 1 : -2));
      d.stats({'happiness': -6, 'health': -2});
      if (cs.served >= cs.sentence) {
        _release(d);
      } else {
        d.log('prison', 'Mais um ano em ${cs.prisonName}. Faltam ${cs.yearsLeft} ano(s).', icon: 'lock', color: '#64748B');
      }
      return;
    }
    cs.heat = _c(cs.heat - 12);
    if (cs.probationYears > 0) cs.probationYears -= 1;
    if (cs.gangId != null) {
      cs.gangLoyalty = _c(cs.gangLoyalty - 5);
      if (cs.gangLoyalty <= 10) {
        final g = CrimeCatalog.gang(cs.gangId);
        cs.gangId = null;
        cs.gangRank = 0;
        d.log('crime', 'A ${g?.name ?? 'organização'} te expulsou por falta de lealdade.', icon: 'logout', color: '#EF4444');
      }
    }
    if (cs.notoriety > 0 && cs.successes == 0) cs.notoriety = _c(cs.notoriety - 2);
  }
}
