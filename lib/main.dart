import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jarvis_mobile_app/config/app_config.dart';
import 'package:jarvis_mobile_app/config/theme.dart';
import 'package:jarvis_mobile_app/core/providers/providers.dart';
import 'package:jarvis_mobile_app/core/router/app_router.dart';
import 'package:jarvis_mobile_app/core/services/notification_service.dart';
import 'package:jarvis_mobile_app/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation Hive
  await Hive.initFlutter();
  await StorageService.initialize();
  
  // Initialisation notifications
  await NotificationService.initialize();
  
  // Configuration app
  await AppConfig.initialize();
  
  runApp(
    const ProviderScope(
      child: JarvisApp(),
    ),
  );
}

class JarvisApp extends ConsumerWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'Jarvis Assistant IA',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
