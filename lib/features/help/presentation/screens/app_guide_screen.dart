import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// アプリガイド画面
///
/// 初回起動時（[isFirstLaunch] = true）は「始める」ボタンで /home へ遷移。
/// 設定からの手動閲覧時はシンプルな戻る導線のみ。
class AppGuideScreen extends StatefulWidget {
  final bool isFirstLaunch;

  const AppGuideScreen({super.key, required this.isFirstLaunch});

  @override
  State<AppGuideScreen> createState() => _AppGuideScreenState();
}

class _GuidePage {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _GuidePage({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}

class _AppGuideScreenState extends State<AppGuideScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _GuidePage(
      icon: Icons.trending_down_rounded,
      color: AppTheme.errorColor,
      title: '放置損失メーター',
      description:
          '期限切れのタスクを放置すると、失われる金額をリアルタイムで見える化します。'
          '損を可視化することで、うっかり忘れを防ぎます。',
    ),
    _GuidePage(
      icon: Icons.calendar_month_rounded,
      color: AppTheme.primaryColor,
      title: '人生の締め切りカレンダー',
      description:
          '免許更新・保険・税務申告など、日本の法定期限を自動で検出。'
          '見落としがちな重要な期限をカレンダーで一元管理します。',
    ),
    _GuidePage(
      icon: Icons.document_scanner_rounded,
      color: AppTheme.accentColor,
      title: '書類カメラ',
      description:
          '書類を撮影するだけで、期限や金額をAIが自動抽出。'
          'タスクへの入力の手間を大幅に削減します。',
    ),
    _GuidePage(
      icon: Icons.local_fire_department_rounded,
      color: AppTheme.warningColor,
      title: '防衛ストリーク',
      description:
          '期限を守り続けた日数を記録し、継続をゲーム感覚で応援。'
          '家族と一緒に防衛記録を伸ばしましょう。',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    if (widget.isFirstLaunch) {
      context.goNamed('home');
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed('home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isFirstLaunch
          ? null
          : AppBar(
              title: const Text('アプリガイド'),
              backgroundColor: Colors.white,
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.isFirstLaunch)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('スキップ'),
                ),
              ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _GuidePageView(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: FilledButton(
                onPressed: isLastPage
                    ? _finish
                    : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                child: Text(
                  isLastPage
                      ? (widget.isFirstLaunch ? '始める' : '閉じる')
                      : '次へ',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidePageView extends StatelessWidget {
  final _GuidePage page;
  const _GuidePageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 56, color: page.color),
          ),
          const Gap(32),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
