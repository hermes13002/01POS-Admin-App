// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'low_stock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lowStockProductsHash() => r'a32a451342962bb559f569d801541ccdfe3f2c36';

/// low stock products provider
///
/// Copied from [LowStockProducts].
@ProviderFor(LowStockProducts)
final lowStockProductsProvider =
    AutoDisposeAsyncNotifierProvider<
      LowStockProducts,
      List<ProductModel>
    >.internal(
      LowStockProducts.new,
      name: r'lowStockProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lowStockProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LowStockProducts = AutoDisposeAsyncNotifier<List<ProductModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
