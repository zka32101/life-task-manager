import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_task_manager/features/auth/data/models/user_preferences_model.dart';
import 'package:life_task_manager/features/auth/domain/entities/user_preferences_entity.dart';
import 'package:life_task_manager/features/auth/presentation/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// users/{uid}/preferences/main をリアルタイム監視
// ---------------------------------------------------------------------------

/// users/{uid}/preferences/main ドキュメントをリアルタイム監視する StreamProvider
final userPreferencesProvider = StreamProvider<UserPreferencesEntity?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('preferences')
      .doc('main')
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return UserPreferencesModel.fromFirestore(doc).toEntity();
  });
});

// ---------------------------------------------------------------------------
// PreferencesNotifier — 通知設定の更新
// ---------------------------------------------------------------------------

class PreferencesNotifier extends StateNotifier<AsyncValue<void>> {
  PreferencesNotifier(this._uid) : super(const AsyncValue.data(null));

  final String? _uid;

  /// preferences/main ドキュメントを部分更新する（merge: true）
  Future<void> updatePreferences(Map<String, dynamic> data) async {
    if (_uid == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('preferences')
          .doc('main')
          .set(
            {...data, 'updatedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
    });
  }
}

final preferencesNotifierProvider =
    StateNotifierProvider<PreferencesNotifier, AsyncValue<void>>((ref) {
  final user = ref.watch(currentUserProvider);
  return PreferencesNotifier(user?.uid);
});
