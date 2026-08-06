import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/tasks_provider.dart';
import '../../domain/entities/task_entity.dart';

/// タスク追加・編集画面（設計書 extended-data-design.md の UI 仕様準拠）
///
/// 機能:
/// - タイトル（50文字以内）
/// - カテゴリ（階層選択：最大3階層）
/// - 次回予定日
/// - 繰り返し設定
/// - リマインダー（0/1/3/7/14日前）
/// - 対象外設定（永続 or 期限付き）
/// - メモ、費用
class TaskAddEditScreen extends ConsumerStatefulWidget {
  final String? taskId;   // null のとき新規作成
  final String? groupId;  // null のとき個人タスク

  const TaskAddEditScreen({super.key, this.taskId, this.groupId});

  bool get isEditing => taskId != null;

  @override
  ConsumerState<TaskAddEditScreen> createState() => _TaskAddEditScreenState();
}

class _TaskAddEditScreenState extends ConsumerState<TaskAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  // カテゴリ選択状態（階層）
  String? _level0CategoryId;
  String? _level1CategoryId;
  String? _level2CategoryId;

  // スケジュール
  DateTime _nextDueAt = DateTime.now().add(const Duration(days: 30));
  String _recurrenceType = 'yearly';
  int? _recurrenceValue;
  String? _recurrenceUnit;
  int _reminderDaysBefore = AppConstants.defaultReminderDays;

  // 対象外設定
  bool _isExcluded = false;
  bool _isTemporaryExclusion = false;
  DateTime? _exclusionValidUntil;
  final _exclusionReasonController = TextEditingController();

  // コスト
  final _costController = TextEditingController();
  String _costCurrency = 'JPY';

  // 対象外設定の折りたたみ状態
  bool _advancedExpanded = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _exclusionReasonController.dispose();
    _costController.dispose();
    super.dispose();
  }

  // カテゴリ（AppCategories から一元参照）
  static final _level0Categories = AppCategories.level0;
  static final _level1Categories = AppCategories.level1;
  static final _level2Categories = AppCategories.level2;

  String get _selectedCategoryId {
    return _level2CategoryId ??
        _level1CategoryId ??
        _level0CategoryId ??
        '';
  }

  String get _selectedCategoryPath {
    final parts = <String>[];
    if (_level0CategoryId != null) {
      final cat = _level0Categories.firstWhere(
          (c) => c.$1 == _level0CategoryId,
          orElse: () => ('', '', ''));
      if (cat.$3.isNotEmpty) parts.add(cat.$3);
    }
    if (_level1CategoryId != null) {
      final cats = _level1Categories[_level0CategoryId] ?? [];
      final cat = cats.firstWhere(
          (c) => c.$1 == _level1CategoryId,
          orElse: () => ('', '', ''));
      if (cat.$3.isNotEmpty) parts.add(cat.$3);
    }
    if (_level2CategoryId != null) {
      final cats = _level2Categories[_level1CategoryId] ?? [];
      final cat = cats.firstWhere(
          (c) => c.$1 == _level2CategoryId,
          orElse: () => ('', ''));
      if (cat.$2.isNotEmpty) parts.add(cat.$2);
    }
    return parts.join(' > ');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('カテゴリを選択してください')),
      );
      return;
    }

    final uid = ref.read(currentUserProvider)?.uid ?? '';
    final now = DateTime.now();
    final categoryLabels = _buildCategoryLabels();
    final isGroupTask = widget.groupId != null;
    final task = TaskEntity(
      taskId: widget.taskId ?? '',
      title: _titleController.text.trim(),
      categoryId: _selectedCategoryId,
      categoryPath: _buildCategoryPath().join('/'),
      categoryLabels: categoryLabels,
      nextDueAt: _nextDueAt,
      recurrenceType: _recurrenceType,
      recurrenceValue: _recurrenceValue,
      recurrenceUnit: _recurrenceUnit,
      reminderDaysBefore: _reminderDaysBefore,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      cost: _costController.text.trim().isEmpty
          ? null
          : double.tryParse(_costController.text.trim()),
      costCurrency: _costController.text.trim().isEmpty ? null : _costCurrency,
      groupId: widget.groupId,
      assigneeUids: isGroupTask ? [uid] : [],
      isArchived: false,
      isLocalePreset: false,
      isGroupTask: isGroupTask,
      createdByUid: uid,
      updatedByUid: uid,
      createdAt: now,
      updatedAt: now,
    );

    try {
      if (widget.isEditing) {
        await ref.read(taskNotifierProvider.notifier).updateTask(
          widget.taskId!,
          {
            'title': task.title,
            'categoryId': task.categoryId,
            'categoryPath': task.categoryPath,
            'categoryLabels': task.categoryLabels,
            'nextDueAt': task.nextDueAt.toIso8601String(),
            'recurrenceType': task.recurrenceType,
            if (task.recurrenceValue != null)
              'recurrenceValue': task.recurrenceValue,
            if (task.recurrenceUnit != null)
              'recurrenceUnit': task.recurrenceUnit,
            'reminderDaysBefore': task.reminderDaysBefore,
            if (task.notes != null) 'notes': task.notes,
            if (task.cost != null) 'cost': task.cost,
            if (task.costCurrency != null) 'costCurrency': task.costCurrency,
            'updatedByUid': uid,
          },
        );
      } else {
        await ref.read(taskNotifierProvider.notifier).createTask(task);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    }
  }

  List<String> _buildCategoryPath() {
    final path = <String>[];
    if (_level0CategoryId != null) path.add(_level0CategoryId!);
    if (_level1CategoryId != null) path.add(_level1CategoryId!);
    if (_level2CategoryId != null) path.add(_level2CategoryId!);
    return path;
  }

  List<String> _buildCategoryLabels() {
    final labels = <String>[];
    if (_level0CategoryId != null) {
      final cat = _level0Categories
          .firstWhere((c) => c.$1 == _level0CategoryId, orElse: () => ('', '', ''));
      if (cat.$3.isNotEmpty) labels.add(cat.$3);
    }
    if (_level1CategoryId != null) {
      final level1 = _level1Categories[_level0CategoryId] ?? [];
      final cat = level1.firstWhere(
          (c) => c.$1 == _level1CategoryId,
          orElse: () => ('', '', ''));
      if (cat.$3.isNotEmpty) labels.add(cat.$3);
    }
    if (_level2CategoryId != null) {
      final level2 = _level2Categories[_level1CategoryId] ?? [];
      final cat = level2.firstWhere(
          (c) => c.$1 == _level2CategoryId,
          orElse: () => ('', ''));
      if (cat.$2.isNotEmpty) labels.add(cat.$2);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'タスクを編集' : 'タスクを追加'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // タイトル（自動フォーカス）
            TextFormField(
              controller: _titleController,
              autofocus: !widget.isEditing,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                hintText: '例: 確定申告',
                counterText: '',
              ),
              maxLength: AppConstants.titleMaxLength,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'タイトルを入力してください';
                return null;
              },
            ),
            const Gap(20),

            // カテゴリ選択
            _CategorySelector(
              level0Categories: _level0Categories,
              level1Categories: _level1Categories,
              level2Categories: _level2Categories,
              selectedLevel0: _level0CategoryId,
              selectedLevel1: _level1CategoryId,
              selectedLevel2: _level2CategoryId,
              selectedPath: _selectedCategoryPath,
              onLevel0Changed: (id) => setState(() {
                _level0CategoryId = id;
                _level1CategoryId = null;
                _level2CategoryId = null;
              }),
              onLevel1Changed: (id) => setState(() {
                _level1CategoryId = id;
                _level2CategoryId = null;
              }),
              onLevel2Changed: (id) => setState(() => _level2CategoryId = id),
            ),
            const Gap(20),

            // 次回予定日 + クイック選択
            _DateField(
              label: '次回予定日',
              date: _nextDueAt,
              onChanged: (d) => setState(() => _nextDueAt = d),
            ),
            const Gap(8),
            _QuickDateChips(
              onSelect: (d) => setState(() => _nextDueAt = d),
            ),
            const Gap(16),

            // 繰り返し
            _RecurrenceField(
              value: _recurrenceType,
              onChanged: (v) => setState(() => _recurrenceType = v),
            ),
            const Gap(16),

            // リマインダー
            DropdownButtonFormField<int>(
              value: _reminderDaysBefore,
              decoration: InputDecoration(
                labelText: 'リマインダー',
                helperText: '期限の何日前に通知を受け取るか',
                prefixIcon: const Icon(Icons.notifications_outlined, size: 20),
              ),
              items: AppConstants.reminderOptions
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d == 0 ? '当日（朝9時）' : '$d日前（朝9時）'),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _reminderDaysBefore = v);
              },
            ),
            const Gap(20),

            // メモ
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'メモ（任意）',
                counterText: '',
              ),
              maxLength: AppConstants.notesMaxLength,
              maxLines: 3,
            ),
            const Gap(16),

            // 費用
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _costController,
                    decoration: InputDecoration(
                      labelText: '費用（任意）',
                      helperText: '放置した際の損失リスク額',
                      prefixText: _costCurrency == 'JPY' ? '¥ ' : null,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Gap(8),
                SizedBox(
                  width: 80,
                  child: DropdownButtonFormField<String>(
                    value: _costCurrency,
                    decoration: const InputDecoration(labelText: '通貨'),
                    items: const [
                      DropdownMenuItem(value: 'JPY', child: Text('JPY')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _costCurrency = v);
                    },
                  ),
                ),
              ],
            ),
            const Gap(20),

            // 詳細設定（折りたたみ）
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                initiallyExpanded: _advancedExpanded || _isExcluded,
                onExpansionChanged: (v) => setState(() => _advancedExpanded = v),
                leading: Icon(Icons.tune_rounded,
                    color: Colors.grey.shade500, size: 20),
                title: Text(
                  '詳細設定',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                children: [
                  _ExclusionSection(
                    isExcluded: _isExcluded,
                    isTemporary: _isTemporaryExclusion,
                    validUntil: _exclusionValidUntil,
                    reasonController: _exclusionReasonController,
                    onExcludedChanged: (v) =>
                        setState(() => _isExcluded = v ?? false),
                    onTemporaryChanged: (v) =>
                        setState(() => _isTemporaryExclusion = v ?? false),
                    onValidUntilChanged: (d) =>
                        setState(() => _exclusionValidUntil = d),
                  ),
                ],
              ),
            ),
            const Gap(24),

            // 保存ボタン
            FilledButton(
              onPressed: _save,
              child: Text(widget.isEditing ? '更新する' : '追加する'),
            ),
            const Gap(8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// クイック期限選択チップ
// ─────────────────────────────────────────────────────────
class _QuickDateChips extends StatelessWidget {
  final ValueChanged<DateTime> onSelect;

  const _QuickDateChips({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final options = [
      ('来月', DateTime(now.year, now.month + 1, now.day)),
      ('3ヶ月後', DateTime(now.year, now.month + 3, now.day)),
      ('半年後', DateTime(now.year, now.month + 6, now.day)),
      ('1年後', DateTime(now.year + 1, now.month, now.day)),
      ('2年後', DateTime(now.year + 2, now.month, now.day)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ActionChip(
              label: Text(opt.$1, style: const TextStyle(fontSize: 12)),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              visualDensity: VisualDensity.compact,
              onPressed: () => onSelect(opt.$2),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final List<(String, String, String)> level0Categories;
  final Map<String, List<(String, String, String)>> level1Categories;
  final Map<String, List<(String, String)>> level2Categories;
  final String? selectedLevel0;
  final String? selectedLevel1;
  final String? selectedLevel2;
  final String selectedPath;
  final ValueChanged<String?> onLevel0Changed;
  final ValueChanged<String?> onLevel1Changed;
  final ValueChanged<String?> onLevel2Changed;

  const _CategorySelector({
    required this.level0Categories,
    required this.level1Categories,
    required this.level2Categories,
    required this.selectedLevel0,
    required this.selectedLevel1,
    required this.selectedLevel2,
    required this.selectedPath,
    required this.onLevel0Changed,
    required this.onLevel1Changed,
    required this.onLevel2Changed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'カテゴリ（階層選択）',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const Gap(8),
        // 第1階層
        _CategoryLevel(
          label: '大カテゴリ',
          items: level0Categories.map((c) {
            // 大カテゴリには常に絵文字を付ける（アイコン文字が既にある場合は使用）
            final emoji = c.$2.isNotEmpty ? c.$2 : _categoryEmoji(c.$1);
            return (c.$1, '$emoji ${c.$3}');
          }).toList(),
          selectedId: selectedLevel0,
          onChanged: onLevel0Changed,
        ),
        // 第2階層
        if (selectedLevel0 != null &&
            level1Categories.containsKey(selectedLevel0)) ...[
          const Gap(8),
          _CategoryLevel(
            label: '中カテゴリ',
            items: (level1Categories[selectedLevel0] ?? [])
                .map((c) => (c.$1, '${c.$2} ${c.$3}'))
                .toList(),
            selectedId: selectedLevel1,
            onChanged: onLevel1Changed,
          ),
        ],
        // 第3階層
        if (selectedLevel1 != null &&
            level2Categories.containsKey(selectedLevel1)) ...[
          const Gap(8),
          _CategoryLevel(
            label: '小カテゴリ',
            items: (level2Categories[selectedLevel1] ?? [])
                .map((c) => (c.$1, c.$2))
                .toList(),
            selectedId: selectedLevel2,
            onChanged: onLevel2Changed,
          ),
        ],
        // 選択中パス表示
        if (selectedPath.isNotEmpty) ...[
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '選択中: $selectedPath',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String _categoryEmoji(String categoryId) {
  switch (categoryId.toLowerCase()) {
    case 'house': return '🏠';
    case 'vehicle': return '🚗';
    case 'health': return '🏥';
    case 'finance': return '💴';
    default: return '📋';
  }
}

class _CategoryLevel extends StatelessWidget {
  final String label;
  final List<(String, String)> items;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _CategoryLevel({
    required this.label,
    required this.items,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const Gap(4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items
              .map(
                (item) => ChoiceChip(
                  label: Text(item.$2, style: const TextStyle(fontSize: 13)),
                  selected: selectedId == item.$1,
                  onSelected: (selected) =>
                      onChanged(selected ? item.$1 : null),
                  selectedColor: AppTheme.primaryLight,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        child: Text(
          '${date.year}年${date.month}月${date.day}日',
        ),
      ),
    );
  }
}

class _RecurrenceField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _RecurrenceField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('none', '繰り返しなし'),
      ('weekly', '毎週'),
      ('biweekly', '隔週'),
      ('monthly', '毎月'),
      ('quarterly', '四半期ごと'),
      ('yearly', '毎年'),
    ];

    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(labelText: '繰り返し'),
      items: items
          .map((i) => DropdownMenuItem(value: i.$1, child: Text(i.$2)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _ExclusionSection extends StatelessWidget {
  final bool isExcluded;
  final bool isTemporary;
  final DateTime? validUntil;
  final TextEditingController reasonController;
  final ValueChanged<bool?> onExcludedChanged;
  final ValueChanged<bool?> onTemporaryChanged;
  final ValueChanged<DateTime?> onValidUntilChanged;

  const _ExclusionSection({
    required this.isExcluded,
    required this.isTemporary,
    required this.validUntil,
    required this.reasonController,
    required this.onExcludedChanged,
    required this.onTemporaryChanged,
    required this.onValidUntilChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: isExcluded,
            onChanged: onExcludedChanged,
            title: const Text('対象外にする'),
            subtitle: const Text('このタスクをホーム画面から非表示にします'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (isExcluded) ...[
            const Divider(),
            const Gap(8),
            RadioListTile<bool>(
              value: false,
              groupValue: isTemporary,
              onChanged: (v) => onTemporaryChanged(v == true ? true : false),
              title: const Text('期限なし（永続に対象外）'),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<bool>(
              value: true,
              groupValue: isTemporary,
              onChanged: (v) => onTemporaryChanged(v == true ? true : false),
              title: const Text('期限付き'),
              contentPadding: EdgeInsets.zero,
            ),
            if (isTemporary) ...[
              const Gap(8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: validUntil ?? DateTime.now().add(const Duration(days: 90)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  onValidUntilChanged(picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '対象外期間の終了日',
                    suffixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(
                    validUntil == null
                        ? '日付を選択'
                        : '${validUntil!.year}年${validUntil!.month}月${validUntil!.day}日',
                  ),
                ),
              ),
            ],
            const Gap(12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: '対象外の理由（任意）',
                hintText: '例: 会社員なので不要',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
