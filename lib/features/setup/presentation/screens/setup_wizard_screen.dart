import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// 初期設定ウィザード
///
/// 住宅・自動車などの購入日を入力すると、
/// 車検・外壁塗装・税金などのタスクを自動登録する。
class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  int _step = 0;
  bool _isLoading = false;

  // ── 住宅 ──
  bool _hasOwnHome = false;
  DateTime? _homePurchaseDate;

  // ── 自動車 ──
  bool _hasVehicle = false;
  DateTime? _vehiclePurchaseDate;
  bool _isNewCar = true; // 新車か中古車か

  // ── 健康 ──
  bool _addHealthTasks = true;

  // ── 確定申告 ──
  bool _addTaxTasks = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => setState(() => _step--),
              )
            : null,
        title: Text(
          '初期設定 ${_step + 1} / 4',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('スキップ'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // プログレスバー
            LinearProgressIndicator(
              value: (_step + 1) / 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(_step),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return _HomeStep(key: const ValueKey(0), self: this);
      case 1:
        return _VehicleStep(key: const ValueKey(1), self: this);
      case 2:
        return _HealthStep(key: const ValueKey(2), self: this);
      case 3:
        return _ConfirmStep(key: const ValueKey(3), self: this);
      default:
        return const SizedBox();
    }
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _complete();
    }
  }

  Future<void> _skip() async {
    await _saveSetupFlag();
    if (mounted) context.goNamed('home');
  }

  Future<void> _complete() async {
    setState(() => _isLoading = true);
    try {
      final uid = ref.read(currentUserProvider)?.uid;
      if (uid == null) throw Exception('ログインが必要です');

      final tasks = _generateTasks(uid);
      if (tasks.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final data in tasks) {
          final docRef = FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(uid)
              .collection(AppConstants.tasksSubCollection)
              .doc();
          batch.set(docRef, {...data, 'taskId': docRef.id});
        }
        await batch.commit();
      }

      await _saveSetupFlag();
      if (mounted) context.goNamed('home');
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

  Future<void> _saveSetupFlag() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'setupCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// 設定に基づくタスクデータ一覧を生成
  List<Map<String, dynamic>> _generateTasks(String uid) {
    final now = DateTime.now();
    final tasks = <Map<String, dynamic>>[];

    // ── 住宅タスク ──
    if (_hasOwnHome && _homePurchaseDate != null) {
      final purchase = _homePurchaseDate!;

      tasks.add(_makeTask(
        uid: uid,
        title: '外壁・屋根点検',
        categoryId: 'housing_maintenance',
        categoryPath: 'housing/housing_maintenance',
        categoryLabels: ['住宅', 'メンテナンス'],
        nextDueAt: _nextAnniversary(purchase, 10),
        recurrenceType: 'yearly',
        reminderDays: 30,
        notes: '目安: 購入から10年ごと。専門業者に依頼',
      ));

      tasks.add(_makeTask(
        uid: uid,
        title: '給湯器の交換確認',
        categoryId: 'housing_equipment_water_heater',
        categoryPath: 'housing/housing_equipment/housing_equipment_water_heater',
        categoryLabels: ['住宅', '設備交換', '給湯器'],
        nextDueAt: _nextAnniversary(purchase, 15),
        recurrenceType: 'none',
        reminderDays: 30,
        notes: '目安: 購入から15年前後で交換を検討',
      ));

      tasks.add(_makeTask(
        uid: uid,
        title: '固定資産税の支払い',
        categoryId: 'housing_tax',
        categoryPath: 'housing/housing_tax',
        categoryLabels: ['住宅', '税金・費用'],
        nextDueAt: _nextMonthDay(5, 1), // 毎年5月
        recurrenceType: 'yearly',
        reminderDays: 14,
        notes: '納付書が4月末〜5月初に届く',
      ));

      tasks.add(_makeTask(
        uid: uid,
        title: '火災保険の更新確認',
        categoryId: 'insurance_fire',
        categoryPath: 'insurance/insurance_fire',
        categoryLabels: ['保険', '火災保険'],
        nextDueAt: _nextAnniversary(purchase, 10),
        recurrenceType: 'yearly',
        reminderDays: 60,
        notes: '保険期間・補償内容を見直す',
      ));
    }

    // ── 自動車タスク ──
    if (_hasVehicle && _vehiclePurchaseDate != null) {
      final purchase = _vehiclePurchaseDate!;
      // 新車は初回3年、中古・以降は2年
      final firstInspection = _isNewCar ? 3 : 2;

      tasks.add(_makeTask(
        uid: uid,
        title: '車検',
        categoryId: 'vehicle_inspection',
        categoryPath: 'vehicle/vehicle_inspection',
        categoryLabels: ['自動車', '車検・点検'],
        nextDueAt: _nextAnniversary(purchase, firstInspection),
        recurrenceType: 'yearly',
        reminderDays: 30,
        notes: _isNewCar
            ? '新車: 初回3年後、以降2年毎'
            : '2年毎に受検が必要',
      ));

      tasks.add(_makeTask(
        uid: uid,
        title: '自動車税の支払い',
        categoryId: 'vehicle_tax',
        categoryPath: 'vehicle/vehicle_tax',
        categoryLabels: ['自動車', '税金'],
        nextDueAt: _nextMonthDay(5, 1), // 毎年5月
        recurrenceType: 'yearly',
        reminderDays: 14,
        notes: '毎年5月に納税通知が届く',
      ));

      tasks.add(_makeTask(
        uid: uid,
        title: '自動車保険の更新',
        categoryId: 'vehicle_insurance',
        categoryPath: 'vehicle/vehicle_insurance',
        categoryLabels: ['自動車', '保険'],
        nextDueAt: _nextAnniversaryFrom(purchase, now),
        recurrenceType: 'yearly',
        reminderDays: 30,
        notes: '補償内容・等級を確認してから更新',
      ));

      tasks.add(_makeTask(
        uid: uid,
        title: 'タイヤ交換の確認',
        categoryId: 'vehicle_parts_tire',
        categoryPath: 'vehicle/vehicle_parts/vehicle_parts_tire',
        categoryLabels: ['自動車', '消耗品交換', 'タイヤ'],
        nextDueAt: _nextAnniversary(purchase, 3),
        recurrenceType: 'yearly',
        reminderDays: 14,
        notes: '目安: 3〜5年または走行距離3〜5万km',
      ));
    }

    // ── 健康タスク ──
    if (_addHealthTasks) {
      tasks.add(_makeTask(
        uid: uid,
        title: '健康診断',
        categoryId: 'health_checkup',
        categoryPath: 'health/health_checkup',
        categoryLabels: ['健康・医療', '健康診断'],
        nextDueAt: _nextMonthDay(10, 1), // 毎年10月目安
        recurrenceType: 'yearly',
        reminderDays: 30,
        notes: '年1回受診（会社の健診 or 自治体の特定健診）',
      ));

      tasks.add(_makeTask(
        uid: uid,
        title: '歯科健診',
        categoryId: 'health_dental',
        categoryPath: 'health/health_dental',
        categoryLabels: ['健康・医療', '歯科'],
        nextDueAt: _nextMonthDay(6, 1), // 次の6月
        recurrenceType: 'yearly',
        reminderDays: 14,
        notes: '半年に1回が目安（虫歯・歯周病チェック）',
      ));
    }

    // ── お金タスク ──
    if (_addTaxTasks) {
      tasks.add(_makeTask(
        uid: uid,
        title: '確定申告',
        categoryId: 'finance_tax',
        categoryPath: 'finance/finance_tax',
        categoryLabels: ['お金・税金', '確定申告'],
        nextDueAt: _nextMonthDay(2, 16), // 毎年2月16日
        recurrenceType: 'yearly',
        reminderDays: 30,
        notes: '申告期間: 2月16日〜3月15日',
      ));
    }

    return tasks;
  }

  // ─── 日付ヘルパー ───────────────────────────────────────

  /// 購入日の N 年後記念日（来年以降）
  DateTime _nextAnniversary(DateTime base, int years) {
    final target = DateTime(base.year + years, base.month, base.day);
    final now = DateTime.now();
    if (target.isAfter(now)) return target;
    // すでに過ぎていたら次の周期を探す
    var t = target;
    while (!t.isAfter(now)) {
      t = DateTime(t.year + 1, t.month, t.day);
    }
    return t;
  }

  /// 購入日周年で、直近の未来日
  DateTime _nextAnniversaryFrom(DateTime base, DateTime from) {
    var t = DateTime(from.year, base.month, base.day);
    if (!t.isAfter(from)) t = DateTime(t.year + 1, t.month, t.day);
    return t;
  }

  /// 毎年 M 月 D 日で直近の未来日
  DateTime _nextMonthDay(int month, int day) {
    final now = DateTime.now();
    var t = DateTime(now.year, month, day);
    if (!t.isAfter(now)) t = DateTime(t.year + 1, t.month, t.day);
    return t;
  }

  // ─── タスクデータ生成 ─────────────────────────────────────

  Map<String, dynamic> _makeTask({
    required String uid,
    required String title,
    required String categoryId,
    required String categoryPath,
    required List<String> categoryLabels,
    required DateTime nextDueAt,
    required String recurrenceType,
    required int reminderDays,
    String? notes,
  }) {
    final now = DateTime.now();
    return {
      'title': title,
      'categoryId': categoryId,
      'categoryPath': categoryPath,
      'categoryLabels': categoryLabels,
      'nextDueAt': Timestamp.fromDate(nextDueAt),
      'recurrenceType': recurrenceType,
      'reminderDaysBefore': reminderDays,
      if (notes != null) 'notes': notes,
      'assigneeUids': [],
      'deferCount': 0,
      'isArchived': false,
      'isLocalePreset': false,
      'isGroupTask': false,
      'createdByUid': uid,
      'updatedByUid': uid,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };
  }

  int get _taskCount {
    int count = 0;
    if (_hasOwnHome && _homePurchaseDate != null) count += 4;
    if (_hasVehicle && _vehiclePurchaseDate != null) count += 4;
    if (_addHealthTasks) count += 2;
    if (_addTaxTasks) count += 1;
    return count;
  }
}

