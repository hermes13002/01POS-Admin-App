import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/broadcasts/data/models/broadcast_model.dart';

abstract class BroadcastRepository {
  Future<Either<Failure, void>> sendBroadcast(Map<String, dynamic> body);
  Future<Either<Failure, List<BroadcastModel>>> getBroadcastHistory();
}
