import 'package:flutter/material.dart';

class PersonalityOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Map<String, int> stats;
  const PersonalityOption(this.id, this.name, this.description, this.icon, this.color, this.stats);
}

class TraitOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Map<String, int> stats;
  const TraitOption(this.id, this.name, this.description, this.icon, this.stats);
}

class FamilyOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final double minNetWorth;
  final double maxNetWorth;
  final double minSalary;
  final double maxSalary;
  final double gift18; // presente aproximado aos 18
  const FamilyOption(this.id, this.name, this.description, this.icon, this.color, this.minNetWorth, this.maxNetWorth,
      this.minSalary, this.maxSalary, this.gift18);
}

/// Estrutura de criação vinda da tela de criação de personagem.
class CharacterSetup {
  final String firstName;
  final String lastName;
  final String gender;
  final String sexualOrientation;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final String countryId;
  final String? city;
  final String familyWealth;
  final int siblings;
  final bool parentsTogether;
  final String personality;
  final List<String> traits;
  final dynamic avatar; // AvatarConfig (dynamic para evitar import circular)

  const CharacterSetup({
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.sexualOrientation = 'heterosexual',
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.countryId,
    this.city,
    this.familyWealth = 'middle',
    this.siblings = 0,
    this.parentsTogether = true,
    this.personality = 'balanced',
    this.traits = const [],
    this.avatar,
  });
}

class CharacterOptions {
  static const personalities = <PersonalityOption>[
    PersonalityOption('balanced', 'Equilibrado', 'Um pouco de tudo, sem extremos.', Icons.balance, Color(0xFF94A3B8), {}),
    PersonalityOption('extrovert', 'Extrovertido', 'Ama gente, festas e ser o centro das atenções.', Icons.celebration, Color(0xFFF59E0B), {'charisma': 15, 'happiness': 5, 'discipline': -5}),
    PersonalityOption('introvert', 'Introvertido', 'Profundo, observador e reflexivo.', Icons.headphones, Color(0xFF6366F1), {'smarts': 10, 'discipline': 5, 'charisma': -6}),
    PersonalityOption('creative', 'Criativo', 'Ideias fervilhando e olhar artístico.', Icons.palette, Color(0xFFEC4899), {'smarts': 6, 'happiness': 6, 'charisma': 4}),
    PersonalityOption('ambitious', 'Ambicioso', 'Metas altas e determinação de aço.', Icons.trending_up, Color(0xFF22C55E), {'discipline': 15, 'stress': 6, 'smarts': 3}),
    PersonalityOption('calm', 'Tranquilo', 'Nada tira sua paz.', Icons.spa, Color(0xFF14B8A6), {'stress': -10, 'health': 5, 'happiness': 4}),
    PersonalityOption('rebel', 'Rebelde', 'Regras foram feitas para serem quebradas.', Icons.bolt, Color(0xFFEF4444), {'charisma': 8, 'karma': -10, 'discipline': -8}),
    PersonalityOption('kind', 'Gentil', 'Coração enorme e empatia sem fim.', Icons.volunteer_activism, Color(0xFFFB7185), {'karma': 15, 'reputation': 6, 'charisma': 3}),
    PersonalityOption('analytical', 'Analítico', 'Lógica, números e pensamento crítico.', Icons.psychology, Color(0xFF3B82F6), {'smarts': 15, 'charisma': -5}),
  ];

  static const traits = <TraitOption>[
    TraitOption('athletic', 'Atlético', 'Corpo feito para o esporte.', Icons.directions_run, {'fitness': 15, 'health': 5}),
    TraitOption('beautiful', 'Beleza marcante', 'Chama atenção por onde passa.', Icons.auto_awesome, {'looks': 15}),
    TraitOption('tall', 'Alto', 'Estatura acima da média.', Icons.height, {'looks': 5, 'fitness': 3}),
    TraitOption('iron_health', 'Saúde de ferro', 'Raramente fica doente.', Icons.health_and_safety, {'health': 10}),
    TraitOption('memory', 'Memória fotográfica', 'Aprende tudo com facilidade.', Icons.memory, {'smarts': 12}),
    TraitOption('charming', 'Carismático', 'Conquista qualquer um com um sorriso.', Icons.sentiment_very_satisfied, {'charisma': 12}),
    TraitOption('lucky', 'Sortudo', 'A sorte sorri para você nas decisões arriscadas.', Icons.casino, {'karma': 5}),
    TraitOption('disciplined', 'Disciplinado', 'Rotina e foco inabaláveis.', Icons.schedule, {'discipline': 15}),
  ];

  static const families = <FamilyOption>[
    FamilyOption('poor', 'Humilde', 'Pouco dinheiro, muito amor.', Icons.cottage, Color(0xFF94A3B8), 3000, 25000, 18000, 32000, 300),
    FamilyOption('middle', 'Classe média', 'Vida confortável e estável.', Icons.house, Color(0xFF22C55E), 60000, 250000, 40000, 90000, 3000),
    FamilyOption('rich', 'Rica', 'Viagens, escola particular e mesada farta.', Icons.villa, Color(0xFF3B82F6), 900000, 4000000, 250000, 600000, 40000),
    FamilyOption('elite', 'Milionária', 'Herdeiro(a) de um império.', Icons.diamond, Color(0xFFFFC53D), 15000000, 60000000, 1500000, 4000000, 300000),
  ];

  static PersonalityOption personality(String id) =>
      personalities.firstWhere((p) => p.id == id, orElse: () => personalities.first);
  static TraitOption? trait(String id) {
    for (final t in traits) {
      if (t.id == id) return t;
    }
    return null;
  }

  static FamilyOption family(String id) => families.firstWhere((f) => f.id == id, orElse: () => families[1]);

  static const months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  static String zodiac(int day, int month) {
    const signs = [
      [20, 'Capricórnio', 'Aquário'], [19, 'Aquário', 'Peixes'], [21, 'Peixes', 'Áries'],
      [20, 'Áries', 'Touro'], [21, 'Touro', 'Gêmeos'], [21, 'Gêmeos', 'Câncer'],
      [23, 'Câncer', 'Leão'], [23, 'Leão', 'Virgem'], [23, 'Virgem', 'Libra'],
      [23, 'Libra', 'Escorpião'], [22, 'Escorpião', 'Sagitário'], [22, 'Sagitário', 'Capricórnio'],
    ];
    final s = signs[(month - 1).clamp(0, 11)];
    return day < (s[0] as int) ? s[1] as String : s[2] as String;
  }
}
