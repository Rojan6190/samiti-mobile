import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/base_notifier.dart';
import '../data/accident_repository.dart';
import '../data/accident_model.dart';
import 'package:image_picker/image_picker.dart';

final accidentRepositoryProvider =
Provider((ref) => AccidentRepository());

class AccidentNotifier extends BaseNotifier<Accident> {
  final AccidentRepository _repo;

  AccidentNotifier(this._repo);

  @override
  Future<List<Accident>> fetchData() => _repo.getAccidents();

  Future<void> create({
    required Map<String, dynamic> fields,
    required List<XFile> newImages,
  }) async {
    await _repo.createAccident(
      fields: fields,
      newImages: newImages,
    );
    await fetch();
  }

  Future<void> update({
    required int id,
    required Map<String, dynamic> fields,
    required List<XFile> newImages,
    required List<int> deletedImageIds,
  }) async {
    await _repo.updateAccident(
      id: id,
      fields: fields,
      newImages: newImages,
      deletedImageIds: deletedImageIds,
    );
    await fetch();
  }
}

final accidentProvider =
StateNotifierProvider<AccidentNotifier, AsyncValue<List<Accident>>>(
      (ref) => AccidentNotifier(ref.read(accidentRepositoryProvider)),
);