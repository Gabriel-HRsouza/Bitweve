import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/events/data/event_catalog.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'career_system.dart';
import 'fame_system.dart';
import 'health_system.dart';
import 'life_draft.dart';
import 'relationship_system.dart';
import 'shop_system.dart';

class EventSystem {
  static const _rarityWeight = {'common': 1.0, 'uncommon': 0.6, 'rare': 0.35, 'legendary': 0.12};

  static List<LifeEvent> allEvents(EngineContext ctx) => [...ctx.jsonEvents, ...EventCatalog.events];

  static bool _requirement(LifeDraft d, String r) {
    final c = d.c;
    switch (r) {
      case 'job':
        return c.currentJobTitle != null;
      case 'noJob':
        return c.currentJobTitle == null;
      case 'partner':
        return d.partner != null;
      case 'dating':
        return d.living((n) => n.relationshipType == RelationshipType.partner).isNotEmpty;
      case 'single':
        return d.partner == null;
      case 'married':
        return c.isMarried && d.partner != null;
      case 'student':
        return d.x.education.isStudying;
      case 'university':
        return d.x.education.inHigherEd;
      case 'famous':
        return c.fame >= 35 || d.x.followers >= 20000;
      case 'rich':
        return c.bankBalance >= 200000;
      case 'poor':
        return c.bankBalance < 5000;
      case 'parents':
        return d.living((n) => n.isParent).length >= 2;
      case 'siblings':
        return d.living((n) => n.isSibling).isNotEmpty;
      case 'children':
        return d.living((n) => n.isChild).isNotEmpty;
      case 'friends':
        return d.living((n) => n.relationshipType == RelationshipType.friend).isNotEmpty;
      case 'adult':
        return c.currentAge >= 18;
      case 'criminal':
        return c.criminalRecord;
      case 'hasCar':
        return d.x.vehicles.isNotEmpty;
      case 'indebted':
        return c.debt > 0 || d.x.loans.isNotEmpty;
      case 'sick':
        return d.x.conditions.isNotEmpty;
    }
    return true;
  }

  static List<NpcModel> _targets(LifeDraft d, String target) {
    switch (target) {
      case 'parent':
        return d.living((n) => n.isParent);
      case 'sibling':
        return d.living((n) => n.isSibling);
      case 'family':
        return d.living((n) => n.isFamily && !n.isRomantic);
      case 'friend':
        return d.living((n) => n.relationshipType == RelationshipType.friend);
      case 'partner':
        return d.living((n) => n.relationshipType == RelationshipType.partner || n.relationshipType == RelationshipType.spouse);
      case 'spouse':
        return d.living((n) => n.relationshipType == RelationshipType.spouse);
      case 'child':
        return d.living((n) => n.isChild && n.age >= 5);
      case 'coworker':
        return d.living((n) => n.relationshipType == RelationshipType.coworker);
      case 'boss':
        return d.living((n) => n.relationshipType == RelationshipType.boss);
      case 'crush':
        return d.living((n) => n.relationshipType == RelationshipType.crush);
      case 'rival':
        return d.living((n) => n.relationshipType == RelationshipType.rival);
      case 'ex':
        return d.living((n) => n.relationshipType == RelationshipType.exPartner);
      default:
        return d.living((n) => true);
    }
  }

  /// Sorteia até [max] eventos para o ano atual.
  static void rollYear(LifeDraft d, {int max = 2}) {
    final ctx = d.ctx;
    final picked = <PendingEvent>[];
    final probs = [0.78, 0.3];
    for (var k = 0; k < max; k++) {
      if (!ctx.chance(probs[k.clamp(0, probs.length - 1)])) break;
      final candidates = <(LifeEvent, NpcModel?, double)>[];
      for (final e in allEvents(ctx)) {
        if (d.age < e.minAge || d.age > e.maxAge) continue;
        if (picked.any((p) => p.event.id == e.id)) continue;
        final last = d.x.counters['ev:${e.id}'];
        if (last != null && d.age - last < (e.rarity == 'legendary' ? 40 : 7)) continue;
        if (!e.requires.every((r) => _requirement(d, r))) continue;
        NpcModel? target;
        if (e.target != null) {
          final list = _targets(d, e.target!);
          if (list.isEmpty) continue;
          target = ctx.pick(list);
        }
        candidates.add((e, target, e.weight * (_rarityWeight[e.rarity] ?? 1.0)));
      }
      if (candidates.isEmpty) break;
      final total = candidates.fold<double>(0, (s, c) => s + c.$3);
      var r = ctx.roll() * total;
      var chosen = candidates.first;
      for (final c in candidates) {
        r -= c.$3;
        if (r <= 0) {
          chosen = c;
          break;
        }
      }
      final ev = chosen.$2 == null ? chosen.$1 : chosen.$1.personalize(chosen.$2!.fullName, chosen.$2!.relationLabel);
      picked.add(PendingEvent(ev, targetNpcId: chosen.$2?.id));
      d.x.counters['ev:${chosen.$1.id}'] = d.age;
    }
    d.pending = [...d.pending, ...picked];
  }

