import 'package:intl/intl.dart';

class BroadcastModel {
  final int id;
  final String message;
  final bool htmlMode;
  final List<int>? customerIds;
  final int recipientCount;
  final String status;
  final DateTime createdAt;
  final DateTime? sendAt;
  final String? recurring;

  const BroadcastModel({
    required this.id,
    required this.message,
    required this.htmlMode,
    this.customerIds,
    required this.recipientCount,
    required this.status,
    required this.createdAt,
    this.sendAt,
    this.recurring,
  });

  factory BroadcastModel.fromJson(Map<String, dynamic> json) {
    return BroadcastModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      htmlMode: json['html_mode'] == 1 || json['html_mode'] == true,
      customerIds: (json['customer_ids'] as List?)
          ?.map((e) => int.parse(e.toString()))
          .toList(),
      recipientCount:
          int.tryParse(json['recipient_count']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'sent',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      sendAt: DateTime.tryParse(json['send_at']?.toString() ?? ''),
      recurring: json['recurring']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'html_mode': htmlMode ? 1 : 0,
      'customer_ids': customerIds,
      if (sendAt != null)
        'send_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(sendAt!),
      if (recurring != null) 'recurring': recurring,
    };
  }
}
