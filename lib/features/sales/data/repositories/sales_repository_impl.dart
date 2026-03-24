import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';
import 'package:onepos_admin_app/features/sales/domain/repositories/sales_repository.dart';
import 'package:onepos_admin_app/features/reports/data/models/reports_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDatasource _datasource;

  SalesRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PaginatedSalesResponse>> getSales({
    int page = 1,
  }) async {
    return _handleException(() => _datasource.getSales(page: page));
  }

  @override
  Future<Either<Failure, void>> activateDownload(int companyId) async {
    return _handleException(() => _datasource.activateDownload(companyId));
  }

  @override
  Future<Either<Failure, void>> deactivateDownload(int companyId) async {
    return _handleException(() => _datasource.deactivateDownload(companyId));
  }

  @override
  Future<Either<Failure, List<SaleModel>>> downloadSales({
    required String from,
    required String to,
  }) async {
    return _handleException(
      () => _datasource.downloadSales(from: from, to: to),
    );
  }

  @override
  Future<Either<Failure, List<MonthlySalesData>>> getSalesSummaryDashboard({
    String dateFilter = '12months',
  }) async {
    return _handleException(
      () => _datasource.getSalesSummaryDashboard(dateFilter: dateFilter),
    );
  }

  @override
  Future<Either<Failure, List<SaleModel>>> getAllSalesDashboard() async {
    return _handleException(() => _datasource.getAllSalesDashboard());
  }

  @override
  Future<Either<Failure, SalesOverviewData>> getSalesOverviewDashboard() async {
    return _handleException(() => _datasource.getSalesOverviewDashboard());
  }

  @override
  Future<Either<Failure, List<StockLevelData>>> getStockLevelDashboard({
    String dateFilter = '12months',
  }) async {
    return _handleException(
      () => _datasource.getStockLevelDashboard(dateFilter: dateFilter),
    );
  }

  @override
  Future<Either<Failure, ExpenseStatisticsData>> getExpenseStatistics() async {
    return _handleException(() => _datasource.getExpenseStatistics());
  }

  Future<Either<Failure, T>> _handleException<T>(
    Future<T> Function() action,
  ) async {
    try {
      final result = await action();
      return Right(result);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
