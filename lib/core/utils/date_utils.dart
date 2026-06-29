import 'package:intl/intl.dart';

/// ロケール別の日付フォーマットユーティリティ
class AppDateUtils {
  AppDateUtils._();

  static const Map<String, String> _dateFormats = {
    'ja-JP': 'yyyy年M月d日',
    'en-US': 'MMMM d, yyyy',
    'en-GB': 'd MMMM yyyy',
    'en-AU': 'd MMMM yyyy',
    'en-CA': 'MMMM d, yyyy',
    'zh-CN': 'yyyy年M月d日',
    'zh-TW': 'yyyy年M月d日',
    'zh-HK': 'yyyy年M月d日',
    'de-DE': 'd. MMMM yyyy',
    'de-AT': 'd. MMMM yyyy',
    'fr-FR': 'd MMMM yyyy',
    'fr-CA': 'd MMMM yyyy',
    'es-ES': 'd de MMMM de yyyy',
    'es-MX': 'd de MMMM de yyyy',
    'ko-KR': 'yyyy년 M월 d일',
    'pt-BR': 'd de MMMM de yyyy',
    'it-IT': 'd MMMM yyyy',
  };

  static String formatDate(DateTime date, String locale) {
    final format = _dateFormats[locale] ?? 'yyyy-MM-dd';
    final lang = locale.split('-').first;
    return DateFormat(format, lang).format(date);
  }

  static String formatShort(DateTime date, String locale) {
    final lang = locale.split('-').first;
    switch (locale) {
      case 'ja-JP':
      case 'zh-CN':
      case 'zh-TW':
        return DateFormat('M月d日', lang).format(date);
      case 'ko-KR':
        return DateFormat('M월 d일', lang).format(date);
      default:
        return DateFormat('MMM d', lang).format(date);
    }
  }

  static String formatRelative(DateTime date, String locale) {
    final now = DateTime.now();
    final diff = date.difference(now);
    final lang = locale.split('-').first;
    final isJa = lang == 'ja';

    if (diff.isNegative) {
      final days = diff.inDays.abs();
      if (days == 0) return isJa ? '今日期限切れ' : 'Overdue today';
      if (days == 1) return isJa ? '昨日期限切れ' : '1 day overdue';
      return isJa ? '$days日前に期限切れ' : '$days days overdue';
    }

    final days = diff.inDays;
    if (days == 0) return isJa ? '今日' : 'Today';
    if (days == 1) return isJa ? '明日' : 'Tomorrow';
    if (days < 7) return isJa ? '$days日後' : 'In $days days';
    if (days < 30) {
      final weeks = (days / 7).floor();
      return isJa ? '$weeks週間後' : 'In $weeks weeks';
    }
    if (days < 365) {
      final months = (days / 30).floor();
      return isJa ? '$months ヶ月後' : 'In $months months';
    }
    return formatShort(date, locale);
  }

  /// タスクの次回予定日を計算
  static DateTime calculateNextDueDate({
    required DateTime currentDueAt,
    required String recurrenceType,
    int? recurrenceValue,
    String? recurrenceUnit,
  }) {
    switch (recurrenceType) {
      case 'weekly':
        return currentDueAt.add(const Duration(days: 7));
      case 'biweekly':
        return currentDueAt.add(const Duration(days: 14));
      case 'monthly':
        return DateTime(
          currentDueAt.year,
          currentDueAt.month + 1,
          currentDueAt.day,
        );
      case 'quarterly':
        return DateTime(
          currentDueAt.year,
          currentDueAt.month + 3,
          currentDueAt.day,
        );
      case 'yearly':
        return DateTime(
          currentDueAt.year + 1,
          currentDueAt.month,
          currentDueAt.day,
        );
      case 'custom':
        if (recurrenceValue != null && recurrenceUnit != null) {
          switch (recurrenceUnit) {
            case 'days':
              return currentDueAt.add(Duration(days: recurrenceValue));
            case 'weeks':
              return currentDueAt.add(Duration(days: recurrenceValue * 7));
            case 'months':
              return DateTime(
                currentDueAt.year,
                currentDueAt.month + recurrenceValue,
                currentDueAt.day,
              );
            case 'years':
              return DateTime(
                currentDueAt.year + recurrenceValue,
                currentDueAt.month,
                currentDueAt.day,
              );
          }
        }
        return currentDueAt;
      default:
        return currentDueAt;
    }
  }

  static bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  static int daysUntil(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.difference(DateTime(now.year, now.month, now.day));
    return diff.inDays;
  }
}
