import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';
import 'package:onepos_admin_app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';

part 'sales_provider.g.dart';

/// sales provider with filtering support
@Riverpod(keepAlive: true)
class Sales extends _$Sales {
  SalesRepositoryImpl get _repo =>
      SalesRepositoryImpl(SalesRemoteDatasourceImpl(DioClient()));

  @override
  Future<SalesState> build() async {
    final profile = await ref.watch(userProfileProvider.future);
    final isDownloadEnabled = profile.company?.salesDownload ?? false;
    final state = await _fetchPage(1);
    return state.copyWith(isDownloadEnabled: isDownloadEnabled);
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
    final currentEnabled = state.valueOrNull?.isDownloadEnabled ?? false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newState = await _fetchPage(1);
      return newState.copyWith(isDownloadEnabled: currentEnabled);
    });
  }

  /// toggle sales download activation
  Future<void> toggleDownloadActivation(int companyId, bool activate) async {
    final result = activate
        ? await _repo.activateDownload(companyId)
        : await _repo.deactivateDownload(companyId);

    result.fold((failure) => throw Exception(failure.message), (_) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(current.copyWith(isDownloadEnabled: activate));
        // We removed ref.invalidate(userProfileProvider) here because:
        // 1. It forces a complete rebuild of the sales list (kills pagination).
        // 2. The API might not immediately reflect the update, causing a local stale state flash.
        // Instead, the UI in StoreProfileScreen now strictly listens to this provider for sync.
      }
    });
  }

  /// download sales
  Future<List<SaleModel>> downloadSales({
    required String from,
    required String to,
  }) async {
    final result = await _repo.downloadSales(from: from, to: to);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (sales) => sales,
    );
  }
}
