import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';
import 'package:onepos_admin_app/features/sales/data/repositories/sales_repository_impl.dart';

part 'sales_provider.g.dart';

/// sales provider with filtering support
@Riverpod(keepAlive: true)
class Sales extends _$Sales {
  SalesRepositoryImpl get _repo =>
      SalesRepositoryImpl(SalesRemoteDatasourceImpl(DioClient()));

  @override
  Future<SalesState> build() async {
    return _fetchPage(1);
  }

  /// fetches a page and returns fresh state
  Future<SalesState> _fetchPage(int page) async {
    final result = await _repo.getSales(page: page);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) => SalesState(
        sales: response.sales,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        hasMorePages: response.hasMorePages,
      ),
    );
  }

  /// fetches next page and appends data
  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMorePages || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _repo.getSales(page: nextPage);

    result.fold(
      (_) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (response) {
        state = AsyncData(
          current.copyWith(
            sales: [...current.sales, ...response.sales],
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            hasMorePages: response.hasMorePages,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  /// refresh sales list
  Future<void> refreshSales() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }
}