// ─────────────────────────────────────────────────────────
// Step 0: 住宅
// ─────────────────────────────────────────────────────────
class _HomeStep extends StatefulWidget {
  final _SetupWizardScreenState self;
  const _HomeStep({super.key, required this.self});

  @override
  State<_HomeStep> createState() => _HomeStepState();
}

class _HomeStepState extends State<_HomeStep> {
  @override
  Widget build(BuildContext context) {
    final s = widget.self;
    return _StepScaffold(
      icon: '🏠',
      title: '住宅について',
      subtitle: '持ち家をお持ちですか？',
      onNext: s._next,
      child: Column(
        children: [
          _ToggleRow(
            label: '持ち家・マンション（所有）がある',
            value: s._hasOwnHome,
            onChanged: (v) => setState(() => s._hasOwnHome = v),
          ),
          if (s._hasOwnHome) ...[
            const Gap(16),
            _DatePickerRow(
              label: '購入年月',
              date: s._homePurchaseDate,
              firstDate: DateTime(1970),
              lastDate: DateTime.now(),
              onChanged: (d) => setState(() => s._homePurchaseDate = d),
            ),
            const Gap(8),
            _InfoBox(
              '入力するとこんなタスクが自動登録されます:\n'
              '• 外壁・屋根点検（10年毎）\n'
              '• 給湯器交換確認（15年目）\n'
              '• 固定資産税（毎年5月）\n'
              '• 火災保険更新（10年毎）',
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Step 1: 自動車
// ─────────────────────────────────────────────────────────
class _VehicleStep extends StatefulWidget {
  final _SetupWizardScreenState self;
  const _VehicleStep({super.key, required this.self});

  @override
  State<_VehicleStep> createState() => _VehicleStepState();
}

class _VehicleStepState extends State<_VehicleStep> {
  @override
  Widget build(BuildContext context) {
    final s = widget.self;
    return _StepScaffold(
      icon: '🚗',
      title: '自動車について',
      subtitle: '車をお持ちですか？',
      onNext: s._next,
      child: Column(
        children: [
          _ToggleRow(
            label: '自動車を所有している',
            value: s._hasVehicle,
            onChanged: (v) => setState(() => s._hasVehicle = v),
          ),
          if (s._hasVehicle) ...[
            const Gap(16),
            _DatePickerRow(
              label: '購入（登録）年月',
              date: s._vehiclePurchaseDate,
              firstDate: DateTime(1990),
              lastDate: DateTime.now(),
              onChanged: (d) => setState(() => s._vehiclePurchaseDate = d),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: _ChoiceChipRow(
                    label: '新車で購入',
                    selected: s._isNewCar,
                    onTap: () => setState(() => s._isNewCar = true),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _ChoiceChipRow(
                    label: '中古車で購入',
                    selected: !s._isNewCar,
                    onTap: () => setState(() => s._isNewCar = false),
                  ),
                ),
              ],
            ),
            const Gap(8),
            _InfoBox(
              '入力するとこんなタスクが自動登録されます:\n'
              '• 車検（新車3年→以降2年毎）\n'
              '• 自動車税（毎年5月）\n'
              '• 自動車保険更新（毎年）\n'
              '• タイヤ交換確認（3年毎）',
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Step 2: 健康・お金
// ─────────────────────────────────────────────────────────
class _HealthStep extends StatefulWidget {
  final _SetupWizardScreenState self;
  const _HealthStep({super.key, required this.self});

  @override
  State<_HealthStep> createState() => _HealthStepState();
}

class _HealthStepState extends State<_HealthStep> {
  @override
  Widget build(BuildContext context) {
    final s = widget.self;
    return _StepScaffold(
      icon: '💊',
      title: '健康・お金',
      subtitle: '定期タスクを追加しますか？',
      onNext: s._next,
      child: Column(
        children: [
          _ToggleRow(
            label: '健康診断・歯科健診（毎年）',
            value: s._addHealthTasks,
            onChanged: (v) => setState(() => s._addHealthTasks = v),
            subtitle: '健康診断（10月目安）、歯科健診（6月目安）',
          ),
          const Gap(12),
          _ToggleRow(
            label: '確定申告（毎年2月〜3月）',
            value: s._addTaxTasks,
            onChanged: (v) => setState(() => s._addTaxTasks = v),
            subtitle: '申告期間: 2月16日〜3月15日',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Step 3: 確認・完了
// ─────────────────────────────────────────────────────────
class _ConfirmStep extends StatefulWidget {
  final _SetupWizardScreenState self;
  const _ConfirmStep({super.key, required this.self});

  @override
  State<_ConfirmStep> createState() => _ConfirmStepState();
}

class _ConfirmStepState extends State<_ConfirmStep> {
  @override
  Widget build(BuildContext context) {
    final s = widget.self;
    final count = s._taskCount;

    return _StepScaffold(
      icon: '✅',
      title: '設定完了',
      subtitle: '$count 件のタスクを自動登録します',
      onNext: s._isLoading ? null : s._complete,
      nextLabel: s._isLoading ? null : '登録してホームへ',
      child: Column(
        children: [
          if (s._hasOwnHome && s._homePurchaseDate != null)
            _SummaryCard(
              icon: '🏠',
              title: '住宅タスク 4件',
              items: const [
                '外壁・屋根点検（10年毎）',
                '給湯器交換確認（15年目）',
                '固定資産税（毎年5月）',
                '火災保険更新（10年毎）',
              ],
            ),
          if (s._hasVehicle && s._vehiclePurchaseDate != null)
            _SummaryCard(
              icon: '🚗',
              title: '自動車タスク 4件',
              items: [
                '車検（${s._isNewCar ? "初回3年" : "2年"}毎）',
                '自動車税（毎年5月）',
                '自動車保険更新（毎年）',
                'タイヤ交換確認（3年毎）',
              ],
            ),
          if (s._addHealthTasks)
            _SummaryCard(
              icon: '💊',
              title: '健康タスク 2件',
              items: const ['健康診断（毎年10月）', '歯科健診（毎年6月）'],
            ),
          if (s._addTaxTasks)
            _SummaryCard(
              icon: '💴',
              title: 'お金タスク 1件',
              items: const ['確定申告（毎年2月）'],
            ),
          if (count == 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                '設定なし。あとからタスクを手動追加できます。',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          if (s._isLoading) ...[
            const Gap(16),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 共通ウィジェット
// ─────────────────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onNext;
  final String? nextLabel;
  final Widget child;

  const _StepScaffold({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onNext,
    required this.child,
    this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(8),
          Text(icon, style: const TextStyle(fontSize: 48)),
          const Gap(12),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const Gap(24),
          Expanded(child: SingleChildScrollView(child: child)),
          const Gap(16),
          FilledButton(
            onPressed: onNext,
            child: Text(nextLabel ?? '次へ'),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: value ? AppTheme.primaryColor : Colors.grey.shade300,
          width: value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: value ? AppTheme.primaryLight : null,
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              )
            : null,
        activeColor: AppTheme.primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerRow({
    required this.label,
    required this.date,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime(DateTime.now().year - 5),
          firstDate: firstDate,
          lastDate: lastDate,
          initialDatePickerMode: DatePickerMode.year,
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_rounded),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date == null
              ? 'タップして選択'
              : '${date!.year}年${date!.month}月',
          style: TextStyle(
            color: date == null ? Colors.grey : null,
          ),
        ),
      ),
    );
  }
}

class _ChoiceChipRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChipRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : Colors.grey.shade50,
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: AppTheme.primaryColor),
            if (selected) const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? AppTheme.primaryDark : Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade400),
          const Gap(8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<String> items;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const Gap(8),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const Gap(8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(Icons.check_rounded,
                      size: 14, color: AppTheme.primaryColor),
                  const Gap(6),
                  Text(item, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
