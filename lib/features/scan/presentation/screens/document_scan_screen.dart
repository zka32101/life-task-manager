import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../data/services/document_scan_service.dart';

enum _ScanState { idle, extracting, review, saving }

/// 書類カメラ画面
///
/// 書類を撮影/選択 → Claude Vision で期限・金額・タイトルを自動抽出 → 確認・編集 → タスク保存
class DocumentScanScreen extends ConsumerStatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  ConsumerState<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends ConsumerState<DocumentScanScreen> {
  _ScanState _state = _ScanState.idle;
  File? _image;
  String? _error;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _dueDate;
  String _categoryId = 'other';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _state = _ScanState.extracting;
      _error = null;
    });

    try {
      final bytes = await _image!.readAsBytes();
      final result = await DocumentScanService.extractFromImage(bytes);
      setState(() {
        _titleController.text = result.title ?? '';
        _amountController.text = result.amount?.toStringAsFixed(0) ?? '';
        _dueDate = result.dueDate;
        _state = _ScanState.review;
      });
    } catch (e) {
      setState(() {
        _error = '抽出に失敗しました: $e';
        _state = _ScanState.idle;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ja'),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルと期限日を入力してください')),
      );
      return;
    }

    setState(() => _state = _ScanState.saving);

    final uid = ref.read(currentUserProvider)?.uid ?? '';
    final now = DateTime.now();
    final category = AppCategories.level0.firstWhere(
      (c) => c.$1 == _categoryId,
      orElse: () => ('other', '📋', 'その他'),
    );

    final task = TaskEntity(
      taskId: '',
      title: _titleController.text.trim(),
      categoryId: _categoryId,
      categoryPath: _categoryId,
      categoryLabels: [category.$3],
      nextDueAt: _dueDate!,
      cost: _amountController.text.trim().isEmpty
          ? null
          : double.tryParse(_amountController.text.trim()),
      costCurrency: _amountController.text.trim().isEmpty ? null : 'JPY',
      isArchived: false,
      isLocalePreset: false,
      isGroupTask: false,
      createdByUid: uid,
      updatedByUid: uid,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await ref.read(taskNotifierProvider.notifier).createTask(task);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('タスクを追加しました')),
        );
        context.goNamed('home');
      }
    } catch (e) {
      setState(() => _state = _ScanState.review);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _state = _ScanState.idle;
      _image = null;
      _error = null;
      _titleController.clear();
      _amountController.clear();
      _dueDate = null;
      _categoryId = 'other';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('書類カメラ')),
      body: switch (_state) {
        _ScanState.idle => _IdleView(error: _error, onPick: _pickImage),
        _ScanState.extracting => _ExtractingView(image: _image),
        _ScanState.review || _ScanState.saving => _ReviewView(
            image: _image,
            titleController: _titleController,
            amountController: _amountController,
            dueDate: _dueDate,
            categoryId: _categoryId,
            isSaving: _state == _ScanState.saving,
            onPickDate: _pickDate,
            onCategoryChanged: (id) => setState(() => _categoryId = id),
            onSave: _save,
            onRetry: _reset,
          ),
      },
    );
  }
}

class _IdleView extends StatelessWidget {
  final String? error;
  final void Function(ImageSource) onPick;
  const _IdleView({required this.error, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner_rounded,
                size: 72, color: Colors.grey.shade300),
            const Gap(20),
            const Text(
              '書類を撮影すると\n期限・金額をAIが自動抽出します',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            if (error != null) ...[
              const Gap(16),
              Text(error!, style: const TextStyle(color: AppTheme.errorColor)),
            ],
            const Gap(32),
            FilledButton.icon(
              onPressed: () => onPick(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('カメラで撮影'),
            ),
            const Gap(12),
            OutlinedButton.icon(
              onPressed: () => onPick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('ギャラリーから選択'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtractingView extends StatelessWidget {
  final File? image;
  const _ExtractingView({required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (image != null)
          Expanded(
            child: Opacity(
              opacity: 0.4,
              child: Image.file(image!, fit: BoxFit.contain, width: double.infinity),
            ),
          ),
        const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              CircularProgressIndicator(),
              Gap(16),
              Text('AIが書類を解析中...'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewView extends StatelessWidget {
  final File? image;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final DateTime? dueDate;
  final String categoryId;
  final bool isSaving;
  final VoidCallback onPickDate;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onSave;
  final VoidCallback onRetry;

  const _ReviewView({
    required this.image,
    required this.titleController,
    required this.amountController,
    required this.dueDate,
    required this.categoryId,
    required this.isSaving,
    required this.onPickDate,
    required this.onCategoryChanged,
    required this.onSave,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(image!, height: 160, fit: BoxFit.cover),
            ),
          const Gap(20),
          const Text('抽出結果を確認・編集してください',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const Gap(16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'タイトル'),
          ),
          const Gap(12),
          InkWell(
            onTap: onPickDate,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: '期限日'),
              child: Text(
                dueDate != null
                    ? '${dueDate!.year}/${dueDate!.month}/${dueDate!.day}'
                    : '選択してください',
              ),
            ),
          ),
          const Gap(12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '金額（円）'),
          ),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppCategories.level0.map((c) {
              final selected = c.$1 == categoryId;
              return ChoiceChip(
                label: Text('${c.$2} ${c.$3}'),
                selected: selected,
                onSelected: (_) => onCategoryChanged(c.$1),
              );
            }).toList(),
          ),
          const Gap(24),
          isSaving
              ? const Center(child: CircularProgressIndicator())
              : FilledButton(
                  onPressed: onSave,
                  child: const Text('タスクとして保存'),
                ),
          const Gap(8),
          TextButton(onPressed: onRetry, child: const Text('撮り直す')),
        ],
      ),
    );
  }
}
