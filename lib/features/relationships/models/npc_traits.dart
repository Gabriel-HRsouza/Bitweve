import 'package:flutter/material.dart';

import 'package:bitweve/features/relationships/models/npc_model.dart';

/// Personalidade de um NPC. Cada uma altera a chance de aceitar ações sociais.
class Personality {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  /// Modificador (−0.4 .. +0.4) aplicado à chance de sucesso de cada ação.
  final Map<String, double> likes;

  const Personality(this.id, this.label, this.description, this.icon, this.color, this.likes);
}

class Interest {
  final String id;
  final String label;
  final IconData icon;
  const Interest(this.id, this.label, this.icon);
}

/// Traços derivados de forma determinística do id do NPC — cada pessoa é
/// diferente, mas sempre a mesma entre sessões (não exige migração do banco).
class NpcTraits {
  final Personality personality;
  final List<Interest> interests;
  final int basePopularity; // 0..100
  final int pickiness; // 0..100 (exigência em romance/amizade)
  final String socialStatus; // descrição curta
  final List<String> quirks;

  const NpcTraits({
    required this.personality,
    required this.interests,
    required this.basePopularity,
    required this.pickiness,
    required this.socialStatus,
    required this.quirks,
  });

  static const personalities = <Personality>[
    Personality('outgoing', 'Extrovertido(a)', 'Adora gente, festas e conversa fiada.', Icons.campaign_rounded, Color(0xFFF97316),
        {'talk': 0.15, 'party': 0.3, 'hangout': 0.2, 'joke': 0.1, 'befriend': 0.15}),
    Personality('shy', 'Tímido(a)', 'Leva tempo para se abrir. Gestos gentis funcionam melhor.', Icons.visibility_off_rounded, Color(0xFF94A3B8),
        {'flirt': -0.25, 'party': -0.25, 'compliment': 0.15, 'talk': 0.05, 'askOut': -0.1, 'joke': -0.1}),
    Personality('sarcastic', 'Sarcástico(a)', 'Humor ácido. Elogios exagerados soam falsos.', Icons.theater_comedy_rounded, Color(0xFFA855F7),
        {'joke': 0.3, 'compliment': -0.15, 'argue': 0.1, 'talk': 0.05}),
    Personality('romantic', 'Romântico(a)', 'Sonha com grandes gestos e declarações.', Icons.favorite_rounded, Color(0xFFFF4F9A),
        {'flirt': 0.2, 'askOut': 0.15, 'gift': 0.2, 'compliment': 0.1, 'propose': 0.15}),
    Personality('competitive', 'Competitivo(a)', 'Quer ganhar sempre. Respeita quem se destaca.', Icons.emoji_events_rounded, Color(0xFFEAB308),
        {'argue': 0.15, 'joke': -0.05, 'hangout': 0.05, 'befriend': -0.05}),
    Personality('kind', 'Gentil', 'Acolhedor(a) e paciente. Perdoa com facilidade.', Icons.volunteer_activism_rounded, Color(0xFF22C55E),
        {'apologize': 0.3, 'reconcile': 0.3, 'befriend': 0.2, 'talk': 0.1, 'argue': -0.2}),
    Personality('grumpy', 'Ranzinza', 'Difícil de agradar. Valoriza sinceridade.', Icons.sentiment_dissatisfied_rounded, Color(0xFF64748B),
        {'talk': -0.1, 'joke': -0.25, 'party': -0.2, 'flirt': -0.2, 'compliment': -0.1, 'befriend': -0.15}),
    Personality('intellectual', 'Intelectual', 'Ama boas conversas, livros e ideias.', Icons.psychology_rounded, Color(0xFF3B82F6),
        {'talk': 0.25, 'joke': -0.05, 'party': -0.1, 'study': 0.3}),
    Personality('partier', 'Festeiro(a)', 'Nunca perde um rolê. Vive o momento.', Icons.nightlife_rounded, Color(0xFFEC4899),
        {'party': 0.35, 'hangout': 0.2, 'joke': 0.15, 'talk': -0.05}),
    Personality('reserved', 'Reservado(a)', 'Discreto(a). Prefere poucos e bons amigos.', Icons.lock_person_rounded, Color(0xFF0EA5E9),
        {'befriend': -0.1, 'party': -0.15, 'talk': 0.05, 'gift': 0.1, 'flirt': -0.1}),
    Personality('sporty', 'Esportista', 'Treina todo dia e ama competição saudável.', Icons.sports_basketball_rounded, Color(0xFF14B8A6),
        {'hangout': 0.15, 'party': 0.05, 'joke': 0.05, 'study': -0.1}),
    Personality('artsy', 'Artista', 'Sensível e criativo(a). Valoriza autenticidade.', Icons.palette_rounded, Color(0xFFD946EF),
        {'compliment': 0.15, 'gift': 0.1, 'talk': 0.1, 'argue': -0.1}),
  ];

