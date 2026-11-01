class CareerModel {
  final String id;
  final String title;
  final String field;
  final String minEducation; // 'none', 'high_school', 'college', 'master'
  final String? requiredDegree;
  final double entrySalary;
  final double maxSalary;
  final int minSmarts;
  final int stressLevel;
  final String? nextCareerId;
  final bool isSpecial;

  const CareerModel({
    required this.id,
    required this.title,
    required this.field,
    required this.minEducation,
    this.requiredDegree,
    required this.entrySalary,
    required this.maxSalary,
    required this.minSmarts,
    required this.stressLevel,
    this.nextCareerId,
    this.isSpecial = false,
  });

  factory CareerModel.fromMap(Map<String, dynamic> map) {
    return CareerModel(
      id: map['id'] as String,
      title: map['title'] as String,
      field: map['field'] as String,
      minEducation: map['minEducation'] as String,
      requiredDegree: map['requiredDegree'] as String?,
      entrySalary: (map['entrySalary'] as num).toDouble(),
      maxSalary: (map['maxSalary'] as num).toDouble(),
      minSmarts: (map['minSmarts'] as num).toInt(),
      stressLevel: (map['stressLevel'] as num).toInt(),
      nextCareerId: map['nextCareerId'] as String?,
      isSpecial: map['isSpecial'] as bool? ?? false,
    );
  }
}
