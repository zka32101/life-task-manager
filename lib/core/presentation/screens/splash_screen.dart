import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../utils/trial_service.dart';
import '../../../features/auth/domain/entities/user_profile_entity.dart';

/// スプラッシュ画面
///
/// 起動時の認証・アクセス状態チェックを行い、適切な画面へ遷移する。
///
/// フロー:
///   Firebase Auth チェック
///     未ログイン        → /login
///     ログイン済み
///       profile 取得
///         isActive      → /home
///         期限切れ      → /paywall?forced=true
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouter の redirect で認証チェックが完了するまでの間、
    // ロゴ + インジケータを表示する。
    // 初回フレーム後に認証チェックを実行し、適切な画面へ遷移する。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate(context);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ロゴ
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
              const Gap(24),
              Text(
                'LifeTask Manager',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.5,
                ),
              ),
              const Gap(8),
              Text(
                '人生の大事なタスクを、もれなく管理',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const Gap(48),
              const CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkAuthAndNavigate(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!context.mounted) return;

    try {
      // 1. Firebase Auth チェック
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (context.mounted) context.goNamed('login');
        return;
      }

      // 2. Firestore からプロフィール取得
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!context.mounted) return;

      if (!doc.exists || doc.data() == null) {
        // プロフィール未作成 → オンボーディングへ
        context.goNamed('onboarding');
        return;
      }

      // 3. プロフィールデータを変換
      final data = doc.data()!;

      // セットアップウィザード完了チェック
      final setupCompleted = data['setupCompleted'] as bool? ?? false;
      if (!setupCompleted) {
        // setup 未完了 → セットアップウィザードへ
        context.goNamed('setup');
        return;
      }

      final jsonData = _convertTimestamps(data);
      // Ensure required fields exist
      if (!jsonData.containsKey('uid')) jsonData['uid'] = user.uid;

      final profile = UserProfileEntity.fromJson(jsonData);

      // 4. アクセス状態チェック
      final status = UserAccessStatus.evaluate(
        isPaid: profile.isPaid,
        trialStartAt: profile.trialStartAt,
      );

      if (!context.mounted) return;

      switch (status) {
        case UserAccessStatus.trialActive:
        case UserAccessStatus.paid:
          context.goNamed('home');
        case UserAccessStatus.trialExpired:
          context.goNamed(
            'paywall',
            queryParameters: {'forced': 'true', 'remaining': '0'},
          );
      }
    } catch (e, st) {
      // あらゆるエラー（Exception/Error）はログイン画面へ
      debugPrint('SplashScreen navigate error: $e\n$st');
      if (context.mounted) {
        context.goNamed('login');
      }
    }
  }

  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.value is Timestamp) {
        result[entry.key] = (entry.value as Timestamp).toDate().toIso8601String();
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}
