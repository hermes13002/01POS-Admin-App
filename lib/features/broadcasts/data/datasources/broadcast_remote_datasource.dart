import 'dart:convert';
import 'dart:developer';

import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/broadcasts/data/models/broadcast_model.dart';

abstract class BroadcastRemoteDatasource {
  Future<void> sendBroadcast(Map<String, dynamic> body);
  Future<List<BroadcastModel>> getBroadcastHistory();
}

class BroadcastRemoteDatasourceImpl implements BroadcastRemoteDatasource {
  final DioClient _client;

  BroadcastRemoteDatasourceImpl(this._client);

  @override
  Future<void> sendBroadcast(Map<String, dynamic> body) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.storeBroadcast}';

    log('send_broadcast url: $url', name: 'API');
    log('send_broadcast body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(
      ApiEndpoints.storeBroadcast,
      data: body,
    );
    final responseBody = response.data as Map<String, dynamic>;

    log('send_broadcast response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to send broadcast',
      );
    }
  }

  @override
  Future<List<BroadcastModel>> getBroadcastHistory() async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.broadcastHistory}';

    log('get_broadcast_history url: $url', name: 'API');

    final response = await _client.get(ApiEndpoints.broadcastHistory);
    final responseBody = response.data as Map<String, dynamic>;

    log(
      'get_broadcast_history response: ${jsonEncode(responseBody)}',
      name: 'API',
    );

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to fetch broadcast history',
      );
    }

    final List<dynamic> data = responseBody['data'] ?? [];
    return data
        .map((json) => BroadcastModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
