import 'package:dio/dio.dart';
import '../../../core/network/base_repository.dart';
import '../../../core/constants/api_constants.dart';
import 'vehicle_model.dart';

class VehicleRepository extends BaseRepository {
  Future<List<Vehicle>> getVehicles() =>
      getList(ApiConstants.vehicles, Vehicle.fromJson);

  Future<Vehicle> createVehicle(FormData data) async {
    final response = await dio.post(
      ApiConstants.vehicles,
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Vehicle.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Vehicle> updateVehicle(int id, FormData data) async {
    final response = await dio.patch(
      '${ApiConstants.vehicles}$id/',
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Vehicle.fromJson(response.data as Map<String, dynamic>);
  }
}