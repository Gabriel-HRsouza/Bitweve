enum ConditionCategory {
  congenital,
  neurodevelopment,
  mentalHealth,
  chronicPhysical,
  acute,
}

enum ConditionSeverity {
  mild,
  moderate,
  severe,
}

enum TreatmentState {
  none,
  medication,
  therapy,
  underControl,
  inRemission,
  cured,
}

class HealthCondition {
  final String id;
  final String name;
  final ConditionCategory category;
  final String description;
  final ConditionSeverity severity;
  final bool isDiagnosed;
  final int? diagnosedAge;
  final TreatmentState treatmentState;
  final String? medicationName;
  final double monthlyCost;
  final String supportNeeds;

  const HealthCondition({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.severity = ConditionSeverity.moderate,
    this.isDiagnosed = false,
    this.diagnosedAge,
    this.treatmentState = TreatmentState.none,
    this.medicationName,
    this.monthlyCost = 0.0,
    required this.supportNeeds,
  });

  HealthCondition copyWith({
    String? id,
    String? name,
    ConditionCategory? category,
    String? description,
    ConditionSeverity? severity,
    bool? isDiagnosed,
    int? diagnosedAge,
    TreatmentState? treatmentState,
    String? medicationName,
    double? monthlyCost,
    String? supportNeeds,
  }) {
    return HealthCondition(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      isDiagnosed: isDiagnosed ?? this.isDiagnosed,
      diagnosedAge: diagnosedAge ?? this.diagnosedAge,
      treatmentState: treatmentState ?? this.treatmentState,
      medicationName: medicationName ?? this.medicationName,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      supportNeeds: supportNeeds ?? this.supportNeeds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'description': description,
        'severity': severity.name,
        'isDiagnosed': isDiagnosed,
        'diagnosedAge': diagnosedAge,
        'treatmentState': treatmentState.name,
        'medicationName': medicationName,
        'monthlyCost': monthlyCost,
        'supportNeeds': supportNeeds,
      };

  factory HealthCondition.fromJson(Map<String, dynamic> json) {
    return HealthCondition(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ConditionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ConditionCategory.chronicPhysical,
      ),
      description: json['description'] as String? ?? '',
      severity: ConditionSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => ConditionSeverity.moderate,
      ),
      isDiagnosed: json['isDiagnosed'] as bool? ?? false,
      diagnosedAge: json['diagnosedAge'] as int?,
      treatmentState: TreatmentState.values.firstWhere(
        (t) => t.name == json['treatmentState'],
        orElse: () => TreatmentState.none,
      ),
      medicationName: json['medicationName'] as String?,
      monthlyCost: (json['monthlyCost'] as num?)?.toDouble() ?? 0.0,
      supportNeeds: json['supportNeeds'] as String? ?? '',
    );
  }
}
