import 'package:public_commodity_distribution/models/commodities_model.dart';
import 'package:public_commodity_distribution/models/customer_model.dart';
import 'package:public_commodity_distribution/models/retailer_cooperative_shop_model.dart';

class Transaction {
  final String id;
  final RetailerCooperativeShop shop; // maps from shopId
  final Customer customer; // maps from customerId
  final double amount;
  final Commodity commodity;
  final String status;
  final DateTime createdAt; // prefer createdAt if present
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    required this.shop,
    required this.customer,
    required this.amount,
    required this.commodity,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: (json['_id'] ?? json['id']).toString(),
      shop: RetailerCooperativeShop.fromJson(json['shopId'] ?? const {}),
      customer: Customer.fromJson(json['customerId'] ?? const {}),
      amount: _toDouble(json['amount']),
      commodity: Commodity.fromJson(json['commodity'] ?? const {}),
      status: (json['status'] ?? '').toString(),
      createdAt: _parseDate(json['createdAt'] ?? json['date']),
      updatedAt: _tryParseDate(json['updatedAt']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(dynamic v) {
    if (v is String) {
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _tryParseDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static List<Transaction> fromJsonList(List<dynamic> list) {
    return list.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
  }
}
