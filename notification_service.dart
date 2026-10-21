import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(initializationSettings);
    
    // طلب إذن الإشعارات
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showSalawatNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'salawat_channel',
      'تذكير الصلاة على النبي',
      channelDescription: 'إشعارات متكررة للصلاة على النبي',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false, // صامت عشان ميزعجش المستخدم
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await _notificationsPlugin.show(
      0,
      'تذكير مبارك 🌟',
      'اللهم صلِّ وسلم على نبينا محمد ﷺ',
      platformChannelSpecifics,
    );
  }
}