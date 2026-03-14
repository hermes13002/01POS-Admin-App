class CurrencyModel {
  final int id;
  final String code;
  final String symbol;
  final String country;

  const CurrencyModel({
    required this.id,
    required this.code,
    required this.symbol,
    required this.country,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
    );
  }

  String get displayName => '$code ($symbol) - $country';
}
