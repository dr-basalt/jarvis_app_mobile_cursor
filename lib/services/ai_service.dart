import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/app_config.dart';
import '../models/message.dart';

class AIService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  
  AIService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<String> sendMessage(Message message, AppConfig config) async {
    try {
      final provider = config.defaultProvider;
      final agentName = config.defaultAgent;
      
      switch (provider) {
        case 'openai':
          return await _callOpenAI(message, config);
        case 'claude':
          return await _callClaude(message, config);
        case 'ollama':
          return await _callOllama(message, config);
        case 'n8n':
        default:
          return await _callN8N(message, config);
      }
    } catch (e) {
      _logger.e('Erreur lors de l\'appel IA: $e');
      return 'Désolé, je rencontre des difficultés techniques. Veuillez réessayer.';
    }
  }

  Future<String> _callOpenAI(Message message, AppConfig config) async {
    if (config.openaiApiKey == null || config.openaiApiKey!.isEmpty) {
      throw Exception('Clé API OpenAI manquante');
    }

    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${config.openaiApiKey}',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'Tu es $agentName, un assistant IA personnel. Réponds de manière naturelle et utile.',
          },
          {
            'role': 'user',
            'content': message.formattedContent,
          },
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      },
    );

    return response.data['choices'][0]['message']['content'];
  }

  Future<String> _callClaude(Message message, AppConfig config) async {
    if (config.claudeApiKey == null || config.claudeApiKey!.isEmpty) {
      throw Exception('Clé API Claude manquante');
    }

    final response = await _dio.post(
      'https://api.anthropic.com/v1/messages',
      options: Options(
        headers: {
          'x-api-key': config.claudeApiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'claude-3-sonnet-20240229',
        'max_tokens': 1000,
        'messages': [
          {
            'role': 'user',
            'content': message.formattedContent,
          },
        ],
      },
    );

    return response.data['content'][0]['text'];
  }

  Future<String> _callOllama(Message message, AppConfig config) async {
    if (config.ollamaUrl == null || config.ollamaUrl!.isEmpty) {
      throw Exception('URL Ollama manquante');
    }

    final response = await _dio.post(
      '${config.ollamaUrl}/api/generate',
      data: {
        'model': 'llama2',
        'prompt': message.formattedContent,
        'stream': false,
      },
    );

    return response.data['response'];
  }

  Future<String> _callN8N(Message message, AppConfig config) async {
    final response = await _dio.post(
      config.n8nWebhookUrl,
      data: {
        'message': message.formattedContent,
        'userEmail': message.userEmail,
        'agentName': message.agentName ?? config.defaultAgent,
        'provider': message.provider ?? config.defaultProvider,
        'timestamp': message.timestamp.toIso8601String(),
        'conversationId': message.conversationId,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Le webhook n8n peut retourner différents formats
    if (response.data is String) {
      return response.data;
    } else if (response.data is Map) {
      return response.data['response'] ?? response.data['message'] ?? 'Réponse reçue';
    } else {
      return 'Réponse reçue du webhook';
    }
  }

  Future<List<Message>> syncConversations(AppConfig config) async {
    try {
      if (config.userEmail == null || config.userEmail!.isEmpty) {
        return [];
      }

      final response = await _dio.get(
        '${config.n8nWebhookUrl}/sync',
        queryParameters: {
          'userEmail': config.userEmail,
        },
      );

      if (response.data is List) {
        return response.data.map((json) => Message.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      _logger.e('Erreur lors de la synchronisation: $e');
      return [];
    }
  }
}
