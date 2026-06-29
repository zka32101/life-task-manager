import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// ログイン画面（Google Sign-In のみ）
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final isNewUser =
          await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      if (mounted) {
        // 新規ユーザー → オンボーディング → セットアップウィザード → ホーム
        // 既存ユーザー → ホーム
        context.goNamed(isNewUser ? 'onboarding' : 'home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログインに失敗しました: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // ロゴ・タイトル
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const Gap(24),
                    Text(
                      'LifeTask Manager',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const Gap(8),
                    Text(
                      '人生の大事なタスクを、もれなく管理',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // 機能紹介
              _FeatureRow(
                icon: Icons.home_rounded,
                title: '住宅・車・保険・健康',
                subtitle: '大事なタスクを一元管理',
              ),
              const Gap(16),
              _FeatureRow(
                icon: Icons.group_rounded,
                title: 'グループ共有',
                subtitle: '家族・チームで共同管理',
              ),
              const Gap(16),
              _FeatureRow(
                icon: Icons.notifications_rounded,
                title: 'スマートリマインダー',
                subtitle: '期限前に自動でお知らせ',
              ),
              const Spacer(flex: 2),
              // トライアル案内
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppTheme.primaryColor),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30日間 無料トライアル',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            '全機能フルアクセス・クレカ不要',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),
              // Google ログインボタン
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.login,
                          size: 20,
                        ),
                      ),
                      label: const Text('Google でログイン'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
              const Gap(16),
              // 利用規約
              Text(
                'ログインすることで、利用規約とプライバシーポリシーに同意したものとみなします。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                textAlign: TextAlign.center,
              ),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const Gap(16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
