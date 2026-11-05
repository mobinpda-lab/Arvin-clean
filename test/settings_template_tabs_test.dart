import 'package:arvin/task_template_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Settings template hub exposes two distinct operational tabs', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: TemplatesSettingsPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('task-templates-tab')), findsOneWidget);
    expect(find.byKey(const ValueKey('project-templates-tab')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-template-management-list')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('project-templates-tab')));
    await tester.pumpAndSettle();
    expect(find.text('قالب جدید'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-templates-tab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-template-management-list')), findsOneWidget);
  });
}
