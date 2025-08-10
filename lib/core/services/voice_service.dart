import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:jarvis_mobile_app/config/app_config.dart';

enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

class VoiceService {
  static final SpeechToText _speechToText = SpeechToText();
  static final FlutterTts _flutterTts = FlutterTts();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Singleton pattern
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  VoiceState _state = VoiceState.idle;
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  
  // Streams pour les événements
  final StreamController<VoiceState> _stateController = StreamController<VoiceState>.broadcast();
  final StreamController<String> _transcriptionController = StreamController<String>.broadcast();
  final StreamController<double> _confidenceController = StreamController<double>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  // Getters
  VoiceState get state => _state;
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  
  // Streams
  Stream<VoiceState> get stateStream => _stateController.stream;
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  Stream<double> get confidenceStream => _confidenceController.stream;
  Stream<String> get errorStream => _errorController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Demander les permissions
      await _requestPermissions();
      
      // Initialiser la reconnaissance vocale
      await _initializeSpeechToText();
      
      // Initialiser la synthèse vocale
      await _initializeTextToSpeech();
      
      // Initialiser le lecteur audio
      await _initializeAudioPlayer();
      
      _isInitialized = true;
      _updateState(VoiceState.idle);
      
      if (kDebugMode) {
        print('VoiceService initialisé avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'initialisation de VoiceService: $e');
      }
      _updateState(VoiceState.error);
      _errorController.add('Erreur d\'initialisation: $e');
    }
  }

  Future<void> _requestPermissions() async {
    // Permission microphone
    final microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus != PermissionStatus.granted) {
      throw Exception('Permission microphone refusée');
    }

    // Permission audio
    final audioStatus = await Permission.audio.request();
    if (audioStatus != PermissionStatus.granted) {
      throw Exception('Permission audio refusée');
    }
  }

  Future<void> _initializeSpeechToText() async {
    final available = await _speechToText.initialize(
      onError: (error) {
        if (kDebugMode) {
          print('Erreur reconnaissance vocale: ${error.errorMsg}');
        }
        _errorController.add('Erreur reconnaissance: ${error.errorMsg}');
        _updateState(VoiceState.error);
      },
      onStatus: (status) {
        if (kDebugMode) {
          print('Statut reconnaissance vocale: $status');
        }
        
        switch (status) {
          case 'listening':
            _isListening = true;
            _updateState(VoiceState.listening);
            break;
          case 'notListening':
            _isListening = false;
            _updateState(VoiceState.idle);
            break;
          case 'done':
            _isListening = false;
            _updateState(VoiceState.processing);
            break;
        }
      },
    );

    if (!available) {
      throw Exception('Reconnaissance vocale non disponible');
    }
  }

  Future<void> _initializeTextToSpeech() async {
    // Configuration TTS
    await _flutterTts.setLanguage(AppConfig.getAudioConfig('language'));
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Callbacks TTS
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _updateState(VoiceState.speaking);
    });
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _updateState(VoiceState.idle);
    });
    
    _flutterTts.setErrorHandler((msg) {
      if (kDebugMode) {
        print('Erreur TTS: $msg');
      }
      _errorController.add('Erreur synthèse: $msg');
      _isSpeaking = false;
      _updateState(VoiceState.error);
    });
  }

  Future<void> _initializeAudioPlayer() async {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _updateState(VoiceState.idle);
      }
    });
  }

  void _updateState(VoiceState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  // Démarrer l'écoute
  Future<void> startListening({
    Duration? timeout,
    String? language,
  }) async {
    if (!_isInitialized) {
      throw Exception('VoiceService non initialisé');
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      _updateState(VoiceState.listening);
      
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _transcriptionController.add(result.recognizedWords);
            _confidenceController.add(result.confidence);
          }
        },
        listenFor: timeout ?? const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: language ?? AppConfig.getAudioConfig('language'),
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du démarrage de l\'écoute: $e');
      }
      _errorController.add('Erreur écoute: $e');
      _updateState(VoiceState.error);
    }
  }

  // Arrêter l'écoute
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      _updateState(VoiceState.processing);
    }
  }

  // Annuler l'écoute
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speechToText.cancel();
      _isListening = false;
      _updateState(VoiceState.idle);
    }
  }

  // Synthèse vocale
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      throw Exception('VoiceService non initialisé');
    }

    if (_isSpeaking) {
      await stopSpeaking();
    }

    try {
      _updateState(VoiceState.speaking);
      await _flutterTts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la synthèse vocale: $e');
      }
      _errorController.add('Erreur synthèse: $e');
      _updateState(VoiceState.error);
    }
  }

  // Arrêter la synthèse
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      _updateState(VoiceState.idle);
    }
  }

  // Enregistrer un message vocal
  Future<File?> recordAudio({
    Duration? duration,
    String? filename,
  }) async {
    if (!_isInitialized) {
      throw Exception('VoiceService non initialisé');
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${filename ?? 'voice_message_${DateTime.now().millisecondsSinceEpoch}.wav'}');
      
      // TODO: Implémenter l'enregistrement audio
      // Pour l'instant, on retourne null
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'enregistrement audio: $e');
      }
      _errorController.add('Erreur enregistrement: $e');
      return null;
    }
  }

  // Jouer un fichier audio
  Future<void> playAudio(String filePath) async {
    if (!_isInitialized) {
      throw Exception('VoiceService non initialisé');
    }

    try {
      _updateState(VoiceState.speaking);
      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la lecture audio: $e');
      }
      _errorController.add('Erreur lecture: $e');
      _updateState(VoiceState.error);
    }
  }

  // Arrêter la lecture audio
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _updateState(VoiceState.idle);
  }

  // Configuration de la voix
  Future<void> setVoiceSettings({
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    try {
      if (language != null) {
        await _flutterTts.setLanguage(language);
      }
      if (speechRate != null) {
        await _flutterTts.setSpeechRate(speechRate);
      }
      if (volume != null) {
        await _flutterTts.setVolume(volume);
      }
      if (pitch != null) {
        await _flutterTts.setPitch(pitch);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la configuration de la voix: $e');
      }
    }
  }

  // Obtenir les langues disponibles
  Future<List<Map<String, String>>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.cast<Map<String, String>>();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des langues: $e');
      }
      return [];
    }
  }

  // Obtenir les voix disponibles
  Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices.cast<Map<String, String>>();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des voix: $e');
      }
      return [];
    }
  }

  // Vérifier si la reconnaissance vocale est disponible
  Future<bool> isSpeechToTextAvailable() async {
    return await _speechToText.initialize();
  }

  // Vérifier si la synthèse vocale est disponible
  Future<bool> isTextToSpeechAvailable() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Nettoyer les ressources
  Future<void> dispose() async {
    await stopListening();
    await stopSpeaking();
    await stopAudio();
    
    await _speechToText.cancel();
    await _flutterTts.stop();
    await _audioPlayer.dispose();
    
    await _stateController.close();
    await _transcriptionController.close();
    await _confidenceController.close();
    await _errorController.close();
  }
}
