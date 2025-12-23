import 'package:haraj_adan_app/domain/entities/wallet_transaction_entity.dart';

class WalletTransactionModel {
  final int id;
  final int walletId;
  final String amount;
  final String descr;
  final DateTime created;

  final String typeCode;
  final String typeName;
  final String typeNameEn;

  final String statusCode;
  final String statusName;
  final String statusNameEn;

  WalletTransactionModel({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.descr,
    required this.created,
    required this.typeCode,
    required this.typeName,
    required this.typeNameEn,
    required this.statusCode,
    required this.statusName,
    required this.statusNameEn,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final type = json['transactions_types'] ?? {};
    final status = json['transactions_status'] ?? {};

    return WalletTransactionModel(
      id: json['id'] ?? 0,
      walletId: json['wallet_id'] ?? 0,
      amount: (json['amount'] ?? '').toString(),
      descr: (json['descr'] ?? '').toString(),
      created: DateTime.tryParse((json['created'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),

      typeCode: (type['code'] ?? '').toString(),
      typeName: (type['name'] ?? '').toString(),
      typeNameEn: (type['name_en'] ?? '').toString(),

      statusCode: (status['code'] ?? '').toString(),
      statusName: (status['name'] ?? '').toString(),
      statusNameEn: (status['name_en'] ?? '').toString(),
    );
  }

  WalletTransactionEntity toEntity() => WalletTransactionEntity(
        id: id,
        walletId: walletId,
        amount: amount,
        descr: descr,
        created: created,
        typeCode: typeCode,
        typeName: typeName,
        typeNameEn: typeNameEn,
        statusCode: statusCode,
        statusName: statusName,
        statusNameEn: statusNameEn,
      );
}
