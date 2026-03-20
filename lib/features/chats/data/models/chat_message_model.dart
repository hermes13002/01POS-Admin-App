/// model for a single chat message
class ChatMessage {
  final int id;
  final String message;
  final String role; // 'sender' or 'receiver'
  final bool isRead;
  final String? fileAttachment;
  final String createdAt;

  const ChatMessage({
    required this.id,
    required this.message,
    required this.role,
    required this.isRead,
    this.fileAttachment,
    required this.createdAt,
  });

  /// checks if the message was sent by the current user (admin)
  bool get isMe => role.toLowerCase() == 'sender';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      message: json['message']?.toString() ?? '',
      role: json['role']?.toString() ?? 'receiver',
      isRead:
          json['is_read'] == '1' ||
          json['is_read'] == 1 ||
          json['is_read'] == true,
      fileAttachment: json['file_attachment']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'role': role,
      'is_read': isRead ? "1" : "0",
      'file_attachment': fileAttachment,
      'created_at': createdAt,
    };
  }
}

/// response model for sending a message
class SendMessageResponse {
  final int id;
  final int companyId;
  final int senderId;
  final String receiverId;
  final String message;
  final String? fileAttachment;
  final String createdAt;
  final String updatedAt;

  const SendMessageResponse({
    required this.id,
    required this.companyId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.fileAttachment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      companyId: json['company_id'] is int
          ? json['company_id']
          : int.tryParse(json['company_id'].toString()) ?? 0,
      senderId: json['sender_id'] is int
          ? json['sender_id']
          : int.tryParse(json['sender_id'].toString()) ?? 0,
      receiverId: json['receiver_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      fileAttachment: json['file_attachment']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
