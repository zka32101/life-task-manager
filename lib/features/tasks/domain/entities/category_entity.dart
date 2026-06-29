import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_entity.freezed.dart';
part 'category_entity.g.dart';

@freezed
sealed class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    required String categoryId,
    required String name,
    String? description,
    String? emoji,
    String? parentCategoryId,
    required String path,
    @Default(0) int level,
    @Default(0) int order,
    @Default(false) bool isDefault,
    @Default(0) int taskCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CategoryEntity;

  factory CategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoryEntityFromJson(json);
}

class CategoryNode {
  final CategoryEntity category;
  final List<CategoryNode> children;

  const CategoryNode({
    required this.category,
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;

  CategoryNode copyWith({
    CategoryEntity? category,
    List<CategoryNode>? children,
  }) {
    return CategoryNode(
      category: category ?? this.category,
      children: children ?? this.children,
    );
  }
}
