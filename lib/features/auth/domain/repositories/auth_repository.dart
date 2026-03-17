import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import '../../data/models/login_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseModel>> loginWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, LoginResponseModel>> loginWithPin(String pin);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> resetPassword(String email);
}
