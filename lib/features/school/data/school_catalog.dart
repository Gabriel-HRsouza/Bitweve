import 'dart:math';

import 'package:flutter/material.dart';

class SchoolActivity {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int minAge;
  final double cost;
  final Map<String, int> effects;
  final int popularity;
  final String? interest;

  const SchoolActivity(this.id, this.name, this.description, this.icon, this.color,
      {this.minAge = 6, this.cost = 0, this.effects = const {}, this.popularity = 3, this.interest});
}

class Clique {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String stat; // atributo exigido
  final int min;
  const Clique(this.id, this.name, this.description, this.icon, this.color, this.stat, this.min);
}

class Institution {
  final String id;
  final String name;
  final String tier; // public | private | elite | online
  final double costMult;
  final double entryMod; // somado à chance do vestibular
  final int prestige; // 0..100 (bônus em entrevistas)
  final IconData icon;
  final Color color;
  final String city;
  const Institution(this.id, this.name, this.tier, this.costMult, this.entryMod, this.prestige, this.icon, this.color, this.city);

  String get tierLabel => switch (tier) {
        'public' => 'Pública',
        'private' => 'Particular',
        'elite' => 'Elite',
        _ => 'EAD',
      };
}

class SchoolCatalog {
  // ------------------------------------------------------------------ escolas
  static const _schoolPrefix = ['Escola Estadual', 'Colégio', 'Escola Municipal', 'Instituto', 'Colégio Integrado', 'Escola'];
  static const _schoolNames = [
    'Machado de Assis', 'Cecília Meireles', 'Monteiro Lobato', 'Santos Dumont', 'Anita Garibaldi', 'Tiradentes',
    'Dom Pedro II', 'Clarice Lispector', 'Oswaldo Cruz', 'Carlos Drummond', 'Rui Barbosa', 'Vinícius de Moraes',
    'Nova Geração', 'Horizonte', 'Aurora', 'Saber Vivo', 'Pequeno Príncipe', 'Arco-Íris', 'Vila Verde', 'Novo Tempo',
    'Portinari', 'Zilda Arns', 'Paulo Freire', 'Darcy Ribeiro', 'Chico Mendes', 'Bertha Lutz', 'Cora Coralina',
  ];

  static String randomSchoolName(Random rng, String type) {
    final prefix = type == 'public'
        ? (rng.nextBool() ? 'Escola Estadual' : 'Escola Municipal')
        : _schoolPrefix[rng.nextInt(_schoolPrefix.length)];
    final name = _schoolNames[rng.nextInt(_schoolNames.length)];
    final suffix = type == 'elite' ? ' International' : '';
    return '$prefix $name$suffix';
  }

  static String schoolTypeLabel(String t) => switch (t) {
        'private' => 'Particular',
        'elite' => 'Internacional (elite)',
        _ => 'Pública',
      };

  static double schoolYearCost(String t) => switch (t) {
        'private' => 14000,
        'elite' => 60000,
        _ => 0,
      };

