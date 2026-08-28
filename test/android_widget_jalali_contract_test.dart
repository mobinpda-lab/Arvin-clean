import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/persian_date_formatter.dart';

void main() {
  test('canonical known date converts to the owner-approved Jalali value', () {
    const formatter = PersianDateFormatter();

    expect(
      formatter.format(DateTime(2026, 8, 28), usePersianDate: true),
      '۱۴۰۵/۰۶/۰۶',
    );
  });

  test('native widget derives Jalali date and Persian time from canonical ISO', () {
    final source = File(
      'android/app/src/main/kotlin/com/example/arvin/ArvinWidgetProvider.kt',
    ).readAsStringSync();

    expect(source, contains('toJalali(year, month, day)'));
    expect(source, contains('toPersianDigits(date)'));
    expect(source, contains('toPersianDigits(time)'));
    expect(source, contains('private fun isGregorianLeap'));
    expect(
      source,
      isNot(contains(r'return "${value.substring(0, 10)} | ${value.substring(11, 16)}"')),
    );
  });
}
