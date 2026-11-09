import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/models/npc_traits.dart';
import 'package:bitweve/features/relationships/romance_rules.dart';
import 'life_draft.dart';
import 'school_system.dart';

/// Ação disponível para um NPC (usada pela UI para montar os botões).
class NpcAction {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final double cost;
  const NpcAction(this.id, this.label, this.icon, this.color, [this.cost = 0]);
}

class RelationshipSystem {
  static const _actions = {
    'talk': NpcAction('talk', 'Conversar', Icons.chat_bubble, Color(0xFF3B82F6)),
    'compliment': NpcAction('compliment', 'Elogiar', Icons.thumb_up, Color(0xFF22C55E)),
    'gift': NpcAction('gift', 'Presentear', Icons.card_giftcard, Color(0xFFF59E0B), 150),
    'hangout': NpcAction('hangout', 'Sair juntos', Icons.local_cafe, Color(0xFF14B8A6), 120),
    'apologize': NpcAction('apologize', 'Pedir desculpas', Icons.handshake, Color(0xFF10B981)),
    'argue': NpcAction('argue', 'Discutir', Icons.flash_on, Color(0xFFEF4444)),
    'befriend': NpcAction('befriend', 'Fazer amizade', Icons.person_add, Color(0xFFEC4899)),
    'flirt': NpcAction('flirt', 'Flertar', Icons.favorite_border, Color(0xFFFF4F9A)),
    'askOut': NpcAction('askOut', 'Pedir em namoro', Icons.favorite, Color(0xFFFF4F9A)),
    'propose': NpcAction('propose', 'Pedir em casamento', Icons.diamond, Color(0xFFA855F7), 6000),
    'haveBaby': NpcAction('haveBaby', 'Ter um filho', Icons.child_friendly, Color(0xFF22D3EE)),
    'breakUp': NpcAction('breakUp', 'Terminar', Icons.heart_broken, Color(0xFF64748B)),
    'divorce': NpcAction('divorce', 'Divorciar', Icons.gavel, Color(0xFF64748B)),
    'askMoney': NpcAction('askMoney', 'Pedir dinheiro', Icons.payments, Color(0xFF22C55E)),
    'playTogether': NpcAction('playTogether', 'Brincar juntos', Icons.toys, Color(0xFFF97316)),
    'insult': NpcAction('insult', 'Provocar', Icons.sentiment_very_dissatisfied, Color(0xFFEF4444)),
    'reconcile': NpcAction('reconcile', 'Fazer as pazes', Icons.emoji_people, Color(0xFF10B981)),
    'joke': NpcAction('joke', 'Fazer brincadeira', Icons.sentiment_very_satisfied, Color(0xFFF59E0B)),
    'inviteParty': NpcAction('inviteParty', 'Convidar p/ festa', Icons.celebration, Color(0xFFEC4899), 80),
    'wakeUp': NpcAction('wakeUp', 'Acordar', Icons.alarm, Color(0xFF0EA5E9)),
    'intimacy': NpcAction('intimacy', 'Momento a dois', Icons.nights_stay, Color(0xFFBE185D)),
    'block': NpcAction('block', 'Bloquear', Icons.block, Color(0xFF475569)),
    'unblock': NpcAction('unblock', 'Desbloquear', Icons.lock_open, Color(0xFF22C55E)),
    'askHelp': NpcAction('askHelp', 'Pedir ajuda na matéria', Icons.school, Color(0xFF3B82F6)),
    'suckUp': NpcAction('suckUp', 'Puxar o saco', Icons.thumb_up_alt, Color(0xFF22C55E)),
    'reviewGrade': NpcAction('reviewGrade', 'Pedir revisão de nota', Icons.rate_review, Color(0xFF6366F1)),
    'confront': NpcAction('confront', 'Confrontar', Icons.flash_on, Color(0xFFEF4444)),
  };

  static const _teacherActions = {'askHelp', 'suckUp', 'reviewGrade', 'confront'};

  static NpcAction action(String id) => _actions[id]!;

