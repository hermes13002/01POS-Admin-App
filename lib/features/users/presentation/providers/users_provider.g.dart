// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$usersRepositoryHash() => r'bc9803f25366562149243da7e812287c58a83af6';

/// See also [usersRepository].
@ProviderFor(usersRepository)
final usersRepositoryProvider =
    AutoDisposeProvider<UsersRepositoryImpl>.internal(
      usersRepository,
      name: r'usersRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$usersRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UsersRepositoryRef = AutoDisposeProviderRef<UsersRepositoryImpl>;
String _$allUsersHash() => r'905ff46e8bcc9776334e68a7156ae3210e72714b';

/// manages paginated users state
///
/// Copied from [AllUsers].
@ProviderFor(AllUsers)
final allUsersProvider = AsyncNotifierProvider<AllUsers, UsersState>.internal(
  AllUsers.new,
  name: r'allUsersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AllUsers = AsyncNotifier<UsersState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
