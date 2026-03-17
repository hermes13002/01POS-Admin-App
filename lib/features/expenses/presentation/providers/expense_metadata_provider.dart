import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/expense_metadata_model.dart';
import 'expenses_provider.dart';

part 'expense_metadata_provider.g.dart';

@riverpod
class ExpenseMetadata extends _$ExpenseMetadata {
  @override
  FutureOr<ExpenseMetadataModel> build() async {
    final repo = ref.watch(expenseRepositoryProvider);
    final result = await repo.fetchMetadata();

    return result.fold(
      (l) => throw l,
      (r) => r.data ?? ExpenseMetadataModel(categories: [], types: []),
    );
  }
}
