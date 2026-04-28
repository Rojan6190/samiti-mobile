import 'package:dio/dio.dart';
import '../../../core/network/base_repository.dart';
import '../../../core/constants/api_constants.dart';
import 'accident_model.dart';

class AccidentRepository extends BaseRepository {
  Future<List<Accident>> getAccidents() =>
      getList(ApiConstants.accidents, Accident.fromJson);

  Future<Accident> createAccident(FormData data) async {
    final response = await dio.post(
      ApiConstants.accidents,
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Accident.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Accident> updateAccident(int id, FormData data) async {
    final response = await dio.patch(
      '${ApiConstants.accidents}$id/',
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Accident.fromJson(response.data as Map<String, dynamic>);
  }
}