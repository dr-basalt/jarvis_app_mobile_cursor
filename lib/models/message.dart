import 'package:flutter/foundation.dart';

enum MessageType { user, assistant }

class Message {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isTyping;

  Message({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isTyping = false,
  });

  Message copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isTyping,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isTyping': isTyping,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isTyping: json['isTyping'] ?? false,
    );
  }
}
