import 'dart:math';

import 'package:flutter/material.dart';

import 'package:bitweve/features/careers/data/career_catalog.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';

enum Rarity { common, rare, epic, legendary }

extension RarityX on Rarity {
  String get label => const ['Comum', 'Rara', 'Épica', 'Lendária'][index];
  Color get color => const [Color(0xFF94A3B8), Color(0xFF3B82F6), Color(0xFFA855F7), Color(0xFFFFC53D)][index];
}

typedef ProgressFn = double Function(LifeEngineState s);

double _ratio(num v, num target) => target <= 0 ? 1 : (v / target).clamp(0.0, 1.0).toDouble();

int _children(LifeEngineState s) => s.npcs.where((n) => n.isChild).length;
int _friends(LifeEngineState s) => s.npcs.where((n) => n.isAlive && n.relationshipType == RelationshipType.friend).length;

int _maxCareerLevelReached(LifeEngineState s) {
  final t = CareerCatalog.byId(s.character.currentJobId);
  if (t == null) return 0;
  return s.extras.careerLevel + 1;
}

bool _atTop(LifeEngineState s) {
  final t = CareerCatalog.byId(s.character.currentJobId);
  return t != null && t.isTop(s.extras.careerLevel);
}

class AchievementDef {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final Rarity rarity;
  final double reward;
  final ProgressFn progress;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.reward,
    required this.progress,
  });
}

class MissionDef {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  /// Missões diárias: contador acompanhado e meta acima da linha de base.
  final String? counter;
  final int target;
  final int minAge;

  /// Missões de vida: progresso absoluto.
  final ProgressFn? progress;
  final double rewardMoney;
  final Map<String, int> rewardStats;

  const MissionDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.counter,
    this.target = 1,
    this.minAge = 0,
    this.progress,
    this.rewardMoney = 0,
    this.rewardStats = const {},
  });
}

