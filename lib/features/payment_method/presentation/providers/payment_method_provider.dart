import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/payment_method/data/datasources/payment_method_remote_datasource.dart';
import 'package:onepos_admin_app/features/payment_method/data/models/payment_method_model.dart';
import 'package:onepos_admin_app/features/payment_method/data/repositories/payment_method_repository_impl.dart';

class PaymentMethodsNotifier extends AsyncNotifier<PaymentMethodsState> {
  PaymentMethodRepositoryImpl get _repo =>
      PaymentMethodRepositoryImpl(PaymentMethodRemoteDatasourceImpl(DioClient()));

  @override
  Future<PaymentMethodsState> build() async {
    return _fetchMethods();
  }

  Future<PaymentMethodsState> _fetchMethods() async {
    final result = await _repo.getPaymentMethods();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (methods) => PaymentMethodsState(methods: methods),
    );
  }

  Future<void> refreshPaymentMethods() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchMethods);
  }

  Future<String?> addPaymentMethod(Map<String, dynamic> body) async {
    final result = await _repo.createPaymentMethod(body);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    final created =
        result.getOrElse(() => throw Exception('failed to create payment method'));
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(methods: [created, ...current.methods]));
    }
    return null;
  }

  Future<String?> updatePaymentMethod(int methodId, Map<String, dynamic> body) async {
    final current = state.valueOrNull;
    if (current == null) return 'payment methods not loaded';

    final result = await _repo.updatePaymentMethod(methodId, body);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    final updated =
        result.getOrElse(() => throw Exception('failed to update payment method'));
    state = AsyncData(
      current.copyWith(
        methods: current.methods
            .map((item) => item.id == methodId ? updated : item)
            .toList(),
      ),
    );
    return null;
  }

  Future<String?> deletePaymentMethod(int methodId) async {
    final current = state.valueOrNull;
    if (current == null) return 'payment methods not loaded';

    final result = await _repo.deletePaymentMethod(methodId);
    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    state = AsyncData(
      current.copyWith(
        methods: current.methods.where((item) => item.id != methodId).toList(),
      ),
    );
    return null;
  }

  Future<PaymentMethodModel> getPaymentMethod(int methodId) async {
    final result = await _repo.getPaymentMethod(methodId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (method) => method,
    );
  }
}

final paymentMethodsProvider =
    AsyncNotifierProvider<PaymentMethodsNotifier, PaymentMethodsState>(
      PaymentMethodsNotifier.new,
    );
