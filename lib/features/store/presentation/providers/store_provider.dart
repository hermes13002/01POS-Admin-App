import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/sub_category_repository.dart';
import '../../data/models/category_model.dart';
import '../../data/datasources/sub_category_remote_datasource.dart';

part 'store_provider.g.dart';

class StoreCategoriesState {
  final List<CategoryModel> categories;
  final int currentPage;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;

  StoreCategoriesState({
    this.categories = const [],
    this.currentPage = 1,
    this.total = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  StoreCategoriesState copyWith({
    List<CategoryModel>? categories,
    int? currentPage,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return StoreCategoriesState(
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class StoreCategories extends _$StoreCategories {
  CategoryRepository get _repo =>
      CategoryRepositoryImpl(CategoryRemoteDatasourceImpl(DioClient()));

  @override
  Future<StoreCategoriesState> build() async {
    final result = await _repo.getCategories(page: 1);
    return result.fold(
      (failure) => throw failure,
      (response) => StoreCategoriesState(
        categories: response.categories,
        currentPage: response.currentPage,
        total: response.total,
        hasMore: response.currentPage < response.lastPage,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await _repo.getCategories(page: current.currentPage + 1);

    result.fold(
      (failure) => state = AsyncData(current.copyWith(isLoadingMore: false)),
      (response) {
        state = AsyncData(
          current.copyWith(
            categories: [...current.categories, ...response.categories],
            currentPage: response.currentPage,
            total: response.total,
            hasMore: response.currentPage < response.lastPage,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  /// add a new category
  Future<void> addCategory({
    required String name,
    required String description,
  }) async {
    final result = await _repo.createCategory(
      name: name,
      description: description,
    );

    result.fold(
      (failure) => null, // handle failure in UI
      (newCategory) {
        final current = state.valueOrNull;
        if (current != null) {
          state = AsyncData(
            current.copyWith(
              categories: [newCategory, ...current.categories],
              total: (current.total) + 1,
            ),
          );
        }
      },
    );
  }

  /// update an existing category
  Future<void> updateCategory(
    int id, {
    required String name,
    required String description,
  }) async {
    final result = await _repo.updateCategory(
      id,
      name: name,
      description: description,
    );

    result.fold(
      (failure) => null, // handle failure in UI or locally
      (updatedCategory) {
        final current = state.valueOrNull;
        if (current != null) {
          state = AsyncData(
            current.copyWith(
              categories: current.categories
                  .map((c) => c.id == updatedCategory.id ? updatedCategory : c)
                  .toList(),
            ),
          );
        }
      },
    );
  }

  /// delete a category by id
  Future<bool> deleteCategory(int categoryId) async {
    final result = await _repo.deleteCategory(categoryId);

    return result.fold((failure) => false, (_) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            categories: current.categories
                .where((c) => c.id != categoryId)
                .toList(),
            total: current.total > 0 ? current.total - 1 : 0,
          ),
        );
      }
      return true;
    });
  }

  /// fetch single category details
  Future<CategoryModel?> getCategoryDetails(int id) async {
    final result = await _repo.getCategoryDetails(id);
    return result.fold((failure) => null, (category) => category);
  }

  /// toggle category active status
  Future<bool> toggleCategoryStatus(int id, bool activate) async {
    final result = activate
        ? await _repo.activateCategory(id)
        : await _repo.deactivateCategory(id);

    return result.fold((failure) => false, (updatedCategory) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            categories: current.categories
                .map((c) => c.id == id ? updatedCategory : c)
                .toList(),
          ),
        );
      }
      return true;
    });
  }

  /// refresh categories
  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

class StoreSubCategoriesState {
  final List<SubCategoryModel> subCategories;
  final int currentPage;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;

  StoreSubCategoriesState({
    this.subCategories = const [],
    this.currentPage = 1,
    this.total = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  StoreSubCategoriesState copyWith({
    List<SubCategoryModel>? subCategories,
    int? currentPage,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return StoreSubCategoriesState(
      subCategories: subCategories ?? this.subCategories,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class StoreSubCategories extends _$StoreSubCategories {
  SubCategoryRepository get _repo =>
      SubCategoryRepositoryImpl(SubCategoryRemoteDatasourceImpl(DioClient()));

  @override
  Future<StoreSubCategoriesState> build() async {
    final result = await _repo.getSubCategories(page: 1);
    return result.fold(
      (failure) => throw failure,
      (response) => StoreSubCategoriesState(
        subCategories: response.subCategories,
        currentPage: response.currentPage,
        total: response.total,
        hasMore: response.currentPage < response.lastPage,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await _repo.getSubCategories(page: current.currentPage + 1);

    result.fold(
      (failure) => state = AsyncData(current.copyWith(isLoadingMore: false)),
      (response) {
        state = AsyncData(
          current.copyWith(
            subCategories: [
              ...current.subCategories,
              ...response.subCategories,
            ],
            currentPage: response.currentPage,
            total: response.total,
            hasMore: response.currentPage < response.lastPage,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  /// add a new sub-category
  Future<bool> addSubCategory({
    required int categoryId,
    required String name,
  }) async {
    final result = await _repo.createSubCategory(
      categoryId: categoryId,
      name: name,
    );

    return result.fold((failure) => false, (newSub) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            subCategories: [newSub, ...current.subCategories],
            total: (current.total) + 1,
          ),
        );
      }
      // Invalidate categories as well since a new sub-category was added
      ref.invalidate(storeCategoriesProvider);
      return true;
    });
  }

  /// delete a sub-category by id
  Future<bool> deleteSubCategory(int id) async {
    final result = await _repo.deleteSubCategory(id);

    return result.fold((failure) => false, (_) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            subCategories: current.subCategories
                .where((s) => s.id != id)
                .toList(),
            total: current.total > 0 ? current.total - 1 : 0,
          ),
        );
      }
      ref.invalidate(storeCategoriesProvider);
      return true;
    });
  }

  /// update an existing sub-category
  Future<bool> updateSubCategory(
    int id, {
    required int categoryId,
    required String name,
  }) async {
    final result = await _repo.updateSubCategory(
      id,
      categoryId: categoryId,
      name: name,
    );

    return result.fold((failure) => false, (updatedSub) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            subCategories: current.subCategories
                .map((s) => s.id == id ? updatedSub : s)
                .toList(),
          ),
        );
      }
      ref.invalidate(storeCategoriesProvider);
      return true;
    });
  }

  /// toggle sub-category active status
  Future<bool> toggleSubCategoryStatus(int id, bool activate) async {
    final result = activate
        ? await _repo.activateSubCategory(id)
        : await _repo.deactivateSubCategory(id);

    return result.fold((failure) => false, (updatedSub) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            subCategories: current.subCategories
                .map((s) => s.id == id ? updatedSub : s)
                .toList(),
          ),
        );
      }
      ref.invalidate(storeCategoriesProvider);
      return true;
    });
  }

  /// get sub-category details by id
  Future<SubCategoryModel?> getSubCategoryDetails(int id) async {
    final result = await _repo.getSubCategoryDetails(id);
    return result.fold((failure) => null, (subCategory) => subCategory);
  }

  /// refresh sub-categories
  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}
