import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/message.dart';
import '../models/app_config.dart';
import '../services/ai_service.dart';
import '../services/voice_service.dart';
import '../services/auth_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  final List<Conversation> _conversations = [];
  final AIService _aiService = AIService();
  final VoiceService _voiceService = VoiceService();
  final Uuid _uuid = const Uuid();

  bool _isLoading = false;
  bool _isListening = false;
  String _currentConversationId = '';
  AppConfig? _config;

  List<Message> get messages => List.unmodifiable(_messages);
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String get currentConversationId => _currentConversationId;
  VoiceService get voiceService => _voiceService;
  AppConfig? get config => _config;

  Future<void> initialize(AuthService authService) async {
    _config = authService.config;
    
    // Initialiser Hive
    await Hive.initFlutter();
    Hive.registerAdapter(AppConfigAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(ConversationAdapter());
    
    // Initialiser les services
    await _voiceService.initialize();
    
    // Charger les conversations
    await _loadConversations();
    
    // Synchroniser si connecté
    if (_config?.isAuthenticated == true) {
      await _syncConversations();
    }
    
    notifyListeners();
  }

  void setConfig(AppConfig config) {
    _config = config;
    notifyListeners();
  }

  void addMessage(String content, MessageType type, {bool isVoiceMessage = false}) {
    final message = Message(
      id: _uuid.v4(),
      conversationId: _currentConversationId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      userEmail: _config?.userEmail,
      agentName: _config?.defaultAgent,
      provider: _config?.defaultProvider,
      isVoiceMessage: isVoiceMessage,
      transcription: isVoiceMessage ? content : null,
    );
    
    _messages.add(message);
    _saveMessage(message);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setListening(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  Future<void> sendMessage(String content, {bool isVoiceMessage = false}) async {
    if (content.trim().isEmpty) return;

    // Créer une nouvelle conversation si nécessaire
    if (_currentConversationId.isEmpty) {
      await _createNewConversation(content);
    }

    // Ajouter le message utilisateur
    addMessage(content, MessageType.user, isVoiceMessage: isVoiceMessage);
    
    setLoading(true);
    
    try {
      // Obtenir la réponse IA
      final lastMessage = _messages.last;
      final response = await _aiService.sendMessage(lastMessage, _config!);
      
      // Ajouter la réponse IA
      addMessage(response, MessageType.assistant);
      
      // Mettre à jour la conversation
      await _updateConversation(response);
      
    } catch (e) {
      addMessage('Désolé, je rencontre des difficultés techniques. Veuillez réessayer.', MessageType.assistant);
    } finally {
      setLoading(false);
    }
  }

  Future<void> startVoiceInput() async {
    setListening(true);
    await _voiceService.startListening();
    
    // Écouter les changements de texte
    _voiceService.addListener(() {
      if (_voiceService.state == VoiceState.processing && _voiceService.lastWords.isNotEmpty) {
        sendMessage(_voiceService.lastWords, isVoiceMessage: true);
        setListening(false);
      }
    });
  }

  Future<void> stopVoiceInput() async {
    setListening(false);
    await _voiceService.stopListening();
  }

  Future<void> speakResponse(String text) async {
    await _voiceService.speak(text);
  }

  Future<void> _createNewConversation(String firstMessage) async {
    _currentConversationId = _uuid.v4();
    
    final conversation = Conversation(
      id: _currentConversationId,
      title: firstMessage.length > 50 ? '${firstMessage.substring(0, 50)}...' : firstMessage,
      createdAt: DateTime.now(),
      userEmail: _config?.userEmail,
      agentName: _config?.defaultAgent,
      provider: _config?.defaultProvider,
    );
    
    _conversations.add(conversation);
    await _saveConversation(conversation);
  }

  Future<void> _updateConversation(String lastResponse) async {
    final conversationIndex = _conversations.indexWhere((c) => c.id == _currentConversationId);
    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];
      final updatedConversation = conversation.copyWith(
        updatedAt: DateTime.now(),
        title: lastResponse.length > 50 ? '${lastResponse.substring(0, 50)}...' : lastResponse,
      );
      
      _conversations[conversationIndex] = updatedConversation;
      await _saveConversation(updatedConversation);
    }
  }

  Future<void> loadConversation(String conversationId) async {
    _currentConversationId = conversationId;
    _messages.clear();
    
    // Charger les messages de la conversation
    final box = await Hive.openBox<Message>('messages');
    final conversationMessages = box.values
        .where((msg) => msg.conversationId == conversationId)
        .toList();
    
    conversationMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _messages.addAll(conversationMessages);
    
    notifyListeners();
  }

  Future<void> clearMessages() async {
    _messages.clear();
    _currentConversationId = '';
    notifyListeners();
  }

  Future<void> _loadConversations() async {
    try {
      final box = await Hive.openBox<Conversation>('conversations');
      _conversations.clear();
      _conversations.addAll(box.values);
      _conversations.sort((a, b) => b.updatedAt?.compareTo(a.updatedAt ?? b.updatedAt!) ?? 0);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des conversations: $e');
      }
    }
  }

  Future<void> _saveMessage(Message message) async {
    try {
      final box = await Hive.openBox<Message>('messages');
      await box.put(message.id, message);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la sauvegarde du message: $e');
      }
    }
  }

  Future<void> _saveConversation(Conversation conversation) async {
    try {
      final box = await Hive.openBox<Conversation>('conversations');
      await box.put(conversation.id, conversation);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la sauvegarde de la conversation: $e');
      }
    }
  }

  Future<void> _syncConversations() async {
    if (_config == null) return;
    
    try {
      final syncedMessages = await _aiService.syncConversations(_config!);
      
      for (final message in syncedMessages) {
        // Vérifier si le message existe déjà
        final exists = _messages.any((m) => m.id == message.id);
        if (!exists) {
          _messages.add(message);
          await _saveMessage(message);
        }
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la synchronisation: $e');
      }
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
