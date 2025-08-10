import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis_mobile_app/config/theme.dart';
import 'package:jarvis_mobile_app/core/providers/providers.dart';
import 'package:jarvis_mobile_app/models/message.dart';
import 'package:jarvis_mobile_app/widgets/chat/message_bubble.dart';
import 'package:jarvis_mobile_app/widgets/chat/chat_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Créer une nouvelle conversation si aucune n'est active
    final activeConversation = ref.read(activeConversationProvider);
    if (activeConversation == null) {
      await ref.read(activeConversationProvider.notifier).createNewConversation(
        title: 'Nouvelle conversation',
        description: 'Commencez à discuter avec Jarvis',
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final activeConversation = ref.read(activeConversationProvider);
    if (activeConversation == null) return;

    // Vider le champ de texte
    _textController.clear();

    // Envoyer le message
    await ref.read(messagesProvider.notifier).sendTextMessage(
      conversationId: activeConversation.id,
      content: text,
    );

    // Faire défiler vers le bas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _sendVoiceMessage() async {
    final activeConversation = ref.read(activeConversationProvider);
    if (activeConversation == null) return;

    // Démarrer l'écoute vocale
    await ref.read(voiceStateProvider.notifier).startListening();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider);
    final activeConversation = ref.watch(activeConversationProvider);
    final voiceState = ref.watch(voiceStateProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeConversation?.title ?? 'Jarvis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (activeConversation != null)
                    Text(
                      '${messages.length} messages',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Bouton paramètres admin
          if (currentUser?.hasAdminAccess == true)
            IconButton(
              onPressed: () => context.goToAdminSettings(),
              icon: const Icon(Icons.settings),
              tooltip: 'Paramètres admin',
            ),
          // Bouton nouveau chat
          IconButton(
            onPressed: () async {
              await ref.read(activeConversationProvider.notifier).createNewConversation(
                title: 'Nouvelle conversation',
                description: 'Commencez à discuter avec Jarvis',
              );
              ref.read(messagesProvider.notifier).setMessages([]);
            },
            icon: const Icon(Icons.add),
            tooltip: 'Nouvelle conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isLastMessage = index == messages.length - 1;
                      
                      return Column(
                        children: [
                          MessageBubble(
                            message: message,
                            isLastMessage: isLastMessage,
                          ),
                          if (isLastMessage) const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),

          // Indicateur de frappe
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, repeat: true)
                      .then(delay: 200.ms)
                      .scale(duration: 600.ms, repeat: true),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, repeat: true)
                      .then(delay: 400.ms)
                      .scale(duration: 600.ms, repeat: true),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, repeat: true)
                      .then(delay: 600.ms)
                      .scale(duration: 600.ms, repeat: true),
                  const SizedBox(width: 12),
                  Text(
                    'Jarvis réfléchit...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

          // Indicateur d'état vocal
          if (voiceState == VoiceState.listening)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.mic,
                    size: 16,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Écoute en cours...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ),

          // Zone de saisie
          ChatInput(
            controller: _textController,
            onSend: _sendMessage,
            onVoiceSend: _sendVoiceMessage,
            voiceState: voiceState,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.smart_toy,
              size: 60,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bonjour ! Je suis Jarvis',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre assistant IA personnel',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Que puis-je faire pour vous ?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSuggestionChip('Racontez-moi une histoire'),
                const SizedBox(height: 8),
                _buildSuggestionChip('Aidez-moi avec mon travail'),
                const SizedBox(height: 8),
                _buildSuggestionChip('Planifiez ma journée'),
                const SizedBox(height: 8),
                _buildSuggestionChip('Analysez mes émotions'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        _textController.text = text;
        _sendMessage();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
