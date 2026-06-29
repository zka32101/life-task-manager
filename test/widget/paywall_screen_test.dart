import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_task_manager/features/paywall/presentation/screens/paywall_screen.dart';

void main() {
  group('PaywallScreen', () {
    Widget buildPaywall({
      required bool isForced,
      int remainingDays = 10,
      bool isInvitedUser = false,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: PaywallScreen(
            isForced: isForced,
            remainingDays: remainingDays,
            isInvitedUser: isInvitedUser,
          ),
        ),
      );
    }

    testWidgets('トライアル中 → あとでボタン表示', (tester) async {
      await tester.pumpWidget(
          buildPaywall(isForced: false, remainingDays: 10));
      await tester.pump();
      expect(find.textContaining('あとで'), findsOneWidget);
    });

    testWidgets('強制表示 → あとでボタン非表示', (tester) async {
      await tester.pumpWidget(
          buildPaywall(isForced: true, remainingDays: 0));
      await tester.pump();
      expect(find.textContaining('あとで'), findsNothing);
    });

    testWidgets('招待ユーザー → 割引バナー表示', (tester) async {
      await tester.pumpWidget(
          buildPaywall(isForced: false, remainingDays: 5, isInvitedUser: true));
      await tester.pump();
      expect(find.text('招待特典'), findsOneWidget);
    });

    testWidgets('復元ボタン常に表示', (tester) async {
      await tester.pumpWidget(
          buildPaywall(isForced: true, remainingDays: 0));
      await tester.pump();
      expect(find.text('購入を復元する'), findsOneWidget);
    });
  });
}
