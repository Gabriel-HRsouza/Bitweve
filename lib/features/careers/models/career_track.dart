import 'package:flutter/material.dart';

class CareerLevel {
  final String title;
  final double salary; // anual
  final int years; // anos mínimos no nível anterior para chegar aqui

  const CareerLevel(this.title, this.salary, [this.years = 2]);
}

class CareerCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  const CareerCategory(this.id, this.name, this.icon, this.color);
}

class CareerTrack {
  final String id;
  final String category; // CareerCategory.id
  final String name;
  final String description;
  final IconData icon;
  final int minAge;
  final String minEducation; // none | elementary | high_school | college | master | phd
  final List<String> degrees; // ids de graduação aceitos (vazio = qualquer/nenhum)
  final List<String> requiredCourses; // cursos livres obrigatórios
  final int minSmarts;
  final int minFitness;
  final int minLooks;
  final int minFame;
  final int minCharisma;
  final int minReputation;
  final bool requiresLicense;
  final bool partTime;
  final int stress; // 0..100 (estresse anual)
  final double risk; // risco base de demissão anual
  final int hoursPerWeek;
  final List<String> benefits;
  final List<CareerLevel> levels;
  final int fameGain; // fama por ano trabalhado
  final bool noCriminalRecord;

  const CareerTrack({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.icon,
    this.minAge = 18,
    this.minEducation = 'high_school',
    this.degrees = const [],
    this.requiredCourses = const [],
    this.minSmarts = 0,
    this.minFitness = 0,
    this.minLooks = 0,
    this.minFame = 0,
    this.minCharisma = 0,
    this.minReputation = 0,
    this.requiresLicense = false,
    this.partTime = false,
    this.stress = 40,
    this.risk = 0.05,
    this.hoursPerWeek = 40,
    this.benefits = const [],
    required this.levels,
    this.fameGain = 0,
    this.noCriminalRecord = false,
  });

  CareerLevel level(int i) => levels[i.clamp(0, levels.length - 1)];
  double get entrySalary => levels.first.salary;
  double get topSalary => levels.last.salary;
  bool isTop(int i) => i >= levels.length - 1;
}

const Map<String, int> educationRank = {
  'none': 0,
  'elementary': 1,
  'high_school': 2,
  'college': 3,
  'master': 4,
  'phd': 5,
};

String educationLabel(String level) {
  switch (level) {
    case 'elementary':
      return 'Ensino Fundamental';
    case 'high_school':
      return 'Ensino Médio';
    case 'college':
      return 'Ensino Superior';
    case 'master':
      return 'Mestrado';
    case 'phd':
      return 'Doutorado';
    default:
      return 'Sem escolaridade';
  }
}
