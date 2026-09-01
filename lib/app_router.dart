import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/notifications/data/notification_service.dart';
import 'features/notifications/presentation/screens/notification_center_screen.dart';
import 'core/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/setup/presentation/screens/setup_wizard_screen.dart';
import 'features/tasks/presentation/screens/home_screen.dart';
import 'features/tasks/presentation/screens/task_add_edit_screen.dart';
import 'features/tasks/presentation/screens/task_detail_screen.dart';
import 'features/tasks/presentation/screens/task_search_screen.dart';
import 'features/groups/presentation/screens/group_screen.dart';
import 'features/groups/presentation/screens/group_detail_screen.dart';
import 'features/groups/presentation/screens/invitation_accept_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/settings/presentation/screens/exclusion_items_screen.dart';
import 'features/settings/presentation/screens/language_screen.dart';
import 'features/paywall/presentation/screens/paywall_screen.dart';
import 'features/history/presentation/screens/history_screen.dart';
import 'features/scan/presentation/screens/document_scan_screen.dart';
import 'features/family/presentation/screens/family_monitor_screen.dart';
import 'features/family/presentation/screens/family_tasks_screen.dart';
import 'features/help/presentation/screens/app_guide_screen.dart';

/// 通知タップ時のナビゲーションに使うキー
final navigatorKey = GlobalKey<NavigatorState>();

// ---------------------------------------------------------------------------
// ルートパラメータ検証ヘルパー
// ---------------------------------------------------------------------------

/// パラメータの安全な抽出と検証
class _RouteParams {
  /// pathParameter から ID を安全に抽出（空文字列チェック付き）
  static String? extractId(Map<String, String> params, String key) {
    final value = params[key];
    return (value != null && value.isNotEmpty) ? value : null;
  }

  /// queryParameter から文字列を安全に抽出
  static String? extractString(Map<String, String> queryParams, String key) {
    final value = queryParams[key];
    return (value != null && value.isNotEmpty) ? value : null;
  }

  /// queryParameter からboolを安全に抽出
  static bool extractBool(Map<String, String> queryParams, String key) {
    return queryParams[key]?.toLowerCase() == 'true';
  }

  /// queryParameter から整数を安全に抽出
  static int extractInt(Map<String, String> queryParams, String key,
      {int defaultValue = 0}) {
    return int.tryParse(queryParams[key] ?? '') ?? defaultValue;
  }
}

/// アプリルーター（GoRouter）
///
/// ルート一覧:
///   /login         - ログイン画面
///   /onboarding    - オンボーディング（初回）
///   /home          - ホーム（タスク一覧）
///   /tasks/new     - タスク追加
///   /tasks/:id     - タスク詳細
///   /tasks/:id/edit - タスク編集
///   /groups        - グループ一覧
///   /notifications - 通知センター
///   /settings      - 設定
///   /paywall       - ペイウォール
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      // ナビゲーション自体をスキップすべきパスは exclude
      final isOnAuthPath = state.matchedLocation == '/login' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/paywall';

      // Riverpod のコンテキストが使用できないため、ここでは簡易実装
      // 詳細なロジックは SplashScreen で実装
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/setup',
        name: 'setup',
        builder: (context, state) => const SetupWizardScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const TaskSearchScreen(),
      ),
      GoRoute(
        path: '/tasks/new',
        name: 'task-new',
        builder: (context, state) {
          final groupId = _RouteParams.extractString(
            state.uri.queryParameters,
            'groupId',
          );
          return TaskAddEditScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/tasks/:id',
        name: 'task-detail',
        builder: (context, state) {
          final taskId = _RouteParams.extractId(state.pathParameters, 'id');
          final groupId = _RouteParams.extractString(
            state.uri.queryParameters,
            'groupId',
          );

          if (taskId == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('無効なタスクID'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('ホームに戻る'),
                    ),
                  ],
                ),
              ),
            );
          }

          return TaskDetailScreen(taskId: taskId, groupId: groupId);
        },
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        name: 'task-edit',
        builder: (context, state) {
          final taskId = _RouteParams.extractId(state.pathParameters, 'id');

          if (taskId == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('無効なタスクID'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('ホームに戻る'),
                    ),
                  ],
                ),
              ),
            );
          }

          return TaskAddEditScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/groups',
        name: 'groups',
        builder: (context, state) => const GroupScreen(),
        routes: [
          GoRoute(
            path: ':groupId',
            name: 'group-detail',
            builder: (context, state) {
              final groupId = _RouteParams.extractId(
                state.pathParameters,
                'groupId',
              );

              if (groupId == null) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('無効なグループID'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/groups'),
                          child: const Text('グループに戻る'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GroupDetailScreen(groupId: groupId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/invitation/:code',
        name: 'invitation-accept',
        builder: (context, state) {
          final code = _RouteParams.extractId(state.pathParameters, 'code');

          if (code == null || code.isEmpty) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('無効な招待コード'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('ホームに戻る'),
                    ),
                  ],
                ),
              ),
            );
          }

          return InvitationAcceptScreen(invitationCode: code);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'exclusions',
            name: 'exclusion-items',
            builder: (context, state) => const ExclusionItemsScreen(),
          ),
          GoRoute(
            path: 'language',
            name: 'language-select',
            builder: (context, state) => const LanguageScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const DocumentScanScreen(),
      ),
      GoRoute(
        path: '/family',
        name: 'family',
        builder: (context, state) => const FamilyMonitorScreen(),
      ),
      GoRoute(
        path: '/family/tasks',
        name: 'family-tasks',
        builder: (context, state) {
          final uid = _RouteParams.extractString(
            state.uri.queryParameters,
            'uid',
          );
          final name = _RouteParams.extractString(
                state.uri.queryParameters,
                'name',
              ) ??
              '家族';

          if (uid == null || uid.isEmpty) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('ユーザーID が指定されていません'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/family'),
                      child: const Text('家族管理に戻る'),
                    ),
                  ],
                ),
              ),
            );
          }

          return FamilyTasksScreen(targetUid: uid, name: name);
        },
      ),
      GoRoute(
        path: '/guide',
        name: 'guide',
        builder: (context, state) {
          final isFirst = _RouteParams.extractBool(
            state.uri.queryParameters,
            'first',
          );
          return AppGuideScreen(isFirstLaunch: isFirst);
        },
      ),
      GoRoute(
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) {
          final isForced = _RouteParams.extractBool(
            state.uri.queryParameters,
            'forced',
          );
          final remaining = _RouteParams.extractInt(
            state.uri.queryParameters,
            'remaining',
          );

          return PaywallScreen(
            isForced: isForced,
            remainingDays: remaining,
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              const Text(
                'ページが見つかりません',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'リクエストされたページ: ${state.matchedLocation}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('ホームに戻る'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // 通知タップ → GoRouter でナビゲーション（パラメータ検証付き）
  NotificationService.onNotificationTap = (screen, taskId, groupId) {
    try {
      // タスクIDが有効な場合
      if (taskId != null && taskId.isNotEmpty) {
        final params = {'id': taskId};
        final queryParams = <String, String>{};

        if (groupId != null && groupId.isNotEmpty) {
          queryParams['groupId'] = groupId;
        }

        router.goNamed(
          'task-detail',
          pathParameters: params,
          queryParameters: queryParams,
        );
      } else if (screen == 'notifications') {
        router.goNamed('notifications');
      } else {
        router.goNamed('home');
      }
    } catch (e) {
      // ナビゲーション失敗時はホームに遷移
      router.goNamed('home');
    }
  };

  return router;
});
