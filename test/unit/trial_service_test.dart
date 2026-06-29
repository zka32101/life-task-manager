import 'package:flutter_test/flutter_test.dart';
import 'package:life_task_manager/core/utils/trial_service.dart';

void main() {
  group('TrialService', () {
    late TrialService service;

    setUp(() {
      service = TrialService();
    });

    group('isActive', () {
      test('isPaid=true → 常にアクティブ', () {
        final result = service.isActive(
          isPaid: true,
          trialStartAt: DateTime.now().subtract(const Duration(days: 100)),
        );
        expect(result, true);
      });

      test('トライアル開始から29日 → アクティブ', () {
        final result = service.isActive(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 29)),
        );
        expect(result, true);
      });

      test('トライアル開始から30日 → 期限切れ', () {
        final result = service.isActive(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(result, false);
      });

      test('トライアル開始から31日 → 期限切れ', () {
        final result = service.isActive(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 31)),
        );
        expect(result, false);
      });
    });

    group('remainingDays', () {
      test('isPaid=true → -1（無制限）', () {
        final result = service.remainingDays(
          isPaid: true,
          trialStartAt: DateTime.now(),
        );
        expect(result, -1);
      });

      test('開始から0日 → 30日', () {
        final result = service.remainingDays(
          isPaid: false,
          trialStartAt: DateTime.now(),
        );
        expect(result, 30);
      });

      test('開始から7日 → 23日', () {
        final result = service.remainingDays(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 7)),
        );
        expect(result, 23);
      });

      test('開始から30日 → 0日', () {
        final result = service.remainingDays(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(result, 0);
      });
    });

    group('shouldShowWarning', () {
      test('残7日 → バナー表示', () {
        final result = service.shouldShowWarning(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 23)),
        );
        expect(result, true);
      });

      test('残8日 → バナー非表示', () {
        final result = service.shouldShowWarning(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 22)),
        );
        expect(result, false);
      });

      test('isPaid=true → バナー非表示', () {
        final result = service.shouldShowWarning(
          isPaid: true,
          trialStartAt: DateTime.now().subtract(const Duration(days: 23)),
        );
        expect(result, false);
      });

      test('期限切れ → バナー非表示（強制ロック画面へ）', () {
        final result = service.shouldShowWarning(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 31)),
        );
        expect(result, false);
      });
    });

    group('UserAccessStatus.evaluate', () {
      test('isPaid=true → paid', () {
        final status = UserAccessStatus.evaluate(
          isPaid: true,
          trialStartAt: DateTime.now().subtract(const Duration(days: 100)),
        );
        expect(status, UserAccessStatus.paid);
        expect(status.hasAccess, true);
      });

      test('29日 → trialActive', () {
        final status = UserAccessStatus.evaluate(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 29)),
        );
        expect(status, UserAccessStatus.trialActive);
        expect(status.hasAccess, true);
      });

      test('31日 → trialExpired', () {
        final status = UserAccessStatus.evaluate(
          isPaid: false,
          trialStartAt: DateTime.now().subtract(const Duration(days: 31)),
        );
        expect(status, UserAccessStatus.trialExpired);
        expect(status.hasAccess, false);
      });
    });
  });
}
