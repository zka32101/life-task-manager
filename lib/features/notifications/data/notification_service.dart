import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Firebase Cloud Messaging + ローカル通知サービス
class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 通知タップ時のナビゲーション（app_router 側から登録する）
  static void Function(String? screen, String? taskId, String? groupId)?
      onNotificationTap;

  // Android 通知チャンネル
  static const _defaultChannel = AndroidNotificationChannel(
    'lifetask_default',
    'LifeTask リマインダー',
    description: 'タスクの期限リマインダー',
    importance: Importance.high,
  );

  static const _legalChannel = AndroidNotificationChannel(
    'lifetask_legal',
    '緊急アラート',
    description: '法定期限・高額損失リスクのアラート',
    importance: Importance.max,
  );

  static const _lossAversionChannel = AndroidNotificationChannel(
    'lifetask_loss_aversion',
    '損失防止アラート',
    description: '放置すると損失が発生するタスクのアラート',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    // タイムゾーン初期化
    tz_data.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
    }

    // Android チャンネル作成
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_defaultChannel);
    await androidPlugin?.createNotificationChannel(_legalChannel);
    await androidPlugin?.createNotificationChannel(_lossAversionChannel);

    // iOS/Android 初期設定
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // FCM 権限リクエスト
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _registerFcmToken();
      _fcm.onTokenRefresh.listen(_saveFcmToken);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleFcmTap);

      // アプリが terminated 状態から通知で起動した場合
      final initial = await _fcm.getInitialMessage();
      if (initial != null) _handleFcmTap(initial);
    }
  }

  // ─────────────────────────────────────────────────────────
  // FCM トークン管理
  // ─────────────────────────────────────────────────────────
  static Future<void> _registerFcmToken() async {
    final token = await _fcm.getToken();
    if (token != null) await _saveFcmToken(token);
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

  // ─────────────────────────────────────────────────────────
  // フォアグラウンド FCM
  // ─────────────────────────────────────────────────────────
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final isLegal = message.data['notificationType'] == 'LEGAL_DEADLINE';
    final channelId = isLegal ? 'lifetask_legal' : 'lifetask_default';
    final channelName = isLegal ? '緊急アラート' : 'LifeTask リマインダー';

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: isLegal ? Importance.max : Importance.high,
          priority: isLegal ? Priority.max : Priority.high,
          styleInformation: BigTextStyleInformation(notification.body ?? ''),
        ),
        iOS: const DarwinNotificationDetails(sound: 'default'),
      ),
      payload: jsonEncode(message.data),
    );

    // Firestore にログ保存（通知センター用）
    await _logNotification(
      title: notification.title ?? '',
      body: notification.body ?? '',
      data: message.data,
    );
  }

  // ─────────────────────────────────────────────────────────
  // 通知タップ処理
  // ─────────────────────────────────────────────────────────
  static void _handleFcmTap(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      debugPrint('Notification tap parse error: $e');
    }
  }

  static void _navigateFromData(Map<String, dynamic> data) {
    final screen = data['screen'] as String?;
    final taskId = data['taskId'] as String?;
    final groupId = data['groupId'] as String?;
    onNotificationTap?.call(screen, taskId, groupId);
  }

  // ─────────────────────────────────────────────────────────
  // ローカル通知スケジュール（タスクリマインダー）
  // ─────────────────────────────────────────────────────────

  /// タスクの期限リマインダーをスケジュール
  ///
  /// [taskId] Firestore タスク ID（重複防止に使用）
  /// [title] タスクタイトル
  /// [scheduledTime] 通知を鳴らす日時（端末のローカル時間）
  /// [cost] 費用（損失リスク表示用、任意）
  static Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required DateTime scheduledTime,
    double? cost,
  }) async {
    // 過去の日時はスキップ
    if (scheduledTime.isBefore(DateTime.now())) return;

    final id = _idFromTaskId(taskId);
    await _localNotifications.cancel(id); // 既存の同タスク通知をキャンセル

    final body = cost != null && cost > 0
        ? '放置すると${_fmtCost(cost)}の損失リスクがあります'
        : '期限が近づいています。確認しましょう';

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      '📋 $title',
      body,
      tzScheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          cost != null && cost > 0
              ? 'lifetask_loss_aversion'
              : 'lifetask_default',
          cost != null && cost > 0 ? '損失防止アラート' : 'LifeTask リマインダー',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(sound: 'default'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'screen': 'task_detail', 'taskId': taskId}),
    );

    debugPrint('Scheduled notification for "$title" at $scheduledTime');
  }

  /// タスクの通知をキャンセル
  static Future<void> cancelTaskReminder(String taskId) async {
    await _localNotifications.cancel(_idFromTaskId(taskId));
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // ─────────────────────────────────────────────────────────
  // 通知センター用 Firestore ログ
  // ─────────────────────────────────────────────────────────
  static Future<void> _logNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notificationLogs')
          .add({
        'title': title,
        'body': body,
        'taskId': data?['taskId'],
        'screen': data?['screen'],
        'notificationType': data?['notificationType'] ?? 'reminder',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Notification log error: $e');
    }
  }

  /// ローカル通知送信時にもログを残す（通知センターに表示するため）
  static Future<void> logLocalNotification({
    required String title,
    required String body,
    String? taskId,
    String? notificationType,
  }) async {
    await _logNotification(
      title: title,
      body: body,
      data: {
        'taskId': taskId,
        'screen': taskId != null ? 'task_detail' : null,
        'notificationType': notificationType ?? 'reminder',
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // ヘルパー
  // ─────────────────────────────────────────────────────────
  static int _idFromTaskId(String taskId) => taskId.hashCode.abs() % 100000;

  static String _fmtCost(double cost) => cost >= 10000
      ? '¥${(cost / 10000).toStringAsFixed(1)}万'
      : '¥${cost.toInt()}';
}
