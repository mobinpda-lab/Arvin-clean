import 'package:arvin/services/persian_date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = PersianDateFormatter();

  test('preserves current Gregorian Home format when Persian date is off', () {
    expect(
      formatter.format(DateTime(2026, 8, 26), usePersianDate: false),
      '2026/08/26',
    );
  });

  test('formats the same day as Persian Jalali date with Persian digits', () {
    expect(
      formatter.format(DateTime(2026, 8, 26), usePersianDate: true),
      '۱۴۰۵/۰۶/۰۴',
    );
  });

  test('formats 24-hour time consistently with Persian digits and leading zeros', () {
    expect(formatter.formatTime(3, 5), '۰۳:۰۵');
    expect(formatter.formatTime(23, 0), '۲۳:۰۰');
  });

  test('rejects invalid hour and minute values', () {
    expect(() => formatter.formatTime(24, 0), throwsRangeError);
    expect(() => formatter.formatTime(10, 60), throwsRangeError);
  });
}
