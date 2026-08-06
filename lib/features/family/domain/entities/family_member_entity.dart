/// 家族（共有グループのメンバー）
///
/// グループ機能のメンバー情報を集約した表示用エンティティ。
/// Firestore への保存は行わず、実行時に groups コレクションから合成する。
class FamilyMemberEntity {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final List<String> groupIds;
  final List<String> groupNames;

  const FamilyMemberEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.groupIds,
    required this.groupNames,
  });
}
