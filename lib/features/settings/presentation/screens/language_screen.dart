import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// サポートロケール定義
///
/// (locale-code, flag emoji, display name)
const _supportedLocales = [
  ('ja-JP', '🇯🇵', '日本語（日本）'),
  ('en-US', '🇺🇸', 'English (United States)'),
  ('en-GB', '🇬🇧', 'English (United Kingdom)'),
  ('en-AU', '🇦🇺', 'English (Australia)'),
  ('en-CA', '🇨🇦', 'English (Canada)'),
  ('zh-CN', '🇨🇳', '中文（中国）'),
  ('zh-TW', '🇹🇼', '中文（台灣）'),
  ('de-DE', '🇩🇪', 'Deutsch (Deutschland)'),
  ('fr-FR', '🇫🇷', 'Français (France)'),
  ('es-ES', '🇪🇸', 'Español (España)'),
  ('ko-KR', '🇰🇷', '한국어 (대한민국)'),
  ('pt-BR', '🇧🇷', 'Português (Brasil)'),
];

/// 言語・地域選択画面
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  bool _isSaving = false;

  /// locale-code から language と country を分離する
  /// 例: 'ja-JP' → language='ja', country='JP'
  (String, String) _splitLocale(String code) {
    final parts = code.split('-');
    if (parts.length == 2) {
      return (parts[0], parts[1]);
    }
    return (code, '');
  }

  /// 現在の選択ロケールコードを profile から生成する
  String _currentLocaleCode(String language, String country) {
    return '$language-$country';
  }

  Future<void> _selectLocale(
    String localeCode,
    String currentLocaleCode,
  ) async {
    if (localeCode == currentLocaleCode || _isSaving) return;

    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    final (language, country) = _splitLocale(localeCode);

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'language': language, 'country': country});
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final currentLocaleCode = profile != null
        ? _currentLocaleCode(profile.language, profile.country)
        : 'ja-JP';

    return Scaffold(
      appBar: AppBar(title: const Text('言語・地域')),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _supportedLocales.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final (code, flag, label) = _supportedLocales[index];
                final isSelected = code == currentLocaleCode;

                return ListTile(
                  leading: Text(
                    flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(label),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                  onTap: () => _selectLocale(code, currentLocaleCode),
                );
              },
            ),
    );
  }
}
