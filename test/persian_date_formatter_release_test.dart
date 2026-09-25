import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/persian_date_formatter.dart';

void main() {
  const formatter = PersianDateFormatter();

  test('formats the owner release example as Jalali with Persian digits', () {
    final value = formatter.format(
      DateTime(2026, 9, 21, 14, 5),
      usePersianDate: true,
    );

    expect(value, '۱۴۰۵/۰۶/۳۰');
    expect(value, isNot(contains('2026')));
  });

  test('keeps Gregorian formatting opt-in and separate from Jalali mode', () {
    final value = formatter.format(
      DateTime(2026, 9, 21),
      usePersianDate: false,
    );

    expect(value, '2026/09/21');
  });

  test('converts Persian digits without changing non-numeric text', () {
    expect(
      formatter.toPersianDigits('۱۴۰۵/۰۶/۳۰ ساعت 14:05'),
      '۱۴۰۵/۰۶/۳۰ ساعت ۱۴:۰۵',
    );
  });

  test('Jalali month lengths preserve Esfand leap-year behavior', () {
    expect(formatter.monthLength(1403, 12), 30);
    expect(formatter.monthLength(1404, 12), 29);
  });
}
