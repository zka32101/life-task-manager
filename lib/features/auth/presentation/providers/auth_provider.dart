import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_task_manager/core/constants/app_constants.dart';
import 'package:life_task_manager/core/utils/trial_service.dart';
import 'package:life_task_manager/features/auth/data/datasources/auth_datasource.dart';
import 'package:life_task_manager/features/auth/data/models/user_profile_model.dart';
import 'package:life_task_manager/features/auth/domain/entities/user_profile_entity.dart';

// ---------------------------------------------------------------------------
// DataSource Provider
// ---------------------------------------------------------------------------

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return AuthDatasourceImpl();
});

// ---------------------------------------------------------------------------
// Firebase Auth 状態
// ---------------------------------------------------------------------------

/// Firebase Auth の認証状態ストリーム
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authDatasourceProvider).authStateChanges();
});

/// 現在ログイン中のユーザー（同期取得）
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// ---------------------------------------------------------------------------
// UserProfile
// ---------------------------------------------------------------------------

/// users/{uid} をリアルタイム監視する StreamProvider
final userProfileProvider = StreamProvider<UserProfileEntity?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return UserProfileModel.fromFirestore(doc).toEntity();
      });
});

// ---------------------------------------------------------------------------
// アクセス状態
// ---------------------------------------------------------------------------

/// isPaid / trialStartAt から UserAccessStatus を算出
final userAccessStatusProvider = Provider<UserAccessStatus>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) {
      if (profile == null) return UserAccessStatus.trialActive;
      return UserAccessStatus.evaluate(
        isPaid: profile.isPaid,
        trialStartAt: profile.trialStartAt,
      );
    },
    loading: () => UserAccessStatus.trialActive,
    error: (e, st) => UserAccessStatus.trialActive,
  );
});

/// トライアル残日数（paid = -1、期限切れ = 0）
final remainingTrialDaysProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) {
      if (profile == null) return AppConstants.trialDays;
      final service = TrialService();
      return service.remainingDays(
        isPaid: profile.isPaid,
        trialStartAt: profile.trialStartAt,
      );
    },
    loading: () => AppConstants.trialDays,
    error: (e, st) => 0,
  );
});

// ---------------------------------------------------------------------------
// AuthNotifier — ログイン/ログアウト操作
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._datasource) : super(const AsyncValue.data(null));

  final AuthDatasource _datasource;

  /// Google Sign-In を実行する。
  /// 初回ログイン時は Firestore にユーザープロフィールを作成する。
  /// 戻り値: true = 新規ユーザー, false = 既存ユーザー
  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    bool isNewUser = false;
    state = await AsyncValue.guard(() async {
      final credential = await _datasource.signInWithGoogle();
      final user = credential.user;
      if (user == null) throw Exception('No user returned from Google sign-in');

      // 既存プロフィールを確認し、なければ新規作成
      final existing = await _datasource.getUserProfile(user.uid);
      if (existing == null) {
        isNewUser = true;
        final now = DateTime.now();
        final profile = UserProfileModel(
          uid: user.uid,
          displayName: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          trialStartAt: now,
          lastActiveAt: now,
          createdAt: now,
          updatedAt: now,
        );
        await _datasource.createUserProfile(user.uid, profile);
      } else {
        // lastActiveAt を更新
        await _datasource.updateUserProfile(user.uid, {
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
      }
    });
    final currentState = state;
    if (currentState is AsyncError) throw currentState.error;
    return isNewUser;
  }

  /// サインアウトする。
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _datasource.signOut();
    });
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authDatasourceProvider));
});
