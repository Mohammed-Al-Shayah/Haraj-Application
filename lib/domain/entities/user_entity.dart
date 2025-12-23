class UserEntity {
  final String id;
  final String fullName;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? avatar;
  final String token;

  UserEntity({
    required this.id,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.avatar,
    required this.token,
  });
}
