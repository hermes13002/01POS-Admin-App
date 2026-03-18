// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productRepositoryHash() => r'2c93231218b83a32f74762cc26bd1f73e38b9efa';

/// See also [productRepository].
@ProviderFor(productRepository)
final productRepositoryProvider =
    AutoDisposeProvider<ProductRepositoryImpl>.internal(
      productRepository,
      name: r'productRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductRepositoryRef = AutoDisposeProviderRef<ProductRepositoryImpl>;
String _$singleProductHash() => r'3bf38d54d4cd046b6e1bd3c9879f80adf4a47dd5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// fetch single product by id endpoint
///
/// Copied from [singleProduct].
@ProviderFor(singleProduct)
const singleProductProvider = SingleProductFamily();

/// fetch single product by id endpoint
///
/// Copied from [singleProduct].
class SingleProductFamily
    extends Family<AsyncValue<ApiResponse<ProductModel>>> {
  /// fetch single product by id endpoint
  ///
  /// Copied from [singleProduct].
  const SingleProductFamily();

  /// fetch single product by id endpoint
  ///
  /// Copied from [singleProduct].
  SingleProductProvider call(int id) {
    return SingleProductProvider(id);
  }

  @override
  SingleProductProvider getProviderOverride(
    covariant SingleProductProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'singleProductProvider';
}

/// fetch single product by id endpoint
///
/// Copied from [singleProduct].
class SingleProductProvider
    extends AutoDisposeFutureProvider<ApiResponse<ProductModel>> {
  /// fetch single product by id endpoint
  ///
  /// Copied from [singleProduct].
  SingleProductProvider(int id)
    : this._internal(
        (ref) => singleProduct(ref as SingleProductRef, id),
        from: singleProductProvider,
        name: r'singleProductProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$singleProductHash,
        dependencies: SingleProductFamily._dependencies,
        allTransitiveDependencies:
            SingleProductFamily._allTransitiveDependencies,
        id: id,
      );

  SingleProductProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<ApiResponse<ProductModel>> Function(SingleProductRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SingleProductProvider._internal(
        (ref) => create(ref as SingleProductRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ApiResponse<ProductModel>> createElement() {
    return _SingleProductProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SingleProductProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SingleProductRef
    on AutoDisposeFutureProviderRef<ApiResponse<ProductModel>> {
  /// The parameter `id` of this provider.
  int get id;
}

class _SingleProductProviderElement
    extends AutoDisposeFutureProviderElement<ApiResponse<ProductModel>>
    with SingleProductRef {
  _SingleProductProviderElement(super.provider);

  @override
  int get id => (origin as SingleProductProvider).id;
}

String _$productsHash() => r'28dfdb3eb32c0dc28a7d1c714b45afdda4a14904';

/// products paginated data provider
///
/// Copied from [Products].
@ProviderFor(Products)
final productsProvider =
    AutoDisposeAsyncNotifierProvider<Products, ProductsState>.internal(
      Products.new,
      name: r'productsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Products = AutoDisposeAsyncNotifier<ProductsState>;
String _$productCategoriesHash() => r'33ccd1961702e877e1a9c3da324b4171d4da6e6b';

/// categories provider
///
/// Copied from [ProductCategories].
@ProviderFor(ProductCategories)
final productCategoriesProvider =
    AutoDisposeAsyncNotifierProvider<
      ProductCategories,
      List<ProductCategory>
    >.internal(
      ProductCategories.new,
      name: r'productCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProductCategories = AutoDisposeAsyncNotifier<List<ProductCategory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
