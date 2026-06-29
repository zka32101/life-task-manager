import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// RevenueCat 初期化 Provider
// ---------------------------------------------------------------------------

/// RevenueCat SDK を初期化する。
/// ログイン済みユーザーがいる場合のみ呼ばれる。
final revenueCatInitProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final apiKey = Platform.isAndroid
      ? AppConstants.revenueCatApiKeyAndroid
      : AppConstants.revenueCatApiKeyIos;

  await Purchases.configure(PurchasesConfiguration(apiKey)..appUserID = user.uid);
});

// ---------------------------------------------------------------------------
// Offerings / Package Provider
// ---------------------------------------------------------------------------

/// RevenueCat の Offerings を取得し、最初のパッケージを返す。
/// `null` は取得失敗またはパッケージが存在しない場合。
final revenueCatPackageProvider = FutureProvider<Package?>((ref) async {
  // 初期化が完了していることを確認
  await ref.watch(revenueCatInitProvider.future);

  final offerings = await Purchases.getOfferings();
  final current = offerings.current;
  if (current == null) return null;

  // 招待ユーザー向けのパッケージを優先、なければ lifetime パッケージ、
  // それもなければ先頭のパッケージを使用する。
  final packages = current.availablePackages;
  if (packages.isEmpty) return null;

  return packages.firstWhere(
    (p) => p.storeProduct.identifier == AppConstants.productIdInvited,
    orElse: () => packages.firstWhere(
      (p) =>
          p.storeProduct.identifier == AppConstants.productIdAndroid ||
          p.storeProduct.identifier == AppConstants.productIdIos,
      orElse: () => packages.first,
    ),
  );
});

// ---------------------------------------------------------------------------
// PurchaseNotifier
// ---------------------------------------------------------------------------

/// 購入・復元操作の状態を管理する StateNotifier。
class PurchaseNotifier extends StateNotifier<AsyncValue<void>> {
  PurchaseNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  // -----------------------------------------------------------------------
  // 購入
  // -----------------------------------------------------------------------

  /// [package] を購入する。
  ///
  /// 成功した場合は Firestore の `users/{uid}` を更新する。
  /// `PurchasesErrorCode.purchaseCancelledError` はユーザーによるキャンセル
  /// とみなし、エラーとして扱わない。
  Future<void> purchasePackage(Package package) async {
    state = const AsyncValue.loading();

    try {
      final result = await Purchases.purchasePackage(package);
      await _updateFirestoreIfPurchased(result.customerInfo);
      state = const AsyncValue.data(null);
    } on PlatformException catch (e, st) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        // キャンセルは正常な操作なので loading を解除するだけ
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, st);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // -----------------------------------------------------------------------
  // 復元
  // -----------------------------------------------------------------------

  /// 過去の購入を復元する。
  ///
  /// 購入済みと確認できた場合は Firestore を更新する。
  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final customerInfo = await Purchases.restorePurchases();
      await _updateFirestoreIfPurchased(customerInfo);
    });
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  /// `lifetime_access` エンタイトルメントがアクティブであれば
  /// Firestore の users/{uid} を更新する。
  Future<void> _updateFirestoreIfPurchased(CustomerInfo customerInfo) async {
    final entitlement =
        customerInfo.entitlements.all[AppConstants.entitlementId];
    if (entitlement == null || !entitlement.isActive) return;

    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final platform = Platform.isAndroid ? 'android' : 'ios';

    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update({
      'isPaid': true,
      'purchaseType': 'lifetime',
      'purchasedAt': Timestamp.now(),
      'iapPlatform': platform,
      'iapTransactionId':
          customerInfo.latestExpirationDate?.toString() ?? '',
    });
  }
}

/// [PurchaseNotifier] の StateNotifierProvider。
final purchaseNotifierProvider =
    StateNotifierProvider<PurchaseNotifier, AsyncValue<void>>((ref) {
  return PurchaseNotifier(ref);
});
