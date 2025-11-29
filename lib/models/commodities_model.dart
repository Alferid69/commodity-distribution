class Commodity {
  final String id;
  final String name;
  final double price;
  final String unit;

  Commodity({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['_id'],
      name: json['name'],
      price: _toDouble(json['price']),
      unit: json['unit'] ?? '',
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'unit': unit,
    };
  }

  static List<Commodity> fromJsonList(List<dynamic> list) {
    return list.map((e) => Commodity.fromJson(e)).toList();
  }
}
