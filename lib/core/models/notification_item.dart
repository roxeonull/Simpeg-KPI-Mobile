import 'dart:convert';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // 'cuti', 'absensi', 'perubahan_data', 'pelatihan', 'pengumuman', 'sistem'
  final Map<String, dynamic>? payload;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload != null ? jsonEncode(payload) : null,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedPayload;
    if (json['payload'] != null) {
      if (json['payload'] is Map) {
        parsedPayload = Map<String, dynamic>.from(json['payload']);
      } else if (json['payload'] is String) {
        try {
          parsedPayload = Map<String, dynamic>.from(jsonDecode(json['payload']));
        } catch (_) {}
      }
    }

    return NotificationItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Notifikasi',
      body: json['body'] ?? '',
      type: json['type'] ?? 'sistem',
      payload: parsedPayload,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] == true,
    );
  }
}
