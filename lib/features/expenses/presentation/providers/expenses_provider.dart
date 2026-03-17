import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/presentation/providers/core/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';

part 'expenses_provider.g.dart';

@riverpod
ExpenseRemoteDatasource expenseRemoteDatasource(Ref ref) {
  return ExpenseRemoteDatasourceImpl(ref.watch(dioClientProvider));
}

@riverpod
ExpenseRepository expenseRepository(Ref ref) {
  return ExpenseRepositoryImpl(ref.watch(expenseRemoteDatasourceProvider));
}

/// state holder for expenses list with pagination info
class ExpensesState {
  final List<ExpenseModel> expenses;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool hasMorePages;
  final String? searchQuery;

  const ExpensesState({
    this.expenses = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.hasMorePages = true,
    this.searchQuery,
  });

  ExpensesState copyWith({
    List<ExpenseModel>? expenses,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? hasMorePages,
    String? searchQuery,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

@riverpod
class Expenses extends _$Expenses {
  ExpenseRepository get _repo => ref.watch(expenseRepositoryProvider);

  @override
  Future<ExpensesState> build() async {
    return _fetchPage(1);
  }

  /// fetches a specific page and returns a fresh state
  Future<ExpensesState> _fetchPage(int page, {String? search}) async {
    final result = await _repo.getExpenses(page: page, search: search);
    return result.fold(
      (failure) => throw failure,
      (response) => ExpensesState(
        expenses: response.data ?? [],
        currentPage: response.currentPage ?? 1,
        lastPage: response.lastPage ?? 1,
        hasMorePages: (response.currentPage ?? 1) < (response.lastPage ?? 1),
        searchQuery: search,
      ),
    );
  }

  /// loads the next page and appends expenses to the existing list
  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMorePages || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _repo.getExpenses(
      page: nextPage,
      search: current.searchQuery,
    );

    result.fold(
      (failure) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (response) {
        state = AsyncData(
          current.copyWith(
            expenses: [...current.expenses, ...?response.data],
            currentPage: response.currentPage ?? nextPage,
            lastPage: response.lastPage ?? current.lastPage,
            hasMorePages:
                (response.currentPage ?? nextPage) <
                (response.lastPage ?? current.lastPage),
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  /// updates an existing expense and refreshes the local list
  Future<String?> updateExpense(int id, Map<String, dynamic> body) async {
    final result = await _repo.updateExpense(id, body);

    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    final response = result.getOrElse(
      () => throw Exception('Failed to parse updated expense'),
    );

    final updatedExpense = response.data;
    if (updatedExpense != null) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            expenses: current.expenses.map((e) {
              return e.id == id ? updatedExpense : e;
            }).toList(),
          ),
        );
      }
    }

    return null;
  }

  /// search expenses
  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1, search: query));
  }

  /// creates a new expense and prepends it to the local list
  Future<String?> createExpense(Map<String, dynamic> body) async {
    final result = await _repo.createExpense(body);

    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    final response = result.getOrElse(
      () => throw Exception('Failed to parse created expense'),
    );

    final createdExpense = response.data;
    if (createdExpense != null) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(expenses: [createdExpense, ...current.expenses]),
        );
      }
    }

    return null;
  }

  /// deletes an expense and removes it from the local list
  Future<String?> deleteExpense(int id) async {
    final result = await _repo.deleteExpense(id);

    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          expenses: current.expenses.where((e) => e.id != id).toList(),
        ),
      );
    }

    return null;
  }

  /// refreshes from page 1
  Future<void> refresh() async {
    final currentSearch = state.valueOrNull?.searchQuery;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1, search: currentSearch));
  }
}
