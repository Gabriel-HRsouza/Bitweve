import 'package:flutter/material.dart';

class PartyType {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final double baseCost;
  final int minAge;
  final bool needsProperty;
  final String vibe; // party | family | luxury | chill | academic
  const PartyType(this.id, this.name, this.description, this.icon, this.colors, this.baseCost, this.minAge, this.needsProperty, this.vibe);
}

class PartyOption {
  final String id;
  final String name;
  final IconData icon;
  final double cost; // por convidado (comida) ou fixo
  final int quality; // 0..30
  final String vibe;
  const PartyOption(this.id, this.name, this.icon, this.cost, this.quality, this.vibe);
}

class PartyPlan {
  final String typeId;
  final String? propertyId;
  final List<String> guestIds;
  final int budget; // 0 econômico · 1 padrão · 2 caprichado · 3 sem limites
  final String decor;
  final String food;
  final String music;
  final String activity;

  const PartyPlan({
    required this.typeId,
    this.propertyId,
    required this.guestIds,
    required this.budget,
    required this.decor,
    required this.food,
    required this.music,
    required this.activity,
  });
}

class GuestReaction {
  final String npcId;
  final String name;
  final int score; // −2..2
  final String comment;
  const GuestReaction(this.npcId, this.name, this.score, this.comment);
}

class PartyReport {
  final String title;
  final int rating; // 0..100
  final double cost;
  final List<GuestReaction> guests;
  final List<String> incidents;
  final int popularityGain;
  final bool canPost;
  const PartyReport(this.title, this.rating, this.cost, this.guests, this.incidents, this.popularityGain, this.canPost);

  static const empty = PartyReport('', 0, 0, [], [], 0, false);
}

class PartyCatalog {
  static const types = <PartyType>[
    PartyType('house', 'Festa em casa', 'Reúna os amigos para uma noite descontraída.', Icons.house_rounded,
        [Color(0xFFF97316), Color(0xFFDB2777)], 300, 10, false, 'party'),
    PartyType('birthday', 'Festa de aniversário', 'Bolo, parabéns e muitas fotos.', Icons.cake_rounded,
        [Color(0xFFF472B6), Color(0xFF8B5CF6)], 400, 4, false, 'family'),
    PartyType('friends', 'Encontro com amigos', 'Churrasco, jogos e conversa boa.', Icons.groups_rounded,
        [Color(0xFF22C55E), Color(0xFF0EA5E9)], 250, 12, false, 'chill'),
    PartyType('family', 'Festa de família', 'Almoço caprichado com toda a família.', Icons.family_restroom_rounded,
        [Color(0xFF84CC16), Color(0xFF16A34A)], 350, 18, true, 'family'),
    PartyType('college', 'Festa universitária', 'Open-house da turma com DJ e muito barulho.', Icons.school_rounded,
        [Color(0xFF6366F1), Color(0xFFEC4899)], 600, 17, false, 'party'),
    PartyType('private', 'Festa privada', 'Lista VIP, poucos convidados e muito estilo.', Icons.lock_rounded,
        [Color(0xFF0F172A), Color(0xFF7C3AED)], 2500, 18, true, 'chill'),
    PartyType('luxury', 'Festa de luxo', 'Buffet premium, banda ao vivo e decoração cinematográfica.', Icons.diamond_rounded,
        [Color(0xFFFFC53D), Color(0xFFA16207)], 25000, 21, true, 'luxury'),
  ];

  static PartyType type(String id) => types.firstWhere((t) => t.id == id, orElse: () => types.first);

  static const decors = <PartyOption>[
    PartyOption('none', 'Sem decoração', Icons.not_interested_rounded, 0, 0, 'chill'),
    PartyOption('balloons', 'Balões e faixas', Icons.celebration_rounded, 120, 10, 'family'),
    PartyOption('neon', 'Neon e luz negra', Icons.light_mode_rounded, 450, 18, 'party'),
    PartyOption('rustic', 'Rústica com luzinhas', Icons.emoji_objects_rounded, 380, 16, 'chill'),
    PartyOption('glam', 'Glamour dourado', Icons.auto_awesome_rounded, 3500, 28, 'luxury'),
  ];

  static const foods = <PartyOption>[
    PartyOption('snacks', 'Salgadinhos', Icons.fastfood_rounded, 15, 8, 'party'),
    PartyOption('bbq', 'Churrasco', Icons.outdoor_grill_rounded, 40, 18, 'chill'),
    PartyOption('pizza', 'Pizza', Icons.local_pizza_rounded, 25, 14, 'party'),
    PartyOption('homemade', 'Comida caseira', Icons.soup_kitchen_rounded, 30, 18, 'family'),
    PartyOption('buffet', 'Buffet premium', Icons.room_service_rounded, 180, 30, 'luxury'),
  ];

  static const musics = <PartyOption>[
    PartyOption('playlist', 'Playlist no celular', Icons.queue_music_rounded, 0, 6, 'chill'),
    PartyOption('karaoke', 'Karaokê', Icons.mic_rounded, 200, 16, 'family'),
    PartyOption('dj', 'DJ', Icons.headphones_rounded, 900, 24, 'party'),
    PartyOption('band', 'Banda ao vivo', Icons.music_note_rounded, 4000, 28, 'luxury'),
  ];

  static const activities = <PartyOption>[
    PartyOption('talk', 'Só conversa', Icons.forum_rounded, 0, 6, 'chill'),
    PartyOption('games', 'Jogos de tabuleiro/videogame', Icons.sports_esports_rounded, 80, 14, 'chill'),
    PartyOption('dance', 'Pista de dança', Icons.nightlife_rounded, 150, 18, 'party'),
    PartyOption('pool', 'Piscina', Icons.pool_rounded, 100, 20, 'party'),
    PartyOption('show', 'Show de mágica / atração', Icons.theater_comedy_rounded, 1200, 22, 'family'),
    PartyOption('casino', 'Cassino temático (fichas sem valor)', Icons.casino_rounded, 2500, 26, 'luxury'),
  ];

  static PartyOption pick(List<PartyOption> list, String id) => list.firstWhere((o) => o.id == id, orElse: () => list.first);

  static const budgetLabels = ['Econômico', 'Padrão', 'Caprichado', 'Sem limites'];
  static const budgetMult = [0.7, 1.0, 1.6, 2.6];
}
