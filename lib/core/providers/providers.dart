import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis_mobile_app/config/app_config.dart';
import 'package:jarvis_mobile_app/core/services/auth_service.dart';
import 'package:jarvis_mobile_app/core/services/chat_service.dart';
import 'package:jarvis_mobile_app/core/services/voice_service.dart';
import 'package:jarvis_mobile_app/models/message.dart';
import 'package:jarvis_mobile_app/models/user.dart';

// Providers pour les services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());
final voiceServiceProvider = Provider<VoiceService>((ref) => VoiceService());

// Provider pour le thème
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Provider pour l'utilisateur connecté
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier(ref.read(authServiceProvider));
});

// Provider pour l'état d'authentification
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.read(authServiceProvider));
});

// Provider pour les conversations
final conversationsProvider = StateNotifierProvider<ConversationsNotifier, List<Conversation>>((ref) {
  return ConversationsNotifier(ref.read(chatServiceProvider));
});

// Provider pour la conversation active
final activeConversationProvider = StateNotifierProvider<ActiveConversationNotifier, Conversation?>((ref) {
  return ActiveConversationNotifier(ref.read(chatServiceProvider));
});

// Provider pour les messages de la conversation active
final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>((ref) {
  return MessagesNotifier(ref.read(chatServiceProvider));
});

// Provider pour l'état de la voix
final voiceStateProvider = StateNotifierProvider<VoiceStateNotifier, VoiceState>((ref) {
  return VoiceStateNotifier(ref.read(voiceServiceProvider));
});

// Provider pour la configuration du chat
final chatConfigProvider = StateNotifierProvider<ChatConfigNotifier, ChatConfig>((ref) {
  return ChatConfigNotifier(ref.read(chatServiceProvider));
});

// Provider pour les permissions admin
final adminPermissionsProvider = Provider<AdminPermissions>((ref) {
  final user = ref.watch(currentUserProvider);
  return AdminPermissions(user);
});

// Notifiers
class CurrentUserNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(null) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _authService.initialize();
    state = _authService.currentUser;
  }

  Future<void> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    state = user;
  }

  Future<void> signInWithFacebook() async {
    final user = await _authService.signInWithFacebook();
    state = user;
  }

  Future<void> signInWithGitHub() async {
    final user = await _authService.signInWithGitHub();
    state = user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final updatedUser = await _authService.updateUserProfile(updates);
    if (updatedUser != null) {
      state = updatedUser;
    }
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(AuthState.initializing) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _authService.initialize();
    state = _authService.isAuthenticated ? AuthState.authenticated : AuthState.unauthenticated;
  }

  Future<void> signInWithGoogle() async {
    state = AuthState.authenticating;
    try {
      await _authService.signInWithGoogle();
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.error;
    }
  }

  Future<void> signInWithFacebook() async {
    state = AuthState.authenticating;
    try {
      await _authService.signInWithFacebook();
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.error;
    }
  }

  Future<void> signInWithGitHub() async {
    state = AuthState.authenticating;
    try {
      await _authService.signInWithGitHub();
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.error;
    }
  }

  Future<void> signOut() async {
    state = AuthState.authenticating;
    try {
      await _authService.signOut();
      state = AuthState.unauthenticated;
    } catch (e) {
      state = AuthState.error;
    }
  }
}

class ConversationsNotifier extends StateNotifier<List<Conversation>> {
  final ChatService _chatService;

