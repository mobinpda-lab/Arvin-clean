import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_office_page.dart';

void main() {
  testWidgets('shows dedicated follow-up office shell', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: FollowUpOfficePage()));
    // The page starts with a loading spinner. Do not use pumpAndSettle here:
    // an indeterminate progress indicator is intentionally never idle while
    // the async SharedPreferences load is pending.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('دفتر پیگیری'), findsOneWidget);
  });
}
