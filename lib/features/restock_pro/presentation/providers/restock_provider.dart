import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/restock_suggestion_model.dart';
import '../../data/repositories/restock_repository_impl.dart';
import '../../domain/repositories/restock_repository.dart';

part 'restock_provider.g.dart';

// state holder for restock suggestions list with pagination info
class RestockSuggestionsState {
  final List<RestockSuggestionModel> suggestions;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool hasMorePages;

  const RestockSuggestionsState({
    this.suggestions = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.hasMorePages = true,
  });

  RestockSuggestionsState copyWith({
    List<RestockSuggestionModel>? suggestions,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? hasMorePages,
  }) {
    return RestockSuggestionsState(
      suggestions: suggestions ?? this.suggestions,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

// restock suggestions provider
@riverpod
class RestockSuggestions extends _$RestockSuggestions {
  RestockRepository get _repository => RestockRepositoryImpl();

  @override
  Future<RestockSuggestionsState> build() async {
    return _fetchPage(1);
  }

  Future<RestockSuggestionsState> _fetchPage(int page) async {
    final response = await _repository.fetchRestockSuggestions(page: page);
    if (response.success && response.data != null) {
      final meta = response.meta;
      final hasMorePages = meta == null ? false : meta.currentPage < meta.totalPages;
      return RestockSuggestionsState(
        suggestions: response.data!,
        currentPage: meta?.currentPage ?? 1,
        lastPage: meta?.totalPages ?? 1,
        hasMorePages: hasMorePages,
      );
    } else {
      throw Exception(response.message ?? 'Failed to fetch suggestions');
    }
  }

  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMorePages || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    try {
      final response = await _repository.fetchRestockSuggestions(page: nextPage);
      if (response.success && response.data != null) {
        final meta = response.meta;
        final hasMorePages = meta == null ? false : meta.currentPage < meta.totalPages;
        state = AsyncData(
          current.copyWith(
            suggestions: [...current.suggestions, ...response.data!],
            currentPage: meta?.currentPage ?? nextPage,
            lastPage: meta?.totalPages ?? 1,
            hasMorePages: hasMorePages,
            isLoadingMore: false,
          ),
        );
      } else {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      }
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  // refresh suggestions
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }
}
