import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/data/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 環境変数読み込み
  await dotenv.load(fileName: '.env');

  // Firebase 初期化（duplicate-app を安全にハンドル）
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
    // 既に初期化済み（Firebase Messaging バックグラウンド等）→ 続行
  }

  // RevenueCat 初期化（プラットフォーム別 API キー）
  try {
    final revenueCatApiKey = Platform.isAndroid
        ? AppConstants.revenueCatApiKeyAndroid
        : AppConstants.revenueCatApiKeyIos;
    await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));
  } catch (e) {
    debugPrint('RevenueCat init error: $e');
  }

  // Sentry エラートラッキング（DSN が設定されている場合のみ）
  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment = dotenv.env['ENVIRONMENT'] ?? 'production';
      },
      appRunner: _runApp,
    );
  } else {
    _runApp();
  }
}

void _runApp() {
  runApp(
    const ProviderScope(
      child: LifeTaskApp(),
    ),
  );
  // 通知初期化は runApp 後に非同期で実行（main をブロックしない）
  NotificationService.initialize().catchError((e) {
    debugPrint('Notification init error: $e');
  });
}

class LifeTaskApp extends ConsumerWidget {
  const LifeTaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'LifeTask Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('de', 'DE'),
        Locale('fr', 'FR'),
        Locale('ko', 'KR'),
        Locale('es', 'ES'),
        Locale('pt', 'BR'),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
