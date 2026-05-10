import 'package:flutter/material.dart';
import '../../../core/form/base_form_controller.dart';
import '../../../core/form/form_validator.dart';
import '../data/invoice_model.dart';

class InvoiceLineController {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();
  final discountController = TextEditingController();
  final refController = TextEditingController();
  int? productId;
  int? existingId;

  // callback to notify parent when any value changes
  VoidCallback? onChanged;

  void attachListeners() {
    quantityController.addListener(_notify);
    unitPriceController.addListener(_notify);
    discountController.addListener(_notify);
  }

  void _notify() {
    onChanged?.call();
  }

  double get subTotal {
    final qty = double.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(unitPriceController.text) ?? 0;
    final discount = double.tryParse(discountController.text) ?? 0;
    return (qty * price) - discount;
  }

  Map<String, dynamic> toMap() => {
    'name': nameController.text.trim(),
    'product': productId,
    'quantity': quantityController.text.trim(),
    'unit_price': unitPriceController.text.trim(),
    'discount_amount': discountController.text.trim(),
    'ref': refController.text.trim(),
  };

  void prefill(InvoiceLine line) {
    existingId = line.id;
    nameController.text = line.name;
    quantityController.text = line.quantity.toString();
    unitPriceController.text = line.unitPrice.toString();
    discountController.text = line.discountAmount.toString();
    refController.text = line.ref;
    productId = line.productId;
  }

  void dispose() {
    quantityController.removeListener(_notify);
    unitPriceController.removeListener(_notify);
    discountController.removeListener(_notify);
    nameController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    discountController.dispose();
    refController.dispose();
  }
}

class InvoiceFormController extends BaseFormController {
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final refController = TextEditingController();

  int? selectedVehicleId;
  int? selectedPartnerId;

  List<InvoiceLineController> lineControllers = [];
  List<int> deletedLineIds = [];

  String? validateName(String? v) =>
      FormValidator.required(v, label: 'Name');
  String? validateDate(String? v) =>
      FormValidator.required(v, label: 'Date');
  String? validateRef(String? v) =>
      FormValidator.required(v, label: 'Ref');

  void addLine() => lineControllers.add(InvoiceLineController());

  void removeLine(int index) {
    final controller = lineControllers[index];
    if (controller.existingId != null) {
      deletedLineIds.add(controller.existingId!);
    }
    controller.dispose();
    lineControllers.removeAt(index);
  }

  // local preview only — official value comes from backend after save
  double get grandTotal => lineControllers.fold(
    0,
        (sum, line) => sum + line.subTotal,
  );

  Map<String, dynamic> get formFields => {
    'name': nameController.text.trim(),
    'date': dateController.text.trim(),
    'ref': refController.text.trim(),
    'vehicle': selectedVehicleId,      // ← int directly, not .toString()
    'partner': selectedPartnerId,      // ← int directly, not .toString()
  };

  List<Map<String, dynamic>> get newLines => lineControllers
      .where((c) => c.existingId == null)
      .map((c) => c.toMap())
      .toList();

  List<Map<String, dynamic>> get updatedLines => lineControllers
      .where((c) => c.existingId != null)
      .map((c) => {'id': c.existingId!, ...c.toMap()})
      .toList();

  void prefill(Invoice invoice) {
    nameController.text = invoice.name;
    dateController.text = invoice.date;
    refController.text = invoice.ref;
    selectedVehicleId = invoice.vehicle?.id;
    selectedPartnerId = invoice.partner?.id;
    lineControllers = invoice.invoiceLines.map((line) {
      final controller = InvoiceLineController();
      controller.prefill(line);
      return controller;
    }).toList();
  }

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    refController.dispose();
    for (final line in lineControllers) {
      line.dispose();
    }
  }
}