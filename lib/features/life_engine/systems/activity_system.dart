import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'life_draft.dart';

class ActivityDef {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final double cost;
  final int energy;
  final int minAge;
  final int perYear;
  final Map<String, int> effects;
  final String category; // mente | corpo | lazer | social
  final List<String> texts;

  const ActivityDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.colors,
    this.cost = 0,
    this.energy = 10,
    this.minAge = 4,
    this.perYear = 3,
    required this.effects,
    required this.category,
    required this.texts,
  });
}

class LotteryResult {
  final List<int> drawn;
  final int hits;
  final double prize;
  const LotteryResult(this.drawn, this.hits, this.prize);
}

class ActivitySystem {
  static const activities = <ActivityDef>[
    ActivityDef(id: 'gym', name: 'Academia', description: 'Musculação e aeróbico.', icon: Icons.fitness_center, colors: [Color(0xFF22C55E), Color(0xFF15803D)], cost: 120, energy: 15, minAge: 12, perYear: 4,
        effects: {'health': 5, 'fitness': 8, 'looks': 2, 'stress': -6}, category: 'corpo',
        texts: ['Treino pesado! Você saiu da academia renovado(a).', 'Você bateu recorde no supino.', 'Aula de spinning intensa: suor e endorfina.']),
    ActivityDef(id: 'run', name: 'Correr no parque', description: 'Gratuito e revigorante.', icon: Icons.directions_run, colors: [Color(0xFF34D399), Color(0xFF0F766E)], energy: 12, minAge: 8, perYear: 4,
        effects: {'health': 3, 'fitness': 5, 'stress': -5}, category: 'corpo',
        texts: ['Você correu 5 km ao nascer do sol.', 'Uma corrida leve no parque clareou a mente.']),
    ActivityDef(id: 'meditate', name: 'Meditar', description: 'Respire fundo e desacelere.', icon: Icons.self_improvement, colors: [Color(0xFFA78BFA), Color(0xFF6D28D9)], energy: 0, minAge: 8, perYear: 4,
        effects: {'stress': -12, 'happiness': 5, 'health': 1}, category: 'mente',
        texts: ['20 minutos de meditação e sua mente ficou em paz.', 'Você praticou mindfulness e dormiu como um bebê.']),
    ActivityDef(id: 'read', name: 'Ler um livro', description: 'Viaje sem sair do lugar.', icon: Icons.auto_stories, colors: [Color(0xFF60A5FA), Color(0xFF1E40AF)], cost: 50, energy: 6, minAge: 6, perYear: 4,
        effects: {'smarts': 4, 'stress': -4, 'happiness': 3}, category: 'mente',
        texts: ['Você devorou um romance policial em dois dias.', 'Um livro de filosofia mudou sua forma de ver o mundo.']),
    ActivityDef(id: 'cinema', name: 'Cinema', description: 'Pipoca e tela grande.', icon: Icons.movie, colors: [Color(0xFFF472B6), Color(0xFFBE185D)], cost: 45, energy: 5, minAge: 4, perYear: 4,
        effects: {'happiness': 8, 'stress': -8}, category: 'lazer',
        texts: ['O filme de ação foi eletrizante!', 'Uma comédia te fez chorar de rir.', 'Um drama emocionante te deixou pensativo(a).']),
    ActivityDef(id: 'games', name: 'Jogar videogame', description: 'Algumas partidas para relaxar.', icon: Icons.sports_esports, colors: [Color(0xFF818CF8), Color(0xFF3730A3)], energy: 4, minAge: 5, perYear: 4,
        effects: {'happiness': 7, 'stress': -6, 'fitness': -1}, category: 'lazer',
        texts: ['Você zerou aquele jogo que estava esperando!', 'Partidas online com amigos até tarde.']),
    ActivityDef(id: 'concert', name: 'Show de música', description: 'Seu artista favorito ao vivo.', icon: Icons.music_note, colors: [Color(0xFFF59E0B), Color(0xFFB45309)], cost: 350, energy: 12, minAge: 12, perYear: 2,
        effects: {'happiness': 14, 'stress': -10}, category: 'lazer',
        texts: ['Show inesquecível! Você cantou todas as músicas.', 'A banda tocou sua música favorita no bis.']),
    ActivityDef(id: 'spa', name: 'Dia de spa', description: 'Massagem, sauna e cuidados.', icon: Icons.spa, colors: [Color(0xFF5EEAD4), Color(0xFF0F766E)], cost: 600, energy: 0, minAge: 16, perYear: 2,
        effects: {'stress': -20, 'looks': 3, 'happiness': 8}, category: 'corpo',
        texts: ['Uma massagem relaxante tirou todos os nós das costas.']),
    ActivityDef(id: 'vacation', name: 'Férias', description: 'Uma viagem para recarregar.', icon: Icons.flight_takeoff, colors: [Color(0xFF22D3EE), Color(0xFF0369A1)], cost: 4500, energy: 0, minAge: 18, perYear: 1,
        effects: {'happiness': 25, 'stress': -30, 'health': 4}, category: 'lazer',
        texts: ['Férias em Fernando de Noronha: praias paradisíacas!', 'Mochilão pela Europa: museus, trens e muita história.', 'Uma semana nas montanhas geladas da Patagônia.', 'Resort all-inclusive no Caribe!']),
    ActivityDef(id: 'shopping', name: 'Compras no Shopping', description: 'Roupas novas e acessórios.', icon: Icons.shopping_bag, colors: [Color(0xFFEC4899), Color(0xFFBE185D)], cost: 350, energy: 6, minAge: 12, perYear: 4,
        effects: {'happiness': 10, 'looks': 4, 'stress': -8}, category: 'lazer',
        texts: ['Você renovou o guarda-roupa com roupas estilosas.', 'Dia de compras no shopping! Sacolas cheias e sorriso no rosto.']),
    ActivityDef(id: 'volunteer', name: 'Voluntariado', description: 'Ajude quem precisa.', icon: Icons.volunteer_activism, colors: [Color(0xFFFB7185), Color(0xFFBE123C)], energy: 12, minAge: 10, perYear: 2,
        effects: {'karma': 10, 'happiness': 6, 'reputation': 3}, category: 'social',
        texts: ['Você ajudou a servir refeições num abrigo.', 'Você deu aula de reforço para crianças da comunidade.']),
  ];

