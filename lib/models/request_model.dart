class Request {
  final String id;
  final RequestOffice from;
  final RequestOffice to;
  final String fromModel;
  final String toModel;
  final String message;
  final List<String> files;
  String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Request({
    required this.id,
    required this.from,
    required this.to,
    required this.fromModel,
    required this.toModel,
    required this.message,
    required this.files,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['_id'] ?? '',
      from: RequestOffice.fromJson(json['from']),
      to: RequestOffice.fromJson(json['to']),
      fromModel: json['fromModel'] ?? '',
      toModel: json['toModel'] ?? '',
      message: json['message'] ?? '',
      files: json['file'] != null
          ? List<String>.from(json['file'])
          : <String>[],
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static List<Request> fromJsonList(List<dynamic> list) {
    return list.map((e) => Request.fromJson(e)).toList();
  }
}

class RequestOffice {
  final String id;
  final String name;
  final String modelId;

  RequestOffice({
    required this.id,
    required this.name,
    required this.modelId,
  });

  factory RequestOffice.fromJson(Map<String, dynamic> json) {
    return RequestOffice(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      modelId: json['id'] ?? '',
    );
  }
}


