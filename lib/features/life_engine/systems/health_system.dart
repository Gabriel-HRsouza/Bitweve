import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/health/data/health_catalog.dart';
import 'package:bitweve/features/health/models/health_condition.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'life_draft.dart';

class HealthSystem {
  static void addCondition(LifeDraft d, String id) {
    final base = HealthCatalog.getById(id);
    if (base == null) return;
    if (d.x.conditions.any((c) => c.id == id && c.treatmentState != TreatmentState.cured)) return;
    d.x.conditions.add(base.copyWith(isDiagnosed: true, diagnosedAge: d.age));
    d.log('health', 'Diagnóstico: ${base.name}. ${base.supportNeeds}', icon: 'medical_services', color: '#EF4444');
    d.notify(NoticeKind.health, Icons.sick, 'Problema de saúde', message: base.name);
  }

  static void cureOne(LifeDraft d) {
    final idx = d.x.conditions.indexWhere((c) => c.treatmentState != TreatmentState.cured);
    if (idx < 0) return;
    final c = d.x.conditions.removeAt(idx);
    d.log('health', 'Você se curou de ${c.name}!', icon: 'healing', color: '#22C55E');
  }

  static double _cost(LifeDraft d, double base) => d.x.hasInsurance ? 0 : base * d.ctx.costMult(d.c.country);

  static void toggleInsurance(LifeDraft d) {
    d.x.hasInsurance = !d.x.hasInsurance;
    d.log('health', d.x.hasInsurance ? 'Você contratou um plano de saúde privado (R\$ 2.400/ano).' : 'Você cancelou o plano de saúde.',
        icon: 'health_and_safety', color: d.x.hasInsurance ? '#22C55E' : '#F59E0B');
    d.notify(NoticeKind.health, Icons.health_and_safety, d.x.hasInsurance ? 'Plano de saúde ativo' : 'Plano cancelado');
    d.sfx(GameSfx.buttonTap);
  }

  static void _consult(LifeDraft d, String key, double price, Map<String, num> fx, String text, String icon, {int energy = 5}) {
    if (!d.useAction(key, 3)) return;
    final cost = _cost(d, price);
    if (!d.pay(cost, what: 'a consulta')) {
      d.x.actionsThisYear[key] = (d.x.actionsThisYear[key] ?? 1) - 1;
      return;
    }
    d.c = d.c.copyWith(energy: d.c.energy - energy);
    d.stats(fx);
    d.x.bump('healthActions');
    d.log('health', '$text${cost > 0 ? ' (${Fmt.money(cost)})' : ' (coberto pelo plano)'}', icon: icon, color: '#22C55E');
    d.notify(NoticeKind.health, Icons.medical_services, 'Consulta realizada', message: text, money: cost > 0 ? -cost : null);
    d.sfx(cost > 0 ? GameSfx.moneyLoss : GameSfx.positiveEvent);
  }

  static void publicHealth(LifeDraft d) => _consult(d, 'sus', 0, {'health': 4}, 'Atendimento na rede pública: triagem e orientações gerais.', 'local_hospital', energy: 12);

  static void generalPractitioner(LifeDraft d) {
    _consult(d, 'gp', 220, {'health': 8, 'stress': -3}, 'Check-up com clínico geral: exames em dia.', 'medical_services');
    // Diagnóstico de doenças agudas acelera a cura
    if (d.x.conditions.any((c) => c.category == ConditionCategory.acute)) {
      final acute = d.x.conditions.firstWhere((c) => c.category == ConditionCategory.acute);
      d.x.conditions.remove(acute);
      d.log('health', 'O médico tratou sua ${acute.name}. Você já está melhor!', icon: 'healing', color: '#22C55E');
    }
  }

  static void psychologist(LifeDraft d) =>
      _consult(d, 'psy', 160, {'happiness': 10, 'stress': -15}, 'Sessão de psicoterapia: você saiu mais leve e resiliente.', 'psychology');

  static void psychiatrist(LifeDraft d) {
    final before = d.x.conditions.length;
    _consult(d, 'psychiatrist', 380, {'happiness': 4}, 'Avaliação psiquiátrica completa.', 'biotech');
    if (d.x.conditions.length == before && d.ctx.chance(0.35)) {
      final mental = HealthCatalog.conditions
          .where((c) => c.category == ConditionCategory.mentalHealth || c.category == ConditionCategory.neurodevelopment)
          .toList();
      final pick = d.ctx.pick(mental);
      d.x.conditions.add(pick.copyWith(isDiagnosed: true, diagnosedAge: d.age, treatmentState: TreatmentState.medication));
      d.log('health', 'Diagnóstico cuidadoso: ${pick.name}. Com suporte (${pick.supportNeeds}) sua qualidade de vida vai melhorar.',
          icon: 'biotech', color: '#8B5CF6');
    }
  }

  static void cardiologist(LifeDraft d) =>
      _consult(d, 'cardio', 290, {'health': 7}, 'Consulta cardiológica: eletrocardiograma e teste ergométrico ok.', 'monitor_heart');

