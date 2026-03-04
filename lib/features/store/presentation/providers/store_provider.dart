import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../products/data/models/product_model.dart';

part 'store_provider.g.dart';

/// store categories provider for my store screen
@riverpod
class StoreCategories extends _$StoreCategories {
  @override
  Future<List<ProductCategory>> build() async {
    // TODO: replace with actual api call
    return _getMockCategories();
  }

  /// add a new category
  Future<void> addCategory(ProductCategory category) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, category]);
  }

  /// update an existing category
  Future<void> updateCategory(ProductCategory category) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((c) => c.id == category.id ? category : c).toList(),
    );
  }

  /// delete a category by id
  Future<void> deleteCategory(String categoryId) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((c) => c.id != categoryId).toList());
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

  /// remove a sub-category from a category
  Future<void> removeSubCategory(
      String categoryId, String subCategory) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((c) {
        if (c.id == categoryId) {
          return ProductCategory(
            id: c.id,
            name: c.name,
            subCategories:
                c.subCategories.where((s) => s != subCategory).toList(),
          );
        }
        return c;
      }).toList(),
    );
  }

  /// refresh categories
  Future<void> refreshCategories() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _getMockCategories();
    });
  }

  /// mock data for development
  List<ProductCategory> _getMockCategories() {
    return const [
      ProductCategory(
        id: '1',
        name: 'Furniture',
        subCategories: ['Living Room', 'Bedroom', 'Office Furniture'],
      ),
      ProductCategory(
        id: '2',
        name: 'Pharmaceuticals',
        subCategories: ['Over-the-counter', 'Prescription', 'Supplements'],
      ),
      ProductCategory(
        id: '3',
        name: 'Groceries',
        subCategories: ['Dairy', 'Beverages', 'Snacks'],
      ),
      ProductCategory(
        id: '4',
        name: 'Electronics',
        subCategories: ['Laptops', 'Phones', 'Accessories'],
      ),
      ProductCategory(
        id: '5',
        name: 'Stationery',
        subCategories: ['Pens', 'Notebooks', 'Art Supplies'],
      ),
    ];
  }
}