  static const hobbies = <String, IconData>{
    'Pintura': Icons.brush,
    'Violão': Icons.music_note,
    'Fotografia': Icons.camera_alt,
    'Culinária': Icons.soup_kitchen,
    'Jardinagem': Icons.yard,
    'Xadrez': Icons.extension,
    'Dança': Icons.nightlife,
    'Programação': Icons.code,
  };

  static ActivityDef? byId(String id) {
    for (final a in activities) {
      if (a.id == id) return a;
    }
    return null;
  }

  static void perform(LifeDraft d, String id) {
    final a = byId(id);
    if (a == null) return;
    if (d.age < a.minAge) {
      d.warn('Idade mínima: ${a.minAge} anos');
      return;
    }
    if (!d.useAction('act:$id', a.perYear)) return;
    final cost = a.cost * d.ctx.costMult(d.c.country);
    if (cost > 0 && !d.pay(cost, what: a.name.toLowerCase())) {
      d.x.actionsThisYear['act:$id'] = (d.x.actionsThisYear['act:$id'] ?? 1) - 1;
      return;
    }
    if (!d.useEnergy(a.energy)) {
      d.money(cost);
      d.x.actionsThisYear['act:$id'] = (d.x.actionsThisYear['act:$id'] ?? 1) - 1;
      return;
    }
    d.stats(a.effects);
    if (a.category == 'corpo') d.x.bump('healthActions');
    if (a.category == 'lazer' || a.category == 'social') d.x.bump('leisure');
    if (a.id == 'vacation') {
      d.x.bump('vacations');
      d.c = d.c.copyWith(energy: 100);
    }
    final text = d.ctx.pick(a.texts);
    d.log(a.category == 'corpo' ? 'health' : 'lifestyle', '$text${cost > 0 ? ' (${Fmt.money(cost)})' : ''}', icon: 'auto_awesome', color: '#22D3EE');
    d.notify(NoticeKind.info, a.icon, a.name, message: text, money: cost > 0 ? -cost : null);
    d.sfx(GameSfx.positiveEvent);
  }

