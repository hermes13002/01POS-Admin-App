import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';

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
}
