import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'token_interceptor.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    if (_instance == null) {
      _instance = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ));
      _instance!.interceptors.add(TokenInterceptor(_instance!));
    }
    return _instance!;
  }
}
