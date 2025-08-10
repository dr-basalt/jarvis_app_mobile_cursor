import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String appName = 'Jarvis Assistant IA';
  static const String appVersion = '1.0.0';
  
  // URLs par défaut
  static const String defaultApiUrl = 'https://api.jarvis.local';
  static const String defaultN8nUrl = 'https://n8n.jarvis.local';
  static const String defaultWebhookUrl = 'https://webhook.jarvis.local';
  
  // Super admin emails
  static const List<String> superAdminEmails = [
    'kurushi9000@gmail.com',
  ];
  
  // Domaines admin autorisés
  static const List<String> adminDomains = [
    '@ori3com.cloud',
  ];
  
  // Configuration APIs par défaut
  static const Map<String, String> defaultApiConfig = {
    'openai_url': 'https://api.openai.com/v1',
    'claude_url': 'https://api.anthropic.com/v1',
    'ollama_url': 'http://localhost:11434',
    'custom_ai_url': '',
    'webhook_text_url': '',
    'webhook_voice_url': '',
    'logging_url': '',
  };
  
  // Modèles par défaut
  static const Map<String, String> defaultModels = {
    'openai': 'gpt-4',
    'claude': 'claude-3-sonnet-20240229',
    'ollama': 'llama2:13b',
    'custom': 'custom-model',
  };
  
  // Configuration audio
  static const Map<String, dynamic> audioConfig = {
    'sample_rate': 16000,
    'channels': 1,
    'bit_depth': 16,
    'language': 'fr-FR',
  };
  
  // Configuration RAG
  static const Map<String, dynamic> ragConfig = {
    'vector_db_url': 'http://localhost:6333',
    'embedding_model': 'text-embedding-ada-002',
    'chunk_size': 1000,
    'chunk_overlap': 200,
  };
  
  // Configuration calendrier
  static const Map<String, dynamic> calendarConfig = {
    'google_calendar_enabled': true,
    'notifications_enabled': true,
    'time_tracking_enabled': true,
    'routine_reminders': true,
  };
  
  // Configuration bio-hacking
  static const Map<String, dynamic> bioHackingConfig = {
    'spotify_enabled': false,
    'human_design_enabled': false,
    'mbti_enabled': false,
    'holland_enabled': false,
    'clifton_enabled': false,
    'emotional_checkin_enabled': true,
  };
  
  static late SharedPreferences _prefs;
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _initializeDefaultConfig();
  }
  
  static Future<void> _initializeDefaultConfig() async {
    // Initialiser les configurations par défaut si elles n'existent pas
    for (final entry in defaultApiConfig.entries) {
      if (!_prefs.containsKey('api_${entry.key}')) {
        await _prefs.setString('api_${entry.key}', entry.value);
      }
    }
    
    // Initialiser les modèles par défaut
    for (final entry in defaultModels.entries) {
      if (!_prefs.containsKey('model_${entry.key}')) {
        await _prefs.setString('model_${entry.key}', entry.value);
      }
    }
    
    // Initialiser les configurations audio
    for (final entry in audioConfig.entries) {
      if (!_prefs.containsKey('audio_${entry.key}')) {
        await _prefs.setString('audio_${entry.key}', entry.value.toString());
      }
    }
    
    // Initialiser les configurations RAG
    for (final entry in ragConfig.entries) {
      if (!_prefs.containsKey('rag_${entry.key}')) {
        await _prefs.setString('rag_${entry.key}', entry.value.toString());
      }
    }
    
    // Initialiser les configurations calendrier
    for (final entry in calendarConfig.entries) {
      if (!_prefs.containsKey('calendar_${entry.key}')) {
        await _prefs.setBool('calendar_${entry.key}', entry.value);
      }
    }
    
    // Initialiser les configurations bio-hacking
    for (final entry in bioHackingConfig.entries) {
      if (!_prefs.containsKey('biohacking_${entry.key}')) {
        await _prefs.setBool('biohacking_${entry.key}', entry.value);
      }
    }
  }
  
  // Getters pour les configurations
  static String getApiUrl(String key) {
    return _prefs.getString('api_$key') ?? defaultApiConfig[key] ?? '';
  }
  
  static String getModel(String provider) {
    return _prefs.getString('model_$provider') ?? defaultModels[provider] ?? '';
  }
  
  static String getAudioConfig(String key) {
    return _prefs.getString('audio_$key') ?? audioConfig[key]?.toString() ?? '';
  }
  
  static String getRagConfig(String key) {
    return _prefs.getString('rag_$key') ?? ragConfig[key]?.toString() ?? '';
  }
  
  static bool getCalendarConfig(String key) {
    return _prefs.getBool('calendar_$key') ?? calendarConfig[key] ?? false;
  }
  
  static bool getBioHackingConfig(String key) {
    return _prefs.getBool('biohacking_$key') ?? bioHackingConfig[key] ?? false;
  }
  
  // Setters pour les configurations
  static Future<void> setApiUrl(String key, String value) async {
    await _prefs.setString('api_$key', value);
  }
  
  static Future<void> setModel(String provider, String model) async {
    await _prefs.setString('model_$provider', model);
  }
  
  static Future<void> setAudioConfig(String key, String value) async {
    await _prefs.setString('audio_$key', value);
  }
  
  static Future<void> setRagConfig(String key, String value) async {
    await _prefs.setString('rag_$key', value);
  }
  
  static Future<void> setCalendarConfig(String key, bool value) async {
    await _prefs.setBool('calendar_$key', value);
  }
  
  static Future<void> setBioHackingConfig(String key, bool value) async {
    await _prefs.setBool('biohacking_$key', value);
  }
  
  // Vérification des permissions admin
  static bool isSuperAdmin(String email) {
    return superAdminEmails.contains(email);
  }
  
  static bool isAdminDomain(String email) {
    return adminDomains.any((domain) => email.endsWith(domain));
  }
  
  static bool isAdmin(String email) {
    return isSuperAdmin(email) || isAdminDomain(email);
  }
  
  // Configuration de debug
  static bool get isDebugMode => kDebugMode;
  
  // Configuration de build
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  
  // Configuration de sécurité
  static const int sessionTimeoutMinutes = 60;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
}
