// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'low_stock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lowStockProductsHash() => r'25996f68a66f2ccdef53a10da7effeac298cf9ce';

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
