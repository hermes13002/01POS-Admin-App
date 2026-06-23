// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_insights_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiInsightsRepositoryHash() =>
    r'69bb78aad9ba9b1027b60f79e9cf4f2b7c76c1ba';

/// See also [aiInsightsRepository].
@ProviderFor(aiInsightsRepository)
final aiInsightsRepositoryProvider =
    AutoDisposeProvider<AiInsightsRepository>.internal(
  aiInsightsRepository,
  name: r'aiInsightsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiInsightsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AiInsightsRepositoryRef = AutoDisposeProviderRef<AiInsightsRepository>;
String _$historicalInsightsHash() =>
    r'4ef39461a6e7e3d86ce5683f6aff56d730586dd7';

/// See also [historicalInsights].
@ProviderFor(historicalInsights)
final historicalInsightsProvider =
    AutoDisposeFutureProvider<List<AiInsight>>.internal(
  historicalInsights,
  name: r'historicalInsightsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historicalInsightsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HistoricalInsightsRef = AutoDisposeFutureProviderRef<List<AiInsight>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
