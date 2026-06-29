import 'package:flutter_test/flutter_test.dart';
import 'package:life_task_manager/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('formatDate', () {
      test('ja-JP フォーマット', () {
        final date = DateTime(2026, 3, 15);
        final result = AppDateUtils.formatDate(date, 'ja-JP');
        expect(result, '2026年3月15日');
      });

      test('en-US フォーマット', () {
        final date = DateTime(2026, 3, 15);
        final result = AppDateUtils.formatDate(date, 'en-US');
        expect(result, contains('March'));
        expect(result, contains('15'));
        expect(result, contains('2026'));
      });
    });

    group('calculateNextDueDate', () {
      test('weekly: 7日後', () {
        final original = DateTime(2026, 3, 16);
        final result = AppDateUtils.calculateNextDueDate(
          currentDueAt: original,
          recurrenceType: 'weekly',
        );
        expect(result, DateTime(2026, 3, 23));
      });

      test('monthly: 1ヶ月後', () {
        final original = DateTime(2026, 3, 16);
        final result = AppDateUtils.calculateNextDueDate(
          currentDueAt: original,
          recurrenceType: 'monthly',
        );
        expect(result, DateTime(2026, 4, 16));
      });

      test('yearly: 1年後', () {
        final original = DateTime(2026, 3, 16);
        final result = AppDateUtils.calculateNextDueDate(
          currentDueAt: original,
          recurrenceType: 'yearly',
        );
        expect(result, DateTime(2027, 3, 16));
      });

      test('custom days: 3日後', () {
        final original = DateTime(2026, 3, 16);
        final result = AppDateUtils.calculateNextDueDate(
          currentDueAt: original,
          recurrenceType: 'custom',
          recurrenceValue: 3,
          recurrenceUnit: 'days',
        );
        expect(result, DateTime(2026, 3, 19));
      });

      test('none: 変更なし', () {
        final original = DateTime(2026, 3, 16);
        final result = AppDateUtils.calculateNextDueDate(
          currentDueAt: original,
          recurrenceType: 'none',
        );
        expect(result, original);
      });
    });

    group('daysUntil', () {
      test('未来の日付 → 正の値', () {
        final future = DateTime.now().add(const Duration(days: 7));
        final result = AppDateUtils.daysUntil(future);
        expect(result, greaterThan(0));
      });

      test('過去の日付 → 負の値', () {
        final past = DateTime.now().subtract(const Duration(days: 3));
        final result = AppDateUtils.daysUntil(past);
        expect(result, lessThan(0));
      });
    });

    group('isOverdue', () {
      test('過去の日付 → true', () {
        final past = DateTime.now().subtract(const Duration(hours: 1));
        expect(AppDateUtils.isOverdue(past), true);
      });

      test('未来の日付 → false', () {
        final future = DateTime.now().add(const Duration(hours: 1));
        expect(AppDateUtils.isOverdue(future), false);
      });
    });
  });
}
