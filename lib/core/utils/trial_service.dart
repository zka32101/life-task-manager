import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

/// トライアル状態の管理サービス（設計書 v3.1）
class TrialService {
  static const int trialDays = AppConstants.trialDays;

  /// トライアルが有効かどうか（isPaid または トライアル期間内）
  bool isActive({
    required bool isPaid,
    required DateTime trialStartAt,
  }) {
    if (isPaid) return true;
    final elapsed = DateTime.now().difference(trialStartAt);
    return elapsed.inDays < trialDays;
  }

  /// 残り日数（isPaid の場合は -1 = 無制限）
  int remainingDays({
    required bool isPaid,
    required DateTime trialStartAt,
  }) {
    if (isPaid) return -1;
    final elapsed = DateTime.now().difference(trialStartAt);
    return (trialDays - elapsed.inDays).clamp(0, trialDays);
  }

  /// トライアル期限切れかどうか
  bool isExpired({
    required bool isPaid,
    required DateTime trialStartAt,
  }) {
    if (isPaid) return false;
    return !isActive(isPaid: isPaid, trialStartAt: trialStartAt);
  }

  /// 警告バナーを表示すべきか（残 N 日以下）
  bool shouldShowWarning({
    required bool isPaid,
    required DateTime trialStartAt,
    int warningDays = AppConstants.trialWarningDays,
  }) {
    if (isPaid) return false;
    final remaining = remainingDays(isPaid: isPaid, trialStartAt: trialStartAt);
    return remaining > 0 && remaining <= warningDays;
  }

  /// Firestore Timestamp から isActive チェック
  bool isActiveFromTimestamp({
    required bool isPaid,
    required Timestamp trialStartAt,
  }) {
    return isActive(
      isPaid: isPaid,
      trialStartAt: trialStartAt.toDate(),
    );
  }
}

/// ユーザー状態（設計書 v3.1 マトリクス）
enum UserAccessStatus {
  /// トライアル中: isPaid=false, trialStartAt から 30日未満
  trialActive,

  /// トライアル期限切れ: isPaid=false, trialStartAt から 30日以上
  trialExpired,

  /// 有料: isPaid=true
  paid;

  bool get hasAccess =>
      this == UserAccessStatus.trialActive || this == UserAccessStatus.paid;

  static UserAccessStatus evaluate({
    required bool isPaid,
    required DateTime trialStartAt,
  }) {
    if (isPaid) return UserAccessStatus.paid;
    final elapsed = DateTime.now().difference(trialStartAt);
    if (elapsed.inDays < AppConstants.trialDays) {
      return UserAccessStatus.trialActive;
    }
    return UserAccessStatus.trialExpired;
  }
}
