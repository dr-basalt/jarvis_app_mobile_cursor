import 'package:hive/hive.dart';

part 'app_config.g.dart';

@HiveType(typeId: 0)
class AppConfig extends HiveObject {
  @HiveField(0)
  String? openaiApiKey;

  @HiveField(1)
  String? claudeApiKey;

  @HiveField(2)
  String? ollamaUrl;

  @HiveField(3)
  String n8nWebhookUrl;

  @HiveField(4)
  String defaultProvider;

  @HiveField(5)
  String defaultAgent;

  @HiveField(6)
  bool isDarkMode;

  @HiveField(7)
  String? userEmail;

  @HiveField(8)
  bool isAuthenticated;

  @HiveField(9)
  String? authToken;

  @HiveField(10)
  String? refreshToken;

  @HiveField(11)
  String? provider; // google, facebook, github

  @HiveField(12)
  String? userName;

  @HiveField(13)
  String? userPhotoUrl;

  AppConfig({
    this.openaiApiKey,
    this.claudeApiKey,
    this.ollamaUrl,
    this.n8nWebhookUrl = 'https://n8n1890.infra.ori3com.cloud/webhook/c1eb3222-2afb-4656-b388-f35c2e7d5c73',
    this.defaultProvider = 'n8n',
    this.defaultAgent = 'Jarvis',
    this.isDarkMode = false,
    this.userEmail,
    this.isAuthenticated = false,
    this.authToken,
    this.refreshToken,
    this.provider,
    this.userName,
    this.userPhotoUrl,
  });

  bool get isAdmin => userEmail?.endsWith('@ori3com.cloud') ?? false;

  Map<String, dynamic> toJson() {
    return {
      'openaiApiKey': openaiApiKey,
      'claudeApiKey': claudeApiKey,
      'ollamaUrl': ollamaUrl,
      'n8nWebhookUrl': n8nWebhookUrl,
      'defaultProvider': defaultProvider,
      'defaultAgent': defaultAgent,
      'isDarkMode': isDarkMode,
      'userEmail': userEmail,
      'isAuthenticated': isAuthenticated,
      'authToken': authToken,
      'refreshToken': refreshToken,
      'provider': provider,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      openaiApiKey: json['openaiApiKey'],
      claudeApiKey: json['claudeApiKey'],
      ollamaUrl: json['ollamaUrl'],
      n8nWebhookUrl: json['n8nWebhookUrl'] ?? 'https://n8n1890.infra.ori3com.cloud/webhook/c1eb3222-2afb-4656-b388-f35c2e7d5c73',
      defaultProvider: json['defaultProvider'] ?? 'n8n',
      defaultAgent: json['defaultAgent'] ?? 'Jarvis',
      isDarkMode: json['isDarkMode'] ?? false,
      userEmail: json['userEmail'],
      isAuthenticated: json['isAuthenticated'] ?? false,
      authToken: json['authToken'],
      refreshToken: json['refreshToken'],
      provider: json['provider'],
      userName: json['userName'],
      userPhotoUrl: json['userPhotoUrl'],
    );
  }

  AppConfig copyWith({
    String? openaiApiKey,
    String? claudeApiKey,
    String? ollamaUrl,
    String? n8nWebhookUrl,
    String? defaultProvider,
    String? defaultAgent,
    bool? isDarkMode,
    String? userEmail,
    bool? isAuthenticated,
    String? authToken,
    String? refreshToken,
    String? provider,
    String? userName,
    String? userPhotoUrl,
  }) {
    return AppConfig(
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
      claudeApiKey: claudeApiKey ?? this.claudeApiKey,
      ollamaUrl: ollamaUrl ?? this.ollamaUrl,
      n8nWebhookUrl: n8nWebhookUrl ?? this.n8nWebhookUrl,
      defaultProvider: defaultProvider ?? this.defaultProvider,
      defaultAgent: defaultAgent ?? this.defaultAgent,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      userEmail: userEmail ?? this.userEmail,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authToken: authToken ?? this.authToken,
      refreshToken: refreshToken ?? this.refreshToken,
      provider: provider ?? this.provider,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
    );
  }
}
