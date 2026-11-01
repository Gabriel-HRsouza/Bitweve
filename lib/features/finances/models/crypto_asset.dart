class CryptoAsset {
  final String symbol; // 'BTC', 'ETH', 'BWV'
  final String name;
  final double currentPrice;
  final double change24hPercent;
  final List<double> priceHistory;
  final double ownedUnits;

  const CryptoAsset({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.change24hPercent,
    required this.priceHistory,
    this.ownedUnits = 0.0,
  });

  double get totalValue => ownedUnits * currentPrice;

  CryptoAsset copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? change24hPercent,
    List<double>? priceHistory,
    double? ownedUnits,
  }) {
    return CryptoAsset(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      change24hPercent: change24hPercent ?? this.change24hPercent,
      priceHistory: priceHistory ?? this.priceHistory,
      ownedUnits: ownedUnits ?? this.ownedUnits,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'currentPrice': currentPrice,
        'change24hPercent': change24hPercent,
        'priceHistory': priceHistory,
        'ownedUnits': ownedUnits,
      };

  factory CryptoAsset.fromJson(Map<String, dynamic> json) {
    return CryptoAsset(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      change24hPercent: (json['change24hPercent'] as num).toDouble(),
      priceHistory: (json['priceHistory'] as List).map((e) => (e as num).toDouble()).toList(),
      ownedUnits: (json['ownedUnits'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
