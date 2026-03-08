// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authHash() => r'48361b97fc1078f1d1d85a98ef36c791b68d83b7';

/// holds the current logged-in session
///
/// Copied from [Auth].
@ProviderFor(Auth)
final authProvider =
    AutoDisposeNotifierProvider<Auth, AsyncValue<LoginResponseModel?>>.internal(
      Auth.new,
      name: r'authProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Auth = AutoDisposeNotifier<AsyncValue<LoginResponseModel?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
