import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.fullName,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phoneNumber,
    super.avatar,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'];
    final accessToken = tokens is Map<String, dynamic>
        ? (tokens['access_token'] ?? tokens['token'])
        : null;

    return UserModel(
      id: json['data']?['_id'] ?? '',
      fullName: json['data']?['full_name'] ?? '',
      firstName: json['data']?['first_name'] ?? '',
      lastName: json['data']?['last_name'] ?? '',
      email: json['data']?['email'] ?? '',
      phoneNumber: json['data']?['phone_number'],
      avatar: json['data']?['avatar'],
      token: accessToken ?? json['_loginToken'] ?? '',
    );
  }
}
