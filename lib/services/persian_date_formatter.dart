class PersianDateFormatter {
  const PersianDateFormatter();

  static const _monthNames = <String>[
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  String format(DateTime date, {required bool usePersianDate}) {
    if (!usePersianDate) {
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }

    final jalali = toJalali(date);
    return toPersianDigits(
      '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}',
    );
  }

  JalaliDate toJalali(DateTime date) {
    final gy = date.year - 1600;
    final gm = date.month - 1;
    final gd = date.day - 1;
    const gDays = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var gDayNo =
        365 * gy + (gy + 3) ~/ 4 - (gy + 99) ~/ 100 + (gy + 399) ~/ 400;
    for (var i = 0; i < gm; i++) {
      gDayNo += gDays[i];
    }
    if (gm > 1 && _isGregorianLeap(date.year)) {
      gDayNo++;
    }
    gDayNo += gd;

    var jDayNo = gDayNo - 79;
    final jNp = jDayNo ~/ 12053;
    jDayNo %= 12053;
    var jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
    jDayNo %= 1461;
    if (jDayNo >= 366) {
      jy += (jDayNo - 1) ~/ 365;
      jDayNo = (jDayNo - 1) % 365;
    }
    final jm = jDayNo < 186 ? 1 + jDayNo ~/ 31 : 7 + (jDayNo - 186) ~/ 30;
    final jd =
        1 + (jDayNo < 186 ? jDayNo % 31 : (jDayNo - 186) % 30);
    return JalaliDate(jy, jm, jd);
  }

  DateTime fromJalali(JalaliDate date) {
    var jy = date.year - 979;
    var jDayNo =
        365 * jy + (jy ~/ 33) * 8 + ((jy % 33) + 3) ~/ 4;

    if (date.month <= 6) {
      jDayNo += (date.month - 1) * 31;
    } else {
      jDayNo += 186 + (date.month - 7) * 30;
    }
    jDayNo += date.day - 1;

    var gDayNo = jDayNo + 79;
    var gy = 1600 + 400 * (gDayNo ~/ 146097);
    gDayNo %= 146097;

    var leap = true;
    if (gDayNo >= 36525) {
      gDayNo--;
      gy += 100 * (gDayNo ~/ 36524);
      gDayNo %= 36524;
      if (gDayNo >= 365) {
        gDayNo++;
      } else {
        leap = false;
      }
    }

    gy += 4 * (gDayNo ~/ 1461);
    gDayNo %= 1461;
    if (gDayNo >= 366) {
      leap = false;
      gDayNo--;
      gy += gDayNo ~/ 365;
      gDayNo %= 365;
    }

    final gDays = <int>[
      31,
      leap ? 29 : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];
    var gm = 0;
    while (gm < gDays.length && gDayNo >= gDays[gm]) {
      gDayNo -= gDays[gm];
      gm++;
    }

    return DateTime(gy, gm + 1, gDayNo + 1);
  }

  int monthLength(int year, int month) {
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return _isJalaliLeap(year) ? 30 : 29;
  }

  String monthName(int month) {
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    return _monthNames[month - 1];
  }

  String toPersianDigits(String value) {
    const western = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    var result = value;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], persian[i]);
    }
    return result;
  }

  bool _isJalaliLeap(int year) {
    final start = fromJalali(JalaliDate(year, 1, 1));
    final next = fromJalali(JalaliDate(year + 1, 1, 1));
    return next.difference(start).inDays == 366;
  }

  bool _isGregorianLeap(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}

class JalaliDate {
  const JalaliDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;
}
