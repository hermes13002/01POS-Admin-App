import 'package:onepos_admin_app/features/users/data/models/user_model.dart';

/// model for a chat contact
class ChatContact {
  final int id;
  final int companyId;
  final String firstname;
  final String lastname;
  final String phoneno;
  final String? address;
  final String email;
  final String? gender;
  final String? image;
  final bool canLogin;
  final bool isVerified;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final List<RoleModel> roles;
  final int unreadCount;
  final String? lastMessage;

  const ChatContact({
    required this.id,
    required this.companyId,
    required this.firstname,
    required this.lastname,
    required this.phoneno,
    this.address,
    required this.email,
    this.gender,
    this.image,
    required this.canLogin,
    required this.isVerified,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.roles = const [],
    this.unreadCount = 0,
    this.lastMessage,
  });

  /// full display name
  String get fullName => '$firstname $lastname';

  factory ChatContact.fromJson(Map<String, dynamic> json) {
    final rolesList = json['roles'] as List<dynamic>? ?? [];

    return ChatContact(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      companyId: json['company_id'] is int
          ? json['company_id']
          : int.tryParse(json['company_id'].toString()) ?? 0,
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      phoneno: json['phoneno']?.toString() ?? '',
      address: json['address']?.toString(),
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString(),
      image: json['image']?.toString(),
      canLogin:
          json['can_login'] == true ||
          json['can_login'] == 1 ||
          json['can_login'] == '1',
      isVerified:
          json['is_verified'] == true ||
          json['is_verified'] == 1 ||
          json['is_verified'] == '1',
      isActive:
          json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == '1',
      createdAt: json['created_at']?.toString(),
      updatedAt: _parseUpdatedAt(json),
      roles: rolesList
          .map((r) => RoleModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      unreadCount: _calculateUnreadCount(json),
      lastMessage: _parseLastMessage(json),
    );
  }

  static String? _parseLastMessage(Map<String, dynamic> json) {
    final messages = json['messages'] as List?;
    if (messages != null && messages.isNotEmpty) {
      return messages.last['message']?.toString();
    }
    return null;
  }

  static String? _parseUpdatedAt(Map<String, dynamic> json) {
    final messages = json['messages'] as List?;
    if (messages != null && messages.isNotEmpty) {
      return messages.last['created_at']?.toString();
    }
    return (json['last_message_at'] ??
            json['latest_message_at'] ??
            json['last_message_time'] ??
            json['updated_at'] ??
            json['created_at'])
        ?.toString();
  }

  static int _calculateUnreadCount(Map<String, dynamic> json) {
    final messages = json['messages'];
    if (messages != null && messages is List) {
      int count = 0;
      for (var msg in messages) {
        final isRead =
            msg['is_read'] == '1' ||
            msg['is_read'] == 1 ||
            msg['is_read'] == true;
        final role = msg['role']?.toString().toLowerCase();

        // Count unread messages received from the contact
        if (!isRead && role == 'receiver') {
          count++;
        }
      }
      return count;
    }

    // fallback to flat fields
    return json['unread_count'] is int
        ? json['unread_count']
        : json['unread_chats'] is int
        ? json['unread_chats']
        : json['unread_messages'] is int
        ? json['unread_messages']
        : json['unread'] is int
        ? json['unread']
        : int.tryParse(
                (json['unread_count'] ??
                        json['unread_chats'] ??
                        json['unread_messages'] ??
                        json['unread'] ??
                        '0')
                    .toString(),
              ) ??
              0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'firstname': firstname,
      'lastname': lastname,
      'phoneno': phoneno,
      'address': address,
      'email': email,
      'gender': gender,
      'image': image,
      'can_login': canLogin,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'roles': roles.map((e) => e.toJson()).toList(),
      'unread_count': unreadCount,
      'last_message': lastMessage,
    };
  }
}
