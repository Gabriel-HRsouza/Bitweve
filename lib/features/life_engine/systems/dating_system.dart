import 'dart:math';

import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/dating/models/dating_state.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/models/npc_traits.dart';
import 'package:bitweve/features/relationships/romance_rules.dart';
import 'life_draft.dart';

/// Perfil exibido no app (gerado de forma determinística).
class DatingProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final AvatarConfig avatar;
  final String bio;
  final String occupation;
  final int distanceKm;
  final NpcTraits traits;
  final int looks;
  final String lookingFor;

  const DatingProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.avatar,
    required this.bio,
    required this.occupation,
    required this.distanceKm,
    required this.traits,
    required this.looks,
    required this.lookingFor,
  });

  String get name => '$firstName $lastName';
}

class CompatibilityBreakdown {
  final int total;
  final int interests;
  final int personality;
  final int age;
  final int status;
  final int goals;
  const CompatibilityBreakdown(this.total, this.interests, this.personality, this.age, this.status, this.goals);
}

/// App de namoro "Faísca" (somente 18+).
class DatingSystem {
  static const appName = 'Faísca';
  static const minAge = 18;

  static const _bios = [
    'Amo café, viagens e conversas que viram madrugada.',
    'Procurando alguém para dividir pizza e séries.',
    'Trilha no sábado, cinema no domingo.',
    'Sincero(a), engraçado(a) e péssimo(a) em dançar.',
    'Se você gosta de cachorro, já temos algo em comum.',
    'Cozinho bem e aceito elogios.',
    'Viciado(a) em música ao vivo e festivais.',
    'Livros, vinho e um bom papo.',
    'Na academia às 6h, no sofá às 22h.',
    'Quero alguém que me tire da rotina.',
    'Amo fotografia e pôr do sol.',
    'Gamer nas horas vagas. Desafio aceito?',
  ];
  static const _jobs = [
    'Designer', 'Enfermeiro(a)', 'Advogado(a)', 'Professor(a)', 'Engenheiro(a)', 'Chef', 'Fotógrafo(a)', 'Programador(a)',
    'Arquiteto(a)', 'Personal trainer', 'Músico(a)', 'Médico(a)', 'Jornalista', 'Empreendedor(a)', 'Veterinário(a)', 'Estudante',
  ];
  static const _first = {
    'male': ['Lucas', 'Rafael', 'Thiago', 'Bruno', 'Diego', 'Caio', 'Igor', 'Vítor', 'Hugo', 'Daniel', 'André', 'Renan', 'Otávio', 'Marcelo', 'Leandro', 'Fábio'],
    'female': ['Camila', 'Larissa', 'Bianca', 'Natália', 'Fernanda', 'Bruna', 'Letícia', 'Marina', 'Lara', 'Paula', 'Tainá', 'Sara', 'Renata', 'Olívia', 'Joana', 'Daniela'],
  };
  static const _last = ['Moura', 'Campos', 'Siqueira', 'Valente', 'Reis', 'Paiva', 'Tavares', 'Guimarães', 'Neves', 'Fonseca', 'Macedo', 'Xavier', 'Leite', 'Sales'];

  /// Perfis disponíveis neste ano (12 por ano), excluindo os já vistos.
  static List<DatingProfile> deck(LifeEngineState s) {
    final x = s.extras;
    final c = s.character;
    final year = c.birthYear + c.currentAge;
    final out = <DatingProfile>[];
    final (lo, hi) = RomanceRules.datingRange(c.currentAge);
    final minA = max(lo, x.dating.minAge).clamp(18, 99);
    final maxA = min(hi + 6, x.dating.maxAge).clamp(18, 99);
    for (var i = 0; i < 14; i++) {
      final id = 'fx_${s.saveId.hashCode}_${year}_$i';
      if (x.dating.swiped.contains(id)) continue;
      final rng = Random(id.hashCode);
      final g = _genderFor(c.gender, c.sexualOrientation, rng);
      final age = minA >= maxA ? minA : minA + rng.nextInt(maxA - minA + 1);
      out.add(DatingProfile(
        id: id,
        firstName: _first[g == 'female' ? 'female' : 'male']![rng.nextInt(16)],
        lastName: _last[rng.nextInt(_last.length)],
        gender: g,
        age: age,
        avatar: AvatarConfig.random(gender: g, rng: rng),
        bio: _bios[rng.nextInt(_bios.length)],
        occupation: _jobs[rng.nextInt(_jobs.length)],
        distanceKm: 1 + rng.nextInt(30),
        traits: NpcTraits.fromSeed(id),
        looks: 30 + rng.nextInt(70),
        lookingFor: ['serious', 'casual', 'friendship'][rng.nextInt(3)],
      ));
    }
    return out;
  }

