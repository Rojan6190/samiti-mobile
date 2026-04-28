import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/base_notifier.dart';
import '../data/product_repository.dart';
import '../data/product_model.dart';

final productRepositoryProvider = Provider((ref) => ProductRepository());

class ProductNotifier extends BaseNotifier<Product> {
  final ProductRepository _repo;

  ProductNotifier(this._repo);

  @override
  Future<List<Product>> fetchData() => _repo.getProducts();

  Future<void> create(Map<String, dynamic> data) async {
    await _repo.createProduct(data);
    await fetch();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _repo.updateProduct(id, data);
    await fetch();
  }
}

final productProvider =
StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>(
      (ref) => ProductNotifier(ref.read(productRepositoryProvider)),
);