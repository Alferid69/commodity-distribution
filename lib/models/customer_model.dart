class Woreda {
  final String id;
  final String name;

  Woreda({required this.id, required this.name});

  factory Woreda.fromJson(Map<String, dynamic> json) {
    return Woreda(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class Customer {
  final String id;
  final String status;
  final String name;
  final Woreda woreda;
  final int age;
  final String gender;
  final String houseNo;
  final int ketena;
  final String phone;
  final int numberOfFamilyMembers;
  final List<dynamic> purchasedCommodities;
  final DateTime? lastTransactionDate;
  final DateTime? updatedAt;

  Customer({
    required this.id,
    required this.status,
    required this.name,
    required this.woreda,
    required this.age,
    required this.gender,
    required this.houseNo,
    required this.ketena,
    required this.phone,
    required this.numberOfFamilyMembers,
    required this.purchasedCommodities,
    required this.lastTransactionDate,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Customer(
      id: json['_id']?.toString() ?? '',
      status: json['status'] ?? '',
      name: json['name'] ?? '',
      woreda: Woreda.fromJson(json['woreda'] ?? {}),
      age: parseInt(json['age']),
      gender: json['gender'] ?? '',
      houseNo: json['house_no']?.toString() ?? '',
      ketena: parseInt(json['ketena']),
      phone: json['phone'] ?? '',
      numberOfFamilyMembers: parseInt(json['numberOfFamilyMembers']),
      purchasedCommodities: json['purchasedCommodities'] ?? [],
      lastTransactionDate: json['lastTransactionDate'] != null
          ? DateTime.tryParse(json['lastTransactionDate'])
          : null,
      updatedAt: (json['updatedAt'] != null && json['updatedAt'] is String)
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'status': status,
    'name': name,
    'woreda': woreda.toJson(),
    'age': age,
    'gender': gender,
    'house_no': houseNo,
    'ketena': ketena,
    'phone': phone,
    'numberOfFamilyMembers': numberOfFamilyMembers,
    'purchasedCommodities': purchasedCommodities,
    'lastTransactionDate': lastTransactionDate?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  static List<Customer> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Customer.fromJson(json)).toList();
  }
}