  static void medicine(LifeDraft d) {
    if (d.x.conditions.isEmpty) {
      d.warn('Sem receita', 'Você não tem condições que exijam medicamentos.');
      return;
    }
    if (!d.pay(85 * d.ctx.costMult(d.c.country), what: 'os remédios')) return;
    d.stats({'health': 5});
    d.log('health', 'Farmácia: medicamentos do trimestre comprados.', icon: 'medication', color: '#22C55E');
    d.notify(NoticeKind.health, Icons.medication, 'Remédios comprados', money: -85);
    d.sfx(GameSfx.moneyLoss);
  }

  static void treat(LifeDraft d, String conditionId) {
    final i = d.x.conditions.indexWhere((c) => c.id == conditionId);
    if (i < 0) return;
    final c = d.x.conditions[i];
    final cost = _cost(d, c.monthlyCost * 3);
    if (!d.pay(cost, what: 'o tratamento')) return;
    if (c.category == ConditionCategory.acute || (c.category == ConditionCategory.chronicPhysical && d.ctx.chance(0.3))) {
      d.x.conditions.removeAt(i);
      d.log('health', 'Tratamento concluído: você está curado(a) de ${c.name}!', icon: 'healing', color: '#22C55E');
      d.notify(NoticeKind.health, Icons.healing, 'Curado(a)!', message: c.name, celebrate: true);
    } else {
      d.x.conditions[i] = c.copyWith(treatmentState: TreatmentState.underControl);
      d.log('health', 'Tratamento de ${c.name}: sintomas sob controle.', icon: 'healing', color: '#22C55E');
      d.notify(NoticeKind.health, Icons.healing, 'Sintomas controlados', message: c.name);
    }
    d.stats({'health': 6, 'happiness': 4});
    d.x.bump('healthActions');
    d.sfx(GameSfx.positiveEvent);
  }

  static void plasticSurgery(LifeDraft d) {
    if (d.age < 18) {
      d.warn('Menor de idade');
      return;
    }
    if (!d.useAction('surgery', 1)) return;
    const cost = 18000.0;
    if (!d.pay(cost, what: 'a cirurgia')) return;
    if (d.ctx.chance(0.82)) {
      d.stats({'looks': d.ctx.range(8, 16), 'happiness': 10});
      d.log('health', 'Cirurgia plástica bem-sucedida! Você amou o resultado.', icon: 'auto_awesome', color: '#EC4899');
      d.notify(NoticeKind.health, Icons.auto_awesome, 'Resultado incrível!', message: '+Aparência', celebrate: true, money: -cost);
    } else {
      d.stats({'looks': -8, 'happiness': -12, 'health': -6});
      d.log('health', 'A cirurgia teve complicações e o resultado ficou abaixo do esperado.', icon: 'warning', color: '#EF4444');
      d.notify(NoticeKind.warning, Icons.warning, 'Cirurgia com complicações', money: -cost);
    }
    d.sfx(GameSfx.moneyLoss);
  }

  // ------------------------------------------------------------------ anual
  static void yearly(LifeDraft d) {
    final age = d.age;
    final ctx = d.ctx;
    int health = 0;
    if (age > 45) health -= ctx.range(0, 2);
    if (age > 65) health -= ctx.range(1, 4);
    if (age > 80) health -= ctx.range(2, 5);
    if (d.c.stress > 70) health -= 4;
    if (d.c.fitness > 70) health += 2;
    if (d.c.fitness < 25 && age > 25) health -= 2;
    if (age < 30 && d.c.health < 90) health += 2;
    // Condições
    for (var i = d.x.conditions.length - 1; i >= 0; i--) {
      final c = d.x.conditions[i];
      final controlled = c.treatmentState == TreatmentState.underControl || c.treatmentState == TreatmentState.inRemission;
      if (c.category == ConditionCategory.acute) {
        health -= 3;
        if (ctx.chance(0.6)) {
          d.x.conditions.removeAt(i);
          d.log('health', 'Você se recuperou de ${c.name}.', icon: 'healing', color: '#22C55E');
        }
        continue;
      }
      if (!controlled) {
        health -= c.severity == ConditionSeverity.severe ? 6 : (c.severity == ConditionSeverity.moderate ? 3 : 1);
        if (c.category == ConditionCategory.mentalHealth) d.stats({'happiness': -4});
      }
      if (c.id == 'burnout' && d.c.stress < 40 && ctx.chance(0.5)) {
        d.x.conditions.removeAt(i);
        d.log('health', 'O burnout ficou para trás. Você reencontrou o equilíbrio.', icon: 'self_improvement', color: '#22C55E');
      }
    }
    // Doenças aleatórias leves (além dos eventos)
    if (ctx.chance(age > 60 ? 0.12 : 0.04)) {
      final pool = age > 50 ? ['hypertension', 'back_pain', 'flu'] : ['flu', 'chronic_migraine', 'asthma'];
      addCondition(d, ctx.pick(pool));
    }
    // Condicionamento físico cai sem treino
    final fitDecay = age > 30 ? -2 : -1;
    d.stats({'health': health, 'fitness': fitDecay});
  }
}
