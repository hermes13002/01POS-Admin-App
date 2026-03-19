import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/discount/data/models/discount_model.dart';

class DiscountRepository {
  final DioClient _dioClient;

  DiscountRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// fetch all discounts for a company
  Future<List<DiscountModel>> getDiscounts(int companyId) async {
    try {
      final response = await _dioClient.get('/discounts/$companyId');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DiscountModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// create a new discount
  Future<DiscountModel> createDiscount(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/discounts', data: data);
      return DiscountModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// update an existing discount
  Future<DiscountModel> updateDiscount(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dioClient.put('/discounts/$id', data: data);
      return DiscountModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// delete a discount
  Future<void> deleteDiscount(int id) async {
    try {
      await _dioClient.delete('/discounts/$id');
    } catch (e) {
      rethrow;
    }
  }
}
