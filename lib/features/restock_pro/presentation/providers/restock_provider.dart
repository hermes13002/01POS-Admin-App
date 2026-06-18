import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../../data/models/restock_suggestion_model.dart';
import '../../data/repositories/restock_repository_impl.dart';
import '../../domain/repositories/restock_repository.dart';

part 'restock_provider.g.dart';

// restock suggestions provider
@riverpod
class RestockSuggestions extends _$RestockSuggestions {
  RestockRepository get _repository => RestockRepositoryImpl();

  @override
  Future<ApiResponse<List<RestockSuggestionModel>>> build({int page = 1}) async {
    return _repository.fetchRestockSuggestions(page: page);
  }

  // refresh suggestions
  Future<void> refresh(int page) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.fetchRestockSuggestions(page: page));
  }
}
