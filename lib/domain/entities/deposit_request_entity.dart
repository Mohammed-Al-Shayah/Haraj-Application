class DepositRequestEntity {
  final int id;
  final int userId;
  final int statusId;
  final String amount;
  final String proofImage;
  final DateTime created;

  const DepositRequestEntity({
    required this.id,
    required this.userId,
    required this.statusId,
    required this.amount,
    required this.proofImage,
    required this.created,
  });
}
