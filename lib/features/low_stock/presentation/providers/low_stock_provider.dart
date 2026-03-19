import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../products/data/models/product_model.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../products/presentation/providers/products_provider.dart';

part 'low_stock_provider.g.dart';

/// low stock products provider
@riverpod
class LowStockProducts extends _$LowStockProducts {
  @override
  Future<List<ProductModel>> build() async {
    final repository = ref.read(productRepositoryProvider);
    final response = await repository.fetchLowStockProducts();

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to fetch low stock products');
    }
  }

  /// refresh low stock products
  Future<void> refreshProducts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productRepositoryProvider);
      final response = await repository.fetchLowStockProducts();

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(
          response.message ?? 'Failed to fetch low stock products',
        );
      }
    });
  }

  /// update a product's quantity
  Future<void> updateProductQuantity(
    ProductModel product,
    int newQuantity,
  ) async {
    final repository = ref.read(productRepositoryProvider);

    // we need to send all mandatory fields for the product update api
    final data = {
      "store": product.store ?? '',
      "warehouse": product.warehouse ?? '',
      "supplier": product.supplier ?? '',
      "cat_id": product.catId,
      "sub_cat_id": product.subCatId,
      "product_name": product.name,
      "sku": product.sku ?? '',
      "barcode": product.barcode ?? '',
      "available_quantity": newQuantity,
      "quantity": newQuantity,
      "price": product.price,
      "manufacturing_date": product.manufacturingDate ?? '',
      "expiring_date": product.expiryDate ?? '',
      "description": product.description,
      "product_image": product.imageUrl ?? "",
    };

    final response = await repository.updateProduct(product.id, data);

    if (response.success && response.data != null) {
      final currentProducts = state.valueOrNull ?? [];
      state = AsyncData(
        currentProducts
            .map((p) => p.id == product.id ? response.data! : p)
            .toList(),
      );
    } else {
      throw Exception(response.message ?? 'Failed to update product quantity');
    }
  }
}
