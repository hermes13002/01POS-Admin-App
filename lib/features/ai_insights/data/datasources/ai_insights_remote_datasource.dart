import 'package:onepos_admin_app/core/network/dio_client.dart';

abstract class AiInsightsRemoteDatasource {
  Future<List<dynamic>> getRealTimePrompt(String prompt);
  Future<List<dynamic>> getHistoricalInsights();
}

class AiInsightsRemoteDatasourceImpl implements AiInsightsRemoteDatasource {
  final DioClient _client;

  AiInsightsRemoteDatasourceImpl(this._client);

  @override
  Future<List<dynamic>> getRealTimePrompt(String prompt) async {
    // REAL API CALL
    final response = await _client.get('/admin/prompt');
    return response.data['data'] as List<dynamic>? ?? [];

    /* MOCK DELAY AND RESPONSE
    await Future.delayed(const Duration(seconds: 2));
    return [
      {
        "type": "danger",
        "title": "Critical annual sales anomaly",
        "detail":
            "Last year's total sales are recorded as an extremely large negative amount, ₦-7,537,986,697.19, which is a critical data error requiring immediate investigation.",
      },
      {
        "type": "warning",
        "title": "Unresolved pending orders",
        "detail":
            "Four out of five recent sales, with a combined total price of ₦1400, are currently in a PENDING status with 'No Payment Method,' indicating a potential issue with payment processing or order fulfillment.",
      },
    ];
    */
  }

  @override
  Future<List<dynamic>> getHistoricalInsights() async {
    // REAL API CALL
    final response = await _client.get('/admin/ai-suggestions');
    return response.data['ai_insights'] as List<dynamic>? ?? [];

    /* MOCK DELAY AND RESPONSE
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        "type": "danger",
        "title": "No recent sales activity",
        "detail":
            "The store has reported ₦0.00 in total sales for today, yesterday, this week, and this month, along with 0 transactions over the past 23 days, indicating a severe operational halt or reporting issue.",
      },
      {
        "type": "warning",
        "title": "Erratic stock level reporting",
        "detail":
            "The 30-day stock level graph displays highly erratic data, with periods of zero stock and then large, inconsistent numbers like 759,911,885 units, suggesting significant data integrity issues with inventory tracking.",
      },
    ];
    */
  }
}
