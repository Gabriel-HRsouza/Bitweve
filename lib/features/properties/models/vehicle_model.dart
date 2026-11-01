enum VehicleCategory {
  popular,
  sedan,
  suv,
  sports,
  luxury,
  motorcycle,
  boat,
  aircraft,
}

class VehicleModel {
  final String id;
  final String name;
  final VehicleCategory category;
  final int year;
  final double purchasePrice;
  final double currentValue;
  final double annualMaintenance;
  final double annualInsurance;
  final int conditionPercent; // 0 to 100
  final int mileageKm;
  final bool hasInsurance;

  const VehicleModel({
    required this.id,
    required this.name,
    required this.category,
    required this.year,
    required this.purchasePrice,
    required this.currentValue,
    required this.annualMaintenance,
    required this.annualInsurance,
    this.conditionPercent = 100,
    this.mileageKm = 0,
    this.hasInsurance = true,
  });

  VehicleModel copyWith({
    String? id,
    String? name,
    VehicleCategory? category,
    int? year,
    double? purchasePrice,
    double? currentValue,
    double? annualMaintenance,
    double? annualInsurance,
    int? conditionPercent,
    int? mileageKm,
    bool? hasInsurance,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      year: year ?? this.year,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      annualMaintenance: annualMaintenance ?? this.annualMaintenance,
      annualInsurance: annualInsurance ?? this.annualInsurance,
      conditionPercent: conditionPercent ?? this.conditionPercent,
      mileageKm: mileageKm ?? this.mileageKm,
      hasInsurance: hasInsurance ?? this.hasInsurance,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'year': year,
        'purchasePrice': purchasePrice,
        'currentValue': currentValue,
        'annualMaintenance': annualMaintenance,
        'annualInsurance': annualInsurance,
        'conditionPercent': conditionPercent,
        'mileageKm': mileageKm,
        'hasInsurance': hasInsurance,
      };

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: VehicleCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => VehicleCategory.popular,
      ),
      year: json['year'] as int? ?? 2024,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      annualMaintenance: (json['annualMaintenance'] as num).toDouble(),
      annualInsurance: (json['annualInsurance'] as num).toDouble(),
      conditionPercent: json['conditionPercent'] as int? ?? 100,
      mileageKm: json['mileageKm'] as int? ?? 0,
      hasInsurance: json['hasInsurance'] as bool? ?? true,
    );
  }
}
