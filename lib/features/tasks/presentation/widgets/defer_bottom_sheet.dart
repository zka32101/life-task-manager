import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/task_entity.dart';

/// 延期ボトムシート
class DeferBottomSheet extends ConsumerStatefulWidget {
  final TaskEntity task;
  final Function(DateTime newDueAt, String? reason) onDefer;

  const DeferBottomSheet({
    super.key,
    required this.task,
    required this.onDefer,
  });

  @override
  ConsumerState<DeferBottomSheet> createState() => _DeferBottomSheetState();
}

class _DeferBottomSheetState extends ConsumerState<DeferBottomSheet> {
  late DateTime _selectedDate;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  static const _quickOptions = [
    ('+1日', 1),
    ('+3日', 3),
    ('+1週', 7),
    ('+2週', 14),
    ('+1ヶ月', 30),
  ];

  @override
  void initState() {
    super.initState();
    // デフォルトは +1日
    _selectedDate = widget.task.nextDueAt.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _applyQuickOption(int days) {
    setState(() {
      _selectedDate = widget.task.nextDueAt.add(Duration(days: days));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ja'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final reason = _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim();
      await widget.onDefer(_selectedDate, reason);
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool _isQuickSelected(int days) {
    final expected = widget.task.nextDueAt.add(Duration(days: days));
    return _selectedDate.year == expected.year &&
        _selectedDate.month == expected.month &&
        _selectedDate.day == expected.day;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final locale = profile != null
        ? '${profile.language}-${profile.country}'
        : 'ja-JP';
    final dateLabel = AppDateUtils.formatDate(_selectedDate, locale);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '延期する',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Gap(20),

            // クイック選択ボタン
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickOptions.map((option) {
                final (label, days) = option;
                final isSelected = _isQuickSelected(days);
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => _applyQuickOption(days),
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const Gap(20),

            // カスタム日付
            Text(
              'カスタム日付を選択:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const Gap(8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.primaryColor.withOpacity(0.04),
                ),
                child: Row(
                  children: [
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const Gap(20),

            // 理由（任意）
            Text(
              '理由（任意）:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const Gap(8),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: '延期の理由を入力...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),
            const Gap(24),

            // 延期するボタン
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: const Text(
                      '延期する',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
