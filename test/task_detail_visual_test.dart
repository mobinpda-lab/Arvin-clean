import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

void _installRenderFlexOverflowProbe(WidgetTester tester, String scenario) {
  final previousHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    if (message.contains('RenderFlex') && message.contains('overflowed')) {
      // ignore: avoid_print
      print('\\n===== RENDERFLEX_OVERFLOW_BEGIN [$scenario] =====');
      // ignore: avoid_print
      print(details.toString());
      // The full render dump preserves the offending RenderFlex constraints,
      // its parent chain, and the widget creator information in CI logs.
      debugDumpRenderTree();
      // ignore: avoid_print
      print('===== RENDERFLEX_OVERFLOW_END [$scenario] =====\\n');
    }
    previousHandler?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousHandler);
}

void _dumpVisibleRenderSubtree(
  WidgetTester tester, {
  required String label,
}) {
  final viewport = Rect.fromLTWH(
    0,
    0,
    tester.view.physicalSize.width / tester.view.devicePixelRatio,
    tester.view.physicalSize.height / tester.view.devicePixelRatio,
  );
  var emitted = 0;
  // ignore: avoid_print
  print('\\n===== VISIBLE_RENDER_SUBTREE_BEGIN [$label] =====');
  for (final element in tester.allElements) {
    final renderObject = element.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      continue;
    }
    final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
    if (!rect.overlaps(viewport)) continue;
    final parents = <String>[];
    RenderObject? parent = renderObject.parent;
    for (var depth = 0; parent != null && depth < 5; depth++) {
      if (parent is RenderBox && parent.hasSize) {
        parents.add(
          '${parent.runtimeType}(constraints: ${parent.constraints})',
        );
      } else {
        parents.add(parent.runtimeType.toString());
      }
      parent = parent.parent;
    }
    // ignore: avoid_print
    print(
      'VISIBLE widget=${element.widget.runtimeType} '
      'key=${element.widget.key} rect=$rect '
      'constraints=${renderObject.constraints} '
      'parents=${parents.join(' <- ')}',
    );
    emitted++;
    if (emitted >= 240) {
      // ignore: avoid_print
      print('VISIBLE_SUBTREE_TRUNCATED after 240 render boxes');
      break;
    }
  }
  // ignore: avoid_print
  print('VISIBLE_RENDER_BOX_COUNT=$emitted');
  // ignore: avoid_print
  print('===== VISIBLE_RENDER_SUBTREE_END [$label] =====\\n');
}

