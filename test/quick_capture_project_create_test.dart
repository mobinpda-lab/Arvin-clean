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
              projects: <ProjectPlan>[
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

    final projectPill = find.byKey(const ValueKey('quick-capture-project-rollbox'));
    await tester.ensureVisible(projectPill);
    await tester.tap(projectPill);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quick-capture-create-project')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick-capture-create-project')));
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
