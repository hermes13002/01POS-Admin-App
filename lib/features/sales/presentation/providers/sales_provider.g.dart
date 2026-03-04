// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$salesHash() => r'59e12ab46694b4f76b1931721e6dc27773b022d2';

/// sales provider with filtering support
///
/// Copied from [Sales].
@ProviderFor(Sales)
final salesProvider =
    AutoDisposeAsyncNotifierProvider<Sales, List<SaleModel>>.internal(
      Sales.new,
      name: r'salesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$salesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Sales = AutoDisposeAsyncNotifier<List<SaleModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