Future<void> _scrollTaskDetailUntilVisible(
  WidgetTester tester,
  Finder target,
  double delta,
) async {
  final list = tester.widget<ListView>(
    find.byKey(const ValueKey('task-detail-content-list')),
  );
  final controller = list.controller!;
  expect(controller.hasClients, isTrue);

  for (var pass = 0; pass < 2 && target.evaluate().isEmpty; pass++) {
    for (var step = 0; step < 40 && target.evaluate().isEmpty; step++) {
      final max = controller.position.maxScrollExtent;
      if (controller.offset >= max - 0.5) break;
      final next = (controller.offset + delta).clamp(0.0, max).toDouble();
      if (next <= controller.offset) break;
      controller.jumpTo(next);
      await tester.pumpAndSettle();
    }
    if (target.evaluate().isEmpty && pass == 0 && controller.offset > 0) {
      controller.jumpTo(0);
      await tester.pumpAndSettle();
    }
  }

  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Task Details renders all eleven structural surfaces without overflow and scrolls',
    (tester) async {
      _installRenderFlexOverflowProbe(tester, 'task-detail-structural-412dp');
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
        checklist: const ['[x] بررسی دستور جلسه و هماهنگی با اعضای جلسه', '[ ] آماده‌سازی مستندات تکمیلی و فایل‌های موردنیاز برای ارائه'],
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
              seedColor: const Color(0xFF3A86EF),
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFF3A86EF),
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
        // ListView children are built lazily. Scroll the real content viewport
        // until each off-screen surface is built before asserting its key.
        if (key != 'task-detail-app-bar' && key != 'task-detail-bottom-actions') {
          await _scrollTaskDetailUntilVisible(tester, finder, 280);
          await tester.pump(const Duration(milliseconds: 50));
        }
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
  testWidgets('Task Details title and notes persist directly while typing', (tester) async {
    final task = Task(
      id: 'task-detail-inline-autosave',
      title: 'عنوان اولیه',
      description: 'یادداشت اولیه',
      createdAt: DateTime(2026, 11, 1),
    );
    Task? persisted;
    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onTaskChanged: (candidate) async {
            persisted = candidate;
            return candidate;
          },
          onDescriptionChanged: (current, description) async {
            final updated = Task.fromJson(Map<String, dynamic>.from(current.toJson()))
              ..description = description;
            persisted = updated;
            return updated;
          },
        ),
      ),
    );
    await tester.enterText(find.byKey(const ValueKey('task-detail-title')), 'عنوان ذخیره‌شونده');
    await tester.pump();
    expect(persisted?.title, 'عنوان ذخیره‌شونده');
    expect(find.byKey(const ValueKey('task-detail-inline-edit-toggle')), findsNothing);

    final notes = find.byKey(const ValueKey('task-detail-connected-notes-field'));
    await _scrollTaskDetailUntilVisible(tester, notes, 240);
    await tester.enterText(notes, 'یادداشت ذخیره‌شونده');
    await tester.pump();
    expect(persisted?.description, 'یادداشت ذخیره‌شونده');
  });

  testWidgets('Task Details due-date row fits 360, 390 and 412 dp widths', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(412, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in <double>[360, 390, 412]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true, fontFamily: 'Vazirmatn'),
          home: TaskDetailPage(
            task: Task(
              id: 'due-row-width-$width',
              title: 'آزمون چیدمان موعد',
              dueDate: DateTime(2026, 11, 12, 9, 30),
              createdAt: DateTime(2026, 11, 1),
            ),
            onTaskChanged: (candidate) async => candidate,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      final dueCard = find.byKey(const ValueKey('task-detail-due-date-card'));
      await _scrollTaskDetailUntilVisible(tester, dueCard, 240);
      final dueRect = tester.getRect(dueCard);
      expect(dueRect.height, greaterThanOrEqualTo(48), reason: 'Due-date row must keep a 48dp minimum hit target at $width dp');
      expect(dueRect.width, lessThanOrEqualTo(width), reason: 'Due-date row must stay inside the viewport at $width dp');
      expect(tester.takeException(), isNull, reason: 'Due-date row overflowed at $width dp');
    }
  });

  testWidgets('Task Details full page has zero overflow at 360, 390 and 412 dp', (tester) async {
    _installRenderFlexOverflowProbe(tester, 'task-detail-full-page-widths');
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in <double>[360, 390, 412]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true, fontFamily: 'Vazirmatn'),
          home: TaskDetailPage(
            task: Task(
              id: 'full-page-width-$width',
              title: 'آماده‌سازی جلسه فردا',
              description: 'مرور موارد جلسه و آماده‌سازی مستندات موردنیاز',
              createdAt: DateTime(2026, 11, 1, 8),
              dueDate: DateTime(2026, 11, 6, 9, 30),
              category: 'برنامه‌ریزی',
              tags: const ['جلسه', 'مهم'],
              checklistEnabled: true,
              checklist: const ['[x] بررسی دستور جلسه و هماهنگی با اعضای جلسه', '[ ] آماده‌سازی مستندات تکمیلی و فایل‌های موردنیاز برای ارائه'],
              taskReminders: [
                TaskReminder(
                  id: 'full-page-reminder-$width',
                  title: 'یادآوری جلسه',
                  date: DateTime(2026, 11, 6, 8),
                  sequence: 1,
                ),
              ],
              followUps: [
                FollowUp(
                  id: 'full-page-follow-up-$width',
                  dateTime: DateTime(2026, 11, 4, 16, 30),
                  note: 'هماهنگی اولیه انجام شد',
                ),
              ],
            ),
            now: DateTime(2026, 11, 5, 9),
            onTaskChanged: (candidate) async => candidate,
            onComplete: (candidate) async => candidate,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      final list = tester.widget<ListView>(
        find.byKey(const ValueKey('task-detail-content-list')),
      );
      final controller = list.controller!;
      expect(controller.hasClients, isTrue);
      for (var step = 0; step < 40; step++) {
        final max = controller.position.maxScrollExtent;
        if (controller.offset >= max - 0.5) break;
        controller.jumpTo((controller.offset + 220).clamp(0.0, max).toDouble());
        await tester.pump(const Duration(milliseconds: 20));
        if (width == 360 && step == 3) {
          _dumpVisibleRenderSubtree(
            tester,
            label: 'task-detail-360dp-scroll-step-3',
          );
        }
        expect(
          tester.takeException(),
          isNull,
          reason: 'Task Details overflowed at $width dp, scroll step $step',
        );
      }
      expect(tester.takeException(), isNull, reason: 'Task Details overflowed at $width dp');
    }
  });

}
