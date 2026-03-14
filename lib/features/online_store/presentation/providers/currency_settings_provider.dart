import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/online_store/data/datasources/currency_settings_remote_datasource.dart';
import 'package:onepos_admin_app/features/online_store/data/models/company_currency_setting_model.dart';
import 'package:onepos_admin_app/features/online_store/data/models/currency_model.dart';

class CurrencySettingsState {
  final CompanyCurrencySettingModel companyCurrency;
  final List<CurrencyModel> currencies;

  const CurrencySettingsState({
    required this.companyCurrency,
    required this.currencies,
  });

  CurrencySettingsState copyWith({
    CompanyCurrencySettingModel? companyCurrency,
    List<CurrencyModel>? currencies,
  }) {
    return CurrencySettingsState(
      companyCurrency: companyCurrency ?? this.companyCurrency,
      currencies: currencies ?? this.currencies,
    );
  }
}

class CurrencySettingsNotifier extends AsyncNotifier<CurrencySettingsState> {
  CurrencySettingsRemoteDatasource get _datasource =>
      CurrencySettingsRemoteDatasourceImpl(DioClient());

  @override
  Future<CurrencySettingsState> build() async {
    final companyCurrency = await _datasource.getCompanyCurrency();
    final currencies = await _datasource.getAllCurrencies();
    return CurrencySettingsState(
      companyCurrency: companyCurrency,
      currencies: currencies,
    );
  }

  Future<void> refreshSettings() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final companyCurrency = await _datasource.getCompanyCurrency();
      final currencies = await _datasource.getAllCurrencies();
      return CurrencySettingsState(
        companyCurrency: companyCurrency,
        currencies: currencies,
      );
    });
  }

  Future<String?> updateCurrency({required String currencyId}) async {
    final current = state.valueOrNull;
    if (current == null) return 'currency settings not loaded';

    try {
      await _datasource.updateCompanyCurrency(
        settingId: current.companyCurrency.id,
        currencyId: currencyId,
      );
      final refreshedCompanyCurrency = await _datasource.getCompanyCurrency();
      state = AsyncData(
        current.copyWith(companyCurrency: refreshedCompanyCurrency),
      );
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }
}

final currencySettingsProvider =
    AsyncNotifierProvider<CurrencySettingsNotifier, CurrencySettingsState>(
      CurrencySettingsNotifier.new,
    );
