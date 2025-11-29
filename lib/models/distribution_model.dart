import 'package:public_commodity_distribution/models/commodities_model.dart';
import 'package:public_commodity_distribution/models/retailer_cooperative_model.dart';
import 'package:public_commodity_distribution/models/retailer_cooperative_shop_model.dart';

class Distribution {
  final String id;
  final RetailerCooperative retailerCooperative;
  final RetailerCooperativeShop retailerCooperativeShop;
  final Commodity commodity;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Distribution({
    required this.id,
    required this.retailerCooperative,
    required this.retailerCooperativeShop,
    required this.commodity,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Distribution.fromJson(Map<String, dynamic> json) {
    return Distribution(
      id: json['_id'] ?? '',
      retailerCooperative: RetailerCooperative.fromJson(json['retailerCooperativeId']),
      retailerCooperativeShop: RetailerCooperativeShop.fromJson(json['retailerCooperativeShopId']),
      amount: (json['amount'] ?? 0).toDouble(),
      commodity: Commodity.fromJson(json['commodity']),
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
    static List<Distribution> fromListJson(dynamic jsonList) {
  if (jsonList == null) return [];
    if (jsonList is! List) return [];
  
  return jsonList.map((e) => Distribution.fromJson(e)).toList();
}
}
