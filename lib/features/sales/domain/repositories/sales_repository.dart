import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../reports/data/models/reports_model.dart';
import '../../../reports/data/models/top_selling_model.dart';
import '../../data/models/sale_model.dart';

abstract class SalesRepository {
  /// fetches sales list for a page
  Future<Either<Failure, PaginatedSalesResponse>> getSales({int page = 1});

  /// activate sales download
  Future<Either<Failure, void>> activateDownload(int companyId);

  /// deactivate sales download
  Future<Either<Failure, void>> deactivateDownload(int companyId);

  /// download sales data for a date range
  Future<Either<Failure, List<SaleModel>>> downloadSales({
    required String from,
    required String to,
  });

  /// fetch top selling products for dashboard
  Future<Either<Failure, List<TopSellingProduct>>> getAllSalesDashboard();

  /// fetch sales summary for dashboard
  Future<Either<Failure, List<MonthlySalesData>>> getSalesSummaryDashboard({
    String dateFilter = '12months',
  });

  /// fetch sales overview for dashboard
  Future<Either<Failure, SalesOverviewData>> getSalesOverviewDashboard();

  /// fetch stock level for dashboard
  Future<Either<Failure, List<StockLevelData>>> getStockLevelDashboard({
    String dateFilter = '12months',
  });

  /// fetch expense statistics for dashboard
  Future<Either<Failure, ExpenseStatisticsData>> getExpenseStatistics();

  /// fetch performance stats
  Future<Either<Failure, PerformanceStats>> getPerformanceStats();
}
