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
}
