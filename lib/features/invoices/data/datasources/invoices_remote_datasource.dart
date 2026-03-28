import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';

class InvoicesRemoteDatasource {
  final DioClient _dioClient;

  InvoicesRemoteDatasource({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// fetch all invoices
  Future<Response> fetchInvoices() async {
    const url = '/admin/invoices';
    try {
      log('fetch_invoices url: $url', name: 'API');
      final response = await _dioClient.get(url);
      log('fetch_invoices response: ${jsonEncode(response.data)}', name: 'API');
      return response;
    } catch (e) {
      log('fetch_invoices error: $e', name: 'API');
      rethrow;
    }
  }

  /// create new invoice
  Future<Response> createInvoice(Map<String, dynamic> data) async {
    const url = '/admin/invoices/store';
    try {
      log('create_invoice url: $url', name: 'API');
      log('create_invoice body: ${jsonEncode(data)}', name: 'API');

      final response = await _dioClient.post(url, data: data);

      log('create_invoice response: ${jsonEncode(response.data)}', name: 'API');
      return response;
    } catch (e) {
      log('create_invoice error: $e', name: 'API');
      rethrow;
    }
  }
}
