import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_config.dart';

class AuthService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  AppConfig? _config;
  bool _isInitialized = false;

  AppConfig? get config => _config;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _config?.isAuthenticated ?? false;
  String? get userEmail => _config?.userEmail;
  String? get userName => _config?.userName;
  String? get userPhotoUrl => _config?.userPhotoUrl;
  bool get isAdmin => _config?.isAdmin ?? false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _restoreSession();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'initialisation de l\'auth: $e');
      }
    }
  }

  Future<void> _restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    final userData = await _storage.read(key: _userDataKey);
    
    if (token != null && userData != null) {
      try {
        final userMap = jsonDecode(userData);
        _config = AppConfig.fromJson(userMap);
        _config = _config?.copyWith(
          authToken: token,
          isAuthenticated: true,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors de la restauration de session: $e');
        }
        await signOut();
      }
    } else {
      _config = AppConfig();
    }
  }

  Future<AppConfig?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      _config = AppConfig(
        userEmail: googleUser.email,
        userName: googleUser.displayName,
        userPhotoUrl: googleUser.photoUrl,
        provider: 'google',
        isAuthenticated: true,
        authToken: googleAuth.accessToken,
        refreshToken: googleAuth.idToken,
      );

      await _saveSession();
      notifyListeners();
      
      return _config;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la connexion Google: $e');
      }
      rethrow;
    }
  }

  Future<AppConfig?> signInWithFacebook() async {
    try {
      // TODO: Implémenter l'authentification Facebook
      // Pour l'instant, on retourne null
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la connexion Facebook: $e');
      }
      rethrow;
    }
  }

  Future<AppConfig?> signInWithGitHub() async {
    try {
      // TODO: Implémenter l'authentification GitHub
      // Pour l'instant, on retourne null
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la connexion GitHub: $e');
      }
      rethrow;
    }
  }

  Future<void> _saveSession() async {
    if (_config == null) return;
    
    await _storage.write(key: _tokenKey, value: _config!.authToken);
    await _storage.write(key: _refreshTokenKey, value: _config!.refreshToken);
    await _storage.write(key: _userDataKey, value: jsonEncode(_config!.toJson()));
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userDataKey);
      
      _config = AppConfig();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la déconnexion: $e');
      }
    }
  }

  Future<void> updateConfig(AppConfig newConfig) async {
    _config = newConfig;
    await _saveSession();
    notifyListeners();
  }

  Future<void> updateTheme(bool isDarkMode) async {
    if (_config != null) {
      _config = _config!.copyWith(isDarkMode: isDarkMode);
      await _saveSession();
      notifyListeners();
    }
  }
}
