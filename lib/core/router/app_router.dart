import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis_mobile_app/core/providers/providers.dart';
import 'package:jarvis_mobile_app/screens/auth/login_screen.dart';
import 'package:jarvis_mobile_app/screens/auth/signup_screen.dart';
import 'package:jarvis_mobile_app/screens/chat/chat_screen.dart';
import 'package:jarvis_mobile_app/screens/chat/voice_chat_screen.dart';
import 'package:jarvis_mobile_app/screens/admin/settings_screen.dart';
import 'package:jarvis_mobile_app/screens/home/home_screen.dart';
import 'package:jarvis_mobile_app/screens/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Si l'état d'authentification est en cours d'initialisation, rester sur le splash
      if (authState == AuthState.initializing) {
        return '/splash';
      }
      
      // Si l'utilisateur n'est pas authentifié, rediriger vers la connexion
      if (authState == AuthState.unauthenticated) {
        return '/login';
      }
      
      // Si l'utilisateur est en cours d'authentification, rester sur le splash
      if (authState == AuthState.authenticating) {
        return '/splash';
      }
      
      // Si l'utilisateur est authentifié et sur une route d'auth, rediriger vers l'accueil
      if (authState == AuthState.authenticated) {
        if (state.matchedLocation == '/login' || 
            state.matchedLocation == '/signup' || 
            state.matchedLocation == '/splash') {
          return '/home';
        }
      }
      
      // Sinon, pas de redirection
      return null;
    },
    routes: [
      // Route splash
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Routes d'authentification
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Route principale avec navigation bottom
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          // Route chat
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
            routes: [
              // Route chat vocal
              GoRoute(
                path: 'voice',
                name: 'voice_chat',
                builder: (context, state) => const VoiceChatScreen(),
              ),
            ],
          ),
          
          // Route calendrier (future)
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Calendrier - À venir'),
              ),
            ),
          ),
          
          // Route bio-hacking (future)
          GoRoute(
            path: '/biohacking',
            name: 'biohacking',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Bio-hacking - À venir'),
              ),
            ),
          ),
          
          // Route profil
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Profil - À venir'),
              ),
            ),
          ),
        ],
      ),
      
      // Route admin (protégée)
      GoRoute(
        path: '/admin/settings',
        name: 'admin_settings',
        builder: (context, state) => const SettingsScreen(),
        redirect: (context, state) {
          // Vérifier les permissions admin
          final container = ProviderScope.containerOf(context);
          final adminPermissions = container.read(adminPermissionsProvider);
          
          if (!adminPermissions.canAccessAdminPanel) {
            return '/home';
          }
          
          return null;
        },
      ),
      
      // Route par défaut (redirige vers l'accueil)
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      
      // Route d'accueil
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La page ${state.matchedLocation} n\'existe pas.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Extension pour faciliter la navigation
extension NavigationExtension on BuildContext {
  void goToChat() => go('/chat');
  void goToVoiceChat() => go('/chat/voice');
  void goToCalendar() => go('/calendar');
  void goToBioHacking() => go('/biohacking');
  void goToProfile() => go('/profile');
  void goToAdminSettings() => go('/admin/settings');
  void goToLogin() => go('/login');
  void goToSignup() => go('/signup');
  void goToHome() => go('/home');
  
  void goBack() {
    if (canPop()) {
      pop();
    } else {
      go('/home');
    }
  }
}
