import 'package:onepos_admin_app/core/network/dio_client.dart';
import '../models/chat_contact_model.dart';
import '../models/chat_message_model.dart';

/// remote data source for chat features
class ChatRemoteSource {
  final DioClient _dioClient;

  const ChatRemoteSource(this._dioClient);

  /// fetch conversation history for a specific receiver
  Future<List<ChatMessage>> getMessages(int receiverId) async {
    try {
      final response = await _dioClient.get('/admin/chats/get/$receiverId');

      if (response.data != null && response.data['data'] is List) {
        final list = response.data['data'] as List;
        return list
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// send a message to a specific receiver
  Future<SendMessageResponse> sendMessage(
    int receiverId,
    String message,
  ) async {
    try {
      final response = await _dioClient.post(
        '/admin/chats/send',
        data: {'receiver_id': receiverId, 'message': message},
      );

      if (response.data != null && response.data['data'] != null) {
        return SendMessageResponse.fromJson(response.data['data']);
      }

      throw Exception('Failed to send message: ${response.data?['message']}');
    } catch (e) {
      rethrow;
    }
  }

  /// mark a specific message as read
  Future<void> markAsRead(int messageId) async {
    try {
      await _dioClient.get('/admin/chats/read/$messageId');
    } catch (e) {
      rethrow;
    }
  }

  /// delete a specific message
  Future<void> deleteMessage(int messageId) async {
    try {
      await _dioClient.delete('/admin/chats/delete/$messageId');
    } catch (e) {
      rethrow;
    }
  }

  /// fetch available chat contacts
  Future<List<ChatContact>> fetchContacts() async {
    try {
      final response = await _dioClient.get('/admin/chats/contacts');

      if (response.data != null && response.data['data'] is List) {
        final list = response.data['data'] as List;
        return list
            .map((json) => ChatContact.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
