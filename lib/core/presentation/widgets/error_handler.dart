import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';

/// エラータイプの分類
enum ErrorType {
  /// ドキュメント/リソースが見つからない (404)
  notFound,

  /// 権限がない (403 Forbidden)
  permissionDenied,

  /// ネットワークエラー
  networkError,

  /// 認証エラー
  authenticationError,

  /// その他のエラー
  unknown,
}

/// エラー情報を保持するクラス
class ErrorInfo {
  final ErrorType type;
  final String title;
  final String message;
  final IconData icon;
  final String actionLabel;
  final VoidCallback? onAction;

  /// 元の Firebase エラーコード（デバッグ用）
  final String? errorCode;

  /// リトライ可能か判定（ネットワークエラーなど）
  final bool isRetryable;

  ErrorInfo({
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel = '戻る',
    this.onAction,
    this.errorCode,
    this.isRetryable = false,
  });

  /// 例外からエラータイプを判定
  static ErrorInfo fromException(
    dynamic exception, {
    String? fallbackMessage,
    VoidCallback? onAction,
  }) {
    if (exception is FirebaseException) {
      final code = exception.code;
      switch (code) {
        case 'permission-denied':
          return ErrorInfo(
            type: ErrorType.permissionDenied,
            title: 'アクセスできません',
            message: 'このリソースにアクセスする権限がありません。',
            icon: Icons.lock_outline,
            actionLabel: '戻る',
            onAction: onAction,
            errorCode: code,
            isRetryable: false,
          );

        case 'not-found':
          return ErrorInfo(
            type: ErrorType.notFound,
            title: '見つかりません',
            message: 'お探しのアイテムは削除されているか、アクセスできません。',
            icon: Icons.search_off_rounded,
            actionLabel: '戻る',
            onAction: onAction,
            errorCode: code,
            isRetryable: false,
          );

        case 'unavailable':
        case 'deadline-exceeded':
          return ErrorInfo(
            type: ErrorType.networkError,
            title: 'ネットワークエラー',
            message: 'インターネット接続を確認してください。',
            icon: Icons.wifi_off_rounded,
            actionLabel: 'リトライ',
            onAction: onAction,
            errorCode: code,
            isRetryable: true,
          );

        case 'resource-exhausted':
        case 'internal':
          return ErrorInfo(
            type: ErrorType.networkError,
            title: 'サーバーエラー',
            message: '一時的なエラーが発生しました。後でお試しください。',
            icon: Icons.cloud_off_rounded,
            actionLabel: 'リトライ',
            onAction: onAction,
            errorCode: code,
            isRetryable: true,
          );

        default:
          return ErrorInfo(
            type: ErrorType.unknown,
            title: 'エラーが発生しました',
            message: fallbackMessage ?? exception.message ?? '予期しないエラーが発生しました。',
            icon: Icons.error_outline,
            actionLabel: '戻る',
            onAction: onAction,
            errorCode: code,
            isRetryable: false,
          );
      }
    }

    if (exception is FirebaseAuthException) {
      final code = exception.code;
      switch (code) {
        case 'user-not-found':
          return ErrorInfo(
            type: ErrorType.authenticationError,
            title: 'ユーザーが見つかりません',
            message: 'このユーザーアカウントは存在しません。',
            icon: Icons.person_off_rounded,
            actionLabel: '戻る',
            onAction: onAction,
            errorCode: code,
            isRetryable: false,
          );

        case 'invalid-credential':
        case 'wrong-password':
          return ErrorInfo(
            type: ErrorType.authenticationError,
            title: '認証に失敗しました',
            message: 'ログイン情報が正しくありません。',
            icon: Icons.lock_outline,
            actionLabel: '戻る',
            onAction: onAction,
            errorCode: code,
            isRetryable: false,
          );

        case 'network-request-failed':
          return ErrorInfo(
            type: ErrorType.networkError,
            title: 'ネットワークエラー',
            message: 'インターネット接続を確認してください。',
            icon: Icons.wifi_off_rounded,
            actionLabel: 'リトライ',
            onAction: onAction,
            errorCode: code,
            isRetryable: true,
          );

        case 'too-many-requests':
          return ErrorInfo(
            type: ErrorType.networkError,
            title: 'リクエストが多すぎます',
            message: 'しばらく待ってからお試しください。',
            icon: Icons.hourglass_empty_rounded,
            actionLabel: 'リトライ',
            onAction: onAction,
            errorCode: code,
            isRetryable: true,
          );

        default:
          return ErrorInfo(
            type: ErrorType.authenticationError,
            title: 'ログインエラー',
            message: fallbackMessage ?? exception.message ?? '認証エラーが発生しました。',
            icon: Icons.lock_outline,
            actionLabel: '戻る',
            onAction: onAction,
            errorCode: code,
            isRetryable: false,
          );
      }
    }

    // その他のエラー
    return ErrorInfo(
      type: ErrorType.unknown,
      title: 'エラーが発生しました',
      message: fallbackMessage ?? exception.toString(),
      icon: Icons.error_outline,
      actionLabel: '戻る',
      onAction: onAction,
      isRetryable: false,
    );
  }
}

