class PersianDateFormatter {
  const PersianDateFormatter();

  String format(DateTime date, {required bool usePersianDate}) {
    if (!usePersianDate) {
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }

    final jalali = _toJalali(date);
    return _digits(
      '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}',
    );
  }

  _JalaliDate _toJalali(DateTime date) {
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
    return _JalaliDate(jy, jm, jd);
  }

  bool _isGregorianLeap(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  String _digits(String value) {
    const western = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    var result = value;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], persian[i]);
    }
    return result;
  }
}

class _JalaliDate {
  const _JalaliDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;
}
