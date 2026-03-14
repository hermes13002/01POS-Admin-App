import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/customers/data/datasources/customers_remote_datasource.dart';
import 'package:onepos_admin_app/features/customers/data/models/customer_model.dart';
import 'package:onepos_admin_app/features/customers/data/repositories/customers_repository_impl.dart';

part 'customers_provider.g.dart';

/// customers provider
@Riverpod(keepAlive: true)
class Customers extends _$Customers {
  CustomersRepositoryImpl get _repo =>
      CustomersRepositoryImpl(CustomersRemoteDatasourceImpl(DioClient()));

  @override
  Future<CustomersState> build() async {
    return _fetchPage(1);
  }

  /// fetches a specific page and returns fresh state
  Future<CustomersState> _fetchPage(int page) async {
    final result = await _repo.getCustomers(page: page);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) => CustomersState(
        customers: response.customers,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        hasMorePages: response.hasMorePages,
      ),
    );
  }

  /// fetch next page of customers
  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMorePages || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _repo.getCustomers(page: nextPage);

    result.fold(
      (_) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (response) {
        state = AsyncData(
          current.copyWith(
            customers: [...current.customers, ...response.customers],
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            hasMorePages: response.hasMorePages,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  /// add a new customer
  Future<String?> addCustomer(Map<String, dynamic> body) async {
    final result = await _repo.createCustomer(body);

    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    final createdCustomer =
        result.getOrElse(() => throw Exception('failed to create customer'));
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          customers: [createdCustomer, ...current.customers],
        ),
      );
    }
    return null;
  }

  /// update an existing customer
  Future<String?> updateCustomer(
    int customerId,
    Map<String, dynamic> body,
  ) async {
    final current = state.valueOrNull;
    if (current == null) return 'customers not loaded';

    final result = await _repo.updateCustomer(customerId, body);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    final updatedCustomer =
        result.getOrElse(() => throw Exception('failed to update customer'));

    state = AsyncData(
      current.copyWith(
        customers: current.customers
            .map((c) => c.id == customerId ? updatedCustomer : c)
            .toList(),
      ),
    );
    return null;
  }

  /// delete a customer by id
  Future<String?> deleteCustomer(int customerId) async {
    final current = state.valueOrNull;
    if (current == null) return 'customers not loaded';

    final result = await _repo.deleteCustomer(customerId);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    state = AsyncData(
      current.copyWith(
        customers: current.customers.where((c) => c.id != customerId).toList(),
      ),
    );
    return null;
  }

  /// fetch single customer by id
  Future<CustomerModel> getCustomer(int customerId) async {
    final result = await _repo.getCustomer(customerId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (customer) => customer,
    );
  }

  /// refresh customers list
  Future<void> refreshCustomers() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }
}
