import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الإشعارات
  await NotificationService().init();
  
  runApp(const SalawatApp());
}

// ==========================================
// 1. إعداد الثيم (نفس الكود الموجود في صورتك)
// ==========================================
class AppTheme {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color primary = Color(0xFF1F6FEB);
  static const Color success = Color(0xFF2EA043);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textMuted = Color(0xFF8B949E);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          surface: surface,
          onPrimary: Colors.white,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

// ==========================================
// 2. خدمة الإشعارات (Notification Service)
// ==========================================
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(initializationSettings);
    
    // طلب إذن الإشعارات لأندرويد 13 فما فوق
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
      playSound: false, // جعلناه صامتاً حتى لا يزعج المستخدم كل 10 دقائق
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

// ==========================================
// 3. التطبيق الرئيسي
// ==========================================
class SalawatApp extends StatelessWidget {
  const SalawatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مواقيت وتذكير',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

// ==========================================
// 4. الشاشة الرئيسية
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _salawatTimer;
  bool _isReminderActive = false;
  int _notificationCount = 0;

  // محاكاة لمواقيت الصلاة (لاحقاً يمكنك جلبها من API أو حزمة Adhan)
  final Map<String, String> prayerTimes = {
    'الفجر': '04:30 ص',
    'الظهر': '12:15 م',
    'العصر': '03:40 م',
    'المغرب': '06:50 م',
    'العشاء': '08:20 م',
  };

  void _toggleReminder(bool value) {
    setState(() {
      _isReminderActive = value;
    });

    if (value) {
      // تشغيل العداد كل 10 دقائق
      _salawatTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
        NotificationService.showSalawatNotification();
        setState(() {
          _notificationCount++;
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تفعيل التذكير كل 10 دقائق')),
      );
    } else {
      // إيقاف العداد
      _salawatTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إيقاف التذكير')),
      );
    }
  }

  @override
  void dispose() {
    _salawatTimer?.cancel(); // إيقاف العداد عند إغلاق الشاشة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت وتذكير'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // كارت مواقيت الصلاة
            Card(
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مواقيت الصلاة اليوم',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    ...prayerTimes.entries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: const TextStyle(fontSize: 16)),
                              Text(entry.value, style: const TextStyle(fontSize: 16, color: AppTheme.success, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // كارت التذكير بالصلاة على النبي
            Card(
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.primary, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.favorite, color: AppTheme.success, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'تذكير الصلاة على النبي ﷺ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'سيقوم التطبيق بإرسال إشعار تذكيري كل 10 دقائق (يعمل أثناء فتح التطبيق فقط في هذا النموذج).',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('تفعيل التذكير التلقائي'),
                      value: _isReminderActive,
                      activeColor: AppTheme.primary,
                      onChanged: _toggleReminder,
                    ),
                    if (_isReminderActive)
                      Text(
                        'تم إرسال $_notificationCount إشعارات حتى الآن',
                        style: const TextStyle(color: AppTheme.primary),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // زر تجربة الإشعار فوراً
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.showSalawatNotification();
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('تجربة إرسال إشعار الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}