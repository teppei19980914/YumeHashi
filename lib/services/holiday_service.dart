/// 日本の祝日判定サービス.
library;

/// 日本の祝日を判定するサービス.
///
/// 祝日データのキャッシュにより、同一年の複数回呼び出しを高速化する.
class HolidayService {
  final _cache = <int, Map<DateTime, String>>{};

  /// 指定日が祝日かどうかを判定する.
  bool isHoliday(DateTime date) {
    final holidays = _getYearHolidays(date.year);
    final key = DateTime(date.year, date.month, date.day);
    return holidays.containsKey(key);
  }

  /// 指定日の祝日名を取得する.
  String? getHolidayName(DateTime date) {
    final holidays = _getYearHolidays(date.year);
    final key = DateTime(date.year, date.month, date.day);
    return holidays[key];
  }

  /// 指定年月の祝日を取得する.
  Map<DateTime, String> getHolidaysInMonth(int year, int month) {
    final yearHolidays = _getYearHolidays(year);
    return {
      for (final entry in yearHolidays.entries)
        if (entry.key.month == month) entry.key: entry.value,
    };
  }

  /// 指定日が土曜日かどうかを判定する.
  bool isSaturday(DateTime date) => date.weekday == DateTime.saturday;

  /// 指定日が日曜日かどうかを判定する.
  bool isSunday(DateTime date) => date.weekday == DateTime.sunday;

  /// キャッシュをクリアする.
  void clearCache() => _cache.clear();

  Map<DateTime, String> _getYearHolidays(int year) {
    return _cache.putIfAbsent(year, () => _calculateHolidays(year));
  }

  /// 指定年の日本の祝日を計算する.
  static Map<DateTime, String> _calculateHolidays(int year) {
    final holidays = <DateTime, String>{};

    // 元日 (1/1)
    holidays[DateTime(year, 1, 1)] = '元日';

    // 成人の日 (1月第2月曜)
    holidays[_nthWeekday(year, 1, DateTime.monday, 2)] = '成人の日';

    // 建国記念の日 (2/11)
    holidays[DateTime(year, 2, 11)] = '建国記念の日';

    // 天皇誕生日 (2/23) — 2020年以降
    if (year >= 2020) {
      holidays[DateTime(year, 2, 23)] = '天皇誕生日';
    }

    // 春分の日
    final vernalEquinox = _vernalEquinoxDay(year);
    if (vernalEquinox != null) {
      holidays[DateTime(year, 3, vernalEquinox)] = '春分の日';
    }

    // 昭和の日 (4/29)
    holidays[DateTime(year, 4, 29)] = '昭和の日';

    // 憲法記念日 (5/3)
    holidays[DateTime(year, 5, 3)] = '憲法記念日';

    // みどりの日 (5/4)
    holidays[DateTime(year, 5, 4)] = 'みどりの日';

    // こどもの日 (5/5)
    holidays[DateTime(year, 5, 5)] = 'こどもの日';

    // 海の日 (7月第3月曜)
    holidays[_nthWeekday(year, 7, DateTime.monday, 3)] = '海の日';

    // 山の日 (8/11)
    holidays[DateTime(year, 8, 11)] = '山の日';

    // 敬老の日 (9月第3月曜)
    holidays[_nthWeekday(year, 9, DateTime.monday, 3)] = '敬老の日';

    // 秋分の日
    final autumnalEquinox = _autumnalEquinoxDay(year);
    if (autumnalEquinox != null) {
      holidays[DateTime(year, 9, autumnalEquinox)] = '秋分の日';
    }

    // スポーツの日 (10月第2月曜)
    holidays[_nthWeekday(year, 10, DateTime.monday, 2)] = 'スポーツの日';

    // 文化の日 (11/3)
    holidays[DateTime(year, 11, 3)] = '文化の日';

    // 勤労感謝の日 (11/23)
    holidays[DateTime(year, 11, 23)] = '勤労感謝の日';

    // 振替休日の処理
    final substituteHolidays = <DateTime, String>{};
    for (final date in holidays.keys) {
      if (date.weekday == DateTime.sunday) {
        var substitute = date.add(const Duration(days: 1));
        while (holidays.containsKey(substitute) ||
            substituteHolidays.containsKey(substitute)) {
          substitute = substitute.add(const Duration(days: 1));
        }
        substituteHolidays[substitute] = '振替休日';
      }
    }
    holidays.addAll(substituteHolidays);

    // 国民の休日（祝日に挟まれた平日）
    final sortedDates = holidays.keys.toList()..sort();
    for (var i = 0; i < sortedDates.length - 1; i++) {
      final diff = sortedDates[i + 1].difference(sortedDates[i]).inDays;
      if (diff == 2) {
        final between = sortedDates[i].add(const Duration(days: 1));
        if (between.weekday != DateTime.sunday &&
            !holidays.containsKey(between)) {
          holidays[between] = '国民の休日';
        }
      }
    }

    return holidays;
  }

  /// n番目の指定曜日を求める.
  static DateTime _nthWeekday(int year, int month, int weekday, int n) {
    final first = DateTime(year, month, 1);
    var daysToAdd = (weekday - first.weekday + 7) % 7;
    if (daysToAdd == 0 && n > 0) {
      // first day is already the target weekday
    } else {
      daysToAdd = (weekday - first.weekday + 7) % 7;
    }
    return first.add(Duration(days: daysToAdd + (n - 1) * 7));
  }

  /// 春分の日を計算する.
  static int? _vernalEquinoxDay(int year) {
    if (year < 1900 || year > 2099) return null;
    if (year <= 1979) {
      return (20.8357 + 0.242194 * (year - 1980) - ((year - 1983) ~/ 4))
          .floor();
    }
    if (year <= 2099) {
      return (20.8431 + 0.242194 * (year - 1980) - ((year - 1980) ~/ 4))
          .floor();
    }
    return null;
  }

  /// 秋分の日を計算する.
  static int? _autumnalEquinoxDay(int year) {
    if (year < 1900 || year > 2099) return null;
    if (year <= 1979) {
      return (23.2588 + 0.242194 * (year - 1980) - ((year - 1983) ~/ 4))
          .floor();
    }
    if (year <= 2099) {
      return (23.2488 + 0.242194 * (year - 1980) - ((year - 1980) ~/ 4))
          .floor();
    }
    return null;
  }
}
