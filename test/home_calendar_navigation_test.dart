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

    final calendarDrawerItem = find.widgetWithText(ListTile, 'تقویم');
    expect(calendarDrawerItem, findsOneWidget);
    expect(scaffold.isDrawerOpen, isTrue);

    final drawerRect = tester.getRect(find.byType(Drawer));
    expect(
      drawerRect.center.dx,
      greaterThan(tester.getSize(find.byType(Scaffold).first).width / 2),
    );

    await tester.tap(calendarDrawerItem);
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
}