class ProgressionCatalog {
  // ------------------------------------------------------------------ CONQUISTAS
  static final achievements = <AchievementDef>[
    // Vida
    AchievementDef(id: 'first_steps', title: 'Primeiros Passos', description: 'Complete 1 ano de vida.', icon: Icons.child_friendly, category: 'Vida', rarity: Rarity.common, reward: 100, progress: (s) => _ratio(s.character.currentAge, 1)),
    AchievementDef(id: 'adult', title: 'Maioridade', description: 'Chegue aos 18 anos.', icon: Icons.cake, category: 'Vida', rarity: Rarity.common, reward: 500, progress: (s) => _ratio(s.character.currentAge, 18)),
    AchievementDef(id: 'midlife', title: 'Meia-Idade', description: 'Chegue aos 50 anos.', icon: Icons.hourglass_bottom, category: 'Vida', rarity: Rarity.rare, reward: 2000, progress: (s) => _ratio(s.character.currentAge, 50)),
    AchievementDef(id: 'centenarian', title: 'Centenário', description: 'Viva até os 100 anos.', icon: Icons.military_tech, category: 'Vida', rarity: Rarity.legendary, reward: 50000, progress: (s) => _ratio(s.character.currentAge, 100)),
    AchievementDef(id: 'zen', title: 'Paz Interior', description: 'Tenha 100 de felicidade e estresse abaixo de 10.', icon: Icons.self_improvement, category: 'Vida', rarity: Rarity.rare, reward: 1500, progress: (s) => (s.character.happiness >= 100 && s.character.stress < 10) ? 1 : _ratio(s.character.happiness, 100) * 0.9),
    AchievementDef(id: 'globetrotter', title: 'Viajante', description: 'Tire 5 férias.', icon: Icons.flight_takeoff, category: 'Vida', rarity: Rarity.rare, reward: 2000, progress: (s) => _ratio(s.extras.counter('vacations'), 5)),
    AchievementDef(id: 'pet_lover', title: 'Amigo dos Bichos', description: 'Tenha um pet.', icon: Icons.pets, category: 'Vida', rarity: Rarity.common, reward: 300, progress: (s) => _ratio(s.extras.pets.length, 1)),
    // Educação
    AchievementDef(id: 'high_school', title: 'Formando', description: 'Conclua o Ensino Médio.', icon: Icons.school, category: 'Educação', rarity: Rarity.common, reward: 800, progress: (s) => s.extras.education.hasHighSchool ? 1 : _ratio(s.character.currentAge, 18) * 0.9),
    AchievementDef(id: 'graduate', title: 'Diploma na Mão', description: 'Conclua uma graduação.', icon: Icons.workspace_premium, category: 'Educação', rarity: Rarity.rare, reward: 3000, progress: (s) => ['college', 'master', 'phd'].contains(s.character.educationLevel) ? 1 : 0),
    AchievementDef(id: 'doctor_phd', title: 'Doutor(a)', description: 'Conclua um doutorado.', icon: Icons.emoji_objects, category: 'Educação', rarity: Rarity.epic, reward: 15000, progress: (s) => s.character.educationLevel == 'phd' ? 1 : 0),
    AchievementDef(id: 'genius', title: 'Gênio', description: 'Alcance 100 de inteligência.', icon: Icons.psychology, category: 'Educação', rarity: Rarity.epic, reward: 5000, progress: (s) => _ratio(s.character.smarts, 100)),
    AchievementDef(id: 'lifelong_learner', title: 'Eterno Aprendiz', description: 'Conclua 5 cursos livres.', icon: Icons.menu_book, category: 'Educação', rarity: Rarity.rare, reward: 2500, progress: (s) => _ratio(s.extras.education.courses.length, 5)),
    // Carreira
    AchievementDef(id: 'first_job', title: 'Primeiro Emprego', description: 'Seja contratado(a) pela primeira vez.', icon: Icons.work, category: 'Carreira', rarity: Rarity.common, reward: 500, progress: (s) => _ratio(s.extras.counter('jobsGotten'), 1)),
    AchievementDef(id: 'promoted', title: 'Subindo na Vida', description: 'Receba uma promoção.', icon: Icons.trending_up, category: 'Carreira', rarity: Rarity.common, reward: 1000, progress: (s) => _ratio(s.extras.counter('promotions'), 1)),
    AchievementDef(id: 'ladder', title: 'Escalada Corporativa', description: 'Receba 5 promoções na mesma vida.', icon: Icons.stairs, category: 'Carreira', rarity: Rarity.epic, reward: 10000, progress: (s) => _ratio(s.extras.counter('promotions'), 5)),
    AchievementDef(id: 'top_career', title: 'Topo da Carreira', description: 'Alcance o cargo máximo de uma carreira.', icon: Icons.emoji_events, category: 'Carreira', rarity: Rarity.legendary, reward: 50000, progress: (s) => _atTop(s) ? 1 : _ratio(_maxCareerLevelReached(s), 6) * 0.9),
    AchievementDef(id: 'ceo', title: 'CEO', description: 'Torne-se CEO na Carreira Corporativa.', icon: Icons.apartment, category: 'Carreira', rarity: Rarity.legendary, reward: 80000, progress: (s) => s.character.currentJobTitle == 'CEO' ? 1 : 0),
    AchievementDef(id: 'founder', title: 'Fundador(a)', description: 'Abra sua própria empresa.', icon: Icons.rocket_launch, category: 'Carreira', rarity: Rarity.rare, reward: 5000, progress: (s) => _ratio(s.extras.counter('businessesFounded'), 1)),
    AchievementDef(id: 'fired', title: 'Olho da Rua', description: 'Seja demitido(a).', icon: Icons.work_off, category: 'Carreira', rarity: Rarity.common, reward: 200, progress: (s) => _ratio(s.extras.counter('timesFired'), 1)),
    // Riqueza
    AchievementDef(id: 'first_salary', title: 'Primeiro Salário', description: 'Receba um salário anual.', icon: Icons.payments, category: 'Riqueza', rarity: Rarity.common, reward: 200, progress: (s) => _ratio(s.extras.counter('salariesReceived'), 1)),
    AchievementDef(id: 'hundred_k', title: 'Seis Dígitos', description: 'Tenha patrimônio de R\$ 100 mil.', icon: Icons.savings, category: 'Riqueza', rarity: Rarity.common, reward: 1000, progress: (s) => _ratio(max(0, s.netWorth), 100000)),
    AchievementDef(id: 'millionaire', title: 'Milionário(a)', description: 'Tenha patrimônio de R\$ 1 milhão.', icon: Icons.account_balance, category: 'Riqueza', rarity: Rarity.epic, reward: 10000, progress: (s) => _ratio(max(0, s.netWorth), 1000000)),
    AchievementDef(id: 'billionaire', title: 'Bilionário(a)', description: 'Tenha patrimônio de R\$ 1 bilhão.', icon: Icons.diamond, category: 'Riqueza', rarity: Rarity.legendary, reward: 500000, progress: (s) => _ratio(max(0, s.netWorth), 1000000000)),
    AchievementDef(id: 'homeowner', title: 'Casa Própria', description: 'Compre um imóvel.', icon: Icons.house, category: 'Riqueza', rarity: Rarity.rare, reward: 3000, progress: (s) => _ratio(s.properties.where((p) => p.isRealEstate).length, 1)),
    AchievementDef(id: 'mansion', title: 'Vida de Magnata', description: 'Tenha uma mansão ou castelo.', icon: Icons.villa, category: 'Riqueza', rarity: Rarity.legendary, reward: 25000, progress: (s) => s.properties.any((p) => p.type == 'mansion' || p.type == 'castle') ? 1 : 0),
    AchievementDef(id: 'collector', title: 'Colecionador(a)', description: 'Tenha 10 itens no inventário.', icon: Icons.inventory_2, category: 'Riqueza', rarity: Rarity.rare, reward: 2500, progress: (s) => _ratio(s.extras.inventory.length, 10)),
    AchievementDef(id: 'garage', title: 'Garagem Cheia', description: 'Tenha 3 veículos ao mesmo tempo.', icon: Icons.garage, category: 'Riqueza', rarity: Rarity.epic, reward: 8000, progress: (s) => _ratio(s.extras.vehicles.length, 3)),
    AchievementDef(id: 'debt_free', title: 'Nome Limpo', description: 'Quite todos os empréstimos depois de ter um.', icon: Icons.verified, category: 'Riqueza', rarity: Rarity.rare, reward: 2000, progress: (s) => (s.extras.counter('loansTaken') > 0 && s.extras.loans.isEmpty && s.character.debt <= 0) ? 1 : 0),
    // Social
    AchievementDef(id: 'popular', title: 'Popular', description: 'Tenha 5 amigos.', icon: Icons.groups, category: 'Social', rarity: Rarity.rare, reward: 1500, progress: (s) => _ratio(_friends(s), 5)),
    AchievementDef(id: 'first_love', title: 'Primeiro Amor', description: 'Comece um namoro.', icon: Icons.favorite, category: 'Social', rarity: Rarity.common, reward: 500, progress: (s) => _ratio(s.extras.counter('relationshipsStarted'), 1)),
    AchievementDef(id: 'married', title: 'Felizes para Sempre', description: 'Case-se.', icon: Icons.volunteer_activism, category: 'Família', rarity: Rarity.rare, reward: 3000, progress: (s) => s.character.isMarried ? 1 : _ratio(s.extras.counter('relationshipsStarted'), 1) * 0.5),
    AchievementDef(id: 'parent', title: 'Pai/Mãe de Primeira Viagem', description: 'Tenha um filho.', icon: Icons.child_care, category: 'Família', rarity: Rarity.rare, reward: 2000, progress: (s) => _ratio(_children(s), 1)),
    AchievementDef(id: 'big_family', title: 'Família Grande', description: 'Tenha 4 filhos.', icon: Icons.family_restroom, category: 'Família', rarity: Rarity.epic, reward: 8000, progress: (s) => _ratio(_children(s), 4)),
    AchievementDef(id: 'dynasty', title: 'Dinastia', description: 'Jogue como a 3ª geração da família.', icon: Icons.account_tree, category: 'Família', rarity: Rarity.legendary, reward: 30000, progress: (s) => _ratio(s.generation, 3)),
    AchievementDef(id: 'good_soul', title: 'Alma Boa', description: 'Alcance 100 de karma.', icon: Icons.volunteer_activism, category: 'Social', rarity: Rarity.epic, reward: 5000, progress: (s) => _ratio(s.character.karma, 100)),
    // Fama
    AchievementDef(id: 'followers_10k', title: 'Influente', description: 'Alcance 10 mil seguidores.', icon: Icons.people_alt, category: 'Fama', rarity: Rarity.rare, reward: 2000, progress: (s) => _ratio(s.extras.followers, 10000)),
    AchievementDef(id: 'followers_1m', title: 'Fenômeno', description: 'Alcance 1 milhão de seguidores.', icon: Icons.public, category: 'Fama', rarity: Rarity.legendary, reward: 50000, progress: (s) => _ratio(s.extras.followers, 1000000)),
    AchievementDef(id: 'celebrity', title: 'Celebridade', description: 'Alcance 80 de fama.', icon: Icons.star, category: 'Fama', rarity: Rarity.epic, reward: 15000, progress: (s) => _ratio(s.character.fame, 80)),
    AchievementDef(id: 'headline', title: 'Manchete', description: 'Apareça no noticiário.', icon: Icons.newspaper, category: 'Fama', rarity: Rarity.rare, reward: 1000, progress: (s) => _ratio(s.extras.headlines.length, 1)),
    // Raras
    AchievementDef(id: 'jackpot', title: 'Sortudo(a)', description: 'Ganhe um prêmio grande na loteria.', icon: Icons.casino, category: 'Raras', rarity: Rarity.legendary, reward: 10000, progress: (s) => _ratio(s.extras.counter('bigWins'), 1)),
    AchievementDef(id: 'rare_event', title: 'Destino Extraordinário', description: 'Viva um evento raro ou lendário.', icon: Icons.auto_awesome, category: 'Raras', rarity: Rarity.epic, reward: 5000, progress: (s) => _ratio(s.extras.counter('rareEvents'), 1)),
    AchievementDef(id: 'outlaw', title: 'Fora da Lei', description: 'Seja preso(a) 3 vezes.', icon: Icons.local_police, category: 'Raras', rarity: Rarity.rare, reward: 0, progress: (s) => _ratio(s.character.timesArrested, 3)),
    AchievementDef(id: 'athlete_body', title: 'Corpo de Atleta', description: 'Alcance 100 de condicionamento.', icon: Icons.fitness_center, category: 'Raras', rarity: Rarity.epic, reward: 4000, progress: (s) => _ratio(s.character.fitness, 100)),
    AchievementDef(id: 'astronaut', title: 'Rumo às Estrelas', description: 'Trabalhe na Agência Espacial.', icon: Icons.rocket, category: 'Raras', rarity: Rarity.legendary, reward: 40000, progress: (s) => s.character.currentJobId == 'sci_astronaut' ? 1 : 0),
    AchievementDef(id: 'president', title: 'Chefe de Estado', description: 'Torne-se Presidente da República.', icon: Icons.flag, category: 'Raras', rarity: Rarity.legendary, reward: 100000, progress: (s) => s.character.currentJobTitle == 'Presidente da República' ? 1 : 0),
    // Sistemas v3
    AchievementDef(id: 'school_star', title: 'Estrela da Escola', description: 'Chegue a 90 de popularidade na escola.', icon: Icons.star, category: 'Educação', rarity: Rarity.rare, reward: 1500, progress: (s) => _ratio(s.extras.school.popularity, 90)),
    AchievementDef(id: 'perfect_exam', title: 'Nota Dez', description: 'Tire nota máxima em uma prova.', icon: Icons.quiz, category: 'Educação', rarity: Rarity.common, reward: 400, progress: (s) => _ratio(s.extras.school.bestExam, 100)),
    AchievementDef(id: 'intern', title: 'Primeiro Crachá', description: 'Consiga um estágio na faculdade.', icon: Icons.badge, category: 'Educação', rarity: Rarity.common, reward: 800, progress: (s) => s.extras.school.internshipCompany != null || s.extras.school.internshipYears > 0 ? 1 : 0),
    AchievementDef(id: 'influencer', title: 'Influenciador(a)', description: 'Alcance 100 mil seguidores no Pulso.', icon: Icons.bubble_chart, category: 'Fama', rarity: Rarity.epic, reward: 10000, progress: (s) => _ratio(s.extras.followers, 100000)),
    AchievementDef(id: 'viral', title: 'Viralizou!', description: 'Tenha um post viral.', icon: Icons.trending_up, category: 'Fama', rarity: Rarity.rare, reward: 2500, progress: (s) => s.extras.social.posts.any((p) => p.viral) ? 1 : 0),
    AchievementDef(id: 'first_match', title: 'Faísca', description: 'Consiga 5 matches no app de namoro.', icon: Icons.local_fire_department, category: 'Amor', rarity: Rarity.common, reward: 600, progress: (s) => _ratio(s.extras.counter('datingMatches'), 5)),
    AchievementDef(id: 'party_host', title: 'Anfitrião(ã)', description: 'Dê 5 festas.', icon: Icons.celebration, category: 'Social', rarity: Rarity.rare, reward: 2000, progress: (s) => _ratio(s.extras.counter('partiesHosted'), 5)),
    AchievementDef(id: 'heist', title: 'Mão Leve', description: 'Tenha 10 sucessos no submundo.', icon: Icons.vpn_key, category: 'Submundo', rarity: Rarity.rare, reward: 1500, progress: (s) => _ratio(s.extras.crime.successes, 10)),
    AchievementDef(id: 'kingpin', title: 'Chefão', description: 'Chegue ao topo de uma organização.', icon: Icons.military_tech, category: 'Submundo', rarity: Rarity.legendary, reward: 25000, progress: (s) => s.extras.crime.gangId != null ? _ratio(s.extras.crime.gangRank, 4) : 0),
    AchievementDef(id: 'redemption', title: 'Redenção', description: 'Cumpra uma pena e saia em liberdade.', icon: Icons.lock_open, category: 'Submundo', rarity: Rarity.rare, reward: 3000, progress: (s) => s.extras.counter('prisonTerms') > 0 && !s.extras.crime.inPrison ? 1 : 0),
  ];

