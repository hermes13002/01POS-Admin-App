import 'package:dio/dio.dart';
import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';

class AutoBillRemoteDataSource {
  final DioClient _dioClient;

  AutoBillRemoteDataSource({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// fetch auto bills with pagination
  Future<Response> fetchAutoBills({int page = 1}) async {
    return await _dioClient.post('${ApiEndpoints.autoBills}?page=$page');
  }

  /// fetch bill options
  Future<Response> fetchBillOptions() async {
    return await _dioClient.get(ApiEndpoints.billOptions);
  }

  /// add new auto bill
  Future<Response> addAutoBill(Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);
    return await _dioClient.post(ApiEndpoints.storeAutoBill, data: formData);
  }

  /// update auto bill
  Future<Response> updateAutoBill(int id, Map<String, dynamic> data) async {
    return await _dioClient.put(
      '${ApiEndpoints.updateAutoBill}$id',
      data: data,
    );
  }

  /// delete auto bill
  Future<Response> deleteAutoBill(int id) async {
    return await _dioClient.delete('${ApiEndpoints.deleteAutoBill}$id');
  }

  /// fetch single auto bill
  Future<Response> fetchAutoBill(int id) async {
    return await _dioClient.get('${ApiEndpoints.showAutoBill}$id');
  }

  /// activate auto bill
  Future<Response> activateAutoBill(int id) async {
    return await _dioClient.put('${ApiEndpoints.activateAutoBill}$id');
  }

  /// deactivate auto bill
  Future<Response> deactivateAutoBill(int id) async {
    return await _dioClient.put('${ApiEndpoints.deactivateAutoBill}$id');
  }
}