  static String _genderFor(String own, String orientation, Random rng) {
    switch (orientation) {
      case 'homosexual':
        return own == 'female' ? 'female' : 'male';
      case 'bisexual':
        return rng.nextBool() ? 'male' : 'female';
      default:
        return own == 'female' ? 'male' : (own == 'male' ? 'female' : (rng.nextBool() ? 'male' : 'female'));
    }
  }

  static const _goodPairs = {
    'outgoing': ['partier', 'outgoing', 'sporty'],
    'shy': ['kind', 'intellectual', 'reserved'],
    'sarcastic': ['sarcastic', 'intellectual', 'artsy'],
    'romantic': ['romantic', 'kind', 'artsy'],
    'competitive': ['sporty', 'competitive'],
    'kind': ['kind', 'shy', 'romantic'],
    'grumpy': ['kind', 'reserved'],
    'intellectual': ['intellectual', 'shy', 'sarcastic'],
    'partier': ['partier', 'outgoing'],
    'reserved': ['reserved', 'shy', 'intellectual'],
    'sporty': ['sporty', 'competitive', 'outgoing'],
    'artsy': ['artsy', 'romantic', 'sarcastic'],
  };

  /// Compatibilidade baseada em interesses, personalidade, idade, status,
  /// objetivos e histórico.
  static CompatibilityBreakdown compatibility(LifeEngineState s, DatingProfile p) {
    final x = s.extras;
    final c = s.character;
    final interests = p.traits.interestMatch(x.dating.interests);
    final myP = x.personality;
    final personality = (_goodPairs[myP]?.contains(p.traits.personality.id) ?? false)
        ? 90
        : (_goodPairs[p.traits.personality.id]?.contains(myP) ?? false)
            ? 75
            : 45;
    final age = (100 - (c.currentAge - p.age).abs() * 8).clamp(10, 100);
    final appeal = (c.looks * 0.5 + c.charisma * 0.3 + (s.netWorth > 100000 ? 15 : 0) + c.fame * 0.2).clamp(0, 100);
    final status = (50 + appeal - p.traits.pickiness * 0.6).clamp(0, 100).round();
    final goals = p.lookingFor == x.dating.lookingFor ? 100 : (p.lookingFor == 'friendship' || x.dating.lookingFor == 'friendship' ? 30 : 60);
    var total = (interests * 0.3 + personality * 0.2 + age * 0.15 + status * 0.2 + goals * 0.15).round();
    final hasPartner = s.npcs.any((n) => n.isAlive && (n.relationshipType == RelationshipType.partner || n.relationshipType == RelationshipType.spouse));
    if (hasPartner) total -= 20; // perfis desconfiam de quem já tem alguém
    total -= x.dating.rejections ~/ 4;
    return CompatibilityBreakdown(total.clamp(0, 100), interests, personality, age, status, goals);
  }

  // ------------------------------------------------------------------ ações
  static void setupProfile(LifeDraft d, String bio, List<String> interests, String lookingFor, int minA, int maxA) {
    if (d.age < minAge) {
      d.warn('Somente maiores de 18 anos', 'O $appName é exclusivo para adultos.');
      return;
    }
    final ds = d.x.dating;
    ds.hasProfile = true;
    ds.bio = bio.trim().length > 140 ? bio.trim().substring(0, 140) : bio.trim();
    ds.interests
      ..clear()
      ..addAll(interests.take(5));
    ds.lookingFor = lookingFor;
    ds.minAge = minA.clamp(18, 99);
    ds.maxAge = maxA.clamp(ds.minAge, 99);
    d.notify(NoticeKind.social, Icons.local_fire_department, 'Perfil no $appName salvo', message: '${ds.interests.length} interesses');
  }

