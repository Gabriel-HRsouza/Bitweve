import 'package:flutter/material.dart';

class DegreeInfo {
  final String id;
  final String name;
  final String area;
  final int years;
  final double annualCost;
  final int minSmarts;
  final int difficulty; // 0..100
  final IconData icon;
  final Color color;
  final String level; // college | master | phd | mba | residency
  final String? requires; // id de diploma pré-requisito

  const DegreeInfo({
    required this.id,
    required this.name,
    required this.area,
    required this.years,
    required this.annualCost,
    required this.minSmarts,
    required this.difficulty,
    required this.icon,
    required this.color,
    this.level = 'college',
    this.requires,
  });
}

class CourseInfo {
  final String id;
  final String name;
  final String description;
  final double cost;
  final int minAge;
  final IconData icon;
  final Color color;
  final Map<String, int> boosts; // atributo -> ganho
  final String unlocks;

  const CourseInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.minAge,
    required this.icon,
    required this.color,
    this.boosts = const {},
    this.unlocks = '',
  });
}

class EducationCatalog {
  static const degrees = <DegreeInfo>[
    DegreeInfo(id: 'cs', name: 'Ciência da Computação', area: 'Tecnologia', years: 4, annualCost: 18000, minSmarts: 55, difficulty: 70, icon: Icons.computer, color: Color(0xFF3B82F6)),
    DegreeInfo(id: 'med', name: 'Medicina', area: 'Saúde', years: 6, annualCost: 90000, minSmarts: 75, difficulty: 92, icon: Icons.local_hospital, color: Color(0xFFEF4444)),
    DegreeInfo(id: 'nursing', name: 'Enfermagem', area: 'Saúde', years: 5, annualCost: 14000, minSmarts: 45, difficulty: 55, icon: Icons.healing, color: Color(0xFFF43F5E)),
    DegreeInfo(id: 'pharmacy', name: 'Farmácia', area: 'Saúde', years: 5, annualCost: 20000, minSmarts: 55, difficulty: 65, icon: Icons.medication, color: Color(0xFFFB7185)),
    DegreeInfo(id: 'psychology', name: 'Psicologia', area: 'Saúde', years: 5, annualCost: 17000, minSmarts: 50, difficulty: 55, icon: Icons.psychology, color: Color(0xFFA855F7)),
    DegreeInfo(id: 'law', name: 'Direito', area: 'Humanas', years: 5, annualCost: 22000, minSmarts: 58, difficulty: 70, icon: Icons.balance, color: Color(0xFF8B5CF6)),
    DegreeInfo(id: 'eng_civil', name: 'Engenharia Civil', area: 'Exatas', years: 5, annualCost: 20000, minSmarts: 62, difficulty: 78, icon: Icons.engineering, color: Color(0xFFF59E0B)),
    DegreeInfo(id: 'architecture', name: 'Arquitetura', area: 'Exatas', years: 5, annualCost: 21000, minSmarts: 55, difficulty: 65, icon: Icons.architecture, color: Color(0xFFEAB308)),
    DegreeInfo(id: 'physics', name: 'Física', area: 'Exatas', years: 4, annualCost: 9000, minSmarts: 70, difficulty: 85, icon: Icons.blur_on, color: Color(0xFF06B6D4)),
    DegreeInfo(id: 'biology', name: 'Biologia', area: 'Ciências', years: 4, annualCost: 10000, minSmarts: 52, difficulty: 60, icon: Icons.eco, color: Color(0xFF22C55E)),
    DegreeInfo(id: 'business', name: 'Administração', area: 'Negócios', years: 4, annualCost: 15000, minSmarts: 45, difficulty: 50, icon: Icons.business_center, color: Color(0xFF14B8A6)),
    DegreeInfo(id: 'economics', name: 'Economia', area: 'Negócios', years: 4, annualCost: 16000, minSmarts: 60, difficulty: 70, icon: Icons.show_chart, color: Color(0xFF10B981)),
    DegreeInfo(id: 'marketing', name: 'Marketing', area: 'Negócios', years: 4, annualCost: 14000, minSmarts: 42, difficulty: 45, icon: Icons.campaign, color: Color(0xFFFB923C)),
    DegreeInfo(id: 'journalism', name: 'Jornalismo', area: 'Comunicação', years: 4, annualCost: 13000, minSmarts: 45, difficulty: 50, icon: Icons.newspaper, color: Color(0xFFFB7185)),
    DegreeInfo(id: 'political_science', name: 'Ciência Política', area: 'Humanas', years: 4, annualCost: 12000, minSmarts: 50, difficulty: 55, icon: Icons.how_to_vote, color: Color(0xFF0F766E)),
    DegreeInfo(id: 'pedagogy', name: 'Pedagogia', area: 'Educação', years: 4, annualCost: 9000, minSmarts: 40, difficulty: 40, icon: Icons.school, color: Color(0xFF84CC16)),
    DegreeInfo(id: 'phys_ed', name: 'Educação Física', area: 'Saúde', years: 4, annualCost: 11000, minSmarts: 35, difficulty: 40, icon: Icons.directions_run, color: Color(0xFFF97316)),
    DegreeInfo(id: 'arts', name: 'Artes Cênicas', area: 'Artes', years: 4, annualCost: 12000, minSmarts: 35, difficulty: 45, icon: Icons.theater_comedy, color: Color(0xFFEC4899)),
    DegreeInfo(id: 'design', name: 'Design', area: 'Artes', years: 4, annualCost: 15000, minSmarts: 40, difficulty: 45, icon: Icons.brush, color: Color(0xFFD946EF)),
    DegreeInfo(id: 'music', name: 'Música', area: 'Artes', years: 4, annualCost: 13000, minSmarts: 40, difficulty: 50, icon: Icons.music_note, color: Color(0xFFC084FC)),
    DegreeInfo(id: 'aviation', name: 'Ciências Aeronáuticas', area: 'Tecnologia', years: 4, annualCost: 45000, minSmarts: 58, difficulty: 72, icon: Icons.flight, color: Color(0xFF0EA5E9)),
    DegreeInfo(id: 'gastronomy', name: 'Gastronomia', area: 'Serviços', years: 2, annualCost: 16000, minSmarts: 30, difficulty: 35, icon: Icons.restaurant, color: Color(0xFFF59E0B)),
  ];

