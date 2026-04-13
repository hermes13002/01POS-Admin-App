import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/industry_model.dart';
import 'auth_provider.dart';

part 'industry_provider.g.dart';

@riverpod
Future<List<IndustryModel>> industries(IndustriesRef ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final result = await repo.getIndustries();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
}