  /// Curtir (ou super curtir) um perfil. Match só se a outra pessoa também quiser.
  static bool like(LifeDraft d, String profileId, {bool superLike = false}) {
    final st = d.toState();
    final p = deck(st).where((e) => e.id == profileId).firstOrNull;
    final ds = d.x.dating;
    if (p == null || !ds.hasProfile || d.age < minAge) return false;
    if (!d.useAction('swipe', 20)) return false;
    if (superLike) {
      if (ds.superLikes <= 0) {
        d.warn('Sem super curtidas', 'Você ganha uma por ano.');
        d.x.actionsThisYear['swipe'] = (d.x.actionsThisYear['swipe'] ?? 1) - 1;
        return false;
      }
      ds.superLikes -= 1;
    }
    ds.swiped.add(p.id);
    ds.liked.add(p.id);
    final comp = compatibility(st, p);
    final chance = (comp.total / 100 * 0.9 + (superLike ? 0.15 : 0) - 0.12 + (d.c.looks - p.looks) / 300).clamp(0.03, 0.92);
    if (d.ctx.chance(chance)) {
      ds.matches.insert(
        0,
        DatingMatch(
          profileId: p.id,
          firstName: p.firstName,
          lastName: p.lastName,
          gender: p.gender,
          age: p.age,
          avatarJson: p.avatar.toJson(),
          bio: p.bio,
          compatibility: comp.total,
          interest: (comp.total * 0.6 + 20).round(),
          chat: [ChatLine(false, d.ctx.pick(['Oi! Adorei seu perfil 😊', 'Ei, tudo bem? Deu match!', 'Olá! Curti suas fotos.']))],
        ),
      );
      d.x.bump('datingMatches');
      d.stats({'happiness': 5});
      d.notify(NoticeKind.social, Icons.local_fire_department, 'Deu match!', message: '${p.firstName}, ${p.age}', celebrate: true);
      d.sfx(GameSfx.match);
      return true;
    }
    ds.rejections += 1;
    d.sfx(GameSfx.swipe);
    return false;
  }

  static void pass(LifeDraft d, String profileId) {
    final ds = d.x.dating;
    if (!ds.swiped.contains(profileId)) ds.swiped.add(profileId);
    d.sfx(GameSfx.swipe);
  }

  static const messageOptions = {
    'question': ('Pergunta divertida', 'Se você pudesse jantar com qualquer pessoa, quem seria?'),
    'compliment': ('Elogio gentil', 'Seu sorriso nas fotos é contagiante!'),
    'interests': ('Falar dos interesses', 'Vi que a gente curte as mesmas coisas. Qual seu favorito?'),
    'joke': ('Piada', 'Você acredita em amor à primeira curtida ou devo dar swipe de novo?'),
    'forward': ('Mensagem ousada', 'Você é muito atraente, sabia?'),
    'boring': ('"oi sumida(o)"', 'oi'),
  };

  /// Envia uma mensagem no chat e calcula a reação.
  static void chat(LifeDraft d, String profileId, String option) {
    final ds = d.x.dating;
    final m = ds.matches.where((e) => e.profileId == profileId).firstOrNull;
    if (m == null || !m.active) return;
    if (!d.useAction('chat:$profileId', 4)) return;
    final opt = messageOptions[option] ?? messageOptions['question']!;
    final t = NpcTraits.fromSeed(profileId);
    m.chat.add(ChatLine(true, opt.$2));
    final base = switch (option) {
      'question' => 8,
      'compliment' => 6,
      'interests' => 10,
      'joke' => 7,
      'forward' => -4,
      _ => -6,
    };
    final mod = (t.modifierFor(switch (option) { 'compliment' => 'compliment', 'joke' => 'joke', 'forward' => 'flirt', _ => 'talk' }) * 30).round();
    final delta = base + mod + d.ctx.range(-4, 4) + (m.compatibility - 50) ~/ 10;
    m.interest = (m.interest + delta).clamp(0, 100);
    final String reply;
    if (option == 'forward' && delta < 0) {
      reply = d.ctx.pick(['Calma, a gente acabou de se conhecer...', 'Hmm, prefiro ir com mais calma.']);
    } else if (delta >= 8) {
      reply = d.ctx.pick(['Hahaha adorei! 😄', 'Que pergunta boa! Deixa eu pensar...', 'Você é diferente, gostei.', 'Para, assim eu fico sem graça 😊']);
    } else if (delta >= 0) {
      reply = d.ctx.pick(['Legal!', 'Haha, pode ser.', 'Ah, que interessante.']);
    } else {
      reply = d.ctx.pick(['...', 'Ok.', 'Entendi.']);
    }
    m.chat.add(ChatLine(false, reply));
    if (m.chat.length > 30) m.chat.removeRange(0, m.chat.length - 30);
    if (m.interest <= 5) {
      m.unmatched = true;
      m.chat.add(const ChatLine(false, '(desfez o match)'));
      d.notify(NoticeKind.social, Icons.heart_broken, '${m.firstName} desfez o match');
      d.sfx(GameSfx.negativeEvent);
    }
  }

