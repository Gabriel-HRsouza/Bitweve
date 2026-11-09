import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/parties/data/party_catalog.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/models/npc_traits.dart';
import 'package:bitweve/features/shop/data/shop_catalog.dart';
import 'life_draft.dart';

/// Festas interativas: tipo, convidados, orçamento, decoração, comida,
/// música, atividades, incidentes e reação individual de cada convidado.
class PartySystem {
  /// Custo estimado do plano.
  static double estimate(LifeEngineState s, PartyPlan plan) {
    final t = PartyCatalog.type(plan.typeId);
    final guests = plan.guestIds.length;
    final decor = PartyCatalog.pick(PartyCatalog.decors, plan.decor).cost;
    final food = PartyCatalog.pick(PartyCatalog.foods, plan.food).cost * (guests + 1);
    final music = PartyCatalog.pick(PartyCatalog.musics, plan.music).cost;
    final act = PartyCatalog.pick(PartyCatalog.activities, plan.activity).cost;
    return ((t.baseCost + decor + food + music + act) * PartyCatalog.budgetMult[plan.budget.clamp(0, 3)]).roundToDouble();
  }

  /// Motivo que impede a festa (ou null).
  static String? blocker(LifeEngineState s, PartyPlan plan) {
    final t = PartyCatalog.type(plan.typeId);
    final age = s.character.currentAge;
    if (s.extras.crime.inPrison) return 'Você está preso(a).';
    if (age < t.minAge) return '${t.name}: a partir de ${t.minAge} anos.';
    if (t.needsProperty && plan.propertyId == null) return 'Esta festa precisa de um imóvel seu.';
    if (plan.propertyId != null && !s.properties.any((p) => p.id == plan.propertyId)) return 'Imóvel inválido.';
    if (plan.guestIds.isEmpty) return 'Convide pelo menos uma pessoa.';
    if (t.vibe == 'luxury' && plan.propertyId != null) {
      final p = s.properties.firstWhere((e) => e.id == plan.propertyId);
      if (!{'mansion', 'penthouse', 'castle', 'beach_house', 'farm'}.contains(p.type)) return 'Festa de luxo exige mansão, cobertura, casa de praia, fazenda ou castelo.';
    }
    if (age < 18 && plan.typeId == 'college') return 'Festa universitária só para maiores.';
    return null;
  }

  static int _capacity(LifeDraft d, String? propertyId) {
    if (propertyId == null) return d.age < 18 ? 12 : 15;
    final p = d.props.where((e) => e.id == propertyId).firstOrNull;
    final l = p == null ? null : ShopCatalog.propertyListingByName(p.name);
    final bedrooms = l?.bedrooms ?? 2;
    return 10 + bedrooms * 8;
  }

