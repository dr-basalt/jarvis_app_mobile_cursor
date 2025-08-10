import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis_mobile_app/config/theme.dart';
import 'package:jarvis_mobile_app/core/providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    // Afficher un indicateur de chargement si l'authentification est en cours
    if (authState == AuthState.authenticating) {
      _isLoading = true;
    } else {
      _isLoading = false;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Logo et titre
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                          AppTheme.accentColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      size: 50,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.5, 0.5), duration: 800.ms),

                  const SizedBox(height: 24),

                  Text(
                    'Bienvenue sur Jarvis',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 8),

                  Text(
                    'Votre assistant IA personnel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, duration: 600.ms),
                ],
              ),

              const SizedBox(height: 48),

              // Boutons de connexion
              Column(
                children: [
                  // Google
                  _buildOAuthButton(
                    icon: 'assets/images/google_icon.png',
                    text: 'Continuer avec Google',
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    delay: 600,
                  ),

                  const SizedBox(height: 16),

                  // Facebook
                  _buildOAuthButton(
                    icon: 'assets/images/facebook_icon.png',
                    text: 'Continuer avec Facebook',
                    backgroundColor: const Color(0xFF1877F2),
                    textColor: Colors.white,
                    onPressed: _isLoading ? null : _signInWithFacebook,
                    delay: 800,
                  ),

                  const SizedBox(height: 16),

                  // GitHub
                  _buildOAuthButton(
                    icon: 'assets/images/github_icon.png',
                    text: 'Continuer avec GitHub',
                    backgroundColor: const Color(0xFF24292E),
                    textColor: Colors.white,
                    onPressed: _isLoading ? null : _signInWithGitHub,
                    delay: 1000,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Indicateur de chargement
              if (_isLoading)
                Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .then()
                        .rotate(duration: 1000.ms, repeat: true),
                    const SizedBox(height: 16),
                    Text(
                      'Connexion en cours...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms),
                  ],
                ),

              const SizedBox(height: 24),

              // Texte informatif
              Text(
                'En vous connectant, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1200.ms, duration: 600.ms),

              const Spacer(),

              // Footer
              Text(
                'Version ${AppConfig.appVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1400.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOAuthButton({
    required String icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback? onPressed,
    required int delay,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Icône
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: icon.startsWith('assets/')
                      ? Image.asset(
                          icon,
                          width: 24,
                          height: 24,
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 24,
                          color: textColor,
                        ),
                ),
                const SizedBox(width: 16),
                // Texte
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Icône de flèche
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .slideX(begin: 0.3, duration: 600.ms);
  }

  Future<void> _signInWithGoogle() async {
    try {
      await ref.read(currentUserProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion Google: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      await ref.read(currentUserProvider.notifier).signInWithFacebook();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion Facebook: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _signInWithGitHub() async {
    try {
      await ref.read(currentUserProvider.notifier).signInWithGitHub();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion GitHub: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
