class Holding {
  final String symbol;
  final String name;
  final int units;
  final double avgCost;
  double currentPrice; // Mutable to allow price updates

  Holding({
    required this.symbol,
    required this.name,
    required this.units,
    required this.avgCost,
    required this.currentPrice,
  });

  /// Current market value of this holding
  double get currentValue => units * currentPrice;

  /// Gain (or loss) of this holding
  double get gain => currentValue - (units * avgCost);

  /// Gain percentage
  double get gainPercent =>
      (units > 0 && avgCost > 0) ? (gain / (units * avgCost)) * 100 : 0;

  /// Creates a copy with optional updated values
  Holding copyWith({
    String? symbol,
    String? name,
    int? units,
    double? avgCost,
    double? currentPrice,
  }) {
    return Holding(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      units: units ?? this.units,
      avgCost: avgCost ?? this.avgCost,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }

  /// Factory to create Holding from JSON
  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      units: (json['units'] as num).toInt(),
      avgCost: (json['avg_cost'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
    );
  }

  /// Convert Holding to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'units': units,
      'avg_cost': avgCost,
      'current_price': currentPrice,
    };
  }
}

class Portfolio {
  final String user;
  final List<Holding> holdings;

  Portfolio({required this.user, required this.holdings});

  /// Creates a copy with optional updated values
  Portfolio copyWith({String? user, List<Holding>? holdings}) {
    return Portfolio(
      user: user ?? this.user,
      holdings: holdings ?? this.holdings,
    );
  }

  /// Total portfolio value
  double get portfolioValue =>
      holdings.fold(0, (sum, h) => sum + h.currentValue);

  /// Total gain/loss of portfolio
  double get totalGain => holdings.fold(0, (sum, h) => sum + h.gain);

  /// Total gain percentage
  double get totalGainPercent =>
      portfolioValue > 0 ? (totalGain / (portfolioValue - totalGain)) * 100 : 0;

  /// Factory to create Portfolio from JSON
  factory Portfolio.fromJson(Map<String, dynamic> json) {
    var holdingsJson = json['holdings'] as List? ?? [];
    List<Holding> holdingsList = holdingsJson
        .map((h) => Holding.fromJson(h))
        .toList();

    return Portfolio(
      user: json['user'] as String? ?? 'Unknown',
      holdings: holdingsList,
    );
  }

  /// Convert Portfolio to JSON
  Map<String, dynamic> toJson() {
    return {'user': user, 'holdings': holdings.map((h) => h.toJson()).toList()};
  }

  /// Returns only holdings with non-zero units
  List<Holding> get nonZeroHoldings =>
      holdings.where((h) => h.units > 0).toList();
}
