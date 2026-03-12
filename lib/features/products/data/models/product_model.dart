/// model for a product
class ProductModel {
  final int id;
  final String name;
  final double price;
  final String? category;
  final String? subCategory;
  final int stock;
  final String? imageUrl;
  final String? store;
  final String? warehouse;
  final String? supplier;
  final String? sku;
  final String? barcode;
  final String? manufacturingDate;
  final String? expiryDate;
  final String? description;
  final int? catId;
  final int? subCatId;
  final int quantityPurchased;
  final int inStock;
  final int isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.category,
    this.subCategory,
    this.stock = 0,
    this.imageUrl,
    this.store,
    this.warehouse,
    this.supplier,
    this.sku,
    this.barcode,
    this.manufacturingDate,
    this.expiryDate,
    this.description,
    this.catId,
    this.subCatId,
    this.quantityPurchased = 0,
    this.inStock = 0,
    this.isActive = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // raw values
    final rawCategory = json['category'];
    final rawSubCategory = json['subcategory'];

    // map category name & id
    String? catName;
    int? parsedCatId;
    if (rawCategory is Map<String, dynamic>) {
      catName = rawCategory['cat_name']?.toString();
      parsedCatId = int.tryParse(rawCategory['id']?.toString() ?? '');
    } else {
      catName = rawCategory?.toString();
    }

    // fallback mapping if API returns integers straight on the root
    parsedCatId ??= int.tryParse(json['cat_id']?.toString() ?? '');

    // map subcat name & id
    String? subCatName;
    int? parsedSubCatId;
    if (rawSubCategory is Map<String, dynamic>) {
      subCatName = rawSubCategory['cat_name']?.toString();
      parsedSubCatId = int.tryParse(rawSubCategory['id']?.toString() ?? '');
    } else {
      subCatName = rawSubCategory?.toString();
    }

    // fallback mapping
    parsedSubCatId ??= int.tryParse(json['sub_cat_id']?.toString() ?? '');

    return ProductModel(
      id: json['id'] as int,
      name: json['product_name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      category: catName,
      subCategory: subCatName,
      stock: int.tryParse(json['available_quantity']?.toString() ?? '0') ?? 0,
      imageUrl: json['product_image']?.toString(),
      store: json['store']?.toString(),
      warehouse: json['warehouse']?.toString(),
      supplier: json['supplier']?.toString(),
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      manufacturingDate: json['manufacturing_date']?.toString(),
      expiryDate: json['expiring_date']?.toString(),
      description: json['description']?.toString(),
      catId: parsedCatId,
      subCatId: parsedSubCatId,
      quantityPurchased:
          int.tryParse(json['quantity_purchased']?.toString() ?? '0') ?? 0,
      inStock: int.tryParse(json['in_stock']?.toString() ?? '0') ?? 0,
      isActive: int.tryParse(json['is_active']?.toString() ?? '0') ?? 0,
    );
  }

  ProductModel copyWith({
    int? id,
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
    String? manufacturingDate,
    String? expiryDate,
    String? description,
    int? catId,
    int? subCatId,
    int? quantityPurchased,
    int? inStock,
    int? isActive,
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
      catId: catId ?? this.catId,
      subCatId: subCatId ?? this.subCatId,
      quantityPurchased: quantityPurchased ?? this.quantityPurchased,
      inStock: inStock ?? this.inStock,
      isActive: isActive ?? this.isActive,
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
