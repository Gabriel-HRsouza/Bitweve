import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/businesses/models/business_model.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'life_draft.dart';

class BusinessSystem {
  static double startupCost(String industry) => switch (industry) {
        'restaurant' => 40000.0,
        'digital_agency' => 12000.0,
        'retail_store' => 18000.0,
        _ => 25000.0,
      };

  static void start(LifeDraft d, String name, String industry) {
    if (d.age < 18) {
      d.warn('Menor de idade', 'Abra uma empresa a partir dos 18 anos.');
      return;
    }
    final cost = startupCost(industry);
    if (!d.pay(cost, what: 'abrir a empresa')) return;
    d.x.businesses.add(BusinessModel(
      id: d.ctx.id(),
      saveId: d.saveId,
      name: name,
      industry: industry,
      valuation: cost * 1.5,
      revenue: cost * 1.2,
      expenses: cost * 0.8,
      employeeCount: 3,
    ));
    d.x.bump('businessesFounded');
    d.stats({'happiness': 12, 'stress': 8});
    d.log('business', 'Você fundou "$name" com ${Fmt.money(cost)} de capital. Agora você é CEO!', icon: 'business_center', color: '#22C55E');
    d.notify(NoticeKind.career, Icons.rocket_launch, 'Empresa fundada!', message: name, celebrate: true, money: -cost);
    d.sfx(GameSfx.achievement);
  }

  static void hire(LifeDraft d, String id) {
    final i = d.x.businesses.indexWhere((b) => b.id == id);
    if (i < 0) return;
    const cost = 6000.0;
    if (!d.pay(cost, what: 'contratar')) return;
    final b = d.x.businesses[i];
    d.x.businesses[i] = b.copyWith(
      employeeCount: b.employeeCount + 2,
      revenue: b.revenue + 15000,
      expenses: b.expenses + 9000,
      valuation: b.valuation + 20000,
    );
    d.log('business', 'Você contratou 2 talentos para "${b.name}".', icon: 'group_add', color: '#3B82F6');
    d.notify(NoticeKind.career, Icons.group_add, 'Equipe ampliada', message: b.name, money: -cost);
    d.sfx(GameSfx.buttonTap);
  }

  static void marketing(LifeDraft d, String id) {
    final i = d.x.businesses.indexWhere((b) => b.id == id);
    if (i < 0) return;
    const cost = 2000.0;
    if (!d.pay(cost, what: 'a campanha')) return;
    final b = d.x.businesses[i];
    d.x.businesses[i] = b.copyWith(
      revenue: b.revenue + 8000,
      reputation: (b.reputation + 8).clamp(0, 100),
      valuation: b.valuation + 12000,
    );
    d.log('business', 'Campanha de marketing para "${b.name}" atraiu novos clientes.', icon: 'campaign', color: '#22C55E');
    d.notify(NoticeKind.career, Icons.campaign, 'Marketing ativado', message: b.name, money: -cost);
    d.sfx(GameSfx.moneyLoss);
  }

  static void sell(LifeDraft d, String id) {
    final i = d.x.businesses.indexWhere((b) => b.id == id);
    if (i < 0) return;
    final b = d.x.businesses.removeAt(i);
    d.money(b.valuation);
    d.stats({'fame': 5, 'happiness': 10});
    d.log('business', 'Exit! Você vendeu "${b.name}" por ${Fmt.money(b.valuation)}.', icon: 'monetization_on', color: '#22C55E');
    d.notify(NoticeKind.money, Icons.monetization_on, 'Empresa vendida!', message: b.name, celebrate: true, money: b.valuation);
    d.sfx(GameSfx.achievement);
  }

  static void yearly(LifeDraft d) {
    if (d.x.businesses.isEmpty) return;
    double total = 0;
    for (var i = 0; i < d.x.businesses.length; i++) {
      final b = d.x.businesses[i];
      final skill = 0.95 + d.c.smarts / 500 + d.c.charisma / 700;
      final rev = (b.revenue * (0.88 + d.ctx.roll() * 0.3) * skill).clamp(1000.0, 500000000.0);
      final exp = (b.expenses * (1.0 + d.ctx.roll() * 0.1)).clamp(500.0, 400000000.0);
      final profit = rev - exp;
      total += profit;
      d.x.businesses[i] = b.copyWith(revenue: rev, expenses: exp, valuation: (rev * 2.5 + profit * 3).clamp(5000.0, 2000000000.0));
    }
    d.money(total);
    d.log('business', 'Relatório anual: suas empresas tiveram resultado de ${Fmt.signedMoney(total)}.', icon: 'business',
        color: total >= 0 ? '#22C55E' : '#EF4444');
  }
}

class CrimeSystem {
  static const crimes = {
    'shoplift': ('Furto em loja', 200.0, 0.25),
    'digital_fraud': ('Golpe digital', 2500.0, 0.40),
    'smuggling': ('Contrabando', 12000.0, 0.60),
    'white_collar': ('Desvio corporativo', 65000.0, 0.75),
  };

  static void attempt(LifeDraft d, String crimeId) {
    final c = crimes[crimeId] ?? crimes['shoplift']!;
    if (d.age < 12) {
      d.warn('Muito jovem');
      return;
    }
    if (!d.useAction('crime', 3)) return;
    final caught = d.ctx.chance(c.$3);
    if (caught) {
      d.c = d.c.copyWith(criminalRecord: true, timesArrested: d.c.timesArrested + 1);
      d.stats({'stress': 30, 'happiness': -20, 'reputation': -25, 'karma': -10});
      final fine = (c.$2 * 0.5).clamp(300.0, 50000.0);
      d.money(-fine.clamp(0.0, d.c.bankBalance.clamp(0.0, double.infinity)).toDouble());
      d.log('crime', 'Você foi preso(a) em flagrante tentando ${c.$1.toLowerCase()}! Ficha criminal registrada.', icon: 'local_police', color: '#EF4444');
      d.notify(NoticeKind.warning, Icons.local_police, 'Você foi preso(a)!', message: c.$1);
      d.sfx(GameSfx.negativeEvent);
      if (d.c.currentJobTitle != null && d.ctx.chance(0.6)) {
        d.c = d.c.copyWith(clearJob: true);
        d.x.careerLevel = 0;
        d.log('career', 'Você perdeu o emprego por causa da prisão.', icon: 'work_off', color: '#EF4444');
      }
    } else {
      d.money(c.$2);
      d.stats({'karma': -10, 'stress': 8});
      d.log('crime', 'Você conseguiu: ${c.$1.toLowerCase()} rendeu ${Fmt.money(c.$2)}.', icon: 'vpn_key', color: '#F59E0B');
      d.notify(NoticeKind.money, Icons.vpn_key, 'Golpe bem-sucedido', message: c.$1, money: c.$2);
      d.sfx(GameSfx.moneyGain);
    }
  }

  static void appeal(LifeDraft d) {
    if (!d.c.criminalRecord) return;
    const cost = 15000.0;
    if (!d.pay(cost, what: 'os advogados')) return;
    d.c = d.c.copyWith(criminalRecord: false, reputation: d.c.reputation + 15);
    d.log('justice', 'Seus advogados anularam a condenação. Ficha limpa!', icon: 'gavel', color: '#22C55E');
    d.notify(NoticeKind.info, Icons.gavel, 'Ficha limpa!', celebrate: true, money: -cost);
    d.sfx(GameSfx.achievement);
  }
}

class GodModeSystem {
  static void addMoney(LifeDraft d, double amount) {
    d.money(amount);
    d.log('god_mode', 'Modo Deus: ${Fmt.money(amount)} adicionados ao saldo.', icon: 'bolt', color: '#FFC53D');
    d.notify(NoticeKind.money, Icons.bolt, 'Modo Deus', message: Fmt.money(amount), money: amount);
    d.sfx(GameSfx.moneyGain);
  }

  static void setStats(LifeDraft d, {int? health, int? happiness, int? smarts, int? looks}) {
    d.c = d.c.copyWith(health: health, happiness: happiness, smarts: smarts, looks: looks);
    d.log('god_mode', 'Modo Deus: atributos reconfigurados.', icon: 'auto_awesome', color: '#FFC53D');
    d.notify(NoticeKind.info, Icons.auto_awesome, 'Atributos alterados');
    d.sfx(GameSfx.achievement);
  }

  static void cureAll(LifeDraft d) {
    d.x.conditions.clear();
    d.c = d.c.copyWith(health: 100, stress: 0);
    d.log('god_mode', 'Modo Deus: cura total.', icon: 'healing', color: '#22C55E');
    d.notify(NoticeKind.health, Icons.healing, 'Cura total');
    d.sfx(GameSfx.achievement);
  }

  static void clearRecord(LifeDraft d) {
    d.c = d.c.copyWith(criminalRecord: false, timesArrested: 0);
    d.log('god_mode', 'Modo Deus: ficha criminal apagada.', icon: 'cleaning_services', color: '#22C55E');
    d.notify(NoticeKind.info, Icons.cleaning_services, 'Ficha apagada');
  }

  static void jackpot(LifeDraft d) {
    const jackpot = 12500000.0;
    d.money(jackpot);
    d.c = d.c.copyWith(happiness: 100);
    d.x.bump('bigWins');
    d.log('god_mode', 'Modo Deus: prêmio máximo da loteria de ${Fmt.money(jackpot)}!', icon: 'casino', color: '#FFC53D');
    d.notify(NoticeKind.money, Icons.casino, 'JACKPOT!', celebrate: true, money: jackpot);
    d.sfx(GameSfx.lotteryWin);
  }
}
