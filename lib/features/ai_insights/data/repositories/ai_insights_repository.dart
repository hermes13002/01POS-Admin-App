import 'package:onepos_admin_app/features/ai_insights/data/datasources/ai_insights_remote_datasource.dart';
import 'package:onepos_admin_app/features/ai_insights/data/models/ai_insight_model.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';

abstract class AiInsightsRepository {
  Future<List<AiInsight>> getRealTimePrompt(String prompt);
  Future<List<AiInsight>> getHistoricalInsights();
}

class AiInsightsRepositoryImpl implements AiInsightsRepository {
  final AiInsightsRemoteDatasource _remoteDatasource;

  AiInsightsRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<AiInsight>> getRealTimePrompt(String prompt) async {
    final data = await _remoteDatasource.getRealTimePrompt(prompt);
    return data
        .map((json) => AiInsight.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AiInsight>> getHistoricalInsights() async {
    try {
      final data = await _remoteDatasource.getHistoricalInsights();
      return data
          .map((json) => AiInsight.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return []; // Return empty list if no record exists
      }
      rethrow;
    }
  }
}
