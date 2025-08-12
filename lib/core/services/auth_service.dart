import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:jarvis_mobile_app/config/app_config.dart';
import 'package:jarvis_mobile_app/models/user.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );
  
  // static final FacebookAuth _facebookAuth = FacebookAuth.instance;
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  String? _authToken;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _currentUser != null;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Restaurer la session depuis le stockage sécurisé
      await _restoreSession();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'initialisation de l\'auth: $e');
      }
    }
  }

  Future<void> _restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    final userData = await _storage.read(key: _userKey);
    
    if (token != null && userData != null) {
      try {
        _authToken = token;
        _currentUser = User.fromJson(jsonDecode(userData));
        
        // Vérifier si le token est encore valide
        if (!await _validateToken(token)) {
          await signOut();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors de la restauration de session: $e');
        }
        await signOut();
      }
    }
  }

  Future<bool> _validateToken(String token) async {
    try {
      // TODO: Implémenter la validation du token côté serveur
      // Pour l'instant, on considère que le token est valide
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Créer l'utilisateur
      final user = User(
        id: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        provider: 'google',
        isAdmin: AppConfig.isAdmin(googleUser.email),
        isSuperAdmin: AppConfig.isSuperAdmin(googleUser.email),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Sauvegarder la session
      await _saveSession(googleAuth.accessToken!, user);
      
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la connexion Google: $e');
      }
      rethrow;
    }
  }

  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) return null;

      final userData = await _facebookAuth.getUserData(
        fields: "name,email,picture.width(200)",
      );

      // Créer l'utilisateur
      final user = User(
        id: result.accessToken!.userId,
        email: userData['email'] ?? '',
        name: userData['name'],
        photoUrl: userData['picture']?['data']?['url'],
        provider: 'facebook',
        isAdmin: AppConfig.isAdmin(userData['email'] ?? ''),
        isSuperAdmin: AppConfig.isSuperAdmin(userData['email'] ?? ''),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Sauvegarder la session
      await _saveSession(result.accessToken!.token, user);
      
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la connexion Facebook: $e');
      }
      rethrow;
    }
  }

  Future<User?> signInWithGitHub() async {
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

  Future<void> _saveSession(String token, User user) async {
    _authToken = token;
    _currentUser = user;
    
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> signOut() async {
    try {
      // Déconnexion des providers
      await _googleSignIn.signOut();
      await _facebookAuth.logOut();
      
      // Nettoyer le stockage
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _refreshTokenKey);
      
      // Réinitialiser l'état
      _currentUser = null;
      _authToken = null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la déconnexion: $e');
      }
    }
  }

  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        await signOut();
        return;
      }

      // TODO: Implémenter le refresh token côté serveur
      // Pour l'instant, on déconnecte l'utilisateur
      await signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du refresh token: $e');
      }
      await signOut();
    }
  }

  Future<User?> updateUserProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return null;

    try {
      final updatedUser = _currentUser!.copyWith(
        name: updates['name'] ?? _currentUser!.name,
        photoUrl: updates['photoUrl'] ?? _currentUser!.photoUrl,
        preferences: updates['preferences'] ?? _currentUser!.preferences,
        profile: updates['profile'] ?? _currentUser!.profile,
        birthDate: updates['birthDate'] ?? _currentUser!.birthDate,
        birthPlace: updates['birthPlace'] ?? _currentUser!.birthPlace,
        zodiacSign: updates['zodiacSign'] ?? _currentUser!.zodiacSign,
        mbtiType: updates['mbtiType'] ?? _currentUser!.mbtiType,
        hollandCode: updates['hollandCode'] ?? _currentUser!.hollandCode,
        cliftonStrengths: updates['cliftonStrengths'] ?? _currentUser!.cliftonStrengths,
        humanDesign: updates['humanDesign'] ?? _currentUser!.humanDesign,
        calendarEnabled: updates['calendarEnabled'] ?? _currentUser!.calendarEnabled,
        googleCalendarId: updates['googleCalendarId'] ?? _currentUser!.googleCalendarId,
        spotifyUserId: updates['spotifyUserId'] ?? _currentUser!.spotifyUserId,
        favoriteGenres: updates['favoriteGenres'] ?? _currentUser!.favoriteGenres,
        musicPreferences: updates['musicPreferences'] ?? _currentUser!.musicPreferences,
        routinePreferences: updates['routinePreferences'] ?? _currentUser!.routinePreferences,
        ragPreferences: updates['ragPreferences'] ?? _currentUser!.ragPreferences,
      );

      _currentUser = updatedUser;
      await _storage.write(key: _userKey, value: jsonEncode(updatedUser.toJson()));
      
      return updatedUser;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour du profil: $e');
      }
      return null;
    }
  }

  Future<bool> checkAdminAccess() async {
    if (_currentUser == null) return false;
    return _currentUser!.hasAdminAccess;
  }

  Future<bool> checkSuperAdminAccess() async {
    if (_currentUser == null) return false;
    return _currentUser!.isSuperAdmin;
  }

  // Méthodes pour la gestion des permissions
  bool canAccessAdminPanel() {
    return _currentUser?.hasAdminAccess ?? false;
  }

  bool canModifyConfig() {
    return _currentUser?.isSuperAdmin ?? false;
  }

  bool canAccessBioHacking() {
    return _currentUser?.hasBioHackingData ?? false;
  }

  bool canAccessCalendar() {
    return _currentUser?.hasCalendarAccess ?? false;
  }

  bool canAccessMusic() {
    return _currentUser?.hasMusicAccess ?? false;
  }
}