  /// Ações disponíveis conforme o tipo de relação, idade e bloqueio.
  static List<NpcAction> actionsFor(NpcModel n, int myAge, {bool blocked = false}) {
    if (!n.isAlive) return const [];
    if (blocked) return [action('unblock')];
    final t = n.relationshipType;
    if (t == RelationshipType.teacher) {
      return [for (final id in ['talk', 'compliment', 'askHelp', 'suckUp', 'reviewGrade', 'confront', 'apologize']) action(id)];
    }
    final ids = <String>['talk', 'compliment', 'joke'];
    if (myAge >= 6) ids.add('gift');
    if (myAge >= 8) ids.add('hangout');
    if (myAge >= 10 && !n.isParent && !n.isGrandparent) ids.add('inviteParty');
    ids.add('apologize');
    if (t == RelationshipType.classmate || t == RelationshipType.coworker || t == RelationshipType.exPartner ||
        t == RelationshipType.collegeMate || t == RelationshipType.inmate || t == RelationshipType.crush) {
      ids.add('befriend');
    }
    if (t == RelationshipType.rival || t == RelationshipType.exPartner) {
      ids
        ..remove('compliment')
        ..add('reconcile');
      if (t == RelationshipType.rival) ids.add('insult');
    }
    if (n.isParent && myAge >= 6) ids.add('askMoney');
    if ((n.isChild || n.isSibling) && n.age < 14) ids.add('playTogether');
    if (n.isFamily || t == RelationshipType.partner) ids.add('wakeUp');
    final eligibleRomance = RomanceRules.romanceAllowed(myAge, n.age) && !n.isFamily;
    if (eligibleRomance && (t == RelationshipType.friend || t == RelationshipType.crush || t == RelationshipType.classmate ||
        t == RelationshipType.coworker || t == RelationshipType.exPartner || t == RelationshipType.collegeMate)) {
      ids.add('flirt');
      ids.add('askOut');
    }
    if (t == RelationshipType.partner) {
      if (myAge >= 18) ids.add('propose');
      if (myAge >= 18 && n.age >= 18) ids.add('haveBaby');
      ids.add('breakUp');
    }
    if (t == RelationshipType.spouse) {
      ids.add('haveBaby');
      ids.add('divorce');
    }
    if ((t == RelationshipType.partner || t == RelationshipType.spouse) && RomanceRules.intimacyAllowed(myAge, n.age)) {
      ids.add('intimacy');
    }
    ids.add('argue');
    if (!n.isParent || myAge >= 18) ids.add('block');
    return ids.map(action).toList();
  }

  /// Chance-base de a pessoa topar uma ação social (antes da lógica específica).
  static double _acceptance(LifeDraft d, NpcModel n, String actionId) {
    final t = NpcTraits.of(n);
    final base = switch (actionId) {
      'talk' => 0.82,
      'compliment' => 0.8,
      'joke' => 0.62,
      'gift' => 0.88,
      'hangout' => 0.7,
      'inviteParty' => 0.6,
      'wakeUp' => 0.55,
      _ => 1.0,
    };
    if (base >= 1.0) return 1.0;
    var p = base + (n.relationshipLevel - 50) / 220 + d.c.charisma / 600 + t.modifierFor(actionId == 'inviteParty' ? 'party' : actionId);
    if (n.happiness < 35) p -= 0.12;
    if (n.isFamily) p += 0.1;
    if (n.relationshipType == RelationshipType.rival) p -= 0.25;
    return p.clamp(0.05, 0.97);
  }

  static String _refusal(LifeDraft d, NpcModel n, String actionId) {
    final t = NpcTraits.of(n);
    final who = n.fullName;
    return switch (actionId) {
      'talk' => d.ctx.pick(['$who respondeu com monossílabos e voltou a olhar o celular.', '$who disse que não estava a fim de conversar agora.']),
      'compliment' => t.personality.id == 'sarcastic'
          ? '$who revirou os olhos: "Nossa, que original."'
          : '$who ficou sem graça com o elogio e mudou de assunto.',
      'joke' => d.ctx.pick(['$who não achou a menor graça e ficou irritado(a).', 'A brincadeira pegou mal: $who ficou chateado(a).']),
      'gift' => '$who agradeceu, mas claramente não gostou do presente.',
      'hangout' => d.ctx.pick(['$who recusou o convite: "Hoje não dá."', '$who disse que já tinha compromisso.']),
      'inviteParty' => '$who agradeceu o convite para a festa, mas não vai poder ir.',
      'wakeUp' => '$who acordou de mau humor e jogou o travesseiro em você!',
      _ => '$who não reagiu bem.',
    };
  }

