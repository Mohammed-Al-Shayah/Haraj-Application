class WalletTransactionEntity {
  final int id;
  final int walletId;
  final String amount;
  final String descr;
  final DateTime created;
  final String typeCode;   // credit/debit
  final String typeName;   // ar
  final String typeNameEn; // en
  final String statusCode; // COMPLETED
  final String statusName;
  final String statusNameEn;

  const WalletTransactionEntity({
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
}
