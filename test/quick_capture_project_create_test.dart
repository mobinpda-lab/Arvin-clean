import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/quick_capture_dialog.dart';

void main() {
  testWidgets('Quick Add offers Project create-new and selects the created project',
      (tester) async {
    String? createdTitle;
    var createdId = 'project-created-1';

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              projects: const <ProjectPlan>[
                ProjectPlan(id: 'project-created-1', title: 'پروژه آزمایشی'),
              ],
              onCreateProject: (title) async {
                createdTitle = title;
                return createdId;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('پروژه'));
    await tester.pumpAndSettle();
    expect(find.text('ایجاد جدید'), findsOneWidget);

    await tester.tap(find.text('ایجاد جدید'));
    await tester.pumpAndSettle();
    expect(find.text('پروژه جدید'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'پروژه آزمایشی');
    await tester.tap(find.text('افزودن'));
    await tester.pumpAndSettle();

    expect(createdTitle, 'پروژه آزمایشی');
    expect(find.text('پروژه آزمایشی'), findsWidgets);
  });
}
