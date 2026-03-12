import 'package:onepos_admin_app/features/products/data/models/product_model.dart';

class ProductsState {
  final List<ProductModel> products;
  final bool isLoading;
  final bool hasMorePages;
  final int currentPage;
  final String? error;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.hasMorePages = true,
    this.currentPage = 1,
    this.error,
  });

  ProductsState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? hasMorePages,
    int? currentPage,
    String? error,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}
