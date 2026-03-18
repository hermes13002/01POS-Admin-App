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

  /// add new product
  Future<Response> addProduct(FormData data) async {
    const url = '/admin/products/store';
    try {
      log('add_product url: $url', name: 'API');
      // log form data keys
      log('add_product body: ${data.fields}', name: 'API');

      final response = await _dioClient.post(url, data: data);

      log('add_product response: ${jsonEncode(response.data)}', name: 'API');
      return response;
    } catch (e) {
      log(
        'add_product response: {"error": true, "message": "$e"}',
        name: 'API',
      );
      rethrow;
    }
  }

  /// set low stock limit
  Future<Response> setLowStockLimit(int companyId, int limit) async {
    final url = '/admin/products/low-stock-limit/$companyId';
    try {
      log('set_low_stock_limit url: $url', name: 'API');
      final data = {'low_stock_limit': limit.toString()};
      log('set_low_stock_limit body: $data', name: 'API');

      final response = await _dioClient.put(url, data: data);

      log(
        'set_low_stock_limit response: ${jsonEncode(response.data)}',
        name: 'API',
      );
      return response;
    } catch (e) {
      log(
        'set_low_stock_limit response: {"error": true, "message": "$e"}',
        name: 'API',
      );
      rethrow;
    }
  }

  /// fetch low stock products
  Future<Response> fetchLowStockProducts({int page = 1}) async {
    final url = '/admin/products/low_stock?page=$page';
    try {
      log('fetch_low_stock_products url: $url', name: 'API');

      final response = await _dioClient.post(url);

      log(
        'fetch_low_stock_products response: ${jsonEncode(response.data)}',
        name: 'API',
      );
      return response;
    } catch (e) {
      log(
        'fetch_low_stock_products response: {"error": true, "message": "$e"}',
        name: 'API',
      );
      rethrow;
    }
  }
}
