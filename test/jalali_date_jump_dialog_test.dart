import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin_task_tracker/widgets/jalali_date_jump_dialog.dart';

void main() {
  testWidgets('returns the selected Jalali date without calendar side effects',
      (tester) async {
    JalaliDateSelection? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showJalaliDateJumpDialog(
                  context,
                  initialYear: 1405,
                  initialMonth: 6,
                  initialDay: 7,
                  daysInMonth: (_, month) => month <= 6 ? 31 : 30,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('برو به تاریخ'), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-jump-year')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-jump-month')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-jump-day')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-jump-apply')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.year, 1405);
    expect(result!.month, 6);
    expect(result!.day, 7);
  });

  testWidgets('cancel leaves the calendar selection unchanged', (tester) async {
    JalaliDateSelection? result =
        const JalaliDateSelection(year: 1400, month: 1, day: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showJalaliDateJumpDialog(
                  context,
                  initialYear: 1405,
                  initialMonth: 1,
                  initialDay: 1,
                  daysInMonth: (_, __) => 31,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar-jump-cancel')));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
