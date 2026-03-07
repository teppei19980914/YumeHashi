/// テーマのProvider定義.
///
/// SharedPreferencesでテーマ設定を永続化する.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

const _themeKey = 'theme_type';

/// SharedPreferencesのProvider.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProviderはmain()でoverrideしてください',
  );
});

/// テーマタイプの状態を管理するNotifier.
class ThemeNotifier extends Notifier<ThemeType> {
  @override
  ThemeType build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_themeKey);
    return saved == 'light' ? ThemeType.light : ThemeType.dark;
  }

  /// テーマを切り替える.
  void toggleTheme() {
    state = state == ThemeType.dark ? ThemeType.light : ThemeType.dark;
    _save();
  }

  /// テーマを設定する.
  void setTheme(ThemeType type) {
    state = type;
    _save();
  }

  void _save() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_themeKey, state.name);
  }
}

/// テーマタイプのProvider.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeType>(
  ThemeNotifier.new,
);
