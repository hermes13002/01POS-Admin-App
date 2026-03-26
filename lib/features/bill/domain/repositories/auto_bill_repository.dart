import 'package:onepos_admin_app/data/models/api_response_model.dart';
import 'package:onepos_admin_app/features/bill/data/models/auto_bill_model.dart';

abstract class AutoBillRepository {
  /// fetch all auto bills with pagination
  Future<ApiResponse<List<AutoBillModel>>> fetchAutoBills({int page = 1});

  /// fetch single auto bill
  Future<ApiResponse<AutoBillModel>> fetchAutoBill(int id);

  /// fetch bill options
  Future<ApiResponse<List<BillOptionModel>>> fetchBillOptions();

  /// add new auto bill
  Future<ApiResponse<AutoBillModel>> addAutoBill(Map<String, dynamic> data);

  /// update auto bill
  Future<ApiResponse<AutoBillModel>> updateAutoBill(
    int id,
    Map<String, dynamic> data,
  );

  /// delete auto bill
  Future<ApiResponse<void>> deleteAutoBill(int id);

  /// activate auto bill
  Future<ApiResponse<AutoBillModel>> activateAutoBill(int id);

  /// deactivate auto bill
  Future<ApiResponse<AutoBillModel>> deactivateAutoBill(int id);
}
