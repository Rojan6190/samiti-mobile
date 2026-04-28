import '../../../core/network/base_repository.dart';
import '../../../core/constants/api_constants.dart';
import 'product_model.dart';

class ProductRepository extends BaseRepository {
  Future<List<Product>> getProducts() =>
      getList(ApiConstants.products, Product.fromJson);

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await dio.post(ApiConstants.products, data: data);
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response =
    await dio.patch('${ApiConstants.products}$id/', data: data);
    return Product.fromJson(response.data as Map<String, dynamic>);
  }
}