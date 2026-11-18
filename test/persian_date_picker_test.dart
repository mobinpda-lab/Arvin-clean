import 'package:arvin/services/persian_date_formatter.dart';
import 'package:arvin/widgets/persian_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = PersianDateFormatter();

  test('Gregorian and Jalali conversion round-trip known Iran date', () {
    final jalali = formatter.toJalali(DateTime(2026, 8, 27));

    expect(jalali.year, 1405);
    expect(jalali.month, 6);
    expect(jalali.day, 5);
    expect(
      formatter.format(DateTime(2026, 8, 27), usePersianDate: true),
      '۱۴۰۵/۰۶/۰۵',
    );

    final gregorian = formatter.fromJalali(jalali);
    expect(gregorian, DateTime(2026, 8, 27));
  });

  testWidgets('picker is Persian Jalali and returns selected Gregorian value',
      (tester) async {
    DateTime? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  selected = await showPersianDatePicker(
                    context: context,
                    initialDate: DateTime(2026, 8, 27),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    helpText: 'انتخاب تاریخ پیگیری',
                  );
                },
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);
    expect(find.text('انتخاب تاریخ پیگیری'), findsOneWidget);
    expect(find.text('شهریور'), findsOneWidget);
    expect(find.text('۱۴۰۵'), findsOneWidget);
    expect(find.text('۵ شهریور ۱۴۰۵'), findsOneWidget);
    expect(find.textContaining('Aug'), findsNothing);
    expect(find.textContaining('Thu'), findsNothing);
    expect(find.text('August'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('persian-date-day-6')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'تأیید'));
    await tester.pumpAndSettle();

    expect(selected, DateTime(2026, 8, 28));
  });
}