  static PartyReport host(LifeDraft d, PartyPlan plan) {
    final st = d.toState();
    final block = blocker(st, plan);
    if (block != null) {
      d.warn('Festa não autorizada', block);
      return PartyReport.empty;
    }
    if (!d.useAction('party', 2) || !d.useEnergy(15)) return PartyReport.empty;
    final t = PartyCatalog.type(plan.typeId);
    final cost = estimate(st, plan);
    // Menores: os pais bancam festas simples
    if (d.age < 18) {
      final parents = d.living((n) => n.isParent);
      final wealth = parents.fold<double>(0, (a, n) => a + n.netWorth);
      if (parents.isEmpty || wealth < cost * 3 || cost > 3000) {
        if (!d.pay(cost, what: 'a festa')) return PartyReport.empty;
      } else {
        for (final p in parents) {
          d.updateNpc(p.copyWith(netWorth: p.netWorth - cost / parents.length));
        }
      }
    } else if (!d.pay(cost, what: 'a festa')) {
      d.x.actionsThisYear['party'] = (d.x.actionsThisYear['party'] ?? 1) - 1;
      return PartyReport.empty;
    }

    final decor = PartyCatalog.pick(PartyCatalog.decors, plan.decor);
    final food = PartyCatalog.pick(PartyCatalog.foods, plan.food);
    final music = PartyCatalog.pick(PartyCatalog.musics, plan.music);
    final act = PartyCatalog.pick(PartyCatalog.activities, plan.activity);
    final propMeta = plan.propertyId != null ? d.x.propMeta(plan.propertyId!) : null;
    final venueBonus = (propMeta?.decorLevel ?? 0) * 3 + (plan.propertyId != null ? 5 : 0);
    var base = decor.quality + food.quality + music.quality + act.quality + venueBonus + plan.budget * 6;
    // Coerência temática
    for (final o in [decor, food, music, act]) {
      if (o.vibe == t.vibe) base += 4;
    }
    final incidents = <String>[];
    // Lotação
    final cap = _capacity(d, plan.propertyId);
    if (plan.guestIds.length > cap) {
      base -= 12;
      incidents.add('A casa ficou lotada demais (capacidade ~$cap pessoas). Fila no banheiro!');
    }
    // Incidentes aleatórios
    final rng = d.ctx;
    if (t.vibe == 'party' && rng.chance(0.25)) {
      incidents.add('Os vizinhos reclamaram do barulho e a polícia pediu para baixar o som.');
      base -= 6;
      d.stats({'reputation': -1});
    }
    if (rng.chance(0.18)) {
      final broken = (cost * 0.15 + 200).roundToDouble();
      incidents.add('Alguém quebrou um vaso caro. Prejuízo de ${Fmt.money(broken)}.');
      d.money(-broken.clamp(0, d.balance.clamp(0, double.infinity)).toDouble());
    }
    if (rng.chance(0.15)) {
      incidents.add('Penetras apareceram sem convite, mas trouxeram animação.');
      base += 3;
    }
    if (rng.chance(0.12)) {
      incidents.add('Começou a chover forte no meio da festa!');
      base -= act.id == 'pool' ? 10 : 4;
    }
    if (rng.chance(0.1)) {
      incidents.add('Um vídeo seu dançando viralizou entre os amigos.');
      d.x.followers += rng.range(20, 200);
    }

    // Reação de cada convidado
    final reactions = <GuestReaction>[];
    var sum = 0;
    for (final id in plan.guestIds) {
      final n = d.npc(id);
      if (n == null || !n.isAlive) continue;
      final traits = NpcTraits.of(n);
      var score = base + (traits.modifierFor('party') * 40).round() + (n.relationshipLevel - 50) ~/ 6 + rng.range(-12, 12);
      if (traits.personality.id == 'partier' && music.quality >= 20) score += 8;
      if (traits.personality.id == 'intellectual' && act.id == 'games') score += 8;
      if (traits.personality.id == 'shy' && plan.guestIds.length > 15) score -= 10;
      if (traits.interests.any((i) => i.id == 'cooking') && food.quality >= 18) score += 6;
      final int mood;
      final String comment;
      if (score >= 75) {
        mood = 2;
        comment = rng.pick(['Melhor festa do ano!', 'Quando é a próxima?!', 'Amei cada segundo!']);
      } else if (score >= 55) {
        mood = 1;
        comment = rng.pick(['Foi muito boa!', 'Curti bastante.', 'A comida estava ótima.']);
      } else if (score >= 35) {
        mood = 0;
        comment = rng.pick(['Foi ok.', 'Legalzinha.', 'Saí cedo, mas foi divertido.']);
      } else {
        mood = -1;
        comment = rng.pick(['Achei meio parada...', 'Fiquei entediado(a).', 'Fui embora cedo.']);
      }
      final delta = mood * 5 + (mood > 0 ? 2 : -1);
      d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + delta, happiness: n.happiness + mood * 3));
      d.addMemory(n.id, 'Fui à ${t.name.toLowerCase()} de ${d.c.firstName}: $comment');
      reactions.add(GuestReaction(n.id, n.fullName, mood, comment));
      sum += score;
    }
    final rating = reactions.isEmpty ? 0 : (sum / reactions.length).round().clamp(0, 100);
    // Romance espontâneo entre adultos
    if (d.age >= 13 && rng.chance(0.15)) {
      final options = d.living((n) => plan.guestIds.contains(n.id) && n.relationshipType == RelationshipType.friend && n.relationshipLevel > 60);
      if (options.isNotEmpty) incidents.add('Rolou um clima entre você e ${rng.pick(options).firstName}...');
    }
    // Popularidade e reputação
    final pop = (rating - 45) ~/ 6 + plan.guestIds.length ~/ 5;
    if (d.x.education.inSchool) {
      d.x.school.popularity = (d.x.school.popularity + pop).clamp(0, 100);
    } else if (d.x.education.inHigherEd) {
      d.x.school.collegePopularity = (d.x.school.collegePopularity + pop).clamp(0, 100);
    }
    d.stats({'happiness': (rating / 8).round(), 'stress': -8, 'reputation': pop ~/ 3, 'charisma': rating > 70 ? 2 : 0});
    if (propMeta != null) propMeta.partiesHosted += 1;
    d.x.bump('partiesHosted');
    d.x.bump('leisure');
    final title = rating >= 75
        ? 'Festa lendária!'
        : rating >= 55
            ? 'Festa de sucesso'
            : rating >= 35
                ? 'Festa morna'
                : 'Festa fracassada';
    final where = plan.propertyId != null ? ' em ${d.props.firstWhere((p) => p.id == plan.propertyId).name}' : '';
    d.log('social', '$title: ${t.name}$where com ${reactions.length} convidado(s). Nota $rating/100 · custo ${Fmt.money(cost)}.',
        icon: 'celebration', color: rating >= 55 ? '#EC4899' : '#64748B');
    d.notify(NoticeKind.social, t.icon, title, message: 'Nota $rating/100', celebrate: rating >= 75, money: -cost);
    d.sfx(rating >= 55 ? GameSfx.party : GameSfx.negativeEvent);
    return PartyReport(title, rating, cost, reactions, incidents, pop, d.x.social.hasAccount);
  }

  // ------------------------------------------------------------------ imóveis
  static void decorate(LifeDraft d, String propertyId, String style) {
    final p = d.props.where((e) => e.id == propertyId).firstOrNull;
    if (p == null || !p.isRealEstate) return;
    final meta = d.x.propMeta(propertyId);
    if (meta.decorLevel >= 5 && meta.decorStyle == style) {
      d.warn('Decoração no máximo');
      return;
    }
    final level = meta.decorStyle == style ? meta.decorLevel + 1 : 1;
    final cost = (p.currentValue * 0.012 * level * (style == 'luxury' ? 2.5 : 1)).roundToDouble().clamp(800.0, 5000000.0).toDouble();
    if (!d.pay(cost, what: 'a decoração')) return;
    meta.decorStyle = style;
    meta.decorLevel = level.clamp(0, 5);
    final i = d.props.indexWhere((e) => e.id == propertyId);
    d.props[i] = p.copyWith(currentValue: p.currentValue + cost * 0.4);
    d.stats({'happiness': 4 + level});
    d.log('lifestyle', 'Você decorou ${p.name} no estilo ${meta.styleLabel} (nível ${meta.decorLevel}).', icon: 'chair', color: '#F59E0B');
    d.notify(NoticeKind.purchase, Icons.chair, 'Decoração ${meta.styleLabel}', message: 'Nível ${meta.decorLevel}/5', money: -cost);
    d.sfx(GameSfx.purchase);
  }
}
