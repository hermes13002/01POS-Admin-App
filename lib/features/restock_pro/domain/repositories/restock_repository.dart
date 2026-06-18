import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../../data/models/restock_suggestion_model.dart';

// restock repository interface
abstract class RestockRepository {
  // fetch restock suggestions
  Future<ApiResponse<List<RestockSuggestionModel>>> fetchRestockSuggestions({int page = 1});
}
