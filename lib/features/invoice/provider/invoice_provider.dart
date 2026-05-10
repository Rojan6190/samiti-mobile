import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/base_notifier.dart';
import '../data/invoice_repository.dart';
import '../data/invoice_model.dart';

final invoiceRepositoryProvider =
Provider((ref) => InvoiceRepository());

class InvoiceNotifier extends BaseNotifier<Invoice> {
  final InvoiceRepository _repo;

  InvoiceNotifier(this._repo);

  @override
  Future<List<Invoice>> fetchData() => _repo.getInvoices();

  Future<void> create({
    required Map<String, dynamic> fields,
    required List<Map<String, dynamic>> lines,
  }) async {
    await _repo.createInvoice(fields: fields, lines: lines);
    await fetch();
  }

  Future<void> update({
    required int id,
    required Map<String, dynamic> fields,
    required List<Map<String, dynamic>> newLines,
    required List<Map<String, dynamic>> updatedLines,
    required List<int> deletedLineIds,
  }) async {
    await _repo.updateInvoice(
      id: id,
      fields: fields,
      newLines: newLines,
      updatedLines: updatedLines,
      deletedLineIds: deletedLineIds,
    );
    await fetch();
  }
}

final invoiceProvider =
StateNotifierProvider<InvoiceNotifier, AsyncValue<List<Invoice>>>(
      (ref) => InvoiceNotifier(ref.read(invoiceRepositoryProvider)),
);
