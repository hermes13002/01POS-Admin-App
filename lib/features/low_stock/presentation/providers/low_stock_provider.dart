import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../products/data/models/product_model.dart';

part 'low_stock_provider.g.dart';

/// threshold for low stock items
const int lowStockThreshold = 30;

/// low stock products provider
@riverpod
class LowStockProducts extends _$LowStockProducts {
  @override
  Future<List<ProductModel>> build() async {
    // TODO: replace with actual api call
    return _getMockLowStockProducts();
  }

  /// refresh low stock products
  Future<void> refreshProducts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _getMockLowStockProducts();
    });
  }

  /// mock data for development (products with stock <= threshold)
  List<ProductModel> _getMockLowStockProducts() {
    return const [
      ProductModel(
        id: 1,
        name: 'Ultrabook pro 15',
        price: 70000,
        category: 'Electronics',
        stock: 25,
      ),
      ProductModel(
        id: 2,
        name: 'Herbal sleep aid',
        price: 70000,
        category: 'Health',
        stock: 1,
      ),
      ProductModel(
        id: 3,
        name: 'Cross sectional sofa',
        price: 70000,
        category: 'Furniture',
        stock: 10,
      ),
      ProductModel(
        id: 4,
        name: 'Cold brew coffee',
        price: 70000,
        category: 'Food & Drinks',
        stock: 15,
      ),
      ProductModel(
        id: 5,
        name: 'Organic whole milk',
        price: 70000,
        category: 'Food & Drinks',
        stock: 30,
      ),
    ];
  }
}
