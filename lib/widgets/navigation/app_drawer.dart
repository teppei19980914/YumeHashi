/// ナビゲーションドロワーウィジェット.
///
/// Python版のNavigationDrawerに対応し、6ページへのナビゲーションを提供する.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_labels.dart';
import '../tutorial/tutorial_target_keys.dart';

/// ナビゲーション項目の定義.
class NavItem {
  /// NavItemを作成する.
  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });

  /// アイコン.
  final IconData icon;

  /// 選択時アイコン.
  final IconData selectedIcon;

  /// ラベル.
  final String label;

  /// ルートパス.
  final String path;
}

/// メインナビゲーション項目一覧.
const navItems = [
  NavItem(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: AppLabels.pageHome,
    path: '/',
  ),
  NavItem(
    icon: Icons.auto_awesome_outlined,
    selectedIcon: Icons.auto_awesome,
    label: AppLabels.pageDreams,
    path: '/dreams',
  ),
  NavItem(
    icon: Icons.flag_outlined,
    selectedIcon: Icons.flag,
    label: AppLabels.pageGoals,
    path: '/goals',
  ),
  NavItem(
    icon: Icons.view_timeline_outlined,
    selectedIcon: Icons.view_timeline,
    label: AppLabels.pageSchedule,
    path: '/gantt',
  ),
  NavItem(
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    label: AppLabels.pageBooks,
    path: '/books',
  ),
  NavItem(
    icon: Icons.stars_outlined,
    selectedIcon: Icons.stars,
    label: AppLabels.pageConstellations,
    path: '/constellations',
  ),
  NavItem(
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    label: AppLabels.pageStats,
    path: '/stats',
  ),
];

/// 設定ナビゲーション項目.
const settingsItem = NavItem(
  icon: Icons.settings_outlined,
  selectedIcon: Icons.settings,
  label: AppLabels.pageSettings,
  path: '/settings',
);

/// アプリケーションのナビゲーションドロワー.
class AppDrawer extends StatelessWidget {
  /// AppDrawerを作成する.
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLabels.appName, style: theme.textTheme.titleLarge),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          const SizedBox(height: 8),

          // メインナビゲーション（スクロール可能）
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                for (final item in navItems)
                  _NavTile(
                    key: item.path == '/gantt'
                        ? TutorialTargetKeys.ganttDrawerItem
                        : null,
                    item: item,
                    selected: currentPath == item.path,
                    onTap: () => _navigate(context, item.path, currentPath),
                  ),
              ],
            ),
          ),

          // 設定
          _NavTile(
            item: settingsItem,
            selected: currentPath == settingsItem.path,
            onTap: () => _navigate(context, settingsItem.path, currentPath),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String path, String currentPath) {
    Navigator.of(context).pop();
    if (path != currentPath) {
      context.go(path);
    }
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(selected ? item.selectedIcon : item.icon),
        title: Text(item.label),
        selected: selected,
        onTap: onTap,
      ),
    );
  }
}
