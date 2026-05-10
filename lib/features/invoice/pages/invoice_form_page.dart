import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/invoice_model.dart';
import '../form/invoice_form_controller.dart';
import '../provider/invoice_provider.dart';
import '../../vehicle/provider/vehicle_provider.dart';
import '../../partner/provider/partner_provider.dart';
import '../../product/provider/product_provider.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../shared/widgets/form/text_field_control.dart';
import '../../../shared/widgets/form/dropdown_control.dart';
import '../../../shared/widgets/form/number_field_control.dart';

class InvoiceFormPage extends ConsumerStatefulWidget {
  final Invoice? invoice;
  const InvoiceFormPage({super.key, this.invoice});

  @override
  ConsumerState<InvoiceFormPage> createState() =>
      _InvoiceFormPageState();
}

class _InvoiceFormPageState extends ConsumerState<InvoiceFormPage> {
  late final InvoiceFormController _form;
  bool get _isEditing => widget.invoice != null;

  @override
  void initState() {
    super.initState();
    _form = InvoiceFormController();
    if (_isEditing) {
      _form.prefill(widget.invoice!);
      // attach listeners to prefilled lines
      for (final line in _form.lineControllers) {
        _attachListener(line);
      }
    } else {
      _addLine();
    }
  }

  // attach setState listener to a line controller
  void _attachListener(InvoiceLineController line) {
    line.onChanged = () => setState(() {});
    line.attachListeners();
  }

  // always use this instead of _form.addLine() directly
  void _addLine() {
    _form.addLine();
    _attachListener(_form.lineControllers.last);
    setState(() {});
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_form.validate()) return;

    if (_form.selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }
    if (_form.selectedPartnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a partner')),
      );
      return;
    }
    if (_form.lineControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one invoice line')),
      );
      return;
    }

    for (int i = 0; i < _form.lineControllers.length; i++) {
      if (_form.lineControllers[i].productId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Select a product for line ${i + 1}')),
        );
        return;
      }
    }

    try {
      if (_isEditing) {
        await ref.read(invoiceProvider.notifier).update(
          id: widget.invoice!.id,
          fields: _form.formFields,
          newLines: _form.newLines,
          updatedLines: _form.updatedLines,
          deletedLineIds: _form.deletedLineIds,
        );
      } else {
        await ref.read(invoiceProvider.notifier).create(
          fields: _form.formFields,
          lines: _form.newLines,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildLineCard(int index) {
    final lineCtrl = _form.lineControllers[index];
    final productsState = ref.watch(productProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Line ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => _form.removeLine(index)),
                ),
              ],
            ),
            TextFieldControl(
              label: 'Description',
              controller: lineCtrl.nameController,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            productsState.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (products) => DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Product'),
                value: lineCtrl.productId,
                hint: const Text('Select Product'),
                items: products
                    .map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.name),
                ))
                    .toList(),
                onChanged: (v) => setState(() => lineCtrl.productId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: NumberFieldControl(
                    label: 'Qty',
                    controller: lineCtrl.quantityController,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NumberFieldControl(
                    label: 'Unit Price',
                    controller: lineCtrl.unitPriceController,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NumberFieldControl(
                    label: 'Discount',
                    controller: lineCtrl.discountController,
                  ),
                ),
              ],
            ),
            TextFieldControl(
              label: 'Ref',
              controller: lineCtrl.refController,
              validator: (v) =>
              v == null || v.isEmpty ? 'Required' : null,
            ),
            // subtotal rebuilds via setState from controller listener
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Subtotal: Rs. ${lineCtrl.subTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceProvider);
    final vehiclesState = ref.watch(vehicleProvider);
    final partnersState = ref.watch(partnerProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Invoice' : 'New Invoice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldControl(
                  label: 'Invoice Name',
                  controller: _form.nameController,
                  autoFocus: true,
                  validator: _form.validateName,
                ),
                TextFieldControl(
                  label: 'Date (YYYY-MM-DD)',
                  controller: _form.dateController,
                  validator: _form.validateDate,
                ),
                TextFieldControl(
                  label: 'Ref',
                  controller: _form.refController,
                  validator: _form.validateRef,
                ),
                vehiclesState.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (vehicles) => DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Vehicle'),
                    value: _form.selectedVehicleId,
                    hint: const Text('Select Vehicle'),
                    items: vehicles
                        .map((v) => DropdownMenuItem(
                      value: v.id,
                      child: Text(v.vehicleNo),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _form.selectedVehicleId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
                partnersState.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (partners) => DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Partner'),
                    value: _form.selectedPartnerId,
                    hint: const Text('Select Partner'),
                    items: partners
                        .map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _form.selectedPartnerId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                const Text(
                  'Invoice Lines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                ...List.generate(
                  _form.lineControllers.length,
                      (index) => _buildLineCard(index),
                ),

                OutlinedButton.icon(
                  onPressed: _addLine,   // ← uses _addLine not _form.addLine
                  icon: const Icon(Icons.add),
                  label: const Text('Add Line'),
                ),

                const SizedBox(height: 16),
                const Divider(),

                // grand total rebuilds because setState fires
                // from controller listeners on every keystroke
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Grand Total: Rs. ${_form.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                LoadingButton(
                  isLoading: isLoading,
                  onPressed: _submit,
                  label: _isEditing ? 'Update' : 'Create',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}