  static const postgrad = <DegreeInfo>[
    DegreeInfo(id: 'mba', name: 'MBA Executivo', area: 'Negócios', years: 1, annualCost: 45000, minSmarts: 50, difficulty: 50, icon: Icons.workspace_premium, color: Color(0xFFFFC53D), level: 'mba'),
    DegreeInfo(id: 'master', name: 'Mestrado', area: 'Acadêmico', years: 2, annualCost: 8000, minSmarts: 62, difficulty: 70, icon: Icons.history_edu, color: Color(0xFF7C5CFF), level: 'master'),
    DegreeInfo(id: 'phd', name: 'Doutorado', area: 'Acadêmico', years: 4, annualCost: 6000, minSmarts: 72, difficulty: 82, icon: Icons.emoji_objects, color: Color(0xFF22D3EE), level: 'phd', requires: 'master'),
    DegreeInfo(id: 'residency', name: 'Residência Médica', area: 'Saúde', years: 3, annualCost: 0, minSmarts: 70, difficulty: 85, icon: Icons.monitor_heart, color: Color(0xFFEF4444), level: 'residency', requires: 'med'),
  ];

  static const courses = <CourseInfo>[
    CourseInfo(id: 'driving', name: 'Autoescola', description: 'Tire a carteira de motorista (CNH).', cost: 3200, minAge: 18, icon: Icons.directions_car, color: Color(0xFF0EA5E9), unlocks: 'Carteira de motorista, veículos e empregos de transporte'),
    CourseInfo(id: 'english', name: 'Inglês Fluente', description: 'Abra portas no mercado internacional.', cost: 4800, minAge: 8, icon: Icons.translate, color: Color(0xFF3B82F6), boosts: {'smarts': 6, 'charisma': 3}, unlocks: '+chance em entrevistas'),
    CourseInfo(id: 'coding', name: 'Bootcamp de Programação', description: 'Aprenda a programar em meses.', cost: 7000, minAge: 14, icon: Icons.terminal, color: Color(0xFF6366F1), boosts: {'smarts': 8}, unlocks: 'Conta como formação para Tecnologia (cargos iniciais)'),
    CourseInfo(id: 'public_speaking', name: 'Oratória', description: 'Fale em público com confiança.', cost: 1800, minAge: 12, icon: Icons.record_voice_over, color: Color(0xFFF59E0B), boosts: {'charisma': 10}, unlocks: '+chance em política e vendas'),
    CourseInfo(id: 'first_aid', name: 'Primeiros Socorros', description: 'Saiba agir em emergências.', cost: 600, minAge: 12, icon: Icons.emergency, color: Color(0xFFEF4444), boosts: {'smarts': 2, 'karma': 5}),
    CourseInfo(id: 'photography', name: 'Fotografia Profissional', description: 'Domine luz, composição e edição.', cost: 3500, minAge: 14, icon: Icons.camera_alt, color: Color(0xFF14B8A6), boosts: {'smarts': 2}, unlocks: 'Carreira de Fotografia'),
    CourseInfo(id: 'cooking', name: 'Culinária', description: 'Do arroz soltinho ao risoto perfeito.', cost: 1500, minAge: 10, icon: Icons.soup_kitchen, color: Color(0xFFF97316), boosts: {'happiness': 5}, unlocks: '+chance em Gastronomia'),
    CourseInfo(id: 'digital_marketing', name: 'Marketing Digital', description: 'Cresça nas redes sociais.', cost: 2200, minAge: 14, icon: Icons.trending_up, color: Color(0xFFEC4899), boosts: {'charisma': 3}, unlocks: '+seguidores nas postagens'),
    CourseInfo(id: 'acting', name: 'Teatro e Atuação', description: 'Técnicas de interpretação.', cost: 2600, minAge: 8, icon: Icons.theater_comedy, color: Color(0xFFD946EF), boosts: {'charisma': 6, 'looks': 2}, unlocks: '+chance como ator'),
    CourseInfo(id: 'singing', name: 'Canto', description: 'Afinação, respiração e presença de palco.', cost: 2400, minAge: 8, icon: Icons.mic, color: Color(0xFFC084FC), boosts: {'charisma': 5}, unlocks: '+chance na Música'),
    CourseInfo(id: 'personal_finance', name: 'Educação Financeira', description: 'Invista melhor e fuja das dívidas.', cost: 900, minAge: 14, icon: Icons.savings, color: Color(0xFF22C55E), boosts: {'smarts': 3}, unlocks: '+5% de rendimento em investimentos'),
    CourseInfo(id: 'security_course', name: 'Curso de Vigilante', description: 'Formação obrigatória para segurança privada.', cost: 1200, minAge: 18, icon: Icons.security, color: Color(0xFF64748B), boosts: {'fitness': 3}, unlocks: 'Carreira de Segurança Patrimonial'),
    CourseInfo(id: 'eja', name: 'Supletivo (EJA)', description: 'Conclua o Ensino Médio em 1 ano.', cost: 1500, minAge: 18, icon: Icons.menu_book, color: Color(0xFF84CC16), boosts: {'smarts': 4}, unlocks: 'Diploma de Ensino Médio'),
  ];

  static DegreeInfo? degree(String? id) {
    if (id == null) return null;
    for (final d in [...degrees, ...postgrad]) {
      if (d.id == id) return d;
    }
    return null;
  }

  static CourseInfo? course(String id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }
}
