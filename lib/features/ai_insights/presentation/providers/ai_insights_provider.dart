import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/ai_insights/data/datasources/ai_insights_remote_datasource.dart';
import 'package:onepos_admin_app/features/ai_insights/data/repositories/ai_insights_repository.dart';
import 'package:onepos_admin_app/features/ai_insights/data/models/ai_insight_model.dart';

part 'ai_insights_provider.g.dart';

@riverpod
AiInsightsRepository aiInsightsRepository(AiInsightsRepositoryRef ref) {
  return AiInsightsRepositoryImpl(AiInsightsRemoteDatasourceImpl(DioClient()));
}

@riverpod
Future<List<AiInsight>> historicalInsights(HistoricalInsightsRef ref) async {
  final repository = ref.watch(aiInsightsRepositoryProvider);
  return repository.getHistoricalInsights();
}
