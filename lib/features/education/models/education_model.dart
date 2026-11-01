class DegreeModel {
  final String id;
  final String name;
  final int years;
  final double annualCost;
  final int minSmarts;
  final int difficulty;
  final String careerField;

  const DegreeModel({
    required this.id,
    required this.name,
    required this.years,
    required this.annualCost,
    required this.minSmarts,
    required this.difficulty,
    required this.careerField,
  });

  factory DegreeModel.fromMap(Map<String, dynamic> map) {
    return DegreeModel(
      id: map['id'] as String,
      name: map['name'] as String,
      years: (map['years'] as num).toInt(),
      annualCost: (map['annualCost'] as num).toDouble(),
      minSmarts: (map['minSmarts'] as num).toInt(),
      difficulty: (map['difficulty'] as num).toInt(),
      careerField: map['careerField'] as String,
    );
  }
}

class EducationRecord {
  final String id;
  final String schoolType; // 'fundamental', 'medio', 'faculdade', 'pos_graduacao'
  final String institutionName;
  final String? major;
  final int startAge;
  final int? graduatedAge;
  final bool isCompleted;
  final double grade;

  const EducationRecord({
    required this.id,
    required this.schoolType,
    required this.institutionName,
    this.major,
    required this.startAge,
    this.graduatedAge,
    this.isCompleted = false,
    this.grade = 7.5,
  });
}
