import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      debugPrint('Notification tapped: $payload');
    }
  }

  Future<void> showNewOrderNotification(String orderNumber) async {
    const androidDetails = AndroidNotificationDetails(
      'new_orders',
      'الطلبات الجديدة',
      channelDescription: 'إشعارات الطلبات الجديدة',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'طلب جديد',
      'وصل طلب جديد: $orderNumber',
      details,
    );
  }

  Future<void> showOrderReadyNotification(String orderNumber) async {
    const androidDetails = AndroidNotificationDetails(
      'orders_ready',
      'الطلبات الجاهزة',
      channelDescription: 'إشعارات الطلبات الجاهزة للاستلام',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'طلبك جاهز',
      'طلبك $orderNumber جاهز للاستلام',
      details,
    );
  }

  // TODO: add notification grouping by order status
  Future<void> showOverloadNotification(String stationName) async {
    const androidDetails = AndroidNotificationDetails(
      'station_overload',
      'ازدحام المحطات',
      channelDescription: 'تنبيهات ازدحام محطات الطباعة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '⚠️ ازدحام',
      'المحطة $stationName مزدحمة',
      details,
    );
  }

  void playNewOrderSound() {
    if (!kIsWeb) {
      debugPrint('New order sound triggered');
    }
  }
}
