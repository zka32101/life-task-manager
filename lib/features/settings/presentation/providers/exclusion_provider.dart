import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_task_manager/core/constants/app_constants.dart';
import 'package:life_task_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:life_task_manager/features/settings/domain/entities/exclusion_entity.dart';

// ---------------------------------------------------------------------------
// Firestore helper
// ---------------------------------------------------------------------------

CollectionReference<Map<String, dynamic>> _excludedItemsRef(String uid) {
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection(AppConstants.excludedItemsSubCollection);
}

// ---------------------------------------------------------------------------
// Firestore → Entity 変換
// ---------------------------------------------------------------------------

ExclusionEntity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return ExclusionEntity(
    excludeId: doc.id,
    itemId: data['itemId'] as String? ?? '',
    itemType: data['itemType'] as String? ?? '',
    itemName: data['itemName'] as String? ?? '',
    reason: data['reason'] as String?,
    excludedAt: (data['excludedAt'] as Timestamp).toDate(),
    validUntil: (data['validUntil'] as Timestamp?)?.toDate(),
    isTemporaryExclusion: data['isTemporaryExclusion'] as bool? ?? false,
  );
}

// ---------------------------------------------------------------------------
// 対象外一覧（全件）
// ---------------------------------------------------------------------------

/// users/{uid}/excluded_items を全件リアルタイム監視
final allExclusionsProvider = StreamProvider<List<ExclusionEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return _excludedItemsRef(user.uid)
      .orderBy('excludedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(_fromDoc).toList());
});

/// 現在有効な対象外設定のみ返す（validUntil が null または未来のもの）
final activeExclusionsProvider = StreamProvider<List<ExclusionEntity>>((ref) {
  final allAsync = ref.watch(allExclusionsProvider);
  return allAsync.when(
    data: (list) {
      final now = DateTime.now();
      final active = list
          .where((e) => e.validUntil == null || e.validUntil!.isAfter(now))
          .toList();
      return Stream.value(active);
    },
    loading: () => Stream.value([]),
    error: (e, st) => Stream.error(e, st),
  );
});

// ---------------------------------------------------------------------------
// ExclusionNotifier — 追加 / 削除
// ---------------------------------------------------------------------------

class ExclusionNotifier extends StateNotifier<AsyncValue<void>> {
  ExclusionNotifier(this._uid) : super(const AsyncValue.data(null));

  final String? _uid;

  String get _requireUid {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    return uid;
  }

  /// 対象外設定を追加する
  Future<void> addExclusion({
    required String itemId,
    required String itemType,
    required String itemName,
    String? reason,
    DateTime? validUntil,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final uid = _requireUid;
      await _excludedItemsRef(uid).add({
        'itemId': itemId,
        'itemType': itemType,
        'itemName': itemName,
        'reason': reason,
        'excludedAt': FieldValue.serverTimestamp(),
        'validUntil': validUntil != null ? Timestamp.fromDate(validUntil) : null,
        'isTemporaryExclusion': validUntil != null,
      });
    });
  }

  /// 対象外設定を削除する
  Future<void> removeExclusion(String excludeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _excludedItemsRef(_requireUid).doc(excludeId).delete();
    });
  }
}

final exclusionNotifierProvider =
    StateNotifierProvider<ExclusionNotifier, AsyncValue<void>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ExclusionNotifier(user?.uid);
});
