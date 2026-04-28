import 'package:dio/dio.dart';
import 'dio_client.dart';

abstract class BaseRepository {
  final Dio dio = DioClient.instance;

  Future<List<T>> getList<T>(
      String endpoint,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    final response = await dio.get(endpoint);
    if (response.data is List) {
      return (response.data as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final results = response.data['results'] as List;
    return results
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}