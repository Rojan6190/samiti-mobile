class Product {
  final int id;
  final String name;
  final String? code;
  final double listPrice;
  final String type;

  Product({
    required this.id,
    required this.name,
    this.code,
    required this.listPrice,
    required this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: int.parse(json['id'].toString()),
    name: json['name'],
    code: json['code'],
    listPrice: (json['list_price'] as num).toDouble(),
    type: json['type'],
  );
}