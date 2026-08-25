import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/official_calendar_page.dart';

void main() {
  testWidgets('opens the RTL drawer and navigates to the official calendar',
      (tester) async {
    const stored =
        '[{"id":"task-1","title":"کار نمونه","followUpEnabled":false,"futureField":{"keep":true}}]';
    SharedPreferences.setMockInitialValues(<String, Object>{
      'arvin.tasks': stored,
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).first);
    expect(scaffold.widget.drawer, isNotNull);
    expect(Directionality.of(scaffold.context), TextDirection.rtl);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('تقویم'), findsOneWidget);
    expect(scaffold.isDrawerOpen, isTrue);

    final drawerRect = tester.getRect(find.byType(Drawer));
    expect(
      drawerRect.center.dx,
      greaterThan(tester.getSize(find.byType(Scaffold).first).width / 2),
    );

    await tester.tap(find.text('تقویم'));
    await tester.pumpAndSettle();

    expect(find.byType(IranianOfficialCalendarPage), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(IranianOfficialCalendarPage))),
      TextDirection.rtl,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('arvin.tasks'), stored);
  });

  testWidgets('passes canonical follow-up history into the calendar',
      (tester) async {
    const stored =
        '[{"id":"task-follow","title":"تماس با مشتری","followUpEnabled":true,"followUpDate":"2026-08-26T09:00:00.000","followUps":[{"id":"fu-1","dateTime":"2026-08-27T10:30:00.000","note":"نتیجه جلسه"}]}]';
    SharedPreferences.setMockInitialValues(<String, Object>{
      'arvin.tasks': stored,
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تقویم'));
    await tester.pumpAndSettle();

    final page = tester.widget<IranianOfficialCalendarPage>(
      find.byType(IranianOfficialCalendarPage),
    );
    expect(page.reminders, hasLength(1));
    expect(page.reminders.single.id, 'followup:task-follow:fu-1');
    expect(page.reminders.single.title, 'تماس با مشتری — نتیجه جلسه');
    expect(page.reminders.single.date, DateTime(2026, 8, 27, 10, 30));
  });
}
