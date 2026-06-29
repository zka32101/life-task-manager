import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/trial_service.dart';
import '../providers/purchase_provider.dart';

/// ペイウォール画面（設計書 v3.1 の3パターン対応）
///
/// パターン1: トライアル中（残 N 日） → 「あとで」ボタンあり
/// パターン2: トライアル期限切れ（強制）→ 「あとで」ボタンなし
/// パターン3: 招待ユーザー・期限切れ → 招待割引価格（半額）
class PaywallScreen extends ConsumerStatefulWidget {
  /// isForced=true のとき強制表示（「あとで」なし）
  final bool isForced;
  final int remainingDays;
  final bool isInvitedUser;

  const PaywallScreen({
    super.key,
    required this.isForced,
    required this.remainingDays,
    this.isInvitedUser = false,
  });

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isPurchasing = false;
  bool _isRestoring = false;

  bool get _showLater => !widget.isForced && widget.remainingDays > 0;

  Future<void> _purchase() async {
    setState(() => _isPurchasing = true);
    try {
      final package = await ref.read(revenueCatPackageProvider.future);
      if (package == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('購入パッケージが見つかりませんでした。'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      await ref
          .read(purchaseNotifierProvider.notifier)
          .purchasePackage(package);

      final purchaseState = ref.read(purchaseNotifierProvider);
      if (!mounted) return;

      if (purchaseState is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('購入が完了しました！'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
        Navigator.of(context).pop();
      } else if (purchaseState is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('購入に失敗しました: ${purchaseState.error}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('購入に失敗しました: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restorePurchase() async {
    setState(() => _isRestoring = true);
    try {
      await ref.read(purchaseNotifierProvider.notifier).restorePurchases();

      final purchaseState = ref.read(purchaseNotifierProvider);
      if (!mounted) return;

      if (purchaseState is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('購入の復元を確認しました。')),
        );
      } else if (purchaseState is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('復元に失敗しました: ${purchaseState.error}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('復元に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  void _dismiss() {
    if (!widget.isForced) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isForced,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(40),
                // アイコン
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: widget.isForced
                          ? AppTheme.errorColor.withOpacity(0.1)
                          : AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      widget.isForced
                          ? Icons.lock_rounded
                          : Icons.star_rounded,
                      color: widget.isForced
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                      size: 48,
                    ),
                  ),
                ),
                const Gap(24),
                // タイトル
                Center(
                  child: Text(
                    widget.isForced ? '無料期間が終了しました' : 'LifeTask Manager',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(12),
                // サブタイトル
                Center(
                  child: Text(
                    widget.isForced
                        ? '引き続き使うには購入が必要です'
                        : '${AppConstants.priceDisplay} で永遠に使える',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (!widget.isForced && widget.remainingDays > 0) ...[
                  const Gap(8),
                  Center(
                    child: Text(
                      '無料トライアル残 ${widget.remainingDays} 日',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // 機能リスト
                _FeatureList(isForced: widget.isForced),
                const Spacer(),
                // 招待割引バナー
                if (widget.isInvitedUser) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 24)),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '招待特典',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '\$${AppConstants.appPrice}',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    '→ \$${AppConstants.invitedPrice}（半額）',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                ],
                // 購入ボタン
                _isPurchasing
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton(
                        onPressed: _purchase,
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.isForced
                              ? AppTheme.primaryColor
                              : AppTheme.primaryColor,
                        ),
                        child: Text(
                          widget.isInvitedUser
                              ? '\$${AppConstants.invitedPrice} で購入する（招待特典）'
                              : '${AppConstants.priceDisplay}（\$${AppConstants.appPrice}）で購入する',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                const Gap(12),
                // あとでボタン（トライアル中のみ）
                if (_showLater)
                  TextButton(
                    onPressed: _dismiss,
                    child: Text(
                      'あとで（${widget.remainingDays}日後に期限切れ）',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                // 購入を復元する
                _isRestoring
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: _restorePurchase,
                        child: const Text('購入を復元する'),
                      ),
                // 利用規約
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        '買い切り型。月額費用なし。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade400,
                            ),
                      ),
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse('https://petitworks.app/terms');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Text(
                          '利用規約',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                      Text(
                        ' / ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade400,
                            ),
                      ),
                      InkWell(
                        onTap: () async {
                          final uri =
                              Uri.parse('https://petitworks.app/privacy');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Text(
                          'プライバシーポリシー',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  final bool isForced;

  const _FeatureList({required this.isForced});

  @override
  Widget build(BuildContext context) {
    final features = [
      ('✅', '住宅・車・保険など全カテゴリ管理'),
      ('✅', 'グループ共有・家族で共同管理'),
      ('✅', 'スマートリマインダー（法定締切・季節）'),
      ('✅', '多言語対応（日・英・中・独・仏など）'),
      ('✅', '買い切り型・月額費用なし'),
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(f.$1, style: const TextStyle(fontSize: 16)),
                  const Gap(12),
                  Text(
                    f.$2,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