  static const interestCatalog = <Interest>[
    Interest('music', 'Música', Icons.music_note_rounded),
    Interest('games', 'Games', Icons.sports_esports_rounded),
    Interest('sports', 'Esportes', Icons.sports_soccer_rounded),
    Interest('books', 'Livros', Icons.menu_book_rounded),
    Interest('movies', 'Cinema', Icons.movie_rounded),
    Interest('travel', 'Viagens', Icons.flight_rounded),
    Interest('cooking', 'Culinária', Icons.restaurant_rounded),
    Interest('fashion', 'Moda', Icons.checkroom_rounded),
    Interest('tech', 'Tecnologia', Icons.memory_rounded),
    Interest('art', 'Arte', Icons.brush_rounded),
    Interest('nature', 'Natureza', Icons.forest_rounded),
    Interest('fitness', 'Academia', Icons.fitness_center_rounded),
    Interest('pets', 'Pets', Icons.pets_rounded),
    Interest('dance', 'Dança', Icons.music_video_rounded),
    Interest('science', 'Ciência', Icons.science_rounded),
    Interest('cars', 'Carros', Icons.directions_car_rounded),
    Interest('photo', 'Fotografia', Icons.photo_camera_rounded),
    Interest('volunteer', 'Voluntariado', Icons.handshake_rounded),
  ];

  static Interest interest(String id) => interestCatalog.firstWhere((i) => i.id == id, orElse: () => interestCatalog.first);
  static Personality personalityById(String id) => personalities.firstWhere((p) => p.id == id, orElse: () => personalities.first);

  static const _quirks = [
    'Coleciona vinis antigos', 'Ri alto de tudo', 'Sempre chega atrasado(a)', 'Fala com as plantas',
    'Sabe todas as letras de música', 'Odeia segunda-feira', 'Faz trilhas aos domingos', 'Cozinha muito bem',
    'Tem medo de altura', 'É viciado(a) em café', 'Faz piadas ruins', 'Desenha nos cadernos', 'Ama filmes de terror',
    'Já morou em outro país', 'Treina para maratonas', 'Escreve poesia em segredo', 'Tem três gatos',
    'Joga xadrez online', 'Sonha em ser famoso(a)', 'Sempre defende os amigos', 'Guarda rancor por anos',
    'Planeja tudo em planilhas', 'Vive de dieta', 'Coleciona tênis', 'Toca violão na roda',
  ];

  static int _hash(String s) {
    var h = 0x811C9DC5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return h;
  }

  static final Map<String, NpcTraits> _cache = {};

  /// Traços do NPC. Usa o id como semente.
  static NpcTraits of(NpcModel n) => fromSeed(n.id);

  static NpcTraits fromSeed(String seed) {
    final cached = _cache[seed];
    if (cached != null) return cached;
    final h = _hash(seed);
    final p = personalities[h % personalities.length];
    final ints = <Interest>[];
    var k = h;
    while (ints.length < 3) {
      final it = interestCatalog[k % interestCatalog.length];
      if (!ints.contains(it)) ints.add(it);
      k = (k ~/ 7) + 13 * (ints.length + 1);
    }
    final pop = (h ~/ 13) % 101;
    final picky = (h ~/ 101) % 101;
    final q1 = _quirks[(h ~/ 17) % _quirks.length];
    final q2 = _quirks[(h ~/ 29 + 5) % _quirks.length];
    final status = pop > 80
        ? 'Muito popular'
        : pop > 55
            ? 'Bem relacionado(a)'
            : pop > 30
                ? 'Na média'
                : 'Pouco conhecido(a)';
    final t = NpcTraits(
      personality: p,
      interests: ints,
      basePopularity: pop,
      pickiness: picky,
      socialStatus: status,
      quirks: q1 == q2 ? [q1] : [q1, q2],
    );
    if (_cache.length > 3000) _cache.clear();
    _cache[seed] = t;
    return t;
  }

  /// Modificador de aceitação para uma ação.
  double modifierFor(String actionId) => personality.likes[actionId] ?? 0;

  /// Compatibilidade (0..100) entre os interesses do jogador e deste NPC.
  int interestMatch(List<String> mine) {
    if (mine.isEmpty) return 35;
    final shared = interests.where((i) => mine.contains(i.id)).length;
    return (25 + shared * 25).clamp(0, 100);
  }
}

/// Estado dinâmico e persistido de um NPC (fica em LifeExtras.npcMeta).
class NpcMeta {
  bool blocked;
  String? nickname;
  int romanceStage; // 0 nenhum · 1 paquera · 2 encontros · 3 namoro · 4 casamento
  int intimacy; // 0..100 (só adultos)
  int lastMood; // −2..2 reação mais recente
  String origin; // school | college | work | dating | prison | social | family | party
  int popularityDelta;
  final List<String> history;

  NpcMeta({
    this.blocked = false,
    this.nickname,
    this.romanceStage = 0,
    this.intimacy = 0,
    this.lastMood = 0,
    this.origin = 'social',
    this.popularityDelta = 0,
    List<String>? history,
  }) : history = history ?? [];

  void addHistory(String s) {
    history.add(s);
    if (history.length > 25) history.removeAt(0);
  }

  Map<String, dynamic> toJson() => {
        'blocked': blocked,
        'nickname': nickname,
        'romanceStage': romanceStage,
        'intimacy': intimacy,
        'lastMood': lastMood,
        'origin': origin,
        'popularityDelta': popularityDelta,
        'history': history,
      };

  factory NpcMeta.fromJson(Map<String, dynamic> j) => NpcMeta(
        blocked: j['blocked'] as bool? ?? false,
        nickname: j['nickname'] as String?,
        romanceStage: j['romanceStage'] as int? ?? 0,
        intimacy: j['intimacy'] as int? ?? 0,
        lastMood: j['lastMood'] as int? ?? 0,
        origin: j['origin'] as String? ?? 'social',
        popularityDelta: j['popularityDelta'] as int? ?? 0,
        history: (j['history'] as List?)?.cast<String>().toList(),
      );
}
