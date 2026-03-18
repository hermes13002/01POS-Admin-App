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
}
