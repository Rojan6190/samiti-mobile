import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../constants/api_constants.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;

  TokenInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) {
        handler.next(err);
        return;
      }
      try {
        final response = await dio.post(
          '${ApiConstants.baseUrl}v1/auth/token/refresh/',
          data: {'refresh_token': refreshToken},
          options: Options(headers: {}),
        );
        final newAccess = response.data['access_token'];
        await SecureStorage.saveTokens(
          access: newAccess,
          refresh: refreshToken,
        );
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        final retryResponse = await dio.fetch(err.requestOptions);
        handler.resolve(retryResponse);
      } catch (_) {
        await SecureStorage.clear();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}