import 'package:onepos_admin_app/data/models/api_response_model.dart';
import 'package:onepos_admin_app/features/products/data/models/product_model.dart';

abstract class ProductRepository {
  Future<ApiResponse<List<ProductModel>>> fetchProducts(int page);
  Future<ApiResponse<ProductModel>> fetchSingleProduct(int id);
  Future<ApiResponse<void>> deleteProduct(int id);
  Future<ApiResponse<ProductModel>> updateProduct(
    int id,
    Map<String, dynamic> data,
  );
  Future<ApiResponse<ProductModel>> addProduct(Map<String, dynamic> data);
  Future<ApiResponse<void>> setLowStockLimit(int companyId, int limit);
  Future<ApiResponse<List<ProductModel>>> fetchLowStockProducts({int page = 1});
}
