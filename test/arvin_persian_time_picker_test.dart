import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/widgets/universal_arvin_time_picker.dart';

void main() {
  testWidgets('shows a Persian 24-hour value and saves a selected minute',
      (tester) async {
    TimeOfDay? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                key: const ValueKey('open-time-picker'),
                onPressed: () async {
                  result = await showUniversalArvinTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 9, minute: 10),
                    helpText: 'زمان انجام کار',
                  );
                },
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-time-picker')));
    await tester.pumpAndSettle();

    expect(find.text('زمان انجام کار'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('universal-time-selected-value')),
      findsOneWidget,
    );
    expect(find.text('۰۹'), findsOneWidget);
    expect(find.text('۱۰'), findsOneWidget);

    await tester.tap(find.text('دقیقه'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-minute-5')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('universal-time-save')));
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    expect(result, const TimeOfDay(hour: 9, minute: 5));
  });

  testWidgets('accepts exact Persian-digit manual time entry', (tester) async {
    TimeOfDay? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                key: const ValueKey('open-time-picker'),
                onPressed: () async {
                  result = await showUniversalArvinTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 8, minute: 0),
                    helpText: 'زمان یادآوری',
                  );
                },
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-time-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-manual-toggle')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('universal-time-manual-input')),
      '۲۳:۴۷',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    expect(result, const TimeOfDay(hour: 23, minute: 47));
  });

  testWidgets('selects inner-ring late hours in the 24-hour clock', (tester) async {
    TimeOfDay? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                key: const ValueKey('open-time-picker'),
                onPressed: () async {
                  result = await showUniversalArvinTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 8, minute: 0),
                    helpText: 'زمان انجام کار',
                  );
                },
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-time-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-hour-inner-۲۳')));
    await tester.pumpAndSettle();
    expect(find.text('۲۳'), findsOneWidget);
    expect(find.text('۰۰'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('universal-time-save')));
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    expect(result, const TimeOfDay(hour: 23, minute: 0));
  });

  testWidgets('cancel returns null and does not commit the selected time',
      (tester) async {
    TimeOfDay? result = const TimeOfDay(hour: 4, minute: 30);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                key: const ValueKey('open-time-picker'),
                onPressed: () async {
                  result = await showUniversalArvinTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 4, minute: 30),
                    helpText: 'زمان پیگیری',
                  );
                },
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-time-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-cancel')));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}