  // ------------------------------------------------------------------ extracurriculares
  static const clubs = <SchoolActivity>[
    SchoolActivity('soccer', 'Time de Futebol', 'Treinos, campeonatos interclasses e muita resenha.', Icons.sports_soccer_rounded, Color(0xFF22C55E),
        effects: {'fitness': 4, 'health': 2, 'charisma': 1}, popularity: 6, interest: 'sports'),
    SchoolActivity('volley', 'Vôlei', 'Saque, bloqueio e espírito de equipe.', Icons.sports_volleyball_rounded, Color(0xFFF59E0B),
        effects: {'fitness': 3, 'charisma': 2}, popularity: 5, interest: 'sports'),
    SchoolActivity('chess', 'Clube de Xadrez', 'Estratégia, concentração e torneios.', Icons.extension_rounded, Color(0xFF64748B),
        effects: {'smarts': 4, 'discipline': 2}, popularity: 1, interest: 'games'),
    SchoolActivity('theater', 'Grupo de Teatro', 'Ensaios, figurinos e a peça do fim de ano.', Icons.theater_comedy_rounded, Color(0xFFEC4899),
        effects: {'charisma': 4, 'happiness': 3}, popularity: 5, interest: 'art'),
    SchoolActivity('band', 'Banda da Escola', 'Ensaios e apresentações nas festas.', Icons.music_note_rounded, Color(0xFFA855F7),
        effects: {'happiness': 4, 'charisma': 2}, popularity: 5, interest: 'music'),
    SchoolActivity('robotics', 'Robótica', 'Monte robôs e dispute olimpíadas.', Icons.smart_toy_rounded, Color(0xFF3B82F6),
        minAge: 10, effects: {'smarts': 5, 'discipline': 1}, popularity: 2, interest: 'tech'),
    SchoolActivity('debate', 'Clube de Debate', 'Argumentação e oratória.', Icons.record_voice_over_rounded, Color(0xFF0EA5E9),
        minAge: 11, effects: {'smarts': 3, 'charisma': 3}, popularity: 3, interest: 'books'),
    SchoolActivity('art', 'Oficina de Artes', 'Pintura, grafite e exposições.', Icons.palette_rounded, Color(0xFFD946EF),
        effects: {'happiness': 4, 'stress': -4}, popularity: 2, interest: 'art'),
    SchoolActivity('newspaper', 'Jornal da Escola', 'Reportagens, entrevistas e fofocas do recreio.', Icons.newspaper_rounded, Color(0xFFFB7185),
        minAge: 10, effects: {'smarts': 2, 'charisma': 2}, popularity: 4, interest: 'photo'),
    SchoolActivity('dance', 'Grupo de Dança', 'Coreografias e festivais.', Icons.music_video_rounded, Color(0xFFF472B6),
        effects: {'fitness': 3, 'looks': 1, 'happiness': 3}, popularity: 5, interest: 'dance'),
    SchoolActivity('student_council', 'Grêmio Estudantil', 'Representar os alunos e organizar eventos.', Icons.how_to_vote_rounded, Color(0xFF14B8A6),
        minAge: 12, effects: {'charisma': 3, 'reputation': 3}, popularity: 7),
    SchoolActivity('volunteer', 'Voluntariado', 'Campanhas solidárias na comunidade.', Icons.volunteer_activism_rounded, Color(0xFF10B981),
        effects: {'karma': 5, 'happiness': 3}, popularity: 3, interest: 'volunteer'),
  ];

  static SchoolActivity? club(String id) {
    for (final c in clubs) {
      if (c.id == id) return c;
    }
    for (final c in collegeClubs) {
      if (c.id == id) return c;
    }
    return null;
  }

  static const cliques = <Clique>[
    Clique('jocks', 'Atletas', 'A galera dos esportes. Popularidade garantida no recreio.', Icons.sports_basketball_rounded, Color(0xFFF97316), 'fitness', 55),
    Clique('nerds', 'Nerds', 'Olimpíadas, games e debates sobre ficção científica.', Icons.psychology_rounded, Color(0xFF3B82F6), 'smarts', 60),
    Clique('populars', 'Populares', 'Os mais disputados nas festas.', Icons.star_rounded, Color(0xFFFFC53D), 'looks', 60),
    Clique('artists', 'Artistas', 'Música, desenho e alma criativa.', Icons.palette_rounded, Color(0xFFD946EF), 'charisma', 40),
    Clique('rebels', 'Rebeldes', 'Desafiam as regras — e às vezes levam advertência.', Icons.bolt_rounded, Color(0xFFEF4444), 'charisma', 35),
    Clique('gamers', 'Gamers', 'Campeonatos de e-sports no intervalo.', Icons.sports_esports_rounded, Color(0xFF8B5CF6), 'smarts', 35),
  ];

