import 'package:onepos_admin_app/features/products/data/models/product_model.dart';

/// model for a category with products and sub-categories
class CategoryModel {
  final int id;
  final String name;
  final String? shortDescription;
  final int isActive;
  final List<SubCategoryModel> subCategories;
  final List<ProductModel> products;

  const CategoryModel({
    required this.id,
    required this.name,
    this.shortDescription,
    required this.isActive,
    this.subCategories = const [],
    this.products = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['cat_name']?.toString() ?? '',
      shortDescription: json['short_description']?.toString(),
      isActive: int.tryParse(json['is_active']?.toString() ?? '1') ?? 1,
      subCategories:
          (json['sub_categories'] as List<dynamic>?)
              ?.map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// model for a sub-category
class SubCategoryModel {
  final int id;
  final int? categoryId;
  final String name;
  final int isActive;
  final CategoryModel? category;
  final List<ProductModel> products;

  const SubCategoryModel({
    required this.id,
    this.categoryId,
    required this.name,
    required this.isActive,
    this.category,
    this.products = const [],
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      categoryId: int.tryParse(json['cat_id']?.toString() ?? ''),
      name:
          (json['sub_cat_name'] ?? json['cat_name'] ?? json['name'])
              ?.toString() ??
          '',
      isActive: int.tryParse(json['is_active']?.toString() ?? '1') ?? 1,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// paginated response for sub-categories
class PaginatedSubCategoriesResponse {
  final List<SubCategoryModel> subCategories;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginatedSubCategoriesResponse({
    required this.subCategories,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedSubCategoriesResponse.fromJson(Map<String, dynamic> json) {
    // Handle both wrapped and unwrapped data structure
    final rawData = json['data'];
    List<dynamic> list;
    Map<String, dynamic> meta;

    if (rawData is Map<String, dynamic>) {
      list = rawData['data'] as List<dynamic>? ?? [];
      meta = rawData;
    } else {
      list = rawData as List<dynamic>? ?? [];
      meta = json;
    }

    return PaginatedSubCategoriesResponse(
      subCategories: list
          .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] is int
          ? meta['current_page']
          : int.tryParse(meta['current_page'].toString()) ?? 1,
      lastPage: meta['last_page'] is int
          ? meta['last_page']
          : int.tryParse(meta['last_page'].toString()) ?? 1,
      perPage: meta['per_page'] is int
          ? meta['per_page']
          : int.tryParse(meta['per_page'].toString()) ?? 10,
      total: meta['total'] is int
          ? meta['total']
          : int.tryParse(meta['total'].toString()) ?? 0,
    );
  }
}

/// paginated response for categories
class PaginatedCategoriesResponse {
  final List<CategoryModel> categories;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginatedCategoriesResponse({
    required this.categories,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<dynamic> list;
    Map<String, dynamic> meta;

    if (rawData is Map<String, dynamic>) {
      list = rawData['data'] as List<dynamic>? ?? [];
      meta = rawData;
    } else {
      list = rawData as List<dynamic>? ?? [];
      meta = json;
    }

    return PaginatedCategoriesResponse(
      categories: list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] is int
          ? meta['current_page']
          : int.tryParse(meta['current_page'].toString()) ?? 1,
      lastPage: meta['last_page'] is int
          ? meta['last_page']
          : int.tryParse(meta['last_page'].toString()) ?? 1,
      perPage: meta['per_page'] is int
          ? meta['per_page']
          : int.tryParse(meta['per_page'].toString()) ?? 10,
      total: meta['total'] is int
          ? meta['total']
          : int.tryParse(meta['total'].toString()) ?? 0,
    );
  }
}
