import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

enum VoiceState { idle, listening, processing, speaking }

class VoiceService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final Logger _logger = Logger();

  VoiceState _state = VoiceState.idle;
  bool _isAvailable = false;
  String _lastWords = '';
  String _currentText = '';

  VoiceState get state => _state;
  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;
  String get currentText => _currentText;

  Future<void> initialize() async {
    try {
      // Demander les permissions
      await Permission.microphone.request();
      await Permission.speech.request();

      // Initialiser la reconnaissance vocale
      _isAvailable = await _speechToText.initialize(
        onError: (error) {
          _logger.e('Erreur reconnaissance vocale: $error');
          _setState(VoiceState.idle);
        },
        onStatus: (status) {
          _logger.d('Statut reconnaissance vocale: $status');
          if (status == 'done') {
            _setState(VoiceState.idle);
          }
        },
      );

      // Configurer la synthèse vocale
      await _flutterTts.setLanguage("fr-FR");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _setState(VoiceState.speaking);
      });

      _flutterTts.setCompletionHandler(() {
        _setState(VoiceState.idle);
      });

      _flutterTts.setErrorHandler((msg) {
        _logger.e('Erreur synthèse vocale: $msg');
        _setState(VoiceState.idle);
      });

      notifyListeners();
    } catch (e) {
      _logger.e('Erreur lors de l\'initialisation vocale: $e');
    }
  }

  Future<void> startListening() async {
    if (!_isAvailable) {
      _logger.w('Reconnaissance vocale non disponible');
      return;
    }

    try {
      _setState(VoiceState.listening);
      _lastWords = '';
      _currentText = '';

      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _currentText = result.recognizedWords;
          
          if (result.finalResult) {
            _setState(VoiceState.processing);
          }
          
          notifyListeners();
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'fr_FR',
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      _logger.e('Erreur lors du démarrage de l\'écoute: $e');
      _setState(VoiceState.idle);
    }
  }

  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _setState(VoiceState.idle);
    } catch (e) {
      _logger.e('Erreur lors de l\'arrêt de l\'écoute: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      _setState(VoiceState.speaking);
      await _flutterTts.speak(text);
    } catch (e) {
      _logger.e('Erreur lors de la synthèse vocale: $e');
      _setState(VoiceState.idle);
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      _setState(VoiceState.idle);
    } catch (e) {
      _logger.e('Erreur lors de l\'arrêt de la synthèse: $e');
    }
  }

  void _setState(VoiceState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearText() {
    _lastWords = '';
    _currentText = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
