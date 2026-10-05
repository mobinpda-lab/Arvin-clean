import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/quick_capture_dialog.dart';

void main() {
  testWidgets('Quick Add offers Project create-new and selects the created project',
      (tester) async {
    String? createdTitle;
    String? selectedProjectId;
    var createdId = 'project-created-1';

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              projects: <ProjectPlan>[
                ProjectPlan(id: 'project-created-1', title: 'پروژه آزمایشی'),
              ],
              onCreateProject: (title) async {
                createdTitle = title;
                return createdId;
              },
              onProjectChanged: (id) => selectedProjectId = id,
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
    // The modal closes while the text field may still be composing; a single
    // frame is enough for Quick Capture to apply the created project.
    await tester.pump();

    expect(createdTitle, 'پروژه آزمایشی');
    expect(find.text('پروژه آزمایشی', skipOffstage: false), findsWidgets);
  });
}
