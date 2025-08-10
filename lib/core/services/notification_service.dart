import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jarvis_mobile_app/config/app_config.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Configuration Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration iOS
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configuration générale
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // Demander les permissions
  static Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final DarwinFlutterLocalNotificationsPlugin? iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>();

    bool? androidGranted;
    bool? iosGranted;

    if (androidImplementation != null) {
      androidGranted = await androidImplementation.requestNotificationsPermission();
    }

    if (iosImplementation != null) {
      iosGranted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  // Afficher une notification simple
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'jarvis_channel',
      'Jarvis Notifications',
      channelDescription: 'Notifications de l\'assistant Jarvis',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Notification de rappel de calendrier
  static Future<void> showCalendarReminder({
    required String eventTitle,
    required DateTime eventTime,
    int id = 1,
  }) async {
    final timeUntilEvent = eventTime.difference(DateTime.now());
    final minutesUntilEvent = timeUntilEvent.inMinutes;

    String title;
    String body;

    if (minutesUntilEvent <= 0) {
      title = 'Événement en cours';
      body = '$eventTitle commence maintenant';
    } else if (minutesUntilEvent < 60) {
      title = 'Rappel événement';
      body = '$eventTitle dans $minutesUntilEvent minutes';
    } else {
      final hoursUntilEvent = timeUntilEvent.inHours;
      title = 'Rappel événement';
      body = '$eventTitle dans $hoursUntilEvent heures';
    }

    await showNotification(
      title: title,
      body: body,
      id: id,
      payload: 'calendar_reminder',
    );
  }

  // Notification de routine
  static Future<void> showRoutineReminder({
    required String routineName,
    required String activity,
    int id = 2,
  }) async {
    await showNotification(
      title: 'Routine : $routineName',
      body: 'Il est temps de : $activity',
      id: id,
      payload: 'routine_reminder',
    );
  }

  // Notification de check-in émotionnel
  static Future<void> showEmotionalCheckin({
    required String emotion,
    required String recommendation,
    int id = 3,
  }) async {
    await showNotification(
      title: 'Check-in émotionnel',
      body: 'Vous semblez $emotion. $recommendation',
      id: id,
      payload: 'emotional_checkin',
    );
  }

  // Notification de message reçu
  static Future<void> showMessageNotification({
    required String senderName,
    required String messagePreview,
    int id = 4,
  }) async {
    await showNotification(
      title: 'Message de $senderName',
      body: messagePreview,
      id: id,
      payload: 'new_message',
    );
  }

  // Notification de musique recommandée
  static Future<void> showMusicRecommendation({
    required String songTitle,
    required String artist,
    required String reason,
    int id = 5,
  }) async {
    await showNotification(
      title: 'Musique recommandée',
      body: '$songTitle par $artist - $reason',
      id: id,
      payload: 'music_recommendation',
    );
  }

  // Planifier une notification
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    int id = 100,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'jarvis_scheduled_channel',
      'Jarvis Scheduled Notifications',
      channelDescription: 'Notifications planifiées de l\'assistant Jarvis',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Annuler une notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Annuler toutes les notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Obtenir les notifications en attente
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Vérifier si les notifications sont activées
  static Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }

    return false;
  }
}
