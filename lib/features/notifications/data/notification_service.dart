import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Cloud Messaging + ローカル通知サービス（設計書準拠）
class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android 通知チャンネル
  static const _defaultChannel = AndroidNotificationChannel(
    'lifetask_default',
    'LifeTask Manager Notifications',
    description: 'LifeTask Manager からのお知らせ',
    importance: Importance.high,
  );

  static const _legalChannel = AndroidNotificationChannel(
    'lifetask_legal',
    'Legal Deadline Reminders',
    description: '法定締切のリマインダー',
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    // Android チャンネル作成
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_legalChannel);

    // iOS/Android 初期設定
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // FCM 権限リクエスト
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _registerFcmToken();

      // トークン更新リスナー
      _fcm.onTokenRefresh.listen(_saveFcmToken);

      // フォアグラウンド通知
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // バックグラウンドからアプリ起動
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    }
  }

  static Future<void> _registerFcmToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveFcmToken(token);
    }
  }

  static Future<void> _saveFcmToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('preferences')
          .doc(user.uid)
          .set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FCM token save error: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final isLegal = message.data['notificationType'] == 'LEGAL_DEADLINE';
    final channelId = isLegal ? 'lifetask_legal' : 'lifetask_default';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      isLegal ? 'Legal Deadline Reminders' : 'LifeTask Manager Notifications',
      importance: isLegal ? Importance.max : Importance.high,
      priority: isLegal ? Priority.max : Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(sound: 'default');

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      debugPrint('Notification tap error: $e');
    }
  }

  static void _navigateFromData(Map<String, dynamic> data) {
    final screen = data['screen'] as String?;
    final taskId = data['taskId'] as String?;
    final groupId = data['groupId'] as String?;

    // GoRouter でのナビゲーションは main.dart の navigatorKey を通じて行う
    // この実装は AppRouter と連携する
    debugPrint('Navigate to: $screen, taskId: $taskId, groupId: $groupId');
  }

  /// ローカル通知スケジュール（タスクリマインダー用）
  static Future<void> scheduleTaskReminder({
    required int id,
    required String taskId,
    required String title,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'lifetask_default',
      'LifeTask Manager Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      id,
      '📋 タスクのリマインダー',
      title,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode({'screen': 'task_detail', 'taskId': taskId}),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}
