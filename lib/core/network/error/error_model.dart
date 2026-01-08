class ErrorModel {
  final String status;
  final String message;

  ErrorModel({
    required this.status,
    required this.message,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    final statusValue = json['status'] ??
        json['statusCode'] ??
        json['status_code'] ??
        json['code'] ??
        'Unknown';
    final messageValue = json['message'] ?? json['error'] ?? json['msg'];

    String normalizeMessage(dynamic value) {
      if (value == null) return 'Unknown error';
      if (value is List) {
        return value.map((e) => e.toString()).join(', ');
      }
      if (value is Map) {
        return normalizeMessage(value['message'] ?? value['error'] ?? value['msg']);
      }
      return value.toString();
    }

    return ErrorModel(
      status: statusValue.toString(),
      message: normalizeMessage(messageValue),
    );
  }
}