  /// Convite para um encontro: se aceito, a pessoa entra na sua vida.
  static void askDate(LifeDraft d, String profileId) {
    final ds = d.x.dating;
    final m = ds.matches.where((e) => e.profileId == profileId).firstOrNull;
    if (m == null || !m.active) return;
    if (!d.useAction('date:$profileId', 1) || !d.useEnergy(10)) return;
    final p = (m.interest / 100 * 0.9 + d.c.charisma / 500).clamp(0.05, 0.95);
    if (m.interest >= 55 && d.ctx.chance(p)) {
      if (!d.pay(150, what: 'o encontro')) return;
      m.dates += 1;
      m.interest = (m.interest + 10).clamp(0, 100);
      NpcModel? n = m.npcId == null ? null : d.npc(m.npcId!);
      if (n == null) {
        n = d.makeNpc(type: RelationshipType.crush, gender: m.gender, age: m.age, level: 45 + m.compatibility ~/ 4).copyWith(
          id: m.profileId,
          firstName: m.firstName,
          lastName: m.lastName,
          avatarConfig: AvatarConfig.fromJson(m.avatarJson),
        );
        d.npcs.add(n);
        d.x.meta(n.id)
          ..origin = 'dating'
          ..romanceStage = 2;
        m.npcId = n.id;
      } else {
        d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + 10));
      }
      d.addMemory(n.id, 'Tivemos um encontro pelo $appName.');
      d.stats({'happiness': 10, 'stress': -5});
      final place = d.ctx.pick(['num barzinho charmoso', 'num restaurante japonês', 'num show ao ar livre', 'num café com livraria', 'no parque ao pôr do sol']);
      m.chat.add(ChatLine(false, 'Adorei o encontro! Bora repetir? 💕'));
      d.log('romance', 'Encontro do $appName: você e ${m.firstName} se encontraram $place. Rolou química!', icon: 'favorite', color: '#FF4F9A');
      d.notify(NoticeKind.social, Icons.favorite, 'Encontro incrível!', message: '${m.firstName} agora está nos seus relacionamentos.', celebrate: true);
      d.sfx(GameSfx.wedding);
    } else {
      m.interest = (m.interest - 8).clamp(0, 100);
      m.chat.add(ChatLine(false, d.ctx.pick(['Essa semana não dá 😕', 'Prefiro conversar mais antes.', 'Ah... não sei se estou pronto(a).'])));
      d.stats({'happiness': -4});
      d.notify(NoticeKind.social, Icons.event_busy, 'Encontro recusado', message: m.firstName);
    }
  }

  static void unmatch(LifeDraft d, String profileId, {bool block = false}) {
    final m = d.x.dating.matches.where((e) => e.profileId == profileId).firstOrNull;
    if (m == null) return;
    if (block) {
      m.blocked = true;
      if (m.npcId != null) d.x.meta(m.npcId!).blocked = true;
    } else {
      m.unmatched = true;
    }
    d.notify(NoticeKind.social, block ? Icons.block : Icons.close, block ? 'Perfil bloqueado' : 'Match desfeito', message: m.firstName);
  }

  static void yearly(LifeDraft d) {
    final ds = d.x.dating;
    if (!ds.hasProfile) return;
    ds.superLikes = (ds.superLikes + 1).clamp(0, 3);
    ds.rejections = (ds.rejections * 0.6).round();
    for (final m in ds.matches) {
      if (m.active && m.npcId == null) m.interest = (m.interest - 12).clamp(0, 100);
      if (m.active && m.interest <= 0) m.unmatched = true;
    }
    ds.matches.removeWhere((m) => !m.active && m.npcId == null && ds.matches.length > 20);
  }
}
