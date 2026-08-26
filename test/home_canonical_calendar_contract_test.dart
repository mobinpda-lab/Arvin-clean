import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/widgets/canonical_calendar_launcher.dart';

void main() {
  testWidgets('Home calendar route uses the canonical launcher', (tester) async {
    const stored =
        '[{"id":"task-1","title":"کار نمونه","followUps":[{"id":"follow-1","date":"2026-08-26T09:00:00.000","note":"پیگیری نمونه","completed":false}]}]';
    SharedPreferences.setMockInitialValues(<String, Object>{
      'arvin.tasks': stored,
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تقویم'));
    await tester.pumpAndSettle();

    expect(find.byType(CanonicalCalendarLauncher), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('arvin.tasks'), stored);
  });
}
