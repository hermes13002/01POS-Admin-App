import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';

class ProductRemoteDatasource {
  final DioClient _dioClient;

  ProductRemoteDatasource({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// fetch products with pagination
  Future<Response> fetchProducts(int page) async {
    final url = '/admin/products?page=$page';
    try {
      log('fetch_products url: $url', name: 'API');
      log('fetch_products body: {}', name: 'API');

      final response = await _dioClient.post(url);

      log('fetch_products response: ${jsonEncode(response.data)}', name: 'API');
      return response;
    } catch (e) {
      log(
        'fetch_products response: {"error": true, "message": "$e"}',
        name: 'API',
      );
      rethrow;
    }
  }

  /// fetch single product details
  Future<Response> fetchSingleProduct(int id) async {
    final url = '/admin/products/show/$id';
    try {
      log('fetch_single_product url: $url', name: 'API');
      log('fetch_single_product body: {}', name: 'API');

      final response = await _dioClient.get(url);

      log(
        'fetch_single_product response: ${jsonEncode(response.data)}',
        name: 'API',
      );
      return response;
    } catch (e) {
      log(
        'fetch_single_product response: {"error": true, "message": "$e"}',
        name: 'API',
      );
      rethrow;
    }
  }

  /// delete product
  Future<Response> deleteProduct(int id) async {
    final url = '/admin/products/delete/$id';
    try {
      log('delete_product url: $url', name: 'API');
      log('delete_product body: {}', name: 'API');

      final response = await _dioClient.delete(url);

      log('delete_product response: ${jsonEncode(response.data)}', name: 'API');
      return response;
    } catch (e) {
      log(
        'delete_product response: {"error": true, "message": "$e"}',
        name: 'API',
      );
      rethrow;
    }
  }

  /// update product details
  Future<Response> updateProduct(int id, Map<String, dynamic> data) async {
    final url = '/admin/products/update/$id';
    try {
      log('update_product url: $url', name: 'API');
      log('update_product body: ${jsonEncode(data)}', name: 'API');

      final response = await _dioClient.put(url, data: data);

      log('update_product response: ${jsonEncode(response.data)}', name: 'API');
      return response;
    } catch (e) {
      log(
        'update_product response: {"error": true, "message": "$e"}',
        name: 'API',
      );
      rethrow;
    }
  }
}
