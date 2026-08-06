import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/tasks_provider.dart';

/// タスク完了確認ボトムシート
class CompleteTaskSheet extends ConsumerStatefulWidget {
  final TaskEntity task;
  final String uid;
  final String? groupId;
  final String locale;
  final VoidCallback onCompleted;

  const CompleteTaskSheet({
    super.key,
    required this.task,
    required this.uid,
    required this.groupId,
    required this.locale,
    required this.onCompleted,
  });

  @override
  ConsumerState<CompleteTaskSheet> createState() => _CompleteTaskSheetState();
}

class _CompleteTaskSheetState extends ConsumerState<CompleteTaskSheet> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(taskNotifierProvider.notifier)
          .completeTask(widget.task.taskId);
      if (mounted) {
        Navigator.pop(context);
        widget.onCompleted();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '完了にする',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Gap(16),
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            Text(
              'このタスクを完了として記録します。',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const Gap(24),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: AppTheme.accentColor,
                    ),
                    child: const Text(
                      '完了にする',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
