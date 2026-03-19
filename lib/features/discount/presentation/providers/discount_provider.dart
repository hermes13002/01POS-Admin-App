import 'package:onepos_admin_app/features/discount/data/models/discount_model.dart';
import 'package:onepos_admin_app/features/discount/data/repositories/discount_repository.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discount_provider.g.dart';

@riverpod
class Discounts extends _$Discounts {
  DiscountRepository get _repository => DiscountRepository();

  @override
  Future<List<DiscountModel>> build() async {
    final profile = await ref.watch(userProfileProvider.future);
    final companyId = profile.company?.id;
    if (companyId == null) return [];

    return _repository.getDiscounts(companyId);
  }

  Future<void> createDiscount(Map<String, dynamic> data) async {
    final profile = await ref.read(userProfileProvider.future);
    final companyId = profile.company?.id;
    if (companyId == null) throw Exception('Company ID not found');

    final fullData = {...data, 'company_id': companyId};

    await _repository.createDiscount(fullData);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateDiscount(int id, Map<String, dynamic> data) async {
    final profile = await ref.read(userProfileProvider.future);
    final companyId = profile.company?.id;
    if (companyId == null) throw Exception('Company ID not found');

    final fullData = {...data, 'company_id': companyId};

    await _repository.updateDiscount(id, fullData);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteDiscount(int id) async {
    await _repository.deleteDiscount(id);
    ref.invalidateSelf();
    await future;
  }
}
