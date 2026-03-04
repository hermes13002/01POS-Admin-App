// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeCategoriesHash() => r'367750627d5b88d5742b8969545dd5c2a073045a';

/// store categories provider for my store screen
///
/// Copied from [StoreCategories].
@ProviderFor(StoreCategories)
final storeCategoriesProvider =
    AutoDisposeAsyncNotifierProvider<
      StoreCategories,
      List<ProductCategory>
    >.internal(
      StoreCategories.new,
      name: r'storeCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storeCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StoreCategories = AutoDisposeAsyncNotifier<List<ProductCategory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