  static void hobby(LifeDraft d, String name) {
    if (!d.useAction('hobby', 3) || !d.useEnergy(8)) return;
    d.stats({'happiness': 8, 'stress': -10, 'smarts': 2, 'charisma': name == 'Dança' || name == 'Violão' ? 2 : 0});
    d.x.bump('leisure');
    d.log('hobbies', 'Você dedicou a tarde a $name. Que delícia ter um passatempo!', icon: 'palette', color: '#8B5CF6');
    d.notify(NoticeKind.info, hobbies[name] ?? Icons.palette, 'Hobby: $name', message: '+Felicidade  −Estresse');
    d.sfx(GameSfx.positiveEvent);
  }

  static void adoptPet(LifeDraft d, String type, String name) {
    if (d.age < 6) {
      d.warn('Muito jovem', 'Peça para seus pais quando for maior!');
      return;
    }
    if (d.x.pets.where((p) => p.alive).length >= 4) {
      d.warn('Casa cheia', 'Você já tem pets demais.');
      return;
    }
    const fee = 150.0;
    if (!d.pay(fee, what: 'a adoção')) return;
    d.x.pets.add(Pet(id: d.ctx.id(), name: name, type: type));
    d.stats({'happiness': 18, 'stress': -10, 'karma': 8});
    d.log('pets', 'Você adotou um(a) $type chamado(a) "$name"! A casa ficou cheia de amor.', icon: 'pets', color: '#F59E0B');
    d.notify(NoticeKind.family, Icons.pets, 'Novo membro da família!', message: '$name, seu/sua $type', celebrate: true);
    d.sfx(GameSfx.birth);
  }

  static void petPlay(LifeDraft d, String petId) {
    final p = d.x.pets.where((e) => e.id == petId && e.alive).firstOrNull;
    if (p == null) return;
    if (!d.useAction('pet:$petId', 3)) return;
    p.bond = (p.bond + 10).clamp(0, 100);
    d.stats({'happiness': 6, 'stress': -6});
    d.log('pets', 'Você brincou com ${p.name}. Pura alegria!', icon: 'pets', color: '#F59E0B');
    d.notify(NoticeKind.family, Icons.pets, 'Brincadeira com ${p.name}');
  }

  /// Loteria (6 dezenas de 1 a 60). Retorna o resultado para a UI animar.
  static LotteryResult lottery(LifeDraft d, List<int> chosen) {
    const ticket = 5.0;
    if (d.age < 18) {
      d.warn('Menor de idade', 'Loteria apenas para maiores de 18 anos.');
      return const LotteryResult([], 0, 0);
    }
    if (!d.pay(ticket, what: 'o bilhete')) return const LotteryResult([], 0, 0);
    final drawn = <int>{};
    while (drawn.length < 6) {
      drawn.add(1 + d.ctx.rng.nextInt(60));
    }
    final hits = chosen.where(drawn.contains).length;
    final prize = switch (hits) { 6 => 12500000.0, 5 => 45000.0, 4 => 1800.0, 3 => 25.0, _ => 0.0 };
    d.money(prize);
    d.x.bump('lotteryTickets');
    if (prize >= 45000) d.x.bump('bigWins');
    final text = prize > 0
        ? 'Loteria: você acertou $hits dezenas e ganhou ${Fmt.money(prize)}!'
        : 'Loteria: você acertou $hits dezena(s). Não foi dessa vez.';
    d.log('lottery', text, icon: 'casino', color: prize > 0 ? '#FFC53D' : '#64748B');
    d.stats({'happiness': prize > 1000 ? 25 : (prize > 0 ? 3 : -1)});
    if (prize > 0) {
      d.notify(NoticeKind.money, Icons.casino, hits >= 5 ? 'PRÊMIO GRANDE!' : 'Você ganhou!', message: '$hits acertos', celebrate: hits >= 4, money: prize);
      d.sfx(hits >= 5 ? GameSfx.lotteryWin : GameSfx.moneyGain);
    } else {
      d.sfx(GameSfx.moneyLoss);
    }
    return LotteryResult(drawn.toList()..sort(), hits, prize);
  }
}
