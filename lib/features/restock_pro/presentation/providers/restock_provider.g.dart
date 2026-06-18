// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$restockSuggestionsHash() =>
    r'466c1d733ede0f98e7dd7d8cdf3557a8d852a95b';

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

abstract class _$RestockSuggestions extends BuildlessAutoDisposeAsyncNotifier<
    ApiResponse<List<RestockSuggestionModel>>> {
  late final int page;

  FutureOr<ApiResponse<List<RestockSuggestionModel>>> build({
    int page = 1,
  });
}

/// See also [RestockSuggestions].
@ProviderFor(RestockSuggestions)
const restockSuggestionsProvider = RestockSuggestionsFamily();

/// See also [RestockSuggestions].
class RestockSuggestionsFamily
    extends Family<AsyncValue<ApiResponse<List<RestockSuggestionModel>>>> {
  /// See also [RestockSuggestions].
  const RestockSuggestionsFamily();

  /// See also [RestockSuggestions].
  RestockSuggestionsProvider call({
    int page = 1,
  }) {
    return RestockSuggestionsProvider(
      page: page,
    );
  }

  @override
  RestockSuggestionsProvider getProviderOverride(
    covariant RestockSuggestionsProvider provider,
  ) {
    return call(
      page: provider.page,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'restockSuggestionsProvider';
}

/// See also [RestockSuggestions].
class RestockSuggestionsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    RestockSuggestions, ApiResponse<List<RestockSuggestionModel>>> {
  /// See also [RestockSuggestions].
  RestockSuggestionsProvider({
    int page = 1,
  }) : this._internal(
          () => RestockSuggestions()..page = page,
          from: restockSuggestionsProvider,
          name: r'restockSuggestionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$restockSuggestionsHash,
          dependencies: RestockSuggestionsFamily._dependencies,
          allTransitiveDependencies:
              RestockSuggestionsFamily._allTransitiveDependencies,
          page: page,
        );

  RestockSuggestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
  }) : super.internal();

  final int page;

  @override
  FutureOr<ApiResponse<List<RestockSuggestionModel>>> runNotifierBuild(
    covariant RestockSuggestions notifier,
  ) {
    return notifier.build(
      page: page,
    );
  }

  @override
  Override overrideWith(RestockSuggestions Function() create) {
    return ProviderOverride(
      origin: this,
      override: RestockSuggestionsProvider._internal(
        () => create()..page = page,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<RestockSuggestions,
      ApiResponse<List<RestockSuggestionModel>>> createElement() {
    return _RestockSuggestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RestockSuggestionsProvider && other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RestockSuggestionsRef on AutoDisposeAsyncNotifierProviderRef<
    ApiResponse<List<RestockSuggestionModel>>> {
  /// The parameter `page` of this provider.
  int get page;
}

class _RestockSuggestionsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<RestockSuggestions,
        ApiResponse<List<RestockSuggestionModel>>> with RestockSuggestionsRef {
  _RestockSuggestionsProviderElement(super.provider);

  @override
  int get page => (origin as RestockSuggestionsProvider).page;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
