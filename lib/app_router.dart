import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// アプリルーター（GoRouter）
///
/// ルート一覧:
///   /login       - ログイン画面
///   /onboarding  - オンボーディング（初回）
///   /home        - ホーム（タスク一覧）
///   /tasks/new   - タスク追加
///   /tasks/:id   - タスク詳細
///   /tasks/:id/edit - タスク編集
///   /groups      - グループ一覧
///   /settings    - 設定
///   /paywall     - ペイウォール
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // TODO: auth state を確認してリダイレクト
      // - 未ログイン → /login
      // - 初回ログイン → /onboarding
      // - トライアル期限切れ → /paywall
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
          final groupId = state.uri.queryParameters['groupId'];
          return TaskAddEditScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/tasks/:id',
        name: 'task-detail',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          final groupId = state.uri.queryParameters['groupId'];
          return TaskDetailScreen(taskId: taskId, groupId: groupId);
        },
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        name: 'task-edit',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
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
              final groupId = state.pathParameters['groupId']!;
              return GroupDetailScreen(groupId: groupId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/invitation/:code',
        name: 'invitation-accept',
        builder: (context, state) {
          final code = state.pathParameters['code']!;
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
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) {
          final isForced = state.uri.queryParameters['forced'] == 'true';
          final remaining =
              int.tryParse(state.uri.queryParameters['remaining'] ?? '0') ?? 0;
          return PaywallScreen(
            isForced: isForced,
            remainingDays: remaining,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
