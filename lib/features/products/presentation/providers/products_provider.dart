import 'package:onepos_admin_app/data/models/api_response_model.dart';
import 'package:onepos_admin_app/features/products/data/models/product_model.dart';
import 'package:onepos_admin_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:onepos_admin_app/features/products/presentation/providers/products_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products_provider.g.dart';

final _productRepository = ProductRepositoryImpl();

/// products paginated data provider
@riverpod
class Products extends _$Products {
  @override
  FutureOr<ProductsState> build() async {
    // initial fetch
    final response = await _productRepository.fetchProducts(1);

    if (response.success && response.data != null) {
      final meta = response.meta;
      final hasMorePages = meta == null
          ? false
          : meta.currentPage < meta.totalPages;

      return ProductsState(
        products: response.data!,
        currentPage: meta?.currentPage ?? 1,
        hasMorePages: hasMorePages,
      );
    } else {
      return ProductsState(error: response.message);
    }
  }

  /// load next page of products
  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMorePages || current.isLoading) return;

    state = AsyncData(current.copyWith(isLoading: true));

    final nextPage = current.currentPage + 1;
    final response = await _productRepository.fetchProducts(nextPage);

    if (response.success && response.data != null) {
      final meta = response.meta;
      final hasMorePages = meta == null
          ? false
          : meta.currentPage < meta.totalPages;

      state = AsyncData(
        current.copyWith(
          products: [...current.products, ...response.data!],
          currentPage: meta?.currentPage ?? nextPage,
          hasMorePages: hasMorePages,
          isLoading: false,
        ),
      );
    } else {
      state = AsyncData(
        current.copyWith(isLoading: false, error: response.message),
      );
    }
  }

  /// refresh products list back to page 1
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _productRepository.fetchProducts(1);
      if (response.success && response.data != null) {
        final meta = response.meta;
        final hasMorePages = meta == null
            ? false
            : meta.currentPage < meta.totalPages;
        return ProductsState(
          products: response.data!,
          currentPage: meta?.currentPage ?? 1,
          hasMorePages: hasMorePages,
        );
      } else {
        return ProductsState(error: response.message);
      }
    });
  }

  /// delete a product by id via api
  Future<ApiResponse<void>> deleteProductItem(int productId) async {
    final response = await _productRepository.deleteProduct(productId);

    if (response.success) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            products: current.products.where((p) => p.id != productId).toList(),
          ),
        );
      }
    }
    return response;
  }

  /// update a product by id via api
  Future<ApiResponse<ProductModel>> updateProductItem(
    int productId,
    Map<String, dynamic> data,
  ) async {
    final response = await _productRepository.updateProduct(productId, data);

    if (response.success && response.data != null) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            products: current.products.map((p) {
              return p.id == productId ? response.data! : p;
            }).toList(),
          ),
        );
      }
    }
    return response;
  }
}

/// fetch single product by id endpoint
@riverpod
Future<ApiResponse<ProductModel>> singleProduct(SingleProductRef ref, int id) {
  return _productRepository.fetchSingleProduct(id);
}

/// categories provider
@riverpod
class ProductCategories extends _$ProductCategories {
  @override
  Future<List<ProductCategory>> build() async {
    return const [
      ProductCategory(
        id: '1',
        name: 'Electronics',
        subCategories: ['Laptops', 'Phones', 'Accessories'],
      ),
      ProductCategory(
        id: '2',
        name: 'Health',
        subCategories: ['Supplements', 'Medicine'],
      ),
      ProductCategory(
        id: '3',
        name: 'Furniture',
        subCategories: ['Sofas', 'Tables', 'Chairs'],
      ),
      ProductCategory(
        id: '4',
        name: 'Food & Drinks',
        subCategories: ['Beverages', 'Dairy', 'Snacks'],
      ),
    ];
  }

  /// add a new category
  Future<void> addCategory(ProductCategory category) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, category]);
  }

  /// add a sub-category to an existing category
  Future<void> addSubCategory(String categoryId, String subCategory) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((c) {
        if (c.id == categoryId) {
          return ProductCategory(
            id: c.id,
            name: c.name,
            subCategories: [...c.subCategories, subCategory],
          );
        }
        return c;
      }).toList(),
    );
  }
}
