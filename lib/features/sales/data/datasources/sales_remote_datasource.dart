import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';
import 'package:onepos_admin_app/features/reports/data/models/reports_model.dart';
import 'package:onepos_admin_app/features/reports/data/models/top_selling_model.dart';

abstract class SalesRemoteDatasource {
  /// fetches sales list for a page
  Future<PaginatedSalesResponse> getSales({int page = 1});

  /// activate sales download
  Future<void> activateDownload(int companyId);

  /// deactivate sales download
  Future<void> deactivateDownload(int companyId);

  /// download sales data for a date range
  Future<List<SaleModel>> downloadSales({
    required String from,
    required String to,
  });

  /// fetch top selling products for dashboard
  Future<List<TopSellingProduct>> getAllSalesDashboard();

  /// fetch sales summary for dashboard
  Future<List<MonthlySalesData>> getSalesSummaryDashboard({
    String dateFilter = '12months',
  });

  /// fetch sales overview for dashboard
  Future<SalesOverviewData> getSalesOverviewDashboard();

  /// fetch stock level for dashboard
  Future<List<StockLevelData>> getStockLevelDashboard({
    String dateFilter = '12months',
  });

  /// fetch expense statistics for dashboard
  Future<ExpenseStatisticsData> getExpenseStatistics();

  /// fetch performance stats for dashboard
  Future<PerformanceStats> getPerformanceStats();
}

class SalesRemoteDatasourceImpl implements SalesRemoteDatasource {
  final DioClient _client;

  SalesRemoteDatasourceImpl(this._client);

  @override
  Future<PaginatedSalesResponse> getSales({int page = 1}) async {
    final response = await _client.post(
      ApiEndpoints.allSales,
      data: {'page': page},
    );
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch sales',
      );
    }

    final data = responseBody['data'];
    if (data is Map<String, dynamic>) {
      return PaginatedSalesResponse.fromJson(data);
    }

    throw ServerException(message: 'invalid sales response');
  }

  @override
  Future<void> activateDownload(int companyId) async {
    final response = await _client.get(
      '${ApiEndpoints.activateSalesDownload}$companyId',
    );
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to activate download',
      );
    }
  }

  @override
  Future<void> deactivateDownload(int companyId) async {
    final response = await _client.get(
      '${ApiEndpoints.deactivateSalesDownload}$companyId',
    );
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to deactivate download',
      );
    }
  }

  @override
  Future<List<SaleModel>> downloadSales({
    required String from,
    required String to,
  }) async {
    final response = await _client.post(
      ApiEndpoints.downloadSales,
      data: {'from_date': from, 'to_date': to},
    );
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to download sales',
      );
    }

    final data = responseBody['data'];
    if (data is List) {
      return data.map((item) => SaleModel.fromJson(_asMap(item))).toList();
    }

    return [];
  }

  @override
  Future<List<TopSellingProduct>> getAllSalesDashboard() async {
    final response = await _client.get(ApiEndpoints.topSelling);
    final responseBody = _asMap(response.data);

    // The API erroneously returns error: true even on success
    // there is a bug in the API that says
    final message = responseBody['message']?.toString() ?? '';
    final isSuccessMessage = message.contains('found successfully');

    if (_isError(responseBody['error']) && !isSuccessMessage) {
      throw ServerException(
        message:
            responseBody['message'] ?? 'failed to fetch top selling products',
      );
    }

    final data = responseBody['data'];
    if (data is Map<String, dynamic>) {
      final products = data['products'];
      if (products is List) {
        return products
            .map((item) => TopSellingProduct.fromJson(_asMap(item)))
            .toList();
      }
    }

    return [];
  }

  @override
  Future<List<MonthlySalesData>> getSalesSummaryDashboard({
    String dateFilter = '12months',
  }) async {
    final body = {'date_filter': dateFilter};
    final response = await _client.post(
      ApiEndpoints.salesSummaryDashboard,
      data: body,
    );
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch sales summary',
      );
    }

    final data = responseBody['data'];
    if (data is Map<String, dynamic>) {
      return MonthlySalesData.fromDashboardJson(data);
    }

    return [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  bool _isError(dynamic error) {
    return error == true || error?.toString().toLowerCase() == 'true';
  }

  @override
  Future<SalesOverviewData> getSalesOverviewDashboard() async {
    final response = await _client.get(ApiEndpoints.adminDashboard);
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch sales overview',
      );
    }

    final data = responseBody['data'];
    if (data is Map<String, dynamic>) {
      return SalesOverviewData.fromJson(data);
    }

    throw ServerException(message: 'invalid sales overview response');
  }

  @override
  Future<List<StockLevelData>> getStockLevelDashboard({
    String dateFilter = '12months',
  }) async {
    final body = {'date_filter': dateFilter};
    final response = await _client.post(
      ApiEndpoints.adminStockLevelDashboard,
      data: body,
    );
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch stock level',
      );
    }

    final data = responseBody['data'];
    if (data is Map<String, dynamic>) {
      return StockLevelData.fromDashboardJson(data);
    }

    return [];
  }

  @override
  Future<ExpenseStatisticsData> getExpenseStatistics() async {
    final response = await _client.get(ApiEndpoints.expenseStatisticsDashboard);
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message:
            responseBody['message'] ?? 'failed to fetch expense statistics',
      );
    }

    final data = responseBody['data'];
    if (data is Map<String, dynamic>) {
      return ExpenseStatisticsData.fromJson(data);
    }

    throw ServerException(message: 'invalid expense statistics response');
  }

  @override
  Future<PerformanceStats> getPerformanceStats() async {
    final response = await _client.get(ApiEndpoints.performanceStats);
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch performance stats',
      );
    }

    final data = responseBody['data'];
    if (data is Map<String, dynamic>) {
      return PerformanceStats.fromJson(data);
    }

    throw ServerException(message: 'invalid performance stats response');
  }
}
