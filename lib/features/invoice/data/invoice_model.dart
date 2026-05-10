import '../../vehicle/data/vehicle_model.dart';
import '../../partner/data/partner_model.dart';

class InvoiceLine {
  final int id;
  final String name;
  final int? productId;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double subTotalPrice;
  final String ref;

  InvoiceLine({
    required this.id,
    required this.name,
    this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.subTotalPrice,
    required this.ref,
  });

  factory InvoiceLine.fromJson(Map<String, dynamic> json) => InvoiceLine(
    id: int.parse(json['id'].toString()),
    name: json['name'] ?? '',
    productId: json['product'] != null
        ? int.parse(json['product'].toString())
        : null,
    quantity: (json['quantity'] as num).toDouble(),
    unitPrice: (json['unit_price'] as num).toDouble(),
    discountAmount: (json['discount_amount'] as num).toDouble(),
    subTotalPrice: (json['sub_total_price'] as num).toDouble(),
    ref: json['ref'] ?? '',
  );
}

class Invoice {
  final int id;
  final String name;
  final String date;
  final String ref;
  final Vehicle? vehicle;
  final Partner? partner;                  // ← now populated from API
  final double grandTotal;
  final List<InvoiceLine> invoiceLines;

  Invoice({
    required this.id,
    required this.name,
    required this.date,
    required this.ref,
    this.vehicle,
    this.partner,
    required this.grandTotal,
    this.invoiceLines = const [],
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: int.parse(json['id'].toString()),
    name: json['name'] ?? '',
    date: json['date'] ?? '',
    ref: json['ref'] ?? '',
    vehicle: json['vehicle'] != null
        ? Vehicle.fromJson(json['vehicle'])
        : null,
    partner: json['partner'] != null
        ? Partner.fromJson(json['partner'])    // ← now parsed correctly
        : null,
    grandTotal: (json['grand_total'] as num).toDouble(),
    invoiceLines: (json['invoice_lines'] as List? ?? [])
        .map((e) => InvoiceLine.fromJson(e))
        .toList(),
  );
}