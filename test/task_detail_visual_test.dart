import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  testWidgets(
    'Task Details renders all eleven structural surfaces without overflow and scrolls',
    (tester) async {
      tester.view.physicalSize = const Size(412, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final task = Task(
        id: 'layout-smoke-task-detail',
        title: 'آماده‌سازی جلسه فردا',
        description: 'مرور موارد جلسه و آماده‌سازی مستندات موردنیاز',
        createdAt: DateTime(2026, 11, 1, 8, 0),
        updatedAt: DateTime(2026, 11, 4, 16, 30),
        dueDate: DateTime(2026, 11, 6, 9, 30),
        category: 'برنامه‌ریزی',
        tags: const ['جلسه', 'مهم'],
        templateTaskId: 'layout-template',
        checklistEnabled: true,
        checklist: const ['[x] بررسی دستور جلسه', '[ ] آماده‌سازی مستندات'],
        taskReminders: [
          TaskReminder(
            id: 'layout-reminder',
            title: 'یادآوری جلسه',
            date: DateTime(2026, 11, 6, 8),
            sequence: 1,
          ),
        ],
        followUps: [
          FollowUp(
            id: 'layout-follow-up',
            dateTime: DateTime(2026, 11, 4, 16, 30),
            note: 'هماهنگی اولیه انجام شد',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4A4CAB),
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFF4A4CAB),
              onPrimary: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F6FA),
            fontFamily: 'Vazirmatn',
          ),
          home: TaskDetailPage(
            task: task,
            centerName: 'مرکز نمونه',
            project: ProjectPlan(
              id: 'layout-project',
              title: 'پروژه نمونه',
              templateId: 'layout-template',
              templateNameSnapshot: 'الگوی جلسه',
            ),
            now: DateTime(2026, 11, 5, 9),
            onEdit: (value) async => value,
            onTaskChanged: (value) async => value,
            onComplete: (value) async => value,
            onDelete: (value) async {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(find.byType(TaskDetailPage), findsOneWidget);

      // Nine real content sections plus the AppBar and fixed bottom actions
      // make the eleven independently asserted structural surfaces.
      const surfaceKeys = <String>[
        'task-detail-app-bar',
        'task-detail-metadata',
        'task-detail-summary-card',
        'task-detail-due-date-card',
        'task-detail-assignee-card',
        'task-detail-independent-reminders',
        'task-detail-recurrence',
        'task-detail-checklist',
        'task-detail-latest-followup',
        'task-detail-timeline',
        'task-detail-bottom-actions',
      ];
      expect(surfaceKeys, hasLength(11));

      for (final key in surfaceKeys) {
        final finder = find.byKey(ValueKey<String>(key));
        expect(finder, findsOneWidget, reason: 'Missing real Task Details surface: $key');
        await tester.ensureVisible(finder);
        await tester.pump(const Duration(milliseconds: 50));
        final rect = tester.getRect(finder);
        expect(rect.width.isFinite, isTrue, reason: '$key width must be finite');
        expect(rect.height.isFinite, isTrue, reason: '$key height must be finite');
        expect(rect.width, greaterThan(0), reason: '$key must have a measurable width');
        expect(rect.height, greaterThan(0), reason: '$key must have a measurable height');
        expect(rect.width, lessThanOrEqualTo(412), reason: '$key must not exceed the viewport width');
        expect(tester.takeException(), isNull, reason: 'Render/layout exception at $key');
      }

      final list = tester.widget<ListView>(
        find.byKey(const ValueKey('task-detail-content-list')),
      );
      expect(list.controller, isNotNull);
      expect(list.controller!.hasClients, isTrue);
      expect(list.controller!.position.maxScrollExtent, greaterThan(0));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
