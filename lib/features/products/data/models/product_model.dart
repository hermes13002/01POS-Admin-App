/// model for a product
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? subCategory;
  final int stock;
  final String? imageUrl;
  final String? store;
  final String? warehouse;
  final String? supplier;
  final String? sku;
  final String? barcode;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final String? description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.subCategory,
    required this.stock,
    this.imageUrl,
    this.store,
    this.warehouse,
    this.supplier,
    this.sku,
    this.barcode,
    this.manufacturingDate,
    this.expiryDate,
    this.description,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? subCategory,
    int? stock,
    String? imageUrl,
    String? store,
    String? warehouse,
    String? supplier,
    String? sku,
    String? barcode,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    String? description,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      store: store ?? this.store,
      warehouse: warehouse ?? this.warehouse,
      supplier: supplier ?? this.supplier,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
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
