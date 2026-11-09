import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'life_draft.dart';

class FameSystem {
  static String tier(int fame) {
    if (fame >= 90) return 'Lenda';
    if (fame >= 75) return 'Superestrela';
    if (fame >= 55) return 'Celebridade';
    if (fame >= 35) return 'Famoso(a)';
    if (fame >= 15) return 'Conhecido(a)';
    return 'Anônimo(a)';
  }

  static void addHeadline(LifeDraft d, String text) {
    d.x.headlines.insert(0, 'Ano ${d.year}: $text');
    if (d.x.headlines.length > 25) d.x.headlines.removeLast();
  }

  static int _growth(LifeDraft d, int base) {
    final mult = 1 + d.c.fame / 25 + d.c.looks / 200 + d.c.charisma / 200;
    final mkt = d.x.education.courses.contains('digital_marketing') ? 1.4 : 1.0;
    return (base * mult * mkt * (0.6 + d.ctx.roll() * 0.8)).round();
  }

  /// kind: photo | video | live
  static void post(LifeDraft d, String kind) {
    if (d.age < 12) {
      d.warn('Muito jovem', 'Redes sociais a partir dos 12 anos.');
      return;
    }
    if (!d.useAction('post', 6) || !d.useEnergy(kind == 'live' ? 15 : 6)) return;
    d.x.bump('socialPosts');
    final viralP = (kind == 'video' ? 0.12 : kind == 'live' ? 0.08 : 0.06) + d.c.charisma / 600 + d.c.fame / 500;
    final viral = d.ctx.chance(viralP);
    final base = kind == 'video' ? 180 : kind == 'live' ? 120 : 80;
    var gained = _growth(d, base) + (d.x.followers * (viral ? 0.25 : 0.02)).round();
    if (viral) gained = (gained * 8).clamp(2000, 5000000);
    d.x.followers += gained;
    d.stats({'fame': viral ? 6 : (gained > 2000 ? 2 : 1), 'happiness': viral ? 12 : 3});
    double income = 0;
    if (kind == 'live' && d.x.followers > 5000) {
      income = (d.x.followers * 0.02 * (0.5 + d.ctx.roll())).roundToDouble();
      d.money(income);
    }
    final what = kind == 'video' ? 'um vídeo' : kind == 'live' ? 'uma live' : 'uma foto';
    final text = viral
        ? 'VIRALIZOU! Você postou $what e ganhou ${Fmt.compact(gained)} seguidores!'
        : 'Você postou $what e ganhou ${Fmt.compact(gained)} seguidores.${income > 0 ? ' Doações: ${Fmt.money(income)}.' : ''}';
    d.log('social_media', text, icon: 'share', color: '#FF4F9A');
    d.notify(NoticeKind.fame, viral ? Icons.local_fire_department : Icons.photo_camera, viral ? 'Post viral!' : 'Post publicado',
        message: '+${Fmt.compact(gained)} seguidores', celebrate: viral, money: income > 0 ? income : null);
    d.sfx(viral ? GameSfx.achievement : GameSfx.notification);
    if (viral) addHeadline(d, '${d.c.fullName} viraliza na internet');
  }

  static void interview(LifeDraft d) {
    if (d.c.fame < 25) {
      d.warn('Pouco conhecido(a)', 'A imprensa ainda não se interessa por você (fama 25+).');
      return;
    }
    if (!d.useAction('interview', 2) || !d.useEnergy(10)) return;
    final p = 0.5 + d.c.charisma / 200 + d.c.smarts / 400;
    if (d.ctx.chance(p.clamp(0.1, 0.95))) {
      final gained = _growth(d, 2000);
      d.x.followers += gained;
      d.stats({'reputation': 6, 'fame': 4});
      final fee = (d.c.fame * 300).toDouble();
      d.money(fee);
      d.log('fame', 'Entrevista brilhante na TV! +${Fmt.compact(gained)} seguidores e cachê de ${Fmt.money(fee)}.', icon: 'mic', color: '#A855F7');
      d.notify(NoticeKind.fame, Icons.mic, 'Entrevista de sucesso!', message: '+${Fmt.compact(gained)} seguidores', money: fee);
      addHeadline(d, '${d.c.fullName} conquista o público em entrevista');
      d.sfx(GameSfx.positiveEvent);
    } else {
      d.stats({'reputation': -6});
      d.log('fame', 'Você deu uma declaração polêmica na entrevista e foi criticado(a).', icon: 'mic_off', color: '#EF4444');
      d.notify(NoticeKind.warning, Icons.mic_off, 'Entrevista desastrosa', message: '-Reputação');
      addHeadline(d, 'Declaração de ${d.c.fullName} gera polêmica');
      d.sfx(GameSfx.negativeEvent);
    }
  }

