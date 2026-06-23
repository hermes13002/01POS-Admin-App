class AiInsight {
  final String type;
  final String title;
  final String detail;

  const AiInsight({
    required this.type,
    required this.title,
    required this.detail,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      type: json['type']?.toString() ?? 'info',
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'detail': detail,
    };
  }
}
