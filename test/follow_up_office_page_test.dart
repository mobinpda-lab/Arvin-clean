import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_office_page.dart';

void main() {
  testWidgets('shows dedicated follow-up office shell', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: FollowUpOfficePage()));
    await tester.pumpAndSettle();
    expect(find.text('دفتر پیگیری'), findsOneWidget);
  });
}
