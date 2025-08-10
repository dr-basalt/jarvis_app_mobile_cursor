import 'package:hive_flutter/hive_flutter.dart';
import 'package:jarvis_mobile_app/models/message.dart';
import 'package:jarvis_mobile_app/models/user.dart';

class StorageService {
  static const String _userBox = 'user_box';
  static const String _messagesBox = 'messages_box';
  static const String _conversationsBox = 'conversations_box';
  static const String _settingsBox = 'settings_box';

  static late Box<User> _userBoxInstance;
  static late Box<Message> _messagesBoxInstance;
  static late Box<Conversation> _conversationsBoxInstance;
  static late Box _settingsBoxInstance;

  static Future<void> initialize() async {
    // Enregistrer les adaptateurs Hive
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(ConversationAdapter());
    Hive.registerAdapter(EmotionalCheckinAdapter());
    Hive.registerAdapter(RoutineAdapter());
    Hive.registerAdapter(MessageAttachmentAdapter());

    // Ouvrir les boîtes
    _userBoxInstance = await Hive.openBox<User>(_userBox);
    _messagesBoxInstance = await Hive.openBox<Message>(_messagesBox);
    _conversationsBoxInstance = await Hive.openBox<Conversation>(_conversationsBox);
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
  }

  // Méthodes pour les utilisateurs
  static Future<void> saveUser(User user) async {
    await _userBoxInstance.put(user.id, user);
  }

  static User? getUser(String userId) {
    return _userBoxInstance.get(userId);
  }

  static Future<void> deleteUser(String userId) async {
    await _userBoxInstance.delete(userId);
  }

  // Méthodes pour les messages
  static Future<void> saveMessage(Message message) async {
    await _messagesBoxInstance.put(message.id, message);
  }

  static Message? getMessage(String messageId) {
    return _messagesBoxInstance.get(messageId);
  }

  static List<Message> getMessagesByConversation(String conversationId) {
    return _messagesBoxInstance.values
        .where((message) => message.conversationId == conversationId)
        .toList();
  }

  static Future<void> deleteMessage(String messageId) async {
    await _messagesBoxInstance.delete(messageId);
  }

  // Méthodes pour les conversations
  static Future<void> saveConversation(Conversation conversation) async {
    await _conversationsBoxInstance.put(conversation.id, conversation);
  }

  static Conversation? getConversation(String conversationId) {
    return _conversationsBoxInstance.get(conversationId);
  }

  static List<Conversation> getAllConversations() {
    return _conversationsBoxInstance.values.toList();
  }

  static Future<void> deleteConversation(String conversationId) async {
    await _conversationsBoxInstance.delete(conversationId);
  }

  // Méthodes pour les paramètres
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBoxInstance.put(key, value);
  }

  static T? getSetting<T>(String key) {
    return _settingsBoxInstance.get(key) as T?;
  }

  static Future<void> deleteSetting(String key) async {
    await _settingsBoxInstance.delete(key);
  }

  // Nettoyage
  static Future<void> clearAll() async {
    await _userBoxInstance.clear();
    await _messagesBoxInstance.clear();
    await _conversationsBoxInstance.clear();
    await _settingsBoxInstance.clear();
  }

  static Future<void> dispose() async {
    await _userBoxInstance.close();
    await _messagesBoxInstance.close();
    await _conversationsBoxInstance.close();
    await _settingsBoxInstance.close();
  }
}
