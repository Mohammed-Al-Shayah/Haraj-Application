import 'package:haraj_adan_app/domain/entities/deposit_request_entity.dart';

class DepositRequestModel {
  final int id;
  final int userId;
  final int statusId;
  final String amount;
  final String proofImage;
  final DateTime created;

  DepositRequestModel({
    required this.id,
    required this.userId,
    required this.statusId,
    required this.amount,
    required this.proofImage,
    required this.created,
  });

  factory DepositRequestModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DepositRequestModel(
      id: data['id'] ?? 0,
      userId: data['user_id'] ?? 0,
      statusId: data['status_id'] ?? 0,
      amount: (data['amount'] ?? '').toString(),
      proofImage: (data['proof_image'] ?? '').toString(),
      created: DateTime.tryParse((data['created'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  DepositRequestEntity toEntity() => DepositRequestEntity(
        id: id,
        userId: userId,
        statusId: statusId,
        amount: amount,
        proofImage: proofImage,
        created: created,
      );
}
