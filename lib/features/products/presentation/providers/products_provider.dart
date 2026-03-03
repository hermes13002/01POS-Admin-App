import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/product_model.dart';

part 'products_provider.g.dart';

/// products data provider
@riverpod
class Products extends _$Products {
  @override
  Future<List<ProductModel>> build() async {
    // TODO: replace with actual api call
    return _getMockProducts();
  }

  /// add a new product
  Future<void> addProduct(ProductModel product) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, product]);
  }

  /// update an existing product
  Future<void> updateProduct(ProductModel product) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((p) => p.id == product.id ? product : p).toList(),
    );
  }

  /// delete a product by id
  Future<void> deleteProduct(String productId) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((p) => p.id != productId).toList());
  }

  /// refresh products list
  Future<void> refreshProducts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _getMockProducts();
    });
  }

  /// mock data for development
  List<ProductModel> _getMockProducts() {
    return const [
      ProductModel(
        id: '1',
        name: 'Ultrabook pro 15',
        price: 70000,
        category: 'Electronics',
        stock: 25,
      ),
      ProductModel(
        id: '2',
        name: 'Herbal sleep aid',
        price: 70000,
        category: 'Health',
        stock: 1,
      ),
      ProductModel(
        id: '3',
        name: 'Cross sectional sofa',
        price: 70000,
        category: 'Furniture',
        stock: 10,
      ),
      ProductModel(
        id: '4',
        name: 'Cold brew coffee',
        price: 70000,
        category: 'Food & Drinks',
        stock: 15,
      ),
      ProductModel(
        id: '5',
        name: 'Organic whole milk',
        price: 70000,
        category: 'Food & Drinks',
        stock: 30,
      ),
    ];
  }
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
