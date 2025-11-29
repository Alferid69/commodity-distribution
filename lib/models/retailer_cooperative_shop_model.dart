class RetailerCooperativeShop {
  final String id;
  final String name;
  final String? retailerCooperativeId;
  final Map<String, dynamic>? retailerCooperative;

  RetailerCooperativeShop({
    required this.id,
    required this.name,
    this.retailerCooperativeId,
    this.retailerCooperative,
  });

  factory RetailerCooperativeShop.fromJson(Map<String, dynamic> json) {
    return RetailerCooperativeShop(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      retailerCooperativeId:
          json['retailerCooperative'] is Map<String, dynamic>
          ? json['retailerCooperative']['_id'] ??
                json['retailerCooperative']['id']
          : json['retailerCooperativeId']?.toString(),
      retailerCooperative: json['retailerCooperative'] is Map<String, dynamic>
          ? json['retailerCooperative']
          : null,
    );
  }

  static List<RetailerCooperativeShop> fromJsonList(List<dynamic> list) {
    return list.map((e) => RetailerCooperativeShop.fromJson(e)).toList();
  }
}
