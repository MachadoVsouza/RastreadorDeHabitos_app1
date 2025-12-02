import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final location = tz.getLocation('America/Sao_Paulo');
    tz.setLocalLocation(location);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
      },
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      
      await androidPlugin.requestExactAlarmsPermission();
      
      print('✅ Permissões de notificação solicitadas');
    }
  }

  static Future<void> scheduleHabitNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
      
      print('📅 Agendando notificação:');
      print('   ID: $id');
      print('   Título: $title');
      print('   Horário: ${tzScheduledTime.toString()}');
      print('   Timezone: ${tz.local.name}');
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel',
            'Habit Reminders',
            channelDescription: 'Notifications for habit reminders',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('✅ Notificação agendada com sucesso!');
    } catch (e, stackTrace) {
      print('❌ ERRO ao agendar notificação: $e');
      print('Stack: $stackTrace');
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> scheduleTestNotification() async {
    print('🧪 Tentando mostrar notificação IMEDIATA...');
    
    try {
      await _notifications.show(
        999,
        '🧪 Teste Imediato',
        'Notificação instantânea funcionando!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel',
            'Habit Reminders',
            channelDescription: 'Notifications for habit reminders',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            showWhen: true,
          ),
        ),
      );
      print('✅ Notificação imediata enviada!');
      
      final now = tz.TZDateTime.now(tz.local);
      final testTime = now.add(const Duration(seconds: 5));
      
      print('⏰ Agendando segunda notificação em 5 segundos...');
      print('   Horário atual: ${now.toString()}');
      print('   Horário agendado: ${testTime.toString()}');
      
      await _notifications.zonedSchedule(
        998,
        '⏰ Teste Agendado',
        'Esta notificação foi agendada!',
        testTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel',
            'Habit Reminders',
            channelDescription: 'Notifications for habit reminders',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('✅ Notificação agendada com sucesso!');
    } catch (e, stackTrace) {
      print('❌ ERRO ao criar notificação: $e');
      print('Stack: $stackTrace');
    }
  }

  static Future<void> printPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    print('\n📋 Notificações Pendentes: ${pending.length}');
    for (final notification in pending) {
      print('   ID: ${notification.id} - ${notification.title}');
    }
    print('');
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
