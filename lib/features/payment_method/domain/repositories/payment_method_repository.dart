import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/payment_method/data/models/payment_method_model.dart';

abstract class PaymentMethodRepository {
  Future<Either<Failure, List<PaymentMethodModel>>> getPaymentMethods();
  Future<Either<Failure, PaymentMethodModel>> getPaymentMethod(int methodId);
  Future<Either<Failure, PaymentMethodModel>> createPaymentMethod(
    Map<String, dynamic> body,
  );
  Future<Either<Failure, PaymentMethodModel>> updatePaymentMethod(
    int methodId,
    Map<String, dynamic> body,
  );
  Future<Either<Failure, void>> deletePaymentMethod(int methodId);
}
