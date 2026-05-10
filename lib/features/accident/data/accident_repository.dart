import 'package:dio/dio.dart';
import '../../../core/network/base_repository.dart';
import '../../../core/network/multipart_builder.dart';
import '../../../core/network/to_many_command.dart';
import '../../../core/constants/api_constants.dart';
import 'accident_model.dart';
import 'package:image_picker/image_picker.dart';

class AccidentRepository extends BaseRepository {
  Future<List<Accident>> getAccidents() =>
      getList(ApiConstants.accidents, Accident.fromJson);

  Future<Accident> createAccident({
    required Map<String, dynamic> fields,
    required List<XFile> newImages,
  }) async {
    final builder = MultipartBuilder().fields(fields);

    // build create commands for each image
    final commands = <List<dynamic>>[];
    for (int i = 0; i < newImages.length; i++) {
      commands.add(ToManyCommand.create({'image': newImages[i]}));
    }

    builder.toManyCommands('images', commands);

    // attach files
    for (int i = 0; i < newImages.length; i++) {
      await builder.toManyFile('images', i, 'image', newImages[i]);
    }

    final response = await dio.post(
      ApiConstants.accidents,
      data: builder.build(),
      options: Options(contentType: 'multipart/form-data'),
    );
    return Accident.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Accident> updateAccident({
    required int id,
    required Map<String, dynamic> fields,
    required List<XFile> newImages,
    required List<int> deletedImageIds,
  }) async {
    final builder = MultipartBuilder().fields(fields);

    final commands = <List<dynamic>>[];

    // delete commands for removed images
    for (final imageId in deletedImageIds) {
      commands.add(ToManyCommand.delete(imageId));
    }

    // create commands for new images
    for (int i = 0; i < newImages.length; i++) {
      commands.add(ToManyCommand.create({'image': newImages[i]}));
    }

    builder.toManyCommands('images', commands);

    // attach new image files
    // offset index by deletedImageIds length since delete commands come first
    final offset = deletedImageIds.length;
    for (int i = 0; i < newImages.length; i++) {
      await builder.toManyFile(
          'images', offset + i, 'image', newImages[i]);
    }

    final response = await dio.patch(
      '${ApiConstants.accidents}$id/',
      data: builder.build(),
      options: Options(contentType: 'multipart/form-data'),
    );
    return Accident.fromJson(response.data as Map<String, dynamic>);
  }
}