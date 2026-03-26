// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'4d6554d7fe4659daf49f9c0d530adda921019294';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = AutoDisposeProvider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatRepositoryRef = AutoDisposeProviderRef<ChatRepository>;
String _$individualChatHash() => r'd369ac66d04d1a84600372f5306a60319bc44e2f';

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

/// See also [individualChat].
@ProviderFor(individualChat)
const individualChatProvider = IndividualChatFamily();

/// See also [individualChat].
class IndividualChatFamily extends Family<AsyncValue<List<ChatMessage>>> {
  /// See also [individualChat].
  const IndividualChatFamily();

  /// See also [individualChat].
  IndividualChatProvider call(int receiverId) {
    return IndividualChatProvider(receiverId);
  }

  @override
  IndividualChatProvider getProviderOverride(
    covariant IndividualChatProvider provider,
  ) {
    return call(provider.receiverId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'individualChatProvider';
}

/// See also [individualChat].
class IndividualChatProvider
    extends AutoDisposeFutureProvider<List<ChatMessage>> {
  /// See also [individualChat].
  IndividualChatProvider(int receiverId)
    : this._internal(
        (ref) => individualChat(ref as IndividualChatRef, receiverId),
        from: individualChatProvider,
        name: r'individualChatProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$individualChatHash,
        dependencies: IndividualChatFamily._dependencies,
        allTransitiveDependencies:
            IndividualChatFamily._allTransitiveDependencies,
        receiverId: receiverId,
      );

  IndividualChatProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.receiverId,
  }) : super.internal();

  final int receiverId;

  @override
  Override overrideWith(
    FutureOr<List<ChatMessage>> Function(IndividualChatRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IndividualChatProvider._internal(
        (ref) => create(ref as IndividualChatRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        receiverId: receiverId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ChatMessage>> createElement() {
    return _IndividualChatProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IndividualChatProvider && other.receiverId == receiverId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, receiverId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IndividualChatRef on AutoDisposeFutureProviderRef<List<ChatMessage>> {
  /// The parameter `receiverId` of this provider.
  int get receiverId;
}

class _IndividualChatProviderElement
    extends AutoDisposeFutureProviderElement<List<ChatMessage>>
    with IndividualChatRef {
  _IndividualChatProviderElement(super.provider);

  @override
  int get receiverId => (origin as IndividualChatProvider).receiverId;
}

String _$chatContactsHash() => r'0073b79884e6c3eb00ca8020fccfaca145f3b0be';

/// See also [chatContacts].
@ProviderFor(chatContacts)
final chatContactsProvider =
    AutoDisposeFutureProvider<List<ChatContact>>.internal(
      chatContacts,
      name: r'chatContactsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatContactsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatContactsRef = AutoDisposeFutureProviderRef<List<ChatContact>>;
String _$totalUnreadCountHash() => r'0ba529f363000fa71a9f44133444c198696fa4ae';

/// See also [totalUnreadCount].
@ProviderFor(totalUnreadCount)
final totalUnreadCountProvider = AutoDisposeProvider<int>.internal(
  totalUnreadCount,
  name: r'totalUnreadCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalUnreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalUnreadCountRef = AutoDisposeProviderRef<int>;
String _$chatNotifierHash() => r'059cbce8818a59e421bf71127768e03d19a44dbd';

/// See also [ChatNotifier].
@ProviderFor(ChatNotifier)
final chatNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ChatNotifier, void>.internal(
      ChatNotifier.new,
      name: r'chatNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
