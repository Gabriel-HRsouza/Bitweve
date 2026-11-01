class InvestmentModel {
  final String id;
  final String saveId;
  final String type; // 'fixed_income', 'stock', 'crypto', 'real_estate_fund'
  final String name;
  final String ticker;
  final double investedAmount;
  final double currentValue;
  final double units;
  final double annualYieldPercent;

  const InvestmentModel({
    required this.id,
    required this.saveId,
    required this.type,
    required this.name,
    required this.ticker,
    required this.investedAmount,
    required this.currentValue,
    required this.units,
    required this.annualYieldPercent,
  });

  double get profitOrLoss => currentValue - investedAmount;
  double get profitPercent => investedAmount > 0 ? (profitOrLoss / investedAmount) * 100 : 0.0;

  InvestmentModel copyWith({
    String? id,
    String? saveId,
    String? type,
    String? name,
    String? ticker,
    double? investedAmount,
    double? currentValue,
    double? units,
    double? annualYieldPercent,
  }) {
    return InvestmentModel(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      type: type ?? this.type,
      name: name ?? this.name,
      ticker: ticker ?? this.ticker,
      investedAmount: investedAmount ?? this.investedAmount,
      currentValue: currentValue ?? this.currentValue,
      units: units ?? this.units,
      annualYieldPercent: annualYieldPercent ?? this.annualYieldPercent,
    );
  }
}
