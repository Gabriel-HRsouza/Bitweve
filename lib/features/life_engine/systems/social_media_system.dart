import 'dart:math';

import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/models/npc_traits.dart';
import 'package:bitweve/features/social_media/data/social_catalog.dart';
import 'package:bitweve/features/social_media/models/social_state.dart';
import 'life_draft.dart';

/// Post de um NPC no feed (gerado, não persistido).
class FeedPost {
  final String id;
  final NpcModel author;
  final PostCategory category;
  final int photo;
  final String caption;
  final int likes;
  const FeedPost(this.id, this.author, this.category, this.photo, this.caption, this.likes);
}

/// Rede social "Pulso": publicações, curtidas, comentários, seguidores,
/// mensagens diretas, tendências e polêmicas.
class SocialMediaSystem {
  static const minAge = 13;

  /// Requisito de cada categoria (null = liberada).
  static String? categoryBlocker(LifeEngineState s, String categoryId) {
    final x = s.extras;
    final c = s.character;
    switch (categoryId) {
      case 'travel':
        return x.counter('travels') > 0 || x.counter('exchange') > 0 || x.counter('vacations') > 0 ? null : 'Viaje primeiro (Atividades → Férias).';
      case 'cars':
        return x.vehicles.isNotEmpty ? null : 'Você não tem veículo.';
      case 'love':
        return s.npcs.any((n) => n.isAlive && (n.relationshipType == RelationshipType.partner || n.relationshipType == RelationshipType.spouse))
            ? null
            : 'Você não está num relacionamento.';
      case 'work':
        return c.currentJobTitle != null || x.businesses.isNotEmpty ? null : 'Você não tem emprego.';
      case 'college':
        return x.education.isStudying ? null : 'Você não está estudando.';
      case 'luxury':
        return s.netWorth >= 500000 ? null : 'Patrimônio insuficiente.';
      case 'family':
        return s.npcs.any((n) => n.isAlive && n.isFamily) ? null : 'Sem família por perto.';
    }
    return null;
  }

  /// Tendências do ano (determinísticas): categorias com bônus de alcance.
  static List<String> trends(int year) {
    final rng = Random(year * 31);
    final ids = SocialCatalog.categories.map((c) => c.id).toList()..shuffle(rng);
    return ids.take(3).toList();
  }

  static void createAccount(LifeDraft d, String handle) {
    if (d.age < minAge) {
      d.warn('Idade mínima: $minAge anos', 'O ${SocialCatalog.appName} só aceita usuários a partir de $minAge anos.');
      return;
    }
    final s = d.x.social;
    var h = handle.trim().replaceAll(' ', '_').toLowerCase();
    if (h.isEmpty) h = '${d.c.firstName.toLowerCase()}.${d.c.lastName.toLowerCase()}';
    if (h.length > 24) h = h.substring(0, 24);
    s.handle = h;
    s.hasAccount = true;
    if (d.x.followers < 10) d.x.followers = 10 + d.ctx.range(0, 30) + d.living((n) => n.relationshipLevel > 40).length;
    d.log('fame', 'Você criou seu perfil @$h no ${SocialCatalog.appName}!', icon: 'person_add', color: '#EC4899');
    d.notify(NoticeKind.fame, Icons.phone_iphone, 'Perfil criado!', message: '@$h');
    d.sfx(GameSfx.notification);
  }

