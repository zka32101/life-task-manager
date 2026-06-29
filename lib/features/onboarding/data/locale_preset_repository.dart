import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

/// ロケール別推奨タスクの Firestore リポジトリ
///
/// locale_presets/{locale}/recommended_tasks/ を読み込む。
/// データが存在しない場合は空リストを返す。
class LocalePresetRepository {
  final FirebaseFirestore _db;

  LocalePresetRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// 指定ロケールの推奨タスクを全件取得
  Future<List<LocalePresetTask>> getRecommendedTasks(String locale) async {
    try {
      final snap = await _db
          .collection(AppConstants.localePresetsCollection)
          .doc(locale)
          .collection(AppConstants.recommendedTasksSubCollection)
          .orderBy('categoryId')
          .get();

      return snap.docs.map((doc) {
        final data = doc.data();
        return LocalePresetTask(
          taskId: doc.id,
          title: data['title'] as String? ?? '',
          categoryId: data['categoryId'] as String? ?? 'other',
          categoryLabels: (data['categoryLabels'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          recurrenceType: data['recurrenceType'] as String? ?? 'yearly',
          notes: data['notes'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

class LocalePresetTask {
  final String taskId;
  final String title;
  final String categoryId;
  final List<String> categoryLabels;
  final String recurrenceType;
  final String? notes;

  const LocalePresetTask({
    required this.taskId,
    required this.title,
    required this.categoryId,
    required this.categoryLabels,
    required this.recurrenceType,
    this.notes,
  });
}

// ---------------------------------------------------------------------------
// Riverpod Providers
// ---------------------------------------------------------------------------

final localePresetRepositoryProvider = Provider<LocalePresetRepository>((_) {
  return LocalePresetRepository();
});

/// 指定ロケールの推奨タスク一覧
final recommendedTasksProvider =
    FutureProvider.family<List<LocalePresetTask>, String>((ref, locale) async {
  return ref.watch(localePresetRepositoryProvider).getRecommendedTasks(locale);
});
