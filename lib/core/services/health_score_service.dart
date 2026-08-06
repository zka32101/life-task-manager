import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_task_manager/features/tasks/domain/entities/task_entity.dart';

/// カテゴリ別の健康スコア計算・保存
///
/// カテゴリは categoryPath の先頭セグメント（house/vehicle/health/finance）で判定する。
/// 期限超過タスク1件につき-15点、最低0点。
class HealthScoreService {
  static const categories = ['house', 'vehicle', 'health', 'finance'];

  static Map<String, int> calculate(List<TaskEntity> tasks) {
    final scores = {for (final c in categories) c: 100};
    final now = DateTime.now();

    for (final task in tasks) {
      if (task.isArchived) continue;
      if (!task.nextDueAt.isBefore(now)) continue;

      final category = task.categoryPath.split('/').first;
      if (!scores.containsKey(category)) continue;

      scores[category] = (scores[category]! - 15).clamp(0, 100);
    }

    return scores;
  }

  static int overallScore(Map<String, int> scores) {
    if (scores.isEmpty) return 100;
    final total = scores.values.fold(0, (sum, v) => sum + v);
    return (total / scores.length).round();
  }

  static Future<void> saveScores(Map<String, int> scores) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('preferences')
        .doc(uid)
        .set({'healthScores': scores}, SetOptions(merge: true));
  }
}
