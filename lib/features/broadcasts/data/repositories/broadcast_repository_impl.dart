import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/broadcasts/data/datasources/broadcast_remote_datasource.dart';
import 'package:onepos_admin_app/features/broadcasts/data/models/broadcast_model.dart';
import 'package:onepos_admin_app/features/broadcasts/domain/repositories/broadcast_repository.dart';

class BroadcastRepositoryImpl implements BroadcastRepository {
  final BroadcastRemoteDatasource _remoteDatasource;

  BroadcastRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, void>> sendBroadcast(Map<String, dynamic> body) async {
    try {
      await _remoteDatasource.sendBroadcast(body);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BroadcastModel>>> getBroadcastHistory() async {
    try {
      final history = await _remoteDatasource.getBroadcastHistory();
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
