import 'package:hive/hive.dart';

part 'message.g.dart';

enum MessageType { user, assistant, system }
enum MessageStatus { pending, sent, delivered, failed }

@HiveType(typeId: 1)
class Message extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final MessageType type;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final MessageStatus status;

  @HiveField(6)
  final String? userEmail;

  @HiveField(7)
  final String? agentName;

  @HiveField(8)
  final String? provider;

  @HiveField(9)
  final Map<String, dynamic>? metadata;

  @HiveField(10)
  final bool isVoiceMessage;

  @HiveField(11)
  final String? audioUrl;

  @HiveField(12)
  final String? transcription;

  Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.userEmail,
    this.agentName,
    this.provider,
    this.metadata,
    this.isVoiceMessage = false,
    this.audioUrl,
    this.transcription,
  });

  bool get isUserMessage => type == MessageType.user;
  bool get isAssistantMessage => type == MessageType.assistant;
  bool get isSystemMessage => type == MessageType.system;

  // Format du message pour l'API avec email en en-tête
  String get formattedContent {
    if (userEmail != null && userEmail!.isNotEmpty) {
      return 'Email: $userEmail\nAgent: ${agentName ?? "Jarvis"}\n\n$content';
    }
    return content;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'userEmail': userEmail,
      'agentName': agentName,
      'provider': provider,
      'metadata': metadata,
      'isVoiceMessage': isVoiceMessage,
      'audioUrl': audioUrl,
      'transcription': transcription,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      userEmail: json['userEmail'],
      agentName: json['agentName'],
      provider: json['provider'],
      metadata: json['metadata'],
      isVoiceMessage: json['isVoiceMessage'] ?? false,
      audioUrl: json['audioUrl'],
      transcription: json['transcription'],
    );
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? userEmail,
    String? agentName,
    String? provider,
    Map<String, dynamic>? metadata,
    bool? isVoiceMessage,
    String? audioUrl,
    String? transcription,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      userEmail: userEmail ?? this.userEmail,
      agentName: agentName ?? this.agentName,
      provider: provider ?? this.provider,
      metadata: metadata ?? this.metadata,
      isVoiceMessage: isVoiceMessage ?? this.isVoiceMessage,
      audioUrl: audioUrl ?? this.audioUrl,
      transcription: transcription ?? this.transcription,
    );
  }
}

@HiveType(typeId: 2)
class Conversation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime? updatedAt;

  @HiveField(4)
  final String? userEmail;

  @HiveField(5)
  final String? agentName;

  @HiveField(6)
  final bool isArchived;

  @HiveField(7)
  final String? provider;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    this.updatedAt,
    this.userEmail,
    this.agentName,
    this.isArchived = false,
    this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userEmail': userEmail,
      'agentName': agentName,
      'isArchived': isArchived,
      'provider': provider,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      userEmail: json['userEmail'],
      agentName: json['agentName'],
      isArchived: json['isArchived'] ?? false,
      provider: json['provider'],
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userEmail,
    String? agentName,
    bool? isArchived,
    String? provider,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userEmail: userEmail ?? this.userEmail,
      agentName: agentName ?? this.agentName,
      isArchived: isArchived ?? this.isArchived,
      provider: provider ?? this.provider,
    );
  }
}