/// エラー表示用の統一 Widget
class ErrorHandlerWidget extends StatelessWidget {
  final ErrorInfo errorInfo;
  final EdgeInsets padding;

  const ErrorHandlerWidget({
    super.key,
    required this.errorInfo,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アイコン
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getErrorColor(errorInfo.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorInfo.icon,
                size: 40,
                color: _getErrorColor(errorInfo.type),
              ),
            ),

            const SizedBox(height: 24),

            // タイトル
            Text(
              errorInfo.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // メッセージ
            Text(
              errorInfo.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // アクション ボタン
            if (errorInfo.onAction != null)
              FilledButton(
                onPressed: errorInfo.onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: _getErrorColor(errorInfo.type),
                  minimumSize: const Size(150, 48),
                ),
                child: Text(errorInfo.actionLabel),
              ),
          ],
        ),
      ),
    );
  }

  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.notFound:
        return Colors.orange;
      case ErrorType.permissionDenied:
        return AppTheme.errorColor;
      case ErrorType.networkError:
        return Colors.blue.shade600;
      case ErrorType.authenticationError:
        return AppTheme.errorColor;
      case ErrorType.unknown:
        return Colors.grey.shade600;
    }
  }
}

/// AsyncValue のエラー状態を処理する拡張メソッド
extension AsyncErrorHandler on AsyncValue {
  /// エラーが発生しているかチェック
  bool get hasError => this is AsyncError;

  /// エラー情報を取得
  ErrorInfo? get errorInfo {
    if (this is AsyncError) {
      final asyncError = this as AsyncError;
      return ErrorInfo.fromException(asyncError.error);
    }
    return null;
  }
}

/// エラー画面テンプレート（AppBar 付き）
class ErrorScreenTemplate extends StatelessWidget {
  final String appBarTitle;
  final ErrorInfo errorInfo;
  final VoidCallback onRetry;

  const ErrorScreenTemplate({
    super.key,
    required this.appBarTitle,
    required this.errorInfo,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: ErrorHandlerWidget(
        errorInfo: errorInfo.copyWith(onAction: onRetry),
      ),
    );
  }
}

/// ErrorInfo のコピーメソッド
extension ErrorInfoExtension on ErrorInfo {
  ErrorInfo copyWith({
    ErrorType? type,
    String? title,
    String? message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    String? errorCode,
    bool? isRetryable,
  }) {
    return ErrorInfo(
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      actionLabel: actionLabel ?? this.actionLabel,
      onAction: onAction ?? this.onAction,
      errorCode: errorCode ?? this.errorCode,
      isRetryable: isRetryable ?? this.isRetryable,
    );
  }
}
