import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/trial_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../paywall/presentation/providers/purchase_provider.dart';
import '../../../paywall/presentation/screens/paywall_screen.dart';
import '../../../auth/domain/entities/user_preferences_entity.dart';
import '../providers/preferences_provider.dart';

/// 設定画面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final isPaid = profile?.isPaid ?? false;
    final trialService = TrialService();
    final remainingDays = profile != null
        ? trialService.remainingDays(
            isPaid: profile.isPaid,
            trialStartAt: profile.trialStartAt,
          )
        : AppConstants.trialDays;
    final displayName = profile?.displayName ?? '';
    final email = profile?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          // プロフィール
          _SectionHeader(title: 'アカウント'),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
            title: Text(displayName),
            subtitle: Text(email),
          ),
          const Divider(height: 1),

          // プランステータス
          _SectionHeader(title: 'プラン'),
          ListTile(
            leading: const Icon(Icons.star_rounded, color: AppTheme.primaryColor),
            title: const Text('プラン'),
            subtitle: Text(
              isPaid
                  ? 'LifeTask Manager（購入済み）'
                  : '無料トライアル（残 $remainingDays 日）',
              style: TextStyle(
                color: !isPaid && remainingDays <= AppConstants.trialWarningDays
                    ? AppTheme.warningColor
                    : null,
              ),
            ),
            trailing: isPaid
                ? const Icon(Icons.check_circle_rounded,
                    color: AppTheme.accentColor)
                : FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaywallScreen(
                            isForced: false,
                            remainingDays: remainingDays,
                          ),
                        ),
                      );
                    },
                    child: const Text('今すぐ購入する'),
                  ),
          ),
          const Divider(height: 1),

          // 言語・地域
          _SectionHeader(title: '言語・地域'),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text('言語・地域'),
            subtitle: const Text('日本語（日本）'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.goNamed('language-select'),
          ),
          const Divider(height: 1),

          // 通知設定
          _SectionHeader(title: '通知'),
          const _NotificationSettings(),
          const Divider(height: 1),

          // 対象外設定
          _SectionHeader(title: '対象外に設定したアイテム'),
          ListTile(
            leading: const Icon(Icons.block_rounded),
            title: const Text('対象外アイテム一覧'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.goNamed('exclusion-items'),
          ),
          const Divider(height: 1),

          // サインアウト
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('サインアウト'),
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.goNamed('login');
            },
          ),
          const Divider(height: 1),

          // データ・プライバシー
          _SectionHeader(title: 'データ・プライバシー'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded),
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _launchUrl('https://petitworks.app/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.description_rounded),
            title: const Text('利用規約'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _launchUrl('https://petitworks.app/terms'),
          ),
          ListTile(
            leading:
                Icon(Icons.delete_forever_rounded, color: AppTheme.errorColor),
            title: Text(
              'アカウントを削除',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            onTap: () => _confirmDeleteAccount(context, ref),
          ),
          const Divider(height: 1),

          // アプリ情報
          _SectionHeader(title: 'アプリについて'),
          ListTile(
            leading: const Icon(Icons.info_rounded),
            title: const Text('バージョン'),
            subtitle: const Text('${AppConstants.appVersion}'),
          ),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('購入を復元する'),
            onTap: () async {
              await ref
                  .read(purchaseNotifierProvider.notifier)
                  .restorePurchases();
              final purchaseState = ref.read(purchaseNotifierProvider);
              if (context.mounted) {
                if (purchaseState is AsyncData) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('購入の復元を確認しました。')),
                  );
                } else if (purchaseState is AsyncError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('復元に失敗しました: ${purchaseState.error}'),
                    ),
                  );
                }
              }
            },
          ),
          const Gap(32),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('アカウントを削除'),
        content: const Text(
          'すべてのデータが完全に削除されます。この操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final uid = ref.read(currentUserProvider)?.uid;
                if (uid != null) {
                  // Firestore のユーザーデータ削除（サブコレクションは Cloud Functions で処理）
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .delete();
                }
                // Firebase Auth アカウント削除
                await FirebaseAuth.instance.currentUser?.delete();
                if (context.mounted) context.goNamed('login');
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '削除に失敗しました。再ログインが必要な場合があります: $e'),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NotificationSettings extends ConsumerStatefulWidget {
  const _NotificationSettings();

  @override
  ConsumerState<_NotificationSettings> createState() =>
      _NotificationSettingsState();
}

class _NotificationSettingsState
    extends ConsumerState<_NotificationSettings> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _initialized = false;

  Future<void> _updatePreference(Map<String, dynamic> data) async {
    await ref
        .read(preferencesNotifierProvider.notifier)
        .updatePreferences(data);
  }

  @override
  Widget build(BuildContext context) {
    // Sync local state from Firestore on first load
    ref.listen<AsyncValue<UserPreferencesEntity?>>(
      userPreferencesProvider,
      (_, next) {
        final prefs = next.valueOrNull;
        if (prefs != null && !_initialized) {
          setState(() {
            _pushEnabled = prefs.notificationEnabled;
            _emailEnabled = prefs.emailNotificationEnabled;
            _soundEnabled = prefs.soundEnabled;
            _vibrationEnabled = prefs.vibrationEnabled;
            _initialized = true;
          });
        }
      },
    );

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_rounded),
          title: const Text('プッシュ通知'),
          value: _pushEnabled,
          onChanged: (v) {
            setState(() => _pushEnabled = v);
            _updatePreference({'notificationEnabled': v});
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.email_rounded),
          title: const Text('メール通知'),
          value: _emailEnabled,
          onChanged: (v) {
            setState(() => _emailEnabled = v);
            _updatePreference({'emailNotificationEnabled': v});
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.volume_up_rounded),
          title: const Text('通知音'),
          value: _soundEnabled,
          onChanged: (v) {
            setState(() => _soundEnabled = v);
            _updatePreference({'soundEnabled': v});
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.vibration_rounded),
          title: const Text('バイブレーション'),
          value: _vibrationEnabled,
          onChanged: (v) {
            setState(() => _vibrationEnabled = v);
            _updatePreference({'vibrationEnabled': v});
          },
        ),
      ],
    );
  }
}