  static AchievementDef? achievement(String id) {
    for (final a in achievements) {
      if (a.id == id) return a;
    }
    return null;
  }

  // ------------------------------------------------------------ MISSÕES DIÁRIAS
  static const daily = <MissionDef>[
    MissionDef(id: 'd_age', title: 'Viver o Momento', description: 'Envelheça 2 anos.', icon: Icons.cake, color: Color(0xFF7C5CFF), counter: 'yearsLived', target: 2, rewardMoney: 300, rewardStats: {'happiness': 4}),
    MissionDef(id: 'd_social', title: 'Boa Companhia', description: 'Interaja 3 vezes com pessoas.', icon: Icons.forum, color: Color(0xFFEC4899), counter: 'npcInteractions', target: 3, rewardMoney: 200, rewardStats: {'happiness': 5}),
    MissionDef(id: 'd_friend', title: 'Fazer Amizade', description: 'Faça um novo amigo.', icon: Icons.handshake, color: Color(0xFFF59E0B), counter: 'friendsMade', target: 1, minAge: 4, rewardMoney: 300, rewardStats: {'charisma': 3}),
    MissionDef(id: 'd_study', title: 'Hora de Estudar', description: 'Estude 2 vezes.', icon: Icons.menu_book, color: Color(0xFF3B82F6), counter: 'studySessions', target: 2, minAge: 6, rewardMoney: 250, rewardStats: {'smarts': 3}),
    MissionDef(id: 'd_health', title: 'Corpo São', description: 'Cuide da saúde 2 vezes (academia, médico, corrida...).', icon: Icons.favorite, color: Color(0xFF22C55E), counter: 'healthActions', target: 2, minAge: 6, rewardMoney: 250, rewardStats: {'health': 4}),
    MissionDef(id: 'd_buy', title: 'Às Compras', description: 'Compre algo na loja.', icon: Icons.shopping_bag, color: Color(0xFF14B8A6), counter: 'purchases', target: 1, minAge: 8, rewardMoney: 400),
    MissionDef(id: 'd_job', title: 'Mercado de Trabalho', description: 'Consiga um emprego ou promoção.', icon: Icons.work, color: Color(0xFF6366F1), counter: 'careerWins', target: 1, minAge: 14, rewardMoney: 1000, rewardStats: {'happiness': 5}),
    MissionDef(id: 'd_save', title: 'Poupador(a)', description: 'Termine 2 anos com saldo maior que o anterior.', icon: Icons.savings, color: Color(0xFF10B981), counter: 'savingYears', target: 2, minAge: 16, rewardMoney: 800),
    MissionDef(id: 'd_post', title: 'Criador(a) de Conteúdo', description: 'Publique 2 vezes nas redes.', icon: Icons.photo_camera, color: Color(0xFFFF4F9A), counter: 'socialPosts', target: 2, minAge: 12, rewardMoney: 200, rewardStats: {'fame': 2}),
    MissionDef(id: 'd_fun', title: 'Diversão Garantida', description: 'Faça 2 atividades de lazer.', icon: Icons.celebration, color: Color(0xFFFFC53D), counter: 'leisure', target: 2, minAge: 4, rewardMoney: 200, rewardStats: {'stress': -6}),
    MissionDef(id: 'd_events', title: 'Decisões', description: 'Resolva 2 eventos da vida.', icon: Icons.alt_route, color: Color(0xFF22D3EE), counter: 'eventsResolved', target: 2, rewardMoney: 300),
  ];

