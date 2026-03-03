import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';

/// Base use case class
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// No params class for use cases that don't require parameters
class NoParams {
  const NoParams();
}