  static Clique? clique(String? id) {
    for (final c in cliques) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ------------------------------------------------------------------ eventos escolares
  static const schoolEvents = <SchoolActivity>[
    SchoolActivity('science_fair', 'Feira de Ciências', 'Apresente um projeto para a escola toda.', Icons.science_rounded, Color(0xFF06B6D4),
        effects: {'smarts': 3}, popularity: 3),
    SchoolActivity('field_trip', 'Excursão', 'Passeio da turma a um museu ou parque.', Icons.directions_bus_rounded, Color(0xFF22C55E),
        cost: 120, effects: {'happiness': 6, 'stress': -5}, popularity: 3),
    SchoolActivity('sports_day', 'Jogos Interclasses', 'Competição esportiva entre as turmas.', Icons.emoji_events_rounded, Color(0xFFF59E0B),
        effects: {'fitness': 3, 'happiness': 3}, popularity: 5),
    SchoolActivity('talent_show', 'Show de Talentos', 'Suba no palco e mostre o que sabe fazer.', Icons.mic_rounded, Color(0xFFEC4899),
        minAge: 8, effects: {'charisma': 3}, popularity: 8),
    SchoolActivity('festa_junina', 'Festa Junina', 'Quadrilha, pescaria e comidas típicas.', Icons.local_fire_department_rounded, Color(0xFFF97316),
        cost: 40, effects: {'happiness': 6}, popularity: 3),
  ];

  // ------------------------------------------------------------------ faculdade
  static const institutions = <Institution>[
    Institution('uf_capital', 'Universidade Federal da Capital', 'public', 0.0, -0.18, 85, Icons.account_balance_rounded, Color(0xFF2563EB), 'Capital'),
    Institution('ue_estadual', 'Universidade Estadual Paulista do Saber', 'public', 0.0, -0.12, 78, Icons.account_balance_rounded, Color(0xFF0EA5E9), 'Interior'),
    Institution('if_tech', 'Instituto Federal de Tecnologia', 'public', 0.0, -0.08, 70, Icons.precision_manufacturing_rounded, Color(0xFF22C55E), 'Capital'),
    Institution('puc_horizonte', 'Pontifícia Universidade Horizonte', 'private', 1.15, 0.0, 72, Icons.church_rounded, Color(0xFF8B5CF6), 'Capital'),
    Institution('unibrasil', 'Centro Universitário UniBrasil', 'private', 0.8, 0.12, 45, Icons.apartment_rounded, Color(0xFFF59E0B), 'Região Metropolitana'),
    Institution('mackenzie_nova', 'Universidade Nova Aliança', 'private', 1.0, 0.04, 60, Icons.domain_rounded, Color(0xFFEF4444), 'Capital'),
    Institution('insper_elite', 'Instituto de Excelência Atlas', 'elite', 1.9, -0.15, 95, Icons.diamond_rounded, Color(0xFFFFC53D), 'Capital'),
    Institution('global_univ', 'Global Ivy University (exterior)', 'elite', 3.0, -0.22, 99, Icons.public_rounded, Color(0xFFD946EF), 'Exterior'),
    Institution('ead_conecta', 'Conecta EAD', 'online', 0.45, 0.25, 30, Icons.laptop_chromebook_rounded, Color(0xFF14B8A6), 'Online'),
  ];

  static Institution institution(String? id) =>
      institutions.firstWhere((i) => i.id == id, orElse: () => institutions[4]);

  static const collegeClubs = <SchoolActivity>[
    SchoolActivity('atletica', 'Atlética', 'Jogos universitários, festas e torcida organizada.', Icons.sports_rounded, Color(0xFFF97316),
        minAge: 17, effects: {'fitness': 3, 'happiness': 3}, popularity: 7, interest: 'sports'),
    SchoolActivity('centro_academico', 'Centro Acadêmico', 'Política estudantil e organização de eventos.', Icons.groups_rounded, Color(0xFF14B8A6),
        minAge: 17, effects: {'charisma': 3, 'reputation': 2}, popularity: 5),
    SchoolActivity('empresa_jr', 'Empresa Júnior', 'Consultoria real para clientes reais.', Icons.business_center_rounded, Color(0xFF3B82F6),
        minAge: 17, effects: {'smarts': 3, 'discipline': 3}, popularity: 3),
    SchoolActivity('pesquisa', 'Iniciação Científica', 'Laboratório, artigos e congressos.', Icons.biotech_rounded, Color(0xFF06B6D4),
        minAge: 17, effects: {'smarts': 5}, popularity: 1, interest: 'science'),
    SchoolActivity('bateria', 'Bateria Universitária', 'Ritmo, ensaios e apresentações.', Icons.music_note_rounded, Color(0xFFA855F7),
        minAge: 17, effects: {'happiness': 4, 'charisma': 2}, popularity: 5, interest: 'music'),
    SchoolActivity('extensao', 'Projeto de Extensão', 'Leve o conhecimento para a comunidade.', Icons.volunteer_activism_rounded, Color(0xFF10B981),
        minAge: 17, effects: {'karma': 4, 'reputation': 3}, popularity: 3, interest: 'volunteer'),
  ];

  static const _companyA = ['Nexo', 'Vértice', 'Prisma', 'Atlas', 'Órbita', 'Lumen', 'Ápice', 'Fluxo', 'Ômega', 'Sigma', 'Kora', 'Brava'];
  static const _companyB = ['Tech', 'Consultoria', 'Saúde', 'Engenharia', 'Digital', 'Labs', 'Investimentos', 'Comunicação', 'Group', 'Soluções'];

  /// Vagas de estágio (determinísticas por ano e curso).
  static List<(String company, double pay, int selectivity)> internships(String degreeId, int year) {
    final rng = Random(degreeId.hashCode ^ (year * 7919));
    return List.generate(4, (i) {
      final name = '${_companyA[rng.nextInt(_companyA.length)]} ${_companyB[rng.nextInt(_companyB.length)]}';
      final pay = (12000 + rng.nextInt(16) * 1500).toDouble();
      final sel = 30 + rng.nextInt(60);
      return (name, pay, sel);
    });
  }
}
