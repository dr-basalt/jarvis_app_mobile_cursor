import 'package:flutter/material.dart';
import 'package:jarvis_mobile_app/config/theme.dart';
import 'package:jarvis_mobile_app/core/services/voice_service.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onVoiceSend;
  final VoiceState voiceState;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onVoiceSend,
    required this.voiceState,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isComposing = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bouton microphone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.voiceState == VoiceState.listening
                    ? AppTheme.errorColor
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: widget.voiceState == VoiceState.listening
                    ? null
                    : widget.onVoiceSend,
                icon: Icon(
                  widget.voiceState == VoiceState.listening
                      ? Icons.stop
                      : Icons.mic,
                  color: widget.voiceState == VoiceState.listening
                      ? Colors.white
                      : AppTheme.primaryColor,
                ),
                tooltip: widget.voiceState == VoiceState.listening
                    ? 'Arrêter l\'enregistrement'
                    : 'Message vocal',
              ),
            ),

            const SizedBox(width: 12),

            // Champ de texte
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Tapez votre message...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onSubmitted: _isComposing ? (_) => widget.onSend() : null,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Bouton d'envoi
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isComposing
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: _isComposing ? widget.onSend : null,
                icon: Icon(
                  Icons.send,
                  color: _isComposing ? Colors.white : Colors.white.withOpacity(0.5),
                ),
                tooltip: 'Envoyer',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
