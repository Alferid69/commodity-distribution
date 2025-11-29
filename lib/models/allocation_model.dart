class AllocationResponse {
  final String status;
  final int length;
  final List<Allocation> data;

  AllocationResponse({
    required this.status,
    required this.length,
    required this.data,
  });

  factory AllocationResponse.fromJson(Map<String, dynamic> json) {
    return AllocationResponse(
      status: json['status'] ?? '',
      length: json['length'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((e) => Allocation.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'length': length,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class Allocation {
  final String id;
  final TradeBureau tradeBureau;
  final RetailerCooperative retailerCooperative;
  final double amount;
  final Commodity commodity;
  final String status;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Allocation({
    required this.id,
    required this.tradeBureau,
    required this.retailerCooperative,
    required this.amount,
    required this.commodity,
    required this.status,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });
  

  factory Allocation.fromJson(Map<String, dynamic> json) {
    return Allocation(
      id: json['_id'] ?? '',
      tradeBureau: TradeBureau.fromJson(json['tradeBureauId']),
      retailerCooperative:
          RetailerCooperative.fromJson(json['retailerCooperativeId']),
      amount: (json['amount'] ?? 0).toDouble(),
      commodity: Commodity.fromJson(json['commodity']),
      status: json['status'] ?? '',
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static List<Allocation> fromListJson(dynamic jsonList) {
  if (jsonList == null) return [];
  if (jsonList is! List) return [];

  return jsonList.map((e) => Allocation.fromJson(e)).toList();
}

  Map<String, dynamic> toJson() => {
        '_id': id,
        'tradeBureauId': tradeBureau.toJson(),
        'retailerCooperativeId': retailerCooperative.toJson(),
        'amount': amount,
        'commodity': commodity.toJson(),
        'status': status,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class TradeBureau {
  final String id;
  final String name;

  TradeBureau({required this.id, required this.name});

  factory TradeBureau.fromJson(Map<String, dynamic> json) {
    return TradeBureau(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
      };
}

class RetailerCooperative {
  final String id;
  final String name;

  RetailerCooperative({required this.id, required this.name});

  factory RetailerCooperative.fromJson(Map<String, dynamic> json) {
    return RetailerCooperative(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
      };
}

class Commodity {
  final String id;
  final String name;

  Commodity({required this.id, required this.name});

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
      };

}