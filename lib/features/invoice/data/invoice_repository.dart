import 'package:dio/dio.dart';
import '../../../core/network/base_repository.dart';
import '../../../core/network/multipart_builder.dart';
import '../../../core/network/to_many_command.dart';
import '../../../core/constants/api_constants.dart';
import 'invoice_model.dart';

class InvoiceRepository extends BaseRepository {
  Future<List<Invoice>> getInvoices() async {
    final response = await dio.get(ApiConstants.invoices);

    // handle both paginated and non-paginated responses
    if (response.data is List) {
      // plain list response
      final results = response.data as List<dynamic>;
      return results
          .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // paginated response — extract results
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List? ?? [];
      return results
          .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<Invoice> createInvoice({
    required Map<String, dynamic> fields,
    required List<Map<String, dynamic>> lines,
  }) async {
    final commands = lines
        .map((line) => ToManyCommand.create(line))
        .toList();

    final builder = MultipartBuilder()
        .fields(fields)
        .toManyCommands('invoice_lines', commands);

    final response = await dio.post(
      ApiConstants.invoices,
      data: builder.build(),
      options: Options(contentType: 'multipart/form-data'),
    );
    return Invoice.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Invoice> updateInvoice({
    required int id,
    required Map<String, dynamic> fields,
    required List<Map<String, dynamic>> newLines,
    required List<Map<String, dynamic>> updatedLines,
    required List<int> deletedLineIds,
  }) async {
    final commands = <List<dynamic>>[];

    for (final lineId in deletedLineIds) {
      commands.add(ToManyCommand.delete(lineId));
    }
    for (final line in updatedLines) {
      commands.add(ToManyCommand.update(
        line['id'] as int,
        Map.from(line)..remove('id'),
      ));
    }
    for (final line in newLines) {
      commands.add(ToManyCommand.create(line));
    }

    final builder = MultipartBuilder()
        .fields(fields)
        .toManyCommands('invoice_lines', commands);

    final response = await dio.patch(
      '${ApiConstants.invoices}$id/',
      data: builder.build(),
      options: Options(contentType: 'multipart/form-data'),
    );
    return Invoice.fromJson(response.data as Map<String, dynamic>);
  }
}