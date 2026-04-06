import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/online_store/data/datasources/receipt_template_remote_datasource.dart';
import 'package:onepos_admin_app/features/online_store/data/models/receipt_template_model.dart';

class ReceiptTemplateNotifier extends AsyncNotifier<ReceiptTemplateModel> {
  ReceiptTemplateRemoteDatasource get _datasource =>
      ReceiptTemplateRemoteDatasourceImpl(DioClient());

  @override
  Future<ReceiptTemplateModel> build() async {
    return _datasource.getReceiptTemplate();
  }

  Future<void> refreshTemplate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _datasource.getReceiptTemplate());
  }

  Future<String?> updateTemplate({
    required int numberOfPages,
    String? headerLineOne,
    String? headerLineTwo,
    String? headerLineThree,
    String? footerLineOne,
    String? footerLineTwo,
    String? footerLineThree,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return 'receipt template not loaded';

    final body = {
      'header_line_one': headerLineOne ?? current.headerLineOne,
      'header_line_two': headerLineTwo ?? current.headerLineTwo,
      'header_line_three': headerLineThree ?? current.headerLineThree,
      'footer_line_one': footerLineOne ?? current.footerLineOne,
      'footer_line_two': footerLineTwo ?? current.footerLineTwo,
      'footer_line_three': footerLineThree ?? current.footerLineThree,
      'number_of_pages': numberOfPages,
    };

    try {
      final updated = await _datasource.updateReceiptTemplate(current.id, body);
      state = AsyncData(updated);
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }
}

final receiptTemplateProvider =
    AsyncNotifierProvider<ReceiptTemplateNotifier, ReceiptTemplateModel>(
      ReceiptTemplateNotifier.new,
    );
