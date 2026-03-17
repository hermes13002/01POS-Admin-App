// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseRemoteDatasourceHash() =>
    r'531d77e2f2b53086a63a0acef97fe1e57eb19079';

/// See also [expenseRemoteDatasource].
@ProviderFor(expenseRemoteDatasource)
final expenseRemoteDatasourceProvider =
    AutoDisposeProvider<ExpenseRemoteDatasource>.internal(
      expenseRemoteDatasource,
      name: r'expenseRemoteDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseRemoteDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseRemoteDatasourceRef =
    AutoDisposeProviderRef<ExpenseRemoteDatasource>;
String _$expenseRepositoryHash() => r'591a31d3386e8f36a6dabe36f9ee7bc2d186c590';

/// See also [expenseRepository].
@ProviderFor(expenseRepository)
final expenseRepositoryProvider =
    AutoDisposeProvider<ExpenseRepository>.internal(
      expenseRepository,
      name: r'expenseRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseRepositoryRef = AutoDisposeProviderRef<ExpenseRepository>;
String _$expensesHash() => r'ef606e3eef1b4a4e55bffe912fbaa822e54a9f5a';

/// See also [Expenses].
@ProviderFor(Expenses)
final expensesProvider =
    AutoDisposeAsyncNotifierProvider<Expenses, ExpensesState>.internal(
      Expenses.new,
      name: r'expensesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expensesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Expenses = AutoDisposeAsyncNotifier<ExpensesState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
