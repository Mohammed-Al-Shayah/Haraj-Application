class CommentEntity {
  final int id;
  final String text;
  final DateTime created;
  final int userId;
  final String userName;

  CommentEntity({
    required this.id,
    required this.text,
    required this.created,
    required this.userId,
    required this.userName,
  });
}
