// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$companyDetailsHash() => r'cadf0cee051973fe97c468e09569c5c83258b63d';

/// derives company data from the profile provider — no extra api call
///
/// Copied from [companyDetails].
@ProviderFor(companyDetails)
final companyDetailsProvider = AutoDisposeFutureProvider<CompanyModel>.internal(
  companyDetails,
  name: r'companyDetailsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$companyDetailsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompanyDetailsRef = AutoDisposeFutureProviderRef<CompanyModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