  static void publicEvent(LifeDraft d) {
    if (d.c.fame < 40) {
      d.warn('Convite exclusivo', 'Eventos de gala exigem fama 40+.');
      return;
    }
    if (!d.useAction('gala', 2)) return;
    if (!d.pay(5000, what: 'o traje e a produção')) return;
    final gained = _growth(d, 3000);
    d.x.followers += gained;
    d.stats({'fame': 5, 'happiness': 10, 'looks': 1});
    d.log('fame', 'Você brilhou no tapete vermelho de uma premiação. Fotos em todos os portais!', icon: 'star', color: '#FFC53D');
    d.notify(NoticeKind.fame, Icons.star, 'Tapete vermelho!', message: '+${Fmt.compact(gained)} seguidores', celebrate: true, money: -5000);
    addHeadline(d, '${d.c.fullName} rouba a cena em premiação');
    d.sfx(GameSfx.achievement);
  }

  static void seekSponsor(LifeDraft d) {
    if (d.x.followers < 10000) {
      d.warn('Poucos seguidores', 'Marcas procuram perfis com 10 mil+ seguidores.');
      return;
    }
    if (!d.useAction('sponsor', 1)) return;
    if (d.ctx.chance(0.55 + d.c.reputation / 300)) {
      const brands = ['Nimbus Sports', 'Lúmen Cosméticos', 'Órbita Telecom', 'Sabor Real', 'Pulse Fitness', 'Vértice Motors'];
      final pay = (d.x.followers * 0.5).clamp(5000.0, 8000000.0).roundToDouble();
      final s = Sponsorship(brand: d.ctx.pick(brands), annualPay: pay, yearsLeft: d.ctx.range(1, 3));
      d.x.sponsorships.add(s);
      d.log('fame', 'Contrato fechado com ${s.brand}: ${Fmt.money(pay)}/ano por ${s.yearsLeft} ano(s)!', icon: 'handshake', color: '#A855F7');
      d.notify(NoticeKind.fame, Icons.handshake, 'Patrocínio fechado!', message: '${s.brand} · ${Fmt.money(pay)}/ano', celebrate: true);
      d.sfx(GameSfx.promotion);
    } else {
      d.log('fame', 'As marcas recusaram sua proposta de patrocínio este ano.', icon: 'block', color: '#64748B');
      d.notify(NoticeKind.info, Icons.block, 'Nenhuma marca interessada');
    }
  }

  static void yearly(LifeDraft d) {
    // Seguidores e fama esfriam sem atividade
    final active = (d.x.actionsThisYear['post'] ?? 0) > 0 || d.c.currentJobId?.startsWith('ent_') == true ||
        d.c.currentJobId == 'sports_athlete' || d.c.currentJobId == 'pol_politician';
    if (!active) {
      d.x.followers = (d.x.followers * 0.93).round();
      if (d.c.fame > 0) d.stats({'fame': -2});
    }
    if (d.c.fame >= 60 && d.ctx.chance(0.3)) {
      addHeadline(d, d.ctx.pick([
        '${d.c.fullName} é vista(o) jantando em restaurante badalado',
        'Fãs fazem fila para ver ${d.c.fullName}',
        '${d.c.fullName} entra na lista das personalidades do ano',
      ]));
    }
  }
}
