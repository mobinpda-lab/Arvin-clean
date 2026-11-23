import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/official_calendar_page.dart';

void main() {
  testWidgets('primary Home navigation opens the official calendar', (tester) async {
    const stored = '[{"id":"task-1","title":"کار نمونه","followUpEnabled":false,"futureField":{"keep":true}}]';
    SharedPreferences.setMockInitialValues(<String, Object>{'arvin.tasks': stored});

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('تقویم'), findsOneWidget);
    await tester.tap(find.text('تقویم').last);
    await tester.pumpAndSettle();

    expect(find.byType(IranianOfficialCalendarPage), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(IranianOfficialCalendarPage))), TextDirection.rtl);

    // Calendar owns additional top-level controls, so do not depend on the
    // framework Back tooltip hit-test location. Pop the route explicitly.
    final calendarContext = tester.element(find.byType(IranianOfficialCalendarPage));
    Navigator.of(calendarContext).pop();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('arvin.tasks'), stored);
  });
}
