import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await apiClient.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );

    return res;
  }
}
