import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  final Uuid _uuid = const Uuid();

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;

  void addMessage(String content, MessageType type) {
    final message = Message(
      id: _uuid.v4(),
      content: content,
      type: type,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
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

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // Simulation d'une réponse IA
  Future<void> sendMessage(String content) async {
    // Ajouter le message utilisateur
    addMessage(content, MessageType.user);
    
    // Simuler le chargement
    setLoading(true);
    
    // Simuler un délai de réponse
    await Future.delayed(const Duration(seconds: 2));
    
    // Générer une réponse IA simulée
    final response = _generateAIResponse(content);
    
    // Ajouter la réponse IA
    addMessage(response, MessageType.assistant);
    
    setLoading(false);
  }

  String _generateAIResponse(String userMessage) {
    final responses = [
      "Je comprends votre question. Laissez-moi vous aider avec cela.",
      "Excellente question ! Voici ce que je peux vous dire à ce sujet.",
      "Merci pour votre message. Je vais analyser cela et vous donner une réponse appropriée.",
      "C'est un sujet intéressant. Permettez-moi de vous expliquer cela en détail.",
      "Je suis là pour vous aider. Voici ma réponse à votre question.",
    ];
    
    // Logique simple pour choisir une réponse
    final index = userMessage.length % responses.length;
    return responses[index];
  }
}
