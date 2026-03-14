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
  Future<Either<Failure, PaginatedSalesResponse>> getSales({int page = 1}) async {
    try {
      final result = await _datasource.getSales(page: page);
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
