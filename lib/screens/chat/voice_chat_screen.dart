import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VoiceChatScreen extends StatelessWidget {
  const VoiceChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pour l'instant, rediriger vers le chat principal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/chat');
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
