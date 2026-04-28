// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userProfileHash() => r'fa6a6f7381d350b36faae52f1636c4d864e7484c';

/// fetches authenticated user profile — kept alive so it is shared
/// between the home screen and store profile screen without re-fetching
///
/// Copied from [UserProfile].
@ProviderFor(UserProfile)
final userProfileProvider =
    AsyncNotifierProvider<UserProfile, ProfileModel>.internal(
  UserProfile.new,
  name: r'userProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserProfile = AsyncNotifier<ProfileModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