  /// Publica um post. Retorna o post criado (ou null se bloqueado).
  static SocialPost? publish(LifeDraft d, String categoryId, int photo, String caption) {
    final s = d.x.social;
    if (!s.hasAccount) {
      d.warn('Crie seu perfil primeiro');
      return null;
    }
    final blocker = categoryBlocker(d.toState(), categoryId);
    if (blocker != null) {
      d.warn('Não dá para postar isso', blocker);
      return null;
    }
    if (!d.useAction('post', 6)) return null;
    final cat = SocialCatalog.category(categoryId);
    final trending = trends(d.year).contains(categoryId);
    final followers = d.x.followers;
    // Qualidade: aparência, carisma, fama, legenda e sorte
    final cap = caption.trim();
    final capScore = cap.isEmpty ? 0.7 : (cap.length < 6 ? 0.9 : (cap.length > 120 ? 0.85 : 1.1));
    final quality = (0.6 + d.c.looks / 250 + d.c.charisma / 300 + d.c.fame / 250 + d.ctx.roll() * 0.6) * capScore * (trending ? 1.5 : 1.0);
    final reach = followers * (0.08 + d.ctx.roll() * 0.12) * quality;
    final viral = d.ctx.chance(0.03 + (trending ? 0.05 : 0) + d.c.charisma / 2000);
    var likes = (reach + d.ctx.range(1, 12)).round() * (viral ? d.ctx.range(8, 30) : 1);
    final controversy = d.ctx.chance(cat.controversyRisk * (1 + d.c.fame / 100));
    if (controversy) likes = (likes * 1.4).round();
    final shares = (likes * (0.02 + d.ctx.roll() * 0.05)).round();
    var gained = (likes * (0.04 + d.ctx.roll() * 0.08) + (viral ? likes * 0.25 : 0)).round();
    if (controversy) gained = (gained * 0.5).round() - d.ctx.range(0, (followers * 0.02).round());

    final post = SocialPost(
      id: d.ctx.id(),
      category: categoryId,
      imageKey: '${categoryId}_$photo',
      caption: cap.isEmpty ? d.ctx.pick(cat.captions) : cap,
      age: d.age,
      year: d.year,
      likes: likes,
      shares: shares,
      viral: viral,
      controversy: controversy,
      followersGained: gained,
    );

    // Reações de NPCs conhecidos
    final known = d.living((n) => n.age >= minAge && n.relationshipLevel > 25 && !(d.x.npcMeta[n.id]?.blocked ?? false));
    known.shuffle(d.ctx.rng);
    for (final n in known.take(3)) {
      final t = NpcTraits.of(n);
      final likesIt = t.interests.any((i) => i.id == _interestFor(categoryId)) || n.relationshipLevel > 60;
      final negative = controversy && n.relationshipLevel < 50;
      post.comments.add(PostComment(
        author: n.fullName,
        npcId: n.id,
        text: negative
            ? d.ctx.pick(SocialCatalog.negativeComments)
            : (likesIt ? d.ctx.pick(SocialCatalog.positiveComments) : d.ctx.pick(const ['Legal!', 'Boa!', '👏', 'Show'])),
        mood: negative ? -1 : 1,
      ));
      d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + (negative ? -2 : (likesIt ? 3 : 1))));
    }
    // Comentários de desconhecidos
    final strangers = (likes / 400).clamp(1, 4).round();
    for (var i = 0; i < strangers; i++) {
      final neg = controversy ? d.ctx.chance(0.6) : d.ctx.chance(0.1);
      post.comments.add(PostComment(
        author: '@${d.ctx.pick(SocialCatalog.fanHandles)}',
        text: neg ? d.ctx.pick(SocialCatalog.negativeComments) : d.ctx.pick(SocialCatalog.positiveComments),
        mood: neg ? -1 : 1,
      ));
    }

    s.posts.insert(0, post);
    if (s.posts.length > 60) s.posts.removeLast();
    s.totalLikes += likes;
    d.x.followers = (followers + gained).clamp(0, 2000000000);
    d.x.bump('socialPosts');
    if (controversy) {
      s.socialRep = (s.socialRep - 10).clamp(0, 100);
      d.stats({'reputation': -4, 'fame': 3, 'stress': 6});
      d.log('fame', 'Polêmica! Seu post "${post.caption}" dividiu opiniões e gerou ${Fmt.compact(likes)} curtidas.', icon: 'local_fire_department', color: '#EF4444');
      d.notify(NoticeKind.fame, Icons.local_fire_department, 'Seu post virou polêmica!', message: 'Considere apagá-lo.');
      d.sfx(GameSfx.negativeEvent);
    } else if (viral) {
      s.socialRep = (s.socialRep + 5).clamp(0, 100);
      d.stats({'fame': 6, 'happiness': 10});
      d.log('fame', 'VIRALIZOU! Seu post "${post.caption}" teve ${Fmt.compact(likes)} curtidas e +${Fmt.compact(gained)} seguidores.', icon: 'trending_up', color: '#EC4899');
      d.notify(NoticeKind.fame, Icons.trending_up, 'Viralizou!', message: '+${Fmt.compact(gained)} seguidores', celebrate: true);
      d.sfx(GameSfx.achievement);
    } else {
      s.socialRep = (s.socialRep + 1).clamp(0, 100);
      d.stats({'happiness': 3, 'fame': likes > 1000 ? 1 : 0});
      d.log('fame', 'Você postou "${post.caption}" no ${SocialCatalog.appName}: ${Fmt.compact(likes)} curtidas.', icon: 'photo_camera', color: '#EC4899');
      d.notify(NoticeKind.fame, cat.icon, 'Post publicado', message: '${Fmt.compact(likes)} curtidas · +${Fmt.compact(gained < 0 ? 0 : gained)} seguidores');
      d.sfx(GameSfx.notification);
    }
    // Mensagens diretas provocadas pelo post
    _maybeDm(d, post);
    // Oportunidades: marcas notam perfis grandes
    if (d.x.followers > 20000 && d.ctx.chance(0.15) && d.age >= 16) {
      final brand = d.ctx.pick(SocialCatalog.brands);
      s.inbox.insert(0, DirectMessage(id: d.ctx.id(), from: brand, text: 'Oi! Curtimos seu perfil. Topa uma publi? Pagamos ${Fmt.money(d.x.followers * 0.02)}.', age: d.age, kind: 'brand'));
    }
    return post;
  }

  static String _interestFor(String cat) => switch (cat) {
        'travel' => 'travel',
        'cars' => 'cars',
        'fashion' => 'fashion',
        'party' => 'music',
        'humor' => 'movies',
        'lifestyle' => 'fitness',
        'photos' => 'photo',
        _ => 'art',
      };

  static void _maybeDm(LifeDraft d, SocialPost post) {
    final s = d.x.social;
    if (!d.ctx.chance(0.45)) return;
    final friends = d.living((n) => n.age >= minAge && n.relationshipLevel > 50 && !n.isParent);
    if (friends.isNotEmpty && d.ctx.chance(0.5)) {
      final n = d.ctx.pick(friends);
      s.inbox.insert(0, DirectMessage(id: d.ctx.id(), from: n.fullName, npcId: n.id, text: d.ctx.pick([
        'Vi seu post! Bora marcar algo?',
        'Hahaha que foto é essa 😂',
        'Saudade! Tudo bem por aí?',
      ]), age: d.age, kind: 'friend'));
    } else if (post.controversy) {
      s.inbox.insert(0, DirectMessage(id: d.ctx.id(), from: '@${d.ctx.pick(SocialCatalog.fanHandles)}', text: 'Sério que você postou isso? 😒', age: d.age, kind: 'hater'));
    } else {
      s.inbox.insert(0, DirectMessage(id: d.ctx.id(), from: '@${d.ctx.pick(SocialCatalog.fanHandles)}', text: d.ctx.pick([
        'Sou seu fã! Posta mais! 🙌',
        'Seu perfil é muito inspirador',
        'Onde você comprou isso?',
      ]), age: d.age, kind: 'fan'));
    }
    if (s.inbox.length > 40) s.inbox.removeRange(40, s.inbox.length);
  }

  static void deletePost(LifeDraft d, String postId) {
    final s = d.x.social;
    final i = s.posts.indexWhere((p) => p.id == postId);
    if (i < 0) return;
    final p = s.posts.removeAt(i);
    if (p.controversy) {
      s.socialRep = (s.socialRep + 6).clamp(0, 100);
      d.stats({'reputation': 2, 'stress': -4});
      d.log('fame', 'Você apagou o post polêmico. A poeira começou a baixar.', icon: 'delete', color: '#64748B');
    } else {
      d.x.followers = (d.x.followers - (p.followersGained * 0.1).round()).clamp(0, 2000000000);
      d.log('fame', 'Você apagou o post "${p.caption}".', icon: 'delete', color: '#64748B');
    }
    d.notify(NoticeKind.info, Icons.delete, 'Post apagado');
  }

  static void replyComment(LifeDraft d, String postId, int index, String reply) {
    final post = d.x.social.posts.where((p) => p.id == postId).firstOrNull;
    if (post == null || index < 0 || index >= post.comments.length) return;
    final c = post.comments[index];
    if (c.reply != null) return;
    c.reply = reply;
    final rude = reply.contains('😒') || reply.toLowerCase().contains('chato');
    if (c.npcId != null) {
      final n = d.npc(c.npcId!);
      if (n != null) d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + (rude ? -6 : 4)));
    }
    if (c.mood < 0 && !rude) d.x.social.socialRep = (d.x.social.socialRep + 2).clamp(0, 100);
    if (rude) d.x.social.socialRep = (d.x.social.socialRep - 3).clamp(0, 100);
    d.notify(NoticeKind.social, Icons.reply, 'Resposta enviada', message: c.author);
  }

  static void replyDm(LifeDraft d, String dmId, String tone) {
    final s = d.x.social;
    final m = s.inbox.where((e) => e.id == dmId).firstOrNull;
    if (m == null || m.reply != null) return;
    m.read = true;
    m.reply = switch (tone) {
      'kind' => 'Obrigado(a)! ❤️',
      'accept' => 'Topo! Vamos fechar.',
      'ignore' => '(visualizado)',
      _ => 'Valeu!',
    };
    if (m.kind == 'brand' && tone == 'accept') {
      final pay = (d.x.followers * 0.02).roundToDouble().clamp(200.0, 2000000.0).toDouble();
      d.money(pay);
      s.socialRep = (s.socialRep - 2).clamp(0, 100);
      d.log('fame', 'Você fechou uma publi com ${m.from} e recebeu ${Fmt.money(pay)}.', icon: 'handshake', color: '#22C55E');
      d.notify(NoticeKind.money, Icons.handshake, 'Publi fechada!', money: pay);
      d.sfx(GameSfx.moneyGain);
      return;
    }
    if (m.npcId != null) {
      final n = d.npc(m.npcId!);
      if (n != null) d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + (tone == 'ignore' ? -4 : 5)));
    }
    if (m.kind == 'fan' && tone == 'kind') d.x.followers += d.ctx.range(1, 20);
  }

  static void markRead(LifeDraft d) {
    for (final m in d.x.social.inbox) {
      m.read = true;
    }
  }

  /// Feed com posts de amigos/conhecidos (determinístico por ano).
  static List<FeedPost> feed(LifeEngineState s) {
    final year = s.character.birthYear + s.character.currentAge;
    final people = s.npcs.where((n) => n.isAlive && n.age >= minAge && !(s.extras.npcMeta[n.id]?.blocked ?? false)).toList();
    final out = <FeedPost>[];
    for (final n in people) {
      final rng = Random(n.id.hashCode ^ year);
      if (rng.nextDouble() > 0.6) continue;
      final t = NpcTraits.of(n);
      final cat = SocialCatalog.categories[rng.nextInt(SocialCatalog.categories.length)];
      out.add(FeedPost('${n.id}_$year', n, cat, rng.nextInt(4), cat.captions[rng.nextInt(cat.captions.length)],
          (t.basePopularity * (2 + rng.nextInt(20))).round()));
    }
    out.sort((a, b) => b.likes.compareTo(a.likes));
    return out.take(25).toList();
  }

  static void likeFeed(LifeDraft d, String feedId, String npcId) {
    final s = d.x.social;
    if (s.likedFeed.contains(feedId)) return;
    s.likedFeed.add(feedId);
    if (s.likedFeed.length > 200) s.likedFeed.removeAt(0);
    final n = d.npc(npcId);
    if (n != null) d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + 2));
  }

  static void commentFeed(LifeDraft d, String feedId, String npcId, bool positive) {
    final s = d.x.social;
    if (s.commentedFeed.contains(feedId)) {
      d.warn('Você já comentou nesse post');
      return;
    }
    s.commentedFeed.add(feedId);
    if (s.commentedFeed.length > 200) s.commentedFeed.removeAt(0);
    final n = d.npc(npcId);
    if (n == null) return;
    d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + (positive ? 5 : -8)));
    d.notify(NoticeKind.social, positive ? Icons.chat_bubble : Icons.mood_bad, positive ? 'Comentário fofo' : 'Comentário ácido',
        message: n.fullName);
  }

  static void shareFeed(LifeDraft d, String npcId) {
    if (!d.useAction('share', 5)) return;
    final n = d.npc(npcId);
    if (n != null) d.updateNpc(n.copyWith(relationshipLevel: n.relationshipLevel + 4));
    d.x.followers += d.ctx.range(0, 5);
    d.notify(NoticeKind.social, Icons.share, 'Compartilhado', message: n?.fullName ?? '');
  }

  // ------------------------------------------------------------------ anual
  static void yearly(LifeDraft d) {
    final s = d.x.social;
    if (!s.hasAccount) return;
    // Engajamento orgânico ou perda por inatividade
    final postedThisYear = s.posts.where((p) => p.age == d.age - 1).length;
    if (postedThisYear == 0) {
      d.x.followers = (d.x.followers * 0.95).round();
    } else {
      d.x.followers += (d.x.followers * 0.02 * postedThisYear).round();
    }
    if (!s.verified && d.x.followers >= 100000) {
      s.verified = true;
      d.log('fame', 'Seu perfil @${s.handle} recebeu o selo de verificado no ${SocialCatalog.appName}! ✅', icon: 'verified', color: '#3B82F6');
      d.notify(NoticeKind.fame, Icons.verified, 'Perfil verificado!', celebrate: true);
    }
    if (s.socialRep < 25 && d.ctx.chance(0.3)) {
      d.stats({'reputation': -3, 'stress': 4});
      d.log('fame', 'Seu histórico de polêmicas fez marcas evitarem você este ano.', icon: 'thumb_down', color: '#EF4444');
    }
    s.socialRep = (s.socialRep + (s.socialRep < 50 ? 2 : 0)).clamp(0, 100);
  }
}
