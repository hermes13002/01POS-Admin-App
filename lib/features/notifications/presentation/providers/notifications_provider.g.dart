// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationRemoteDatasourceHash() =>
    r'5440847f46fc5822d1f6f999653b0878f0d750a3';

/// See also [notificationRemoteDatasource].
@ProviderFor(notificationRemoteDatasource)
final notificationRemoteDatasourceProvider =
    AutoDisposeProvider<NotificationRemoteDatasource>.internal(
      notificationRemoteDatasource,
      name: r'notificationRemoteDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationRemoteDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationRemoteDatasourceRef =
    AutoDisposeProviderRef<NotificationRemoteDatasource>;
String _$notificationRepositoryHash() =>
    r'43c6e182a7df9aa36dccaf87917a7be636c0e567';

/// See also [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    AutoDisposeProvider<NotificationRepository>.internal(
      notificationRepository,
      name: r'notificationRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationRepositoryRef =
    AutoDisposeProviderRef<NotificationRepository>;
String _$notificationDetailHash() =>
    r'eacf7bac1bb13fdfe09e81cab1dc83e831ce89c8';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [notificationDetail].
@ProviderFor(notificationDetail)
const notificationDetailProvider = NotificationDetailFamily();

/// See also [notificationDetail].
class NotificationDetailFamily
    extends Family<AsyncValue<NotificationDetailModel>> {
  /// See also [notificationDetail].
  const NotificationDetailFamily();

  /// See also [notificationDetail].
  NotificationDetailProvider call(int id) {
    return NotificationDetailProvider(id);
  }

  @override
  NotificationDetailProvider getProviderOverride(
    covariant NotificationDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'notificationDetailProvider';
}

/// See also [notificationDetail].
class NotificationDetailProvider
    extends AutoDisposeFutureProvider<NotificationDetailModel> {
  /// See also [notificationDetail].
  NotificationDetailProvider(int id)
    : this._internal(
        (ref) => notificationDetail(ref as NotificationDetailRef, id),
        from: notificationDetailProvider,
        name: r'notificationDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$notificationDetailHash,
        dependencies: NotificationDetailFamily._dependencies,
        allTransitiveDependencies:
            NotificationDetailFamily._allTransitiveDependencies,
        id: id,
      );

  NotificationDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<NotificationDetailModel> Function(NotificationDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotificationDetailProvider._internal(
        (ref) => create(ref as NotificationDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<NotificationDetailModel> createElement() {
    return _NotificationDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotificationDetailRef
    on AutoDisposeFutureProviderRef<NotificationDetailModel> {
  /// The parameter `id` of this provider.
  int get id;
}

class _NotificationDetailProviderElement
    extends AutoDisposeFutureProviderElement<NotificationDetailModel>
    with NotificationDetailRef {
  _NotificationDetailProviderElement(super.provider);

  @override
  int get id => (origin as NotificationDetailProvider).id;
}

String _$unreadNotificationsCountHash() =>
    r'9efeb03188a28cba04e88f43d94bdebe29ca8fb7';

/// See also [unreadNotificationsCount].
@ProviderFor(unreadNotificationsCount)
final unreadNotificationsCountProvider = AutoDisposeProvider<int>.internal(
  unreadNotificationsCount,
  name: r'unreadNotificationsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationsCountRef = AutoDisposeProviderRef<int>;
String _$notificationsHash() => r'f3822c59f3f5c61322be536624db8f8ca38b778a';

/// See also [Notifications].
@ProviderFor(Notifications)
final notificationsProvider =
    AutoDisposeAsyncNotifierProvider<
      Notifications,
      NotificationsState
    >.internal(
      Notifications.new,
      name: r'notificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Notifications = AutoDisposeAsyncNotifier<NotificationsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
