import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/invoice_provider.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';

class InvoiceListPage extends ConsumerWidget {
  const InvoiceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(invoiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/invoices/new'),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(invoiceProvider.notifier).fetch(),
        ),
        data: (invoices) => invoices.isEmpty
            ? const EmptyView(message: 'No invoices yet')
            : ListView.builder(
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return ListTile(
              title: Text(invoice.name),
              subtitle: Text(
                  invoice.vehicle?.vehicleNo ?? ''),
              trailing: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(invoice.date),
                  Text(
                    'Rs. ${invoice.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onTap: () => context.push(
                '/invoices/${invoice.id}',
                extra: invoice,
              ),
            );
          },
        ),
      ),
    );
  }
}