  static void setNickname(LifeDraft d, String npcId, String nickname) {
    final n = d.npc(npcId);
    if (n == null) return;
    final nick = nickname.trim();
    d.x.meta(npcId).nickname = nick.isEmpty ? null : (nick.length > 24 ? nick.substring(0, 24) : nick);
    d.notify(NoticeKind.info, Icons.edit, 'Perfil atualizado', message: nick.isEmpty ? n.fullName : '“$nick”');
  }

  // ------------------------------------------------------------------ interação
  static void interact(LifeDraft d, String npcId, String actionId) {
    final n = d.npc(npcId);
    if (n == null || !n.isAlive) return;
    if (d.x.crime.inPrison && n.relationshipType != RelationshipType.inmate && !n.isFamily && !n.isRomantic) {
      d.warn('Você está preso(a)', 'Só dá para falar com familiares, parceiro(a) e colegas de cela.');
      return;
    }
    final meta = d.x.meta(npcId);
    if (actionId == 'unblock') {
      meta.blocked = false;
      d.log('social', 'Você desbloqueou ${n.fullName}.', icon: 'lock_open', color: '#22C55E');
      d.notify(NoticeKind.social, Icons.lock_open, 'Desbloqueado(a)', message: n.fullName);
      return;
    }
    if (meta.blocked) {
      d.warn('Pessoa bloqueada', 'Desbloqueie para interagir.');
      return;
    }
    if (actionId == 'block') {
      meta.blocked = true;
      var type = n.relationshipType;
      if (type == RelationshipType.partner || type == RelationshipType.crush) {
        type = RelationshipType.exPartner;
        if (d.c.partnerId == n.id) d.c = d.c.copyWith(clearPartner: true);
      }
      d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel - 30, relationshipType: type));
      meta.addHistory('Aos ${d.age}: você bloqueou esta pessoa');
      d.log('social', 'Você bloqueou ${n.fullName}. Paz de espírito.', icon: 'block', color: '#475569');
      d.notify(NoticeKind.social, Icons.block, 'Bloqueado(a)', message: n.fullName);
      return;
    }
    if (_teacherActions.contains(actionId)) {
      SchoolSystem.teacherAction(d, npcId, actionId);
      return;
    }
    if (!d.useAction('npc:$npcId', 4)) return;
    final a = action(actionId);
    // Reação conforme personalidade, humor e afinidade
    final accept = _acceptance(d, n, actionId);
    if (accept < 1.0 && !d.ctx.chance(accept)) {
      if (actionId == 'gift' && !d.pay(a.cost, what: a.label.toLowerCase())) return;
      final text = _refusal(d, n, actionId);
      final harsh = actionId == 'joke' || actionId == 'wakeUp';
      final drop = harsh ? -d.ctx.range(4, 9) : -d.ctx.range(1, 4);
      d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + drop));
      meta.lastMood = harsh ? -2 : -1;
      meta.addHistory('Aos ${d.age}: $text');
      d.addMemory(n.id, text);
      d.stats({'happiness': -2});
      d.log('social', text, icon: 'sentiment_dissatisfied', color: '#64748B');
      d.notify(NoticeKind.social, Icons.sentiment_dissatisfied, '${a.label}: não rolou', message: text);
      d.sfx(GameSfx.negativeEvent);
      return;
    }
    meta.lastMood = 1;
    if (a.cost > 0 && !d.pay(a.cost, what: a.label.toLowerCase())) {
      d.x.actionsThisYear['npc:$npcId'] = (d.x.actionsThisYear['npc:$npcId'] ?? 1) - 1;
      return;
    }
    d.x.bump('npcInteractions');
    final ctx = d.ctx;
    int rel = 0;
    int happy = 0;
    String text = '';
    String icon = 'chat_bubble';
    String color = '#3B82F6';
    var type = n.relationshipType;
    var notice = NoticeKind.social;
    bool celebrate = false;

    switch (actionId) {
      case 'talk':
        rel = ctx.range(4, 10);
        happy = 3;
        text = ctx.pick([
          'Você bateu um papo sincero com ${n.fullName} sobre a vida.',
          'Você e ${n.fullName} riram muito relembrando histórias antigas.',
          '${n.fullName} te contou um segredo. A confiança entre vocês cresceu.',
        ]);
        d.sfx(GameSfx.buttonTap);
        break;
      case 'compliment':
        rel = ctx.range(6, 12);
        happy = 4;
        text = 'Você elogiou ${n.fullName}, que abriu um sorriso enorme.';
        icon = 'thumb_up';
        color = '#22C55E';
        d.sfx(GameSfx.positiveEvent);
        break;
      case 'gift':
        rel = ctx.range(12, 22);
        happy = 6;
        text = 'Você presenteou ${n.fullName} com algo especial. Foi um sucesso!';
        icon = 'card_giftcard';
        color = '#F59E0B';
        d.sfx(GameSfx.purchase);
        break;
      case 'hangout':
        rel = ctx.range(10, 18);
        happy = 10;
        d.stats({'stress': -6});
        text = ctx.pick([
          'Você e ${n.fullName} foram ao cinema e depois comeram pizza.',
          'Um passeio no parque com ${n.fullName} renovou as energias.',
          'Vocês passaram a tarde num café conversando por horas.',
        ]);
        icon = 'local_cafe';
        color = '#14B8A6';
        d.sfx(GameSfx.positiveEvent);
        break;
      case 'apologize':
        rel = n.relationshipLevel < 50 ? ctx.range(10, 20) : 3;
        happy = 3;
        d.stats({'karma': 2});
        text = 'Você pediu desculpas a ${n.fullName}. O clima ficou mais leve.';
        icon = 'handshake';
        color = '#10B981';
        break;
      case 'argue':
        rel = -ctx.range(12, 22);
        happy = -6;
        d.stats({'stress': 6});
        text = 'Você discutiu feio com ${n.fullName}. Palavras duras foram ditas.';
        icon = 'error';
        color = '#EF4444';
        d.sfx(GameSfx.negativeEvent);
        if (n.relationshipLevel + rel < 15 && !n.isFamily && type != RelationshipType.rival) {
          type = RelationshipType.rival;
          text += ' Agora vocês são inimigos.';
        }
        break;
      case 'insult':
        rel = -ctx.range(10, 18);
        d.stats({'karma': -4, 'happiness': 2});
        text = 'Você provocou ${n.fullName} na frente de todos.';
        icon = 'error';
        color = '#EF4444';
        break;
      case 'reconcile':
        if (ctx.chance(0.35 + n.relationshipLevel / 200 + d.c.charisma / 300)) {
          type = RelationshipType.friend;
          rel = 25;
          text = 'Você e ${n.fullName} fizeram as pazes. Inimizade enterrada!';
          icon = 'emoji_people';
          color = '#10B981';
          d.x.bump('friendsMade');
          d.stats({'karma': 6});
        } else {
          rel = -3;
          text = '${n.fullName} recusou a trégua.';
          icon = 'block';
          color = '#64748B';
        }
        break;
      case 'befriend':
        if (ctx.chance(0.45 + n.relationshipLevel / 200 + d.c.charisma / 250)) {
          if (type != RelationshipType.friend) {
            type = RelationshipType.friend;
            d.x.bump('friendsMade');
          }
          rel = 15;
          happy = 6;
          text = 'Você e ${n.fullName} agora são amigos!';
          icon = 'person_add';
          color = '#EC4899';
          d.sfx(GameSfx.positiveEvent);
        } else {
          rel = -2;
          text = '${n.fullName} foi educado(a), mas não pareceu muito interessado(a) em amizade.';
          icon = 'person_off';
          color = '#64748B';
        }
        break;
      case 'flirt':
        final p = 0.35 + d.c.looks / 250 + d.c.charisma / 250 + d.c.fame / 400;
        if (ctx.chance(p)) {
          rel = ctx.range(8, 16);
          happy = 6;
          if (type != RelationshipType.partner && type != RelationshipType.spouse) type = RelationshipType.crush;
          text = 'Você flertou com ${n.fullName} e rolou um clima!';
          icon = 'favorite_border';
          color = '#FF4F9A';
        } else {
          rel = -5;
          happy = -3;
          text = '${n.fullName} não correspondeu ao flerte. Climão.';
          icon = 'heart_broken';
          color = '#64748B';
        }
        break;
      case 'askOut':
        if (d.partner != null) {
          d.warn('Você já está num relacionamento', 'Termine o atual antes de começar outro.');
          return;
        }
        final p = 0.15 + n.relationshipLevel / 140 + d.c.looks / 400 + d.c.charisma / 400;
        if (ctx.chance(p)) {
          type = RelationshipType.partner;
          rel = 20;
          happy = 18;
          text = '${n.fullName} disse SIM! Vocês estão namorando.';
          icon = 'favorite';
          color = '#FF4F9A';
          celebrate = true;
          d.x.bump('relationshipsStarted');
          d.c = d.c.copyWith(partnerId: n.id);
          d.sfx(GameSfx.wedding);
        } else {
          rel = -8;
          happy = -8;
          text = '${n.fullName} disse que prefere manter só a amizade.';
          icon = 'heart_broken';
          color = '#64748B';
          d.sfx(GameSfx.negativeEvent);
        }
        break;
      case 'propose':
        if (n.relationshipLevel >= 70 && ctx.chance(0.6 + n.relationshipLevel / 400)) {
          type = RelationshipType.spouse;
          rel = 25;
          happy = 30;
          text = 'Você pediu ${n.fullName} em casamento e ouviu um SIM emocionado! Vocês se casaram.';
          icon = 'favorite';
          color = '#A855F7';
          celebrate = true;
          notice = NoticeKind.family;
          d.c = d.c.copyWith(isMarried: true, partnerId: n.id);
          d.sfx(GameSfx.wedding);
        } else {
          rel = -10;
          happy = -12;
          text = '${n.fullName} disse que ainda não está pronto(a) para casar.';
          icon = 'heart_broken';
          color = '#64748B';
          d.sfx(GameSfx.negativeEvent);
        }
        break;
      case 'haveBaby':
        if (d.age > 55 || n.age > 55) {
          d.warn('Idade avançada', 'Vocês podem considerar adoção no futuro.');
          return;
        }
        if (ctx.chance(0.75)) {
          final baby = addChild(d, n);
          happy = 25;
          rel = 10;
          text = 'Nasceu ${baby.firstName}! Uma nova vida chegou à família.';
          icon = 'child_friendly';
          color = '#22D3EE';
          celebrate = true;
          notice = NoticeKind.family;
          d.sfx(GameSfx.birth);
        } else {
          text = 'Vocês tentaram, mas a cegonha ainda não chegou. Tentem de novo no futuro.';
          icon = 'info';
          color = '#64748B';
        }
        break;
      case 'breakUp':
        type = RelationshipType.exPartner;
        rel = -35;
        happy = -15;
        text = 'Você terminou com ${n.fullName}.';
        icon = 'heart_broken';
        color = '#64748B';
        d.c = d.c.copyWith(clearPartner: true);
        d.sfx(GameSfx.negativeEvent);
        break;
      case 'divorce':
        final split = d.c.bankBalance > 0 ? d.c.bankBalance * 0.4 : 0.0;
        d.money(-split);
        type = RelationshipType.exPartner;
        rel = -40;
        happy = -18;
        text = 'Você se divorciou de ${n.fullName}. A partilha levou ${Fmt.money(split)}.';
        icon = 'gavel';
        color = '#64748B';
        d.c = d.c.copyWith(isMarried: false, clearPartner: true);
        d.sfx(GameSfx.negativeEvent);
        break;
      case 'askMoney':
        final p = 0.25 + n.relationshipLevel / 200;
        if (n.netWorth > 500 && ctx.chance(p)) {
          final amount = (n.netWorth * (0.005 + ctx.roll() * 0.02)).clamp(20.0, 50000.0).roundToDouble();
          d.money(amount);
          rel = -3;
          text = '${n.fullName} te deu ${Fmt.money(amount)}.';
          icon = 'payments';
          color = '#22C55E';
          notice = NoticeKind.money;
          d.sfx(GameSfx.moneyGain);
          d.notify(NoticeKind.money, Icons.payments, 'Você recebeu dinheiro', message: text, money: amount);
        } else {
          rel = -6;
          text = '${n.fullName} disse que dinheiro não dá em árvore.';
          icon = 'money_off';
          color = '#64748B';
        }
        break;
      case 'playTogether':
        rel = ctx.range(10, 16);
        happy = 10;
        d.stats({'stress': -8});
        text = 'Você brincou com ${n.fullName} a tarde toda. Risadas garantidas!';
        icon = 'toys';
        color = '#F97316';
        d.x.bump('leisure');
        break;
    }

    switch (actionId) {
      case 'joke':
        rel = ctx.range(5, 11);
        happy = 5;
        text = ctx.pick([
          'Você fez uma piada e ${n.fullName} gargalhou até chorar.',
          'Sua imitação arrancou risadas de ${n.fullName}.',
          'Você pregou uma peça inofensiva em ${n.fullName}, que entrou na brincadeira.',
        ]);
        icon = 'mood';
        color = '#F59E0B';
        d.sfx(GameSfx.positiveEvent);
      case 'inviteParty':
        rel = ctx.range(8, 15);
        happy = 8;
        d.stats({'stress': -5});
        text = 'Você convidou ${n.fullName} para uma festa e vocês curtiram muito juntos!';
        icon = 'celebration';
        color = '#EC4899';
        d.x.bump('leisure');
        d.sfx(GameSfx.positiveEvent);
      case 'wakeUp':
        rel = ctx.range(2, 6);
        happy = 3;
        text = ctx.pick([
          'Você acordou ${n.fullName} com café na cama. Que fofura!',
          'Você acordou ${n.fullName} cantando e foi recebido(a) com um sorriso sonolento.',
        ]);
        icon = 'alarm';
        color = '#0EA5E9';
      case 'intimacy':
        if (!RomanceRules.intimacyAllowed(d.age, n.age)) return;
        final t = NpcTraits.of(n);
        final consent = (0.35 + n.relationshipLevel / 160 + t.modifierFor('flirt') + (n.happiness - 50) / 300 - d.c.stress / 500).clamp(0.05, 0.95);
        if (n.relationshipLevel >= 45 && ctx.chance(consent)) {
          rel = ctx.range(6, 12);
          happy = 12;
          d.stats({'stress': -10});
          meta.intimacy = (meta.intimacy + 10).clamp(0, 100);
          text = ctx.pick([
            'Você e ${n.fullName} tiveram uma noite romântica a dois, com total cumplicidade.',
            'Jantar à luz de velas, conversa sincera e uma noite especial com ${n.fullName}.',
          ]);
          icon = 'nights_stay';
          color = '#BE185D';
          d.sfx(GameSfx.wedding);
        } else {
          rel = 2;
          happy = -2;
          text = '${n.fullName} disse que não está no clima hoje. Você respeitou, e ${n.firstName} agradeceu o carinho.';
          icon = 'favorite_border';
          color = '#64748B';
        }
      default:
        break;
    }

    final updated = n.copyWith(relationshipLevel: n.relationshipLevel + rel, relationshipType: type);
    d.updateNpc(updated);
    meta.addHistory('Aos ${d.age}: $text');
    if (type == RelationshipType.partner) meta.romanceStage = 3;
    if (type == RelationshipType.spouse) meta.romanceStage = 4;
    if (type == RelationshipType.crush && meta.romanceStage < 1) meta.romanceStage = 1;
    d.addMemory(n.id, text);
    d.stats({'happiness': happy});
    d.log(actionId == 'haveBaby' ? 'family' : (n.isRomantic || type == RelationshipType.partner ? 'romance' : 'social'),
        text, icon: icon, color: color);
    if (notice != NoticeKind.money) {
      d.notify(notice, a.icon, a.label, message: text, celebrate: celebrate);
    }
  }

  static NpcModel addChild(LifeDraft d, NpcModel? otherParent) {
    final g = d.ctx.gender();
    final baby = d.makeNpc(
      type: g == 'male' ? RelationshipType.son : RelationshipType.daughter,
      gender: g,
      age: 0,
      lastName: d.c.lastName,
      level: 95,
      occupation: 'Bebê',
    );
    d.npcs.add(baby);
    if (otherParent != null) d.addMemory(otherParent.id, 'Tivemos um bebê: ${baby.firstName}.');
    d.x.bump('children');
    return baby;
  }

  /// Procurar amor (app de namoro / sair à noite): cria uma paquera.
  static void findLove(LifeDraft d) {
    if (d.age < 16) {
      d.warn('Muito jovem', 'Espere completar 16 anos.');
      return;
    }
    if (!d.useAction('findLove', 3) || !d.useEnergy(10)) return;
    final p = 0.45 + d.c.looks / 250 + d.c.charisma / 300 + d.c.fame / 300;
    if (d.ctx.chance(p.clamp(0.1, 0.92))) {
      final g = d.romanticGender();
      final crush = d.makeNpc(
        type: RelationshipType.crush,
        gender: g,
        age: d.ctx.range(RomanceRules.datingRange(d.age).$1, RomanceRules.datingRange(d.age).$2),
        level: 45 + d.ctx.rng.nextInt(25),
      );
      d.npcs.add(crush);
      d.addMemory(crush.id, 'Nos conhecemos num encontro.');
      d.log('romance', 'Você conheceu ${crush.fullName} (${crush.age} anos) e rolou uma conexão!', icon: 'favorite_border', color: '#FF4F9A');
      d.notify(NoticeKind.social, Icons.favorite_border, 'Nova paquera!', message: '${crush.fullName} entrou na sua vida.');
      d.sfx(GameSfx.positiveEvent);
      d.stats({'happiness': 6});
    } else {
      d.log('romance', 'Você tentou conhecer alguém novo, mas nenhum encontro deu match.', icon: 'heart_broken', color: '#64748B');
      d.notify(NoticeKind.info, Icons.heart_broken, 'Sem match desta vez');
      d.stats({'happiness': -3});
    }
  }

  /// Sair para socializar: pode criar um amigo novo.
  static void meetPeople(LifeDraft d) {
    if (!d.useAction('meetPeople', 3) || !d.useEnergy(10)) return;
    d.x.bump('leisure');
    final p = 0.5 + d.c.charisma / 200;
    if (d.ctx.chance(p.clamp(0.2, 0.95))) {
      final friend = d.makeNpc(
        type: RelationshipType.friend,
        age: (d.age + d.ctx.range(-3, 3)).clamp(4, 95),
        level: 50 + d.ctx.rng.nextInt(25),
      );
      d.npcs.add(friend);
      d.x.bump('friendsMade');
      d.addMemory(friend.id, 'Nos conhecemos num rolê.');
      d.log('social', 'Você fez amizade com ${friend.fullName}!', icon: 'person_add', color: '#EC4899');
      d.notify(NoticeKind.social, Icons.person_add, 'Nova amizade', message: '${friend.fullName} agora é seu amigo(a).');
      d.sfx(GameSfx.positiveEvent);
      d.stats({'happiness': 6, 'charisma': 1});
    } else {
      d.log('social', 'Você saiu para socializar, mas a noite foi meio parada.', icon: 'nightlife', color: '#64748B');
      d.notify(NoticeKind.info, Icons.nightlife, 'Noite tranquila');
      d.stats({'happiness': 2});
    }
  }

  // ------------------------------------------------------------------ anual
  static void yearly(LifeDraft d) {
    final ctx = d.ctx;
    final out = <NpcModel>[];
    for (final n in d.npcs) {
      if (!n.isAlive) {
        out.add(n);
        continue;
      }
      final newAge = n.age + 1;
      var health = n.health;
      if (newAge > 60) health -= ctx.rng.nextInt(5);
      health = (health + ctx.rng.nextInt(3) - 1).clamp(0, 100);
      final deathP = newAge < 60 ? 0.002 : (newAge - 58) * 0.018 + (health < 20 ? 0.15 : 0);
      if (ctx.chance(deathP) || health <= 0 || newAge > 104) {
        final cause = newAge >= 70 ? 'causas naturais' : ctx.pick(['um acidente', 'uma doença súbita', 'complicações cardíacas']);
        out.add(n.copyWith(age: newAge, isAlive: false, health: 0, causeOfDeath: cause));
        d.log('family', 'Luto: ${n.relationLabel} ${n.fullName} faleceu aos $newAge anos devido a $cause.',
            icon: 'sentiment_very_dissatisfied', color: '#EF4444');
        d.notify(NoticeKind.family, Icons.sentiment_very_dissatisfied, 'Perda na família',
            message: '${n.fullName} faleceu aos $newAge anos.');
        d.stats({'happiness': n.relationshipLevel > 60 ? -15 : -5});
        if (n.isParent || n.isGrandparent) {
          final share = (n.netWorth * (n.isParent ? 0.5 : 0.2)).clamp(0.0, 20000000.0).roundToDouble();
          if (share > 100) {
            d.money(share);
            d.log('finance', 'Herança: você recebeu ${Fmt.money(share)} de ${n.fullName}.', icon: 'attach_money', color: '#22C55E');
            d.notify(NoticeKind.money, Icons.account_balance_wallet, 'Herança recebida', message: Fmt.money(share), money: share);
          }
        }
        if (n.id == d.c.partnerId) {
          d.c = d.c.copyWith(isMarried: false, clearPartner: true);
        }
        continue;
      }
      // Afeto: relações sem cuidado esfriam com o tempo
      int drift = ctx.rng.nextInt(5) - 3;
      if (n.isRomantic) drift -= 2;
      if (n.isWork && d.c.currentJobId == null) drift -= 6;
      var occupation = n.occupation;
      if (n.isChild || n.isSibling) {
        if (newAge == 6) occupation = 'Estudante';
        if (newAge == 18) occupation = ctx.chance(0.5) ? 'Universitário(a)' : ctx.commonJob();
        if (newAge == 23 && occupation == 'Universitário(a)') occupation = ctx.commonJob();
      }
      if (newAge >= 67 && !n.isChild && occupation != 'Aposentado(a)' && ctx.chance(0.5)) occupation = 'Aposentado(a)';
      out.add(n.copyWith(
        age: newAge,
        health: health,
        relationshipLevel: n.relationshipLevel + drift,
        occupation: occupation,
        netWorth: n.netWorth + n.salary * 0.1,
      ));
    }
    d.npcs = out;

    // Colegas de escola somem quando você sai da escola
    if (!d.x.education.inSchool) {
      d.npcs.removeWhere((n) => n.relationshipType == RelationshipType.classmate && n.isAlive && n.relationshipLevel < 60);
    }
    // Paqueras esquecidas se perdem
    d.npcs.removeWhere((n) => n.relationshipType == RelationshipType.crush && n.relationshipLevel < 25);

    // Colegas de escola novos
    if (d.x.education.inSchool && ctx.chance(0.35) && d.npcs.where((n) => n.relationshipType == RelationshipType.classmate).length < 4) {
      final mate = d.makeNpc(type: RelationshipType.classmate, age: d.age, level: 40 + ctx.rng.nextInt(30));
      d.npcs.add(mate);
      d.log('social', 'Você conheceu ${mate.fullName} na escola.', icon: 'school', color: '#3B82F6');
    }

    // Pets
    for (final p in d.x.pets) {
      if (!p.alive) continue;
      p.age += 1;
      final life = p.type == 'Gato' ? 16 : (p.type == 'Cachorro' ? 13 : 8);
      if (p.age > life - 3 && ctx.chance((p.age - life + 4) * 0.2)) {
        p.alive = false;
        d.log('pets', 'Seu pet ${p.name} partiu aos ${p.age} anos. Obrigado por tanto amor.', icon: 'pets', color: '#64748B');
        d.stats({'happiness': -12});
      } else {
        d.stats({'happiness': 2, 'stress': -2});
      }
    }
  }
}
