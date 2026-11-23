import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/calendar_page.dart';
import 'package:arvin/daily_content.dart';

const _daily = DailyContentItem(
  id: 'quran-2-153',
  kind: DailyContentKind.quran,
  text: 'از صبر و نماز یاری بجویید.',
  author: 'قرآن کریم',
  source: 'قرآن کریم',
  reference: 'سوره بقره، آیه ۱۵۳',
  verifiedBy: 'مرجع معتبر',
  originalText: 'استعينوا بالصبر والصلاة',
);

void main() {
  testWidgets('Daily Content is visible even when there are no reminders', (tester) async {
    final day = DateTime(2026, 8, 27);

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          reminders: const [],
          initialSelectedDay: day,
          dailyContentForDate: (_) => _daily,
        ),
      ),
    );

    expect(find.text('پیام روز • قرآن کریم'), findsOneWidget);
    expect(find.textContaining('سوره بقره، آیه ۱۵۳'), findsOneWidget);
    expect(find.text('برای این روز یادآوری ثبت نشده است'), findsNothing);
  });

  testWidgets('Daily Content and normal reminder coexist on selected day', (tester) async {
    final day = DateTime(2026, 8, 27, 9);

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          reminders: [
            CalendarReminder(id: 'r1', title: 'پیگیری قرارداد', date: day),
          ],
          initialSelectedDay: day,
          dailyContentForDate: (_) => _daily,
        ),
      ),
    );

    expect(find.text('پیام روز • قرآن کریم'), findsOneWidget);
    expect(find.text('پیگیری قرارداد'), findsOneWidget);
  });

  testWidgets('tapping Daily Content opens source detail sheet', (tester) async {
    final day = DateTime(2026, 8, 27);

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          reminders: const [],
          initialSelectedDay: day,
          dailyContentForDate: (_) => _daily,
        ),
      ),
    );

    await tester.tap(find.text('پیام روز • قرآن کریم'));
    await tester.pumpAndSettle();

    expect(find.text('تطبیق/تأیید: مرجع معتبر'), findsOneWidget);
    expect(find.text('استعينوا بالصبر والصلاة'), findsOneWidget);
  });
}
