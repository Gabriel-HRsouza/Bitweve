class PropertyModel {
  final String id;
  final String saveId;
  final String type; // 'house', 'apartment', 'mansion', 'farm', 'car', 'motorcycle', 'yacht', 'jewelry'
  final String name;
  final double purchasePrice;
  final double currentValue;
  final double annualCost;
  final int condition; // 0 a 100
  final bool isFinanced;
  final double monthlyPayment;
  final double remainingDebt;
  final int purchasedAtAge;

  const PropertyModel({
    required this.id,
    required this.saveId,
    required this.type,
    required this.name,
    required this.purchasePrice,
    required this.currentValue,
    required this.annualCost,
    this.condition = 100,
    this.isFinanced = false,
    this.monthlyPayment = 0.0,
    this.remainingDebt = 0.0,
    required this.purchasedAtAge,
  });

  bool get isVehicle => type == 'car' || type == 'motorcycle' || type == 'yacht';
  static const realEstateTypes = {'house', 'apartment', 'mansion', 'farm', 'studio', 'beach_house', 'penthouse', 'castle', 'commercial', 'store', 'warehouse'};
  static const commercialTypes = {'commercial', 'store', 'warehouse'};
  bool get isCommercial => commercialTypes.contains(type);
  bool get isRealEstate => realEstateTypes.contains(type);

  PropertyModel copyWith({
    String? id,
    String? saveId,
    String? type,
    String? name,
    double? purchasePrice,
    double? currentValue,
    double? annualCost,
    int? condition,
    bool? isFinanced,
    double? monthlyPayment,
    double? remainingDebt,
    int? purchasedAtAge,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      type: type ?? this.type,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      annualCost: annualCost ?? this.annualCost,
      condition: (condition ?? this.condition).clamp(0, 100),
      isFinanced: isFinanced ?? this.isFinanced,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      remainingDebt: (remainingDebt ?? this.remainingDebt).clamp(0.0, double.infinity),
      purchasedAtAge: purchasedAtAge ?? this.purchasedAtAge,
    );
  }
}
