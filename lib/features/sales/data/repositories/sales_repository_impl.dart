import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';
import 'package:onepos_admin_app/features/sales/domain/repositories/sales_repository.dart';

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
