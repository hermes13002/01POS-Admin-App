import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/customers/data/models/customer_model.dart';

abstract class CustomersRepository {
  Future<Either<Failure, PaginatedCustomersResponse>> getCustomers({int page = 1});
  Future<Either<Failure, CustomerModel>> getCustomer(int customerId);
  Future<Either<Failure, CustomerModel>> createCustomer(Map<String, dynamic> body);
  Future<Either<Failure, CustomerModel>> updateCustomer(
    int customerId,
    Map<String, dynamic> body,
  );
  Future<Either<Failure, void>> deleteCustomer(int customerId);
}