  static void resolve(LifeDraft d, int choiceIndex) {
    if (d.pending.isEmpty) return;
    final pe = d.pending.first;
    d.pending = d.pending.sublist(1);
    final ev = pe.event;
    if (choiceIndex < 0 || choiceIndex >= ev.choices.length) return;
    final ch = ev.choices[choiceIndex];

    final before = d.snapshot();
    final moneyBefore = d.c.bankBalance;
    final followersBefore = d.x.followers;

    var luck = 0.0;
    if (d.x.traits.contains('lucky')) luck += 0.12;
    luck += (d.c.karma - 50) / 800;
    final success = ch.chance == null || d.ctx.chance((ch.chance! + luck).clamp(0.02, 0.98));

    // Efeitos clássicos (events.json)
    d.stats({
      'health': ch.healthDelta,
      'happiness': ch.happinessDelta,
      'smarts': ch.smartsDelta,
      'looks': ch.looksDelta,
      'karma': ch.karmaDelta,
      'stress': ch.stressDelta,
      'reputation': ch.reputationDelta,
    });
    if (ch.moneyDelta != 0) d.money(ch.moneyDelta);

    final fx = success ? ch.effects : ch.failEffects;
    final text = success ? ch.resultText : (ch.failText ?? ch.resultText);
    applyEffects(d, fx, pe.targetNpcId);

    d.x.bump('eventsResolved');
    if (ev.rarity == 'rare' || ev.rarity == 'legendary') d.x.bump('rareEvents');

    final after = d.snapshot();
    final deltas = <String, num>{};
    for (final k in after.keys) {
      final dv = after[k]! - (before[k] ?? 0);
      if (dv != 0) deltas[k] = dv;
    }
    final dm = d.c.bankBalance - moneyBefore;
    if (dm.abs() >= 1) deltas['money'] = dm;
    final df = d.x.followers - followersBefore;
    if (df != 0) deltas['followers'] = df;

    d.outcome = EventOutcome(title: ev.title, text: text, success: success, deltas: deltas);
    final good = success && (dm >= 0) && (deltas['happiness'] ?? 0) >= 0;
    d.log('event_result', '${ev.title}: $text', icon: good ? 'verified' : 'warning', color: good ? '#22C55E' : '#EF4444');
    d.sfx(good ? GameSfx.positiveEvent : GameSfx.negativeEvent);
    if (pe.targetNpcId != null) d.addMemory(pe.targetNpcId!, '${ev.title} — $text');
  }

