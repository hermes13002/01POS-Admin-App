/// model for a product
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final int stock;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    this.imageUrl,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    int? stock,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// model for a product category
class ProductCategory {
  final String id;
  final String name;
  final List<String> subCategories;

  const ProductCategory({
    required this.id,
    required this.name,
    this.subCategories = const [],
  });
}
