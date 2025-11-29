class RetailerCooperative {
  final String id;
  final String name;
  final String? woredaOffice;

  RetailerCooperative({
    required this.id,
    required this.name,
    this.woredaOffice,
  });

  factory RetailerCooperative.fromJson(Map<String, dynamic> json) {
    return RetailerCooperative(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      woredaOffice: json['woredaOffice'] is Map<String, dynamic>
          ? json['woredaOffice']['_id'] ?? json['woredaOffice']['id']
          : json['woredaOffice']?.toString(),
    );
  }

  static List<RetailerCooperative> fromJsonList(List<dynamic> list) {
    return list.map((e) => RetailerCooperative.fromJson(e)).toList();
  }
}
