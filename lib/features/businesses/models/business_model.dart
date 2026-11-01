class BusinessModel {
  final String id;
  final String saveId;
  final String name;
  final String industry; // 'tech_startup', 'restaurant', 'digital_agency', 'retail_store'
  final double valuation;
  final double revenue;
  final double expenses;
  final int employeeCount;
  final int reputation;
  final double productPrice;
  final double marketingBudget;

  const BusinessModel({
    required this.id,
    required this.saveId,
    required this.name,
    required this.industry,
    required this.valuation,
    required this.revenue,
    required this.expenses,
    this.employeeCount = 3,
    this.reputation = 50,
    this.productPrice = 99.0,
    this.marketingBudget = 5000.0,
  });

  double get netProfit => revenue - expenses;

  BusinessModel copyWith({
    String? id,
    String? saveId,
    String? name,
    String? industry,
    double? valuation,
    double? revenue,
    double? expenses,
    int? employeeCount,
    int? reputation,
    double? productPrice,
    double? marketingBudget,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      valuation: valuation ?? this.valuation,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      employeeCount: employeeCount ?? this.employeeCount,
      reputation: reputation ?? this.reputation,
      productPrice: productPrice ?? this.productPrice,
      marketingBudget: marketingBudget ?? this.marketingBudget,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'saveId': saveId,
        'name': name,
        'industry': industry,
        'valuation': valuation,
        'revenue': revenue,
        'expenses': expenses,
        'employeeCount': employeeCount,
        'reputation': reputation,
        'productPrice': productPrice,
        'marketingBudget': marketingBudget,
      };

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      saveId: json['saveId'] as String,
      name: json['name'] as String,
      industry: json['industry'] as String,
      valuation: (json['valuation'] as num).toDouble(),
      revenue: (json['revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      employeeCount: json['employeeCount'] as int? ?? 3,
      reputation: json['reputation'] as int? ?? 50,
      productPrice: (json['productPrice'] as num?)?.toDouble() ?? 99.0,
      marketingBudget: (json['marketingBudget'] as num?)?.toDouble() ?? 5000.0,
    );
  }
}
