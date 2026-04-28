import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_model.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    print('LOGIN ATTEMPT: login=$email password=$password');
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'login': email, 'password': password},
      );
      print('LOGIN RESPONSE: ${response.data}');
      final tokens = AuthTokens.fromJson(response.data);
      await SecureStorage.saveTokens(
        access: tokens.accessToken,
        refresh: tokens.refreshToken,
      );
      return tokens;
    } on DioException catch (e) {
      print('LOGIN ERROR: ${e.response?.data}');  // ← this shows exact backend error
      rethrow;
    }
  }

  Future<AuthTokens> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
      },
    );
    final tokens = AuthTokens.fromJson(response.data);
    await SecureStorage.saveTokens(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
    );
    return tokens;
  }

  Future<void> logout() async {
    await SecureStorage.clear();
  }
}
