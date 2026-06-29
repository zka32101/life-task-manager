import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_task_manager/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('ログインボタンと無料トライアル文言が表示される', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();
      expect(find.text('Google でログイン'), findsOneWidget);
      expect(find.textContaining('30日間'), findsOneWidget);
    });
  });
}
