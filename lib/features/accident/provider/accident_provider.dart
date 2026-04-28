import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/base_notifier.dart';
import '../data/accident_repository.dart';
import '../data/accident_model.dart';

final accidentRepositoryProvider = Provider((ref) => AccidentRepository());

class AccidentNotifier extends BaseNotifier<Accident> {
  final AccidentRepository _repo;

  AccidentNotifier(this._repo);

  @override
  Future<List<Accident>> fetchData() => _repo.getAccidents();

  Future<void> create(FormData data) async {
    await _repo.createAccident(data);
    await fetch();
  }

  Future<void> update(int id, FormData data) async {
    await _repo.updateAccident(id, data);
    await fetch();
  }
}

final accidentProvider =
StateNotifierProvider<AccidentNotifier, AsyncValue<List<Accident>>>(
      (ref) => AccidentNotifier(ref.read(accidentRepositoryProvider)),
);