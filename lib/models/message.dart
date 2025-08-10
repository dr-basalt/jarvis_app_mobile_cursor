import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String conversationId;
  final String content;
  final MessageType type;
  final MessageRole role;
  final DateTime timestamp;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;
  final List<MessageAttachment>? attachments;
  final String? audioUrl;
  final String? transcription;
  final Map<String, dynamic>? aiResponse;
  final Map<String, dynamic>? context;
  final List<String>? tags;
  final bool isPinned;
  final int? tokenCount;
  final double? cost;

  const Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.type,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.metadata,
    this.attachments,
    this.audioUrl,
    this.transcription,
    this.aiResponse,
    this.context,
    this.tags,
    this.isPinned = false,
    this.tokenCount,
    this.cost,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? id,
    String? conversationId,
    String? content,
    MessageType? type,
    MessageRole? role,
    DateTime? timestamp,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
    List<MessageAttachment>? attachments,
    String? audioUrl,
    String? transcription,
    Map<String, dynamic>? aiResponse,
    Map<String, dynamic>? context,
    List<String>? tags,
    bool? isPinned,
    int? tokenCount,
    double? cost,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      type: type ?? this.type,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
      audioUrl: audioUrl ?? this.audioUrl,
      transcription: transcription ?? this.transcription,
      aiResponse: aiResponse ?? this.aiResponse,
      context: context ?? this.context,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      tokenCount: tokenCount ?? this.tokenCount,
      cost: cost ?? this.cost,
    );
  }

  bool get isUserMessage => role == MessageRole.user;
  bool get isAssistantMessage => role == MessageRole.assistant;
  bool get isSystemMessage => role == MessageRole.system;
  bool get isTextMessage => type == MessageType.text;
  bool get isVoiceMessage => type == MessageType.voice;
  bool get isImageMessage => type == MessageType.image;
  bool get isFileMessage => type == MessageType.file;
  bool get isPending => status == MessageStatus.pending;
  bool get isSent => status == MessageStatus.sent;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isFailed => status == MessageStatus.failed;
}

enum MessageType {
  text,
  voice,
  image,
  file,
  system,
}

enum MessageRole {
  user,
  assistant,
  system,
}

enum MessageStatus {
  pending,
  sent,
  delivered,
  failed,
}

@JsonSerializable()
class MessageAttachment {
  final String id;
  final String name;
  final String url;
  final String type; // image, audio, video, document
  final int size;
  final String? mimeType;
  final Map<String, dynamic>? metadata;

  const MessageAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    this.mimeType,
    this.metadata,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) => _$MessageAttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$MessageAttachmentToJson(this);
}

@JsonSerializable()
class Conversation {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Message> messages;
  final Map<String, dynamic>? settings;
  final List<String>? tags;
  final bool isArchived;
  final String? modelUsed;
  final Map<String, dynamic>? context;

  const Conversation({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.messages = const [],
    this.settings,
    this.tags,
    this.isArchived = false,
    this.modelUsed,
    this.context,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  Conversation copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    Map<String, dynamic>? settings,
    List<String>? tags,
    bool? isArchived,
    String? modelUsed,
    Map<String, dynamic>? context,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      isArchived: isArchived ?? this.isArchived,
      modelUsed: modelUsed ?? this.modelUsed,
      context: context ?? this.context,
    );
  }

  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;
  int get messageCount => messages.length;
  bool get hasUnreadMessages => messages.any((msg) => msg.status == MessageStatus.delivered);
}

@JsonSerializable()
class ChatConfig {
  final String? selectedModel;
  final String? selectedProvider;
  final Map<String, dynamic>? modelSettings;
  final bool enableVoice;
  final bool enableRAG;
  final bool enableContext;
  final Map<String, dynamic>? ragSettings;
  final Map<String, dynamic>? voiceSettings;

  const ChatConfig({
    this.selectedModel,
    this.selectedProvider,
    this.modelSettings,
    this.enableVoice = true,
    this.enableRAG = true,
    this.enableContext = true,
    this.ragSettings,
    this.voiceSettings,
  });

  factory ChatConfig.fromJson(Map<String, dynamic> json) => _$ChatConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ChatConfigToJson(this);
}
