
import 'package:public_commodity_distribution/models/commodities_model.dart';

class Inventory {
  final String id;
  final Commodity commodity;
  final int quantity;

  Inventory({
    required this.id,
    required this.commodity,
    required this.quantity,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['_id'] ?? '',
      commodity: Commodity.fromJson(json['commodity']),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'commodity': commodity.toJson(),
      'quantity': quantity,
    };
  }

  static List<Inventory> fromJsonList(List<dynamic> list) {
    return list.map((item) => Inventory.fromJson(item)).toList();
  }
}
