import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../data/locale_preset_repository.dart';

/// オンボーディング画面（ロケール選択 + 推奨タスク選択）
///
/// フロー:
/// 1. ユーザーが Google Sign-In
/// 2. 端末ロケール検出 → 提案
/// 3. 「日本語（日本）を使用しますか？」
/// 4. YES → 推奨タスク一覧（確定申告・年賀状等）を表示
/// 5. ユーザーがチェック → users/{uid}/tasks に追加
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  String? _selectedLocale;
  final Set<String> _selectedTaskIds = {};
  bool _isLoading = false;

  // ロケール定義
  static const _locales = [
    ('ja-JP', '🇯🇵', '日本語（日本）'),
    ('en-US', '🇺🇸', 'English (United States)'),
    ('en-GB', '🇬🇧', 'English (United Kingdom)'),
    ('zh-CN', '🇨🇳', '中文（中国）'),
    ('zh-TW', '🇹🇼', '中文（台灣）'),
    ('de-DE', '🇩🇪', 'Deutsch (Deutschland)'),
    ('fr-FR', '🇫🇷', 'Français (France)'),
    ('ko-KR', '🇰🇷', '한국어 (대한민국)'),
  ];

  // カテゴリID → 絵文字マッピング
  static const _categoryEmojis = {
    'finance': '💰',
    'housing': '🏠',
    'vehicle': '🚗',
    'health': '🏥',
    'insurance': '📋',
    'other': '📅',
  };

  @override
  void initState() {
    super.initState();
    // 端末ロケールを検出して推奨ロケールを設定
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final localeCode = '${deviceLocale.languageCode}-${deviceLocale.countryCode}';
    _selectedLocale = localeCode;
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final uid = ref.read(currentUserProvider)?.uid;
      if (uid == null) throw Exception('Not logged in');

      final now = DateTime.now();

      // 1. ユーザープロフィールにロケール情報を保存
      if (_selectedLocale != null) {
        final localeparts = _selectedLocale!.split('-');
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .update({
          'language': localeparts.isNotEmpty ? localeparts[0] : 'ja',
          'country': localeparts.length > 1 ? localeparts[1] : 'JP',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 2. 選択した推奨タスクを users/{uid}/tasks に作成
      if (_selectedTaskIds.isNotEmpty) {
        final locale = _selectedLocale ?? 'ja-JP';
        // キャッシュ済みの推奨タスク一覧を読み取る
        final presets = ref.read(recommendedTasksProvider(locale)).valueOrNull ?? [];

        final batch = FirebaseFirestore.instance.batch();
        for (final taskId in _selectedTaskIds) {
          final preset = presets.firstWhere(
            (t) => t.taskId == taskId,
            orElse: () => LocalePresetTask(
              taskId: taskId,
              title: taskId,
              categoryId: 'other',
              categoryLabels: [],
              recurrenceType: 'yearly',
            ),
          );

          final docRef = FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(uid)
              .collection(AppConstants.tasksSubCollection)
              .doc();

          // デフォルトの nextDueAt は1年後
          final nextDueAt = now.add(const Duration(days: 365));

          // categoryPath: categoryId の階層を '/' で分割
          final categoryPath = preset.categoryId.split('_');

          batch.set(docRef, {
            'taskId': docRef.id,
            'title': preset.title,
            'description': preset.notes,
            'categoryId': preset.categoryId,
            'categoryPath': categoryPath,
            'categoryLabels': preset.categoryLabels,
            'nextDueAt': Timestamp.fromDate(nextDueAt),
            'recurrenceType': preset.recurrenceType,
            'reminderDaysBefore': AppConstants.defaultReminderDays,
            'assigneeUids': [],
            'deferCount': 0,
            'isArchived': false,
            'isLocalePreset': true,
            'isGroupTask': false,
            'createdByUid': uid,
            'updatedByUid': uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }

      // オンボーディング後は初期設定ウィザードへ
      if (mounted) context.goNamed('setup');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('設定に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = _selectedLocale ?? 'ja-JP';
    final tasksAsync = ref.watch(recommendedTasksProvider(locale));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _currentStep == 0
            ? _buildLocaleStep()
            : _buildTaskStep(tasksAsync),
      ),
    );
  }

  Widget _buildLocaleStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(24),
          Text(
            '言語・地域を選択',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(8),
          Text(
            'お住まいの地域に合わせたタスクテンプレートが表示されます',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Gap(24),
          Expanded(
            child: ListView.separated(
              itemCount: _locales.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final (code, flag, name) = _locales[i];
                final isSelected = _selectedLocale == code;
                return ListTile(
                  leading: Text(flag, style: const TextStyle(fontSize: 28)),
                  title: Text(name),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primaryColor)
                      : null,
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor,
                  onTap: () => setState(() => _selectedLocale = code),
                );
              },
            ),
          ),
          const Gap(16),
          FilledButton(
            onPressed: _selectedLocale == null
                ? null
                : () => setState(() => _currentStep = 1),
            child: const Text('次へ'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStep(AsyncValue<List<LocalePresetTask>> tasksAsync) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(24),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => setState(() {
                  _currentStep = 0;
                  _selectedTaskIds.clear();
                }),
              ),
              Text(
                'おすすめタスクを選択',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            '選択したタスクが自動で追加されます（後で変更可能）',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Gap(16),
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 48, color: Colors.grey.shade300),
                    const Gap(16),
                    Text(
                      'タスクテンプレートを読み込めませんでした',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Text(
                      'このロケールのテンプレートはありません',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final task = tasks[i];
                    final isSelected = _selectedTaskIds.contains(task.taskId);
                    final emoji = _categoryEmojis[task.categoryId] ??
                        _categoryEmojis[task.categoryId.split('_').first] ??
                        '📋';
                    return CheckboxListTile(
                      value: isSelected,
                      secondary:
                          Text(emoji, style: const TextStyle(fontSize: 24)),
                      title: Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: task.notes != null
                          ? Text(
                              task.notes!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            )
                          : null,
                      activeColor: AppTheme.primaryColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedTaskIds.add(task.taskId);
                          } else {
                            _selectedTaskIds.remove(task.taskId);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Gap(16),
          // 全選択ボタン（タスクがロード済みの場合のみ）
          if (tasksAsync.valueOrNull?.isNotEmpty == true)
            TextButton(
              onPressed: () => setState(() {
                final tasks = tasksAsync.valueOrNull!;
                if (_selectedTaskIds.length == tasks.length) {
                  _selectedTaskIds.clear();
                } else {
                  _selectedTaskIds.addAll(tasks.map((t) => t.taskId));
                }
              }),
              child: Text(
                _selectedTaskIds.length ==
                        (tasksAsync.valueOrNull?.length ?? 0)
                    ? 'すべて解除'
                    : 'すべて選択',
              ),
            ),
          const Gap(8),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FilledButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    _selectedTaskIds.isEmpty
                        ? 'スキップして始める'
                        : '${_selectedTaskIds.length}件を追加して始める',
                  ),
                ),
        ],
      ),
    );
  }
}
