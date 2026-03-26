import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import 'package:onepos_admin_app/features/bill/data/models/auto_bill_model.dart';
import 'package:onepos_admin_app/features/bill/data/repositories/auto_bill_repository_impl.dart';
import 'package:onepos_admin_app/features/bill/presentation/providers/bill_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bill_providers.g.dart';

@riverpod
AutoBillRepositoryImpl autoBillRepository(Ref ref) {
  return AutoBillRepositoryImpl();
}

@riverpod
class Bills extends _$Bills {
  @override
  FutureOr<BillState> build() async {
    final repository = ref.watch(autoBillRepositoryProvider);
    final response = await repository.fetchAutoBills(page: 1);

    if (response.success && response.data != null) {
      final meta = response.meta;
      final hasMorePages = meta == null
          ? false
          : meta.currentPage < meta.totalPages;

      return BillState(
        bills: response.data!,
        currentPage: meta?.currentPage ?? 1,
        hasMorePages: hasMorePages,
      );
    } else {
      return BillState(error: response.message);
    }
  }

  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMorePages || current.isLoading) return;

    state = AsyncData(current.copyWith(isLoading: true));

    final nextPage = current.currentPage + 1;
    final repository = ref.read(autoBillRepositoryProvider);
    final response = await repository.fetchAutoBills(page: nextPage);

    if (response.success && response.data != null) {
      final meta = response.meta;
      final hasMorePages = meta == null
          ? false
          : meta.currentPage < meta.totalPages;

      state = AsyncData(
        current.copyWith(
          bills: [...current.bills, ...response.data!],
          currentPage: meta?.currentPage ?? nextPage,
          hasMorePages: hasMorePages,
          isLoading: false,
        ),
      );
    } else {
      state = AsyncData(
        current.copyWith(isLoading: false, error: response.message),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(autoBillRepositoryProvider);
      final response = await repository.fetchAutoBills(page: 1);
      if (response.success && response.data != null) {
        final meta = response.meta;
        final hasMorePages = meta == null
            ? false
            : meta.currentPage < meta.totalPages;
        return BillState(
          bills: response.data!,
          currentPage: meta?.currentPage ?? 1,
          hasMorePages: hasMorePages,
        );
      } else {
        return BillState(error: response.message);
      }
    });
  }

  Future<ApiResponse<AutoBillModel>> addBillItem(
    Map<String, dynamic> data,
  ) async {
    final repository = ref.read(autoBillRepositoryProvider);
    final response = await repository.addAutoBill(data);

    if (response.success && response.data != null) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(bills: [response.data!, ...current.bills]),
        );
      }
    }
    return response;
  }

  Future<ApiResponse<AutoBillModel>> updateBillItem(
    int id,
    Map<String, dynamic> data,
  ) async {
    final repository = ref.read(autoBillRepositoryProvider);
    final response = await repository.updateAutoBill(id, data);

    if (response.success && response.data != null) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            bills: current.bills
                .map((b) => b.id == id ? response.data! : b)
                .toList(),
          ),
        );
      }
    }
    return response;
  }

  Future<ApiResponse<void>> deleteBillItem(int id) async {
    final repository = ref.read(autoBillRepositoryProvider);
    final response = await repository.deleteAutoBill(id);

    if (response.success) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            bills: current.bills.where((b) => b.id != id).toList(),
          ),
        );
      }
    }
    return response;
  }

  Future<ApiResponse<AutoBillModel>> toggleBillStatus(
    int id,
    bool activate,
  ) async {
    final repository = ref.read(autoBillRepositoryProvider);
    final response = activate
        ? await repository.activateAutoBill(id)
        : await repository.deactivateAutoBill(id);

    if (response.success && response.data != null) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            bills: current.bills
                .map((b) => b.id == id ? response.data! : b)
                .toList(),
          ),
        );
      }
    }
    return response;
  }
}

@riverpod
Future<List<BillOptionModel>> billOptions(Ref ref) async {
  final repository = ref.read(autoBillRepositoryProvider);
  final response = await repository.fetchBillOptions();
  if (response.success && response.data != null) {
    return response.data!;
  }
  return [];
}
