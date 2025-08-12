import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';

class VoiceInput extends StatelessWidget {
  const VoiceInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        final voiceState = provider.voiceService.state;
        final isListening = voiceState == VoiceState.listening;
        final isProcessing = voiceState == VoiceState.processing;
        final currentText = provider.voiceService.currentText;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Bouton microphone
              GestureDetector(
                onTap: () {
                  if (isListening) {
                    provider.stopVoiceInput();
                  } else {
                    provider.startVoiceInput();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isListening 
                        ? Colors.red 
                        : AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (isListening ? Colors.red : AppTheme.primaryBlue).withOpacity(0.3),
                        blurRadius: isListening ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Texte de reconnaissance vocale
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isListening || isProcessing
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: isListening || isProcessing
                        ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.3))
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (isListening || isProcessing) ...[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          isListening || isProcessing
                              ? (currentText.isNotEmpty ? currentText : 'Écoute en cours...')
                              : 'Appuyez pour parler',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isListening || isProcessing
                                ? AppTheme.primaryBlue
                                : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                            fontStyle: currentText.isEmpty && (isListening || isProcessing)
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Indicateur d'état
              if (isListening || isProcessing)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: isListening ? Colors.red : AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