  ConversationsNotifier(this._chatService) : super([]) {
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await _chatService.getConversations();
      state = conversations;
    } catch (e) {
      // En cas d'erreur, on garde la liste vide
    }
  }

  Future<void> createConversation({
    required String title,
    String? description,
    Map<String, dynamic>? settings,
    List<String>? tags,
  }) async {
    try {
      final conversation = await _chatService.createConversation(
        title: title,
        description: description,
        settings: settings,
        tags: tags,
      );
      state = [conversation, ...state];
    } catch (e) {
      // Gérer l'erreur
    }
  }

  Future<void> archiveConversation(String conversationId) async {
    try {
      final success = await _chatService.archiveConversation(conversationId);
      if (success) {
        state = state.map((conv) {
          if (conv.id == conversationId) {
            return conv.copyWith(isArchived: true);
          }
          return conv;
        }).toList();
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final success = await _chatService.deleteConversation(conversationId);
      if (success) {
        state = state.where((conv) => conv.id != conversationId).toList();
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }
}

class ActiveConversationNotifier extends StateNotifier<Conversation?> {
  final ChatService _chatService;

  ActiveConversationNotifier(this._chatService) : super(null);

  void setActiveConversation(Conversation? conversation) {
    state = conversation;
  }

  Future<void> createNewConversation({
    required String title,
    String? description,
  }) async {
    try {
      final conversation = await _chatService.createConversation(
        title: title,
        description: description,
      );
      state = conversation;
    } catch (e) {
      // Gérer l'erreur
    }
  }
}

class MessagesNotifier extends StateNotifier<List<Message>> {
  final ChatService _chatService;

  MessagesNotifier(this._chatService) : super([]);

  void setMessages(List<Message> messages) {
    state = messages;
  }

  void addMessage(Message message) {
    state = [...state, message];
  }

  void updateMessage(Message updatedMessage) {
    state = state.map((msg) {
      if (msg.id == updatedMessage.id) {
        return updatedMessage;
      }
      return msg;
    }).toList();
  }

  Future<void> sendTextMessage({
    required String conversationId,
    required String content,
    Map<String, dynamic>? context,
    List<String>? tags,
  }) async {
    try {
      // Ajouter le message utilisateur immédiatement
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        content: content,
        type: MessageType.text,
        role: MessageRole.user,
        timestamp: DateTime.now(),
        status: MessageStatus.pending,
        context: context,
        tags: tags,
      );
      addMessage(userMessage);

      // Envoyer le message et obtenir la réponse
      final response = await _chatService.sendTextMessage(
        conversationId: conversationId,
        content: content,
        context: context,
        tags: tags,
      );

      if (response != null) {
        // Mettre à jour le message utilisateur
        updateMessage(userMessage.copyWith(status: MessageStatus.delivered));
        // Ajouter la réponse de l'assistant
        addMessage(response);
      } else {
        // Marquer le message comme échoué
        updateMessage(userMessage.copyWith(status: MessageStatus.failed));
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }

  Future<void> sendVoiceMessage({
    required String conversationId,
    required File audioFile,
    Map<String, dynamic>? context,
    List<String>? tags,
  }) async {
    try {
      // Ajouter le message utilisateur immédiatement
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        content: '',
        type: MessageType.voice,
        role: MessageRole.user,
        timestamp: DateTime.now(),
        status: MessageStatus.pending,
        audioUrl: audioFile.path,
        context: context,
        tags: tags,
      );
      addMessage(userMessage);

      // Envoyer le message et obtenir la réponse
      final response = await _chatService.sendVoiceMessage(
        conversationId: conversationId,
        audioFile: audioFile,
        context: context,
        tags: tags,
      );

      if (response != null) {
        // Mettre à jour le message utilisateur avec la transcription
        updateMessage(userMessage.copyWith(
          content: response.transcription ?? '',
          status: MessageStatus.delivered,
        ));
        // Ajouter la réponse de l'assistant
        addMessage(response);
      } else {
        // Marquer le message comme échoué
        updateMessage(userMessage.copyWith(status: MessageStatus.failed));
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }
}

class VoiceStateNotifier extends StateNotifier<VoiceState> {
  final VoiceService _voiceService;

  VoiceStateNotifier(this._voiceService) : super(VoiceState.idle) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _voiceService.initialize();
    _voiceService.stateStream.listen((voiceState) {
      state = voiceState;
    });
  }

  Future<void> startListening() async {
    await _voiceService.startListening();
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
  }

  Future<void> speak(String text) async {
    await _voiceService.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
  }
}

class ChatConfigNotifier extends StateNotifier<ChatConfig> {
  final ChatService _chatService;

  ChatConfigNotifier(this._chatService) : super(ChatConfig()) {
    _loadConfig();
  }

  void _loadConfig() {
    state = _chatService.getChatConfig();
  }

  void updateConfig(ChatConfig config) {
    state = config;
  }

  void setModel(String model) {
    state = state.copyWith(selectedModel: model);
  }

  void setProvider(String provider) {
    state = state.copyWith(selectedProvider: provider);
  }

  void toggleVoice(bool enabled) {
    state = state.copyWith(enableVoice: enabled);
  }

  void toggleRAG(bool enabled) {
    state = state.copyWith(enableRAG: enabled);
  }
}

// Classes d'état
enum AuthState {
  initializing,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AdminPermissions {
  final User? user;

  AdminPermissions(this.user);

  bool get canAccessAdminPanel => user?.hasAdminAccess ?? false;
  bool get canModifyConfig => user?.isSuperAdmin ?? false;
  bool get canAccessBioHacking => user?.hasBioHackingData ?? false;
  bool get canAccessCalendar => user?.hasCalendarAccess ?? false;
  bool get canAccessMusic => user?.hasMusicAccess ?? false;
}
