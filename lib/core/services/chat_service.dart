import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jarvis_mobile_app/config/app_config.dart';
import 'package:jarvis_mobile_app/core/services/auth_service.dart';
import 'package:jarvis_mobile_app/models/message.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  static const _uuid = Uuid();
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  
  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // Configuration des endpoints
  String get _baseUrl => AppConfig.getApiUrl('webhook_text_url');
  String get _voiceUrl => AppConfig.getApiUrl('webhook_voice_url');
  String get _loggingUrl => AppConfig.getApiUrl('logging_url');

  // Configuration des modèles
  String get _selectedModel => AppConfig.getModel('openai');
  String get _selectedProvider => 'openai'; // Par défaut

  Future<void> initialize() async {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    
    // Configuration des intercepteurs pour l'authentification
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _authService.authToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('Erreur API: ${error.message}');
        }
        handler.next(error);
      },
    ));
  }

  // Envoyer un message texte
  Future<Message?> sendTextMessage({
    required String conversationId,
    required String content,
    Map<String, dynamic>? context,
    List<String>? tags,
  }) async {
    try {
      final messageId = _uuid.v4();
      final timestamp = DateTime.now();

      // Créer le message utilisateur
      final userMessage = Message(
        id: messageId,
        conversationId: conversationId,
        content: content,
        type: MessageType.text,
        role: MessageRole.user,
        timestamp: timestamp,
        status: MessageStatus.pending,
        context: context,
        tags: tags,
      );

      // Préparer la requête pour N8N/Flowise
      final requestData = {
        'message_id': messageId,
        'conversation_id': conversationId,
        'content': content,
        'type': 'text',
        'user_id': _authService.currentUser?.id,
        'user_email': _authService.currentUser?.email,
        'model': _selectedModel,
        'provider': _selectedProvider,
        'context': context ?? {},
        'tags': tags ?? [],
        'timestamp': timestamp.toIso8601String(),
        'config': {
          'enable_rag': AppConfig.getBioHackingConfig('emotional_checkin_enabled'),
          'enable_context': true,
          'max_tokens': 2000,
          'temperature': 0.7,
        },
      };

      // Envoyer à N8N/Flowise
      final response = await _dio.post(
        _baseUrl,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Créer le message de l'assistant
        final assistantMessage = Message(
          id: _uuid.v4(),
          conversationId: conversationId,
          content: responseData['content'] ?? 'Désolé, je n\'ai pas pu traiter votre demande.',
          type: MessageType.text,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
          status: MessageStatus.delivered,
          aiResponse: responseData['ai_response'],
          context: responseData['context'],
          tokenCount: responseData['token_count'],
          cost: responseData['cost']?.toDouble(),
        );

        // Logger l'interaction
        await _logInteraction(userMessage, assistantMessage, responseData);

        return assistantMessage;
      } else {
        throw Exception('Erreur lors de l\'envoi du message: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'envoi du message texte: $e');
      }
      rethrow;
    }
  }

  // Envoyer un message vocal
  Future<Message?> sendVoiceMessage({
    required String conversationId,
    required File audioFile,
    Map<String, dynamic>? context,
    List<String>? tags,
  }) async {
    try {
      final messageId = _uuid.v4();
      final timestamp = DateTime.now();

      // Créer le message utilisateur
      final userMessage = Message(
        id: messageId,
        conversationId: conversationId,
        content: '', // Sera rempli après transcription
        type: MessageType.voice,
        role: MessageRole.user,
        timestamp: timestamp,
        status: MessageStatus.pending,
        audioUrl: audioFile.path,
        context: context,
        tags: tags,
      );

      // Préparer la requête pour N8N/Flowise
      final formData = FormData.fromMap({
        'message_id': messageId,
        'conversation_id': conversationId,
        'audio_file': await MultipartFile.fromFile(
          audioFile.path,
          filename: 'voice_message.wav',
        ),
        'type': 'voice',
        'user_id': _authService.currentUser?.id,
        'user_email': _authService.currentUser?.email,
        'model': _selectedModel,
        'provider': _selectedProvider,
        'context': jsonEncode(context ?? {}),
        'tags': jsonEncode(tags ?? []),
        'timestamp': timestamp.toIso8601String(),
        'config': jsonEncode({
          'enable_rag': AppConfig.getBioHackingConfig('emotional_checkin_enabled'),
          'enable_context': true,
          'max_tokens': 2000,
          'temperature': 0.7,
          'audio_config': {
            'sample_rate': AppConfig.getAudioConfig('sample_rate'),
            'language': AppConfig.getAudioConfig('language'),
          },
        }),
      });

      // Envoyer à N8N/Flowise
      final response = await _dio.post(
        _voiceUrl,
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Créer le message de l'assistant
        final assistantMessage = Message(
          id: _uuid.v4(),
          conversationId: conversationId,
          content: responseData['content'] ?? 'Désolé, je n\'ai pas pu traiter votre message vocal.',
          type: MessageType.voice,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
          status: MessageStatus.delivered,
          audioUrl: responseData['audio_url'],
          transcription: responseData['transcription'],
          aiResponse: responseData['ai_response'],
          context: responseData['context'],
          tokenCount: responseData['token_count'],
          cost: responseData['cost']?.toDouble(),
        );

        // Mettre à jour le message utilisateur avec la transcription
        final updatedUserMessage = userMessage.copyWith(
          content: responseData['transcription'] ?? '',
          status: MessageStatus.delivered,
        );

        // Logger l'interaction
        await _logInteraction(updatedUserMessage, assistantMessage, responseData);

        return assistantMessage;
      } else {
        throw Exception('Erreur lors de l\'envoi du message vocal: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'envoi du message vocal: $e');
      }
      rethrow;
    }
  }

  // Logger les interactions
  Future<void> _logInteraction(
    Message userMessage,
    Message assistantMessage,
    Map<String, dynamic> responseData,
  ) async {
    try {
      if (_loggingUrl.isNotEmpty) {
        final logData = {
          'user_message': userMessage.toJson(),
          'assistant_message': assistantMessage.toJson(),
          'response_data': responseData,
          'user_id': _authService.currentUser?.id,
          'timestamp': DateTime.now().toIso8601String(),
          'model': _selectedModel,
          'provider': _selectedProvider,
          'cost': responseData['cost']?.toDouble(),
          'token_count': responseData['token_count'],
        };

        await _dio.post(
          _loggingUrl,
          data: logData,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du logging: $e');
      }
    }
  }

  // Créer une nouvelle conversation
  Future<Conversation> createConversation({
    required String title,
    String? description,
    Map<String, dynamic>? settings,
    List<String>? tags,
  }) async {
    final conversationId = _uuid.v4();
    final timestamp = DateTime.now();

    return Conversation(
      id: conversationId,
      title: title,
      description: description,
      createdAt: timestamp,
      updatedAt: timestamp,
      settings: settings,
      tags: tags,
      modelUsed: _selectedModel,
    );
  }

  // Obtenir l'historique des conversations
  Future<List<Conversation>> getConversations() async {
    try {
      // TODO: Implémenter la récupération depuis le backend
      // Pour l'instant, on retourne une liste vide
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des conversations: $e');
      }
      return [];
    }
  }

  // Obtenir les messages d'une conversation
  Future<List<Message>> getConversationMessages(String conversationId) async {
    try {
      // TODO: Implémenter la récupération depuis le backend
      // Pour l'instant, on retourne une liste vide
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des messages: $e');
      }
      return [];
    }
  }

  // Archiver une conversation
  Future<bool> archiveConversation(String conversationId) async {
    try {
      // TODO: Implémenter l'archivage côté backend
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'archivage de la conversation: $e');
      }
      return false;
    }
  }

  // Supprimer une conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      // TODO: Implémenter la suppression côté backend
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression de la conversation: $e');
      }
      return false;
    }
  }

  // Obtenir les statistiques de chat
  Future<Map<String, dynamic>> getChatStats() async {
    try {
      // TODO: Implémenter les statistiques côté backend
      return {
        'total_conversations': 0,
        'total_messages': 0,
        'total_tokens': 0,
        'total_cost': 0.0,
        'average_response_time': 0.0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des statistiques: $e');
      }
      return {};
    }
  }

  // Vérifier la connectivité
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('$_baseUrl/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Obtenir la configuration du chat
  ChatConfig getChatConfig() {
    return ChatConfig(
      selectedModel: _selectedModel,
      selectedProvider: _selectedProvider,
      enableVoice: AppConfig.getBioHackingConfig('emotional_checkin_enabled'),
      enableRAG: AppConfig.getBioHackingConfig('emotional_checkin_enabled'),
      enableContext: true,
      voiceSettings: {
        'sample_rate': AppConfig.getAudioConfig('sample_rate'),
        'language': AppConfig.getAudioConfig('language'),
      },
    );
  }
}
