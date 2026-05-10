import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'to_many_command.dart';

class MultipartBuilder {
  final Map<String, dynamic> _fields = {};
  final List<MapEntry<String, MultipartFile>> _files = [];

  MultipartBuilder field(String key, dynamic value) {
    if (value != null) _fields[key] = value.toString();
    return this;
  }

  MultipartBuilder fields(Map<String, dynamic> data) {
    data.forEach((key, value) {
      if (value != null) _fields[key] = value.toString();
    });
    return this;
  }

  /// Adds x2many commands for a field that uses ToManyList
  /// Each command is serialized as:
  /// fieldName[index][0] = cmd
  /// fieldName[index][1] = id
  /// fieldName[index][2][subField] = value
  MultipartBuilder toManyCommands(
      String fieldName,
      List<List<dynamic>> commands,
      ) {
    for (int i = 0; i < commands.length; i++) {
      final cmd = commands[i];
      _fields['$fieldName[$i][0]'] = cmd[0].toString();
      if (cmd.length > 1) {
        _fields['$fieldName[$i][1]'] = cmd[1].toString();
      }
      if (cmd.length > 2 && cmd[2] is Map) {
        final data = cmd[2] as Map<String, dynamic>;
        data.forEach((key, value) {
          if (value is! XFile && value is! MultipartFile) {
            _fields['$fieldName[$i][2][$key]'] = value.toString();
          }
        });
      }
    }
    return this;
  }

  /// Adds a file inside a toMany command
  Future<MultipartBuilder> toManyFile(
      String fieldName,
      int index,
      String subField,
      XFile file,
      ) async {
    final multipartFile = await MultipartFile.fromFile(
      file.path,
      filename: file.name,
    );
    _files.add(
      MapEntry('$fieldName[$index][2][$subField]', multipartFile),
    );
    return this;
  }

  /// Adds a single file field
  Future<MultipartBuilder> file(String key, XFile? xfile) async {
    if (xfile == null) return this;
    final multipartFile = await MultipartFile.fromFile(
      xfile.path,
      filename: xfile.name,
    );
    _files.add(MapEntry(key, multipartFile));
    return this;
  }

  FormData build() {
    return FormData.fromMap({
      ..._fields,
      ..._files.fold<Map<String, dynamic>>(
        {},
            (map, entry) => map..[entry.key] = entry.value,
      ),
    });
  }
}