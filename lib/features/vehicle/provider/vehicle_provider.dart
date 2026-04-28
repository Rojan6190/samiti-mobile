import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/base_notifier.dart';
import '../data/vehicle_repository.dart';
import '../data/vehicle_model.dart';

final vehicleRepositoryProvider = Provider((ref) => VehicleRepository());

class VehicleNotifier extends BaseNotifier<Vehicle> {
  final VehicleRepository _repo;

  VehicleNotifier(this._repo);

  @override
  Future<List<Vehicle>> fetchData() => _repo.getVehicles();

  Future<void> create(FormData data) async {
    await _repo.createVehicle(data);
    await fetch();
  }

  Future<void> update(int id, FormData data) async {
    await _repo.updateVehicle(id, data);
    await fetch();
  }
}

final vehicleProvider =
StateNotifierProvider<VehicleNotifier, AsyncValue<List<Vehicle>>>(
      (ref) => VehicleNotifier(ref.read(vehicleRepositoryProvider)),
);