  /// Aplica o mapa de efeitos de uma escolha de evento.
  static void applyEffects(LifeDraft d, Map<String, dynamic> fx, String? targetId) {
    if (fx.isEmpty) return;
    final ctx = d.ctx;
    final statFx = <String, num>{};
    for (final k in LifeDraft.statKeys) {
      if (fx[k] is num) statFx[k] = fx[k] as num;
    }
    d.stats(statFx);

    if (fx['money'] is num) d.money((fx['money'] as num).toDouble());
    if (fx['moneyPct'] is num && d.c.bankBalance > 0) d.money(d.c.bankBalance * (fx['moneyPct'] as num).toDouble());
    if (fx['followers'] is num) d.x.followers = (d.x.followers + (fx['followers'] as num).toInt()).clamp(0, 2000000000);
    if (fx['debt'] is num) d.c = d.c.copyWith(debt: d.c.debt + (fx['debt'] as num).toDouble());
    if (fx['inheritance'] is List) {
      final l = (fx['inheritance'] as List).cast<num>();
      final v = (l[0] + ctx.roll() * (l[1] - l[0])).roundToDouble();
      d.money(v);
      d.notify(NoticeKind.money, Icons.account_balance_wallet, 'Herança!', message: Fmt.money(v), celebrate: true, money: v);
    }

    final target = targetId == null ? null : d.npc(targetId);
    if (fx['rel'] is num && target != null) {
      d.updateNpc(target.copyWith(relationshipLevel: target.relationshipLevel + (fx['rel'] as num).toInt()));
    }
    if (fx['relAll'] is num) {
      final v = (fx['relAll'] as num).toInt();
      d.npcs = d.npcs.map((n) => n.isAlive && n.isFamily ? n.copyWith(relationshipLevel: n.relationshipLevel + v) : n).toList();
    }
    if (fx['addNpc'] is String) {
      final kind = fx['addNpc'] as String;
      final type = switch (kind) {
        'rival' => RelationshipType.rival,
        'crush' => RelationshipType.crush,
        'partner' => RelationshipType.partner,
        'classmate' => RelationshipType.classmate,
        'coworker' => RelationshipType.coworker,
        _ => RelationshipType.friend,
      };
      final romantic = type == RelationshipType.partner || type == RelationshipType.crush;
      if (type == RelationshipType.partner && d.partner != null) {
        // já tem parceiro: vira paquera
      } else {
        final n = d.makeNpc(
          type: type,
          gender: romantic ? d.romanticGender() : null,
          age: (d.age + ctx.range(-2, 2)).clamp(d.age < 18 ? d.age - 1 : 16, 99),
          level: type == RelationshipType.rival ? 15 : (romantic ? 65 : 55),
        );
        d.npcs.add(n);
        if (type == RelationshipType.friend) d.x.bump('friendsMade');
        if (type == RelationshipType.partner) {
          d.x.bump('relationshipsStarted');
          d.c = d.c.copyWith(partnerId: n.id);
        }
      }
    }
    if (fx['removeTarget'] == true && target != null) d.npcs.removeWhere((n) => n.id == target.id);
    if (fx['partnerFromTarget'] == true && target != null && d.partner == null) {
      d.updateNpc(target.copyWith(relationshipType: RelationshipType.partner, relationshipLevel: target.relationshipLevel + 20));
      d.c = d.c.copyWith(partnerId: target.id);
      d.x.bump('relationshipsStarted');
    }
    if (fx['marryTarget'] == true && target != null) {
      d.updateNpc(target.copyWith(relationshipType: RelationshipType.spouse, relationshipLevel: target.relationshipLevel + 20));
      d.c = d.c.copyWith(isMarried: true, partnerId: target.id);
      d.notify(NoticeKind.family, Icons.favorite, 'Casamento!', message: 'Você se casou com ${target.fullName}', celebrate: true);
      d.sfx(GameSfx.wedding);
    }
    if (fx['breakUp'] == true) {
      final p = d.partner;
      if (p != null) {
        d.updateNpc(p.copyWith(relationshipType: RelationshipType.exPartner, relationshipLevel: p.relationshipLevel - 40));
        d.c = d.c.copyWith(isMarried: false, clearPartner: true);
      }
    }
    if (fx['baby'] == true) {
      final baby = RelationshipSystem.addChild(d, d.partner);
      d.notify(NoticeKind.family, Icons.child_friendly, 'Nasceu ${baby.firstName}!', celebrate: true);
    }
    if (fx['sibling'] == true) {
      final g = ctx.gender();
      final sib = d.makeNpc(
        type: g == 'male' ? RelationshipType.brother : RelationshipType.sister,
        gender: g,
        age: 0,
        lastName: d.c.lastName,
        level: 70,
        occupation: 'Bebê',
      );
      d.npcs.add(sib);
      d.log('family', 'Nasceu ${sib.firstName}, seu/sua novo(a) irmão(ã)!', icon: 'child_friendly', color: '#22D3EE');
    }
    if (fx['parentsDivorce'] == true) {
      final parents = d.living((n) => n.isParent);
      for (final p in parents) {
        d.updateNpc(p.copyWith(happiness: p.happiness - 15, memories: [...p.memories, 'Divorciou-se.']));
      }
      d.x.counters['parentsDivorced'] = 1;
    }
    if (fx['parentsReunite'] == true) d.x.counters.remove('parentsDivorced');

    if (fx['loseJob'] == true) CareerSystem.fire(d, 'decisão da empresa');
    if (fx['promote'] == true) CareerSystem.promoteFromEvent(d);
    if (fx['raisePct'] is num && d.c.currentSalary != null) {
      d.c = d.c.copyWith(currentSalary: d.c.currentSalary! * (1 + (fx['raisePct'] as num).toDouble()));
    }
    if (fx['performance'] is num) d.c = d.c.copyWith(jobPerformance: d.c.jobPerformance + (fx['performance'] as num).toInt());

    if (fx['condition'] is String) HealthSystem.addCondition(d, fx['condition'] as String);
    if (fx['cure'] == true) HealthSystem.cureOne(d);
    if (fx['item'] is String) ShopSystem.giftItem(d, fx['item'] as String);
    if (fx['arrest'] == true) d.c = d.c.copyWith(criminalRecord: true, timesArrested: d.c.timesArrested + 1);
    if (fx['license'] == true) d.c = d.c.copyWith(hasDriversLicense: true);
    if (fx['course'] is String && !d.x.education.courses.contains(fx['course'])) d.x.education.courses.add(fx['course'] as String);
    if (fx['pet'] is String) {
      d.x.pets.add(Pet(id: ctx.id(), name: ctx.pick(['Pipoca', 'Thor', 'Luna', 'Mel', 'Bolt', 'Nina']), type: fx['pet'] as String));
    }
    if (fx['relocate'] == true) {
      final cities = ((ctx.countryByName(d.c.country)['cities'] as List?) ?? const []).cast<String>().where((c) => c != d.c.city).toList();
      if (cities.isNotEmpty) {
        final city = ctx.pick(cities);
        d.c = d.c.copyWith(city: city);
        d.log('family', 'Mudança: sua família agora mora em $city.', icon: 'local_shipping', color: '#7C5CFF');
      }
    }
    if (fx['sponsorship'] is List) {
      final l = fx['sponsorship'] as List;
      d.x.sponsorships.add(Sponsorship(brand: l[0] as String, annualPay: (l[1] as num).toDouble(), yearsLeft: (l[2] as num).toInt()));
    }
    if (fx['headline'] is String) FameSystem.addHeadline(d, fx['headline'] as String);
  }
}