  // -------------------------------------------------------------- MISSÕES DE VIDA
  static final life = <MissionDef>[
    MissionDef(id: 'l_millionaire', title: 'Tornar-se Milionário(a)', description: 'Alcance R\$ 1 milhão de patrimônio.', icon: Icons.account_balance, color: Color(0xFFFFC53D), progress: (s) => _ratio(max(0, s.netWorth), 1000000), rewardMoney: 25000),
    MissionDef(id: 'l_family', title: 'Construir uma Família', description: 'Esteja casado(a) e tenha 2 filhos.', icon: Icons.family_restroom, color: Color(0xFFEC4899), progress: (s) => (s.character.isMarried ? 0.5 : 0) + _ratio(_children(s), 2) * 0.5, rewardMoney: 8000, rewardStats: {'happiness': 15}),
    MissionDef(id: 'l_doctor', title: 'Jaleco Branco', description: 'Trabalhe como médico(a).', icon: Icons.local_hospital, color: Color(0xFFEF4444), progress: (s) => s.character.currentJobId == 'med_doctor' ? 1 : (s.extras.education.completedDegrees.contains('med') ? 0.6 : (s.extras.education.degreeId == 'med' ? 0.3 : 0)), rewardMoney: 15000),
    MissionDef(id: 'l_famous', title: 'Ser Famoso(a)', description: 'Alcance 70 de fama.', icon: Icons.star, color: Color(0xFFA855F7), progress: (s) => _ratio(s.character.fame, 70), rewardMoney: 15000, rewardStats: {'happiness': 10}),
    MissionDef(id: 'l_mansion', title: 'Comprar uma Mansão', description: 'Tenha uma mansão ou castelo.', icon: Icons.villa, color: Color(0xFFF59E0B), progress: (s) => s.properties.any((p) => p.type == 'mansion' || p.type == 'castle') ? 1 : _ratio(max(0, s.netWorth), 14000000) * 0.9, rewardMoney: 50000),
    MissionDef(id: 'l_age80', title: 'Longa Vida', description: 'Chegue aos 80 anos.', icon: Icons.elderly, color: Color(0xFF22C55E), progress: (s) => _ratio(s.character.currentAge, 80), rewardMoney: 20000),
    MissionDef(id: 'l_top', title: 'Completar uma Carreira', description: 'Alcance o cargo máximo de uma carreira.', icon: Icons.emoji_events, color: Color(0xFF6366F1), progress: (s) => _atTop(s) ? 1 : _ratio(_maxCareerLevelReached(s), 6) * 0.9, rewardMoney: 30000),
    MissionDef(id: 'l_graduate', title: 'Formatura', description: 'Conclua uma graduação.', icon: Icons.school, color: Color(0xFF3B82F6), progress: (s) => ['college', 'master', 'phd'].contains(s.character.educationLevel) ? 1 : (s.extras.education.stage == 'university' && s.extras.education.yearsTotal > 0 ? s.extras.education.yearsDone / s.extras.education.yearsTotal * 0.9 : 0), rewardMoney: 5000),
    MissionDef(id: 'l_entrepreneur', title: 'Empreendedor(a)', description: 'Abra uma empresa.', icon: Icons.rocket_launch, color: Color(0xFF14B8A6), progress: (s) => _ratio(s.extras.counter('businessesFounded'), 1), rewardMoney: 10000),
    MissionDef(id: 'l_friends', title: 'Rede de Amigos', description: 'Tenha 5 amigos ao mesmo tempo.', icon: Icons.groups, color: Color(0xFFFB7185), progress: (s) => _ratio(_friends(s), 5), rewardMoney: 3000, rewardStats: {'charisma': 5}),
  ];
}
