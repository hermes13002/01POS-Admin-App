// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$autoBillRepositoryHash() =>
    r'2fddbb9ce0a3899c96f0929b5db001824dc8c494';

/// See also [autoBillRepository].
@ProviderFor(autoBillRepository)
final autoBillRepositoryProvider =
    AutoDisposeProvider<AutoBillRepositoryImpl>.internal(
      autoBillRepository,
      name: r'autoBillRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$autoBillRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AutoBillRepositoryRef = AutoDisposeProviderRef<AutoBillRepositoryImpl>;
String _$billOptionsHash() => r'ab0bb78a84f4cf8d7c97c2346a098ae28649746e';

/// See also [billOptions].
@ProviderFor(billOptions)
final billOptionsProvider =
    AutoDisposeFutureProvider<List<BillOptionModel>>.internal(
      billOptions,
      name: r'billOptionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$billOptionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BillOptionsRef = AutoDisposeFutureProviderRef<List<BillOptionModel>>;
String _$billsHash() => r'9ad63ecba9b36e2ce69d4278585f60e8a867ee7f';

/// See also [Bills].
@ProviderFor(Bills)
final billsProvider =
    AutoDisposeAsyncNotifierProvider<Bills, BillState>.internal(
      Bills.new,
      name: r'billsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$billsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Bills = AutoDisposeAsyncNotifier<BillState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
