import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  testWidgets(
    'Task Details standard layout matches the approved visual golden',
    (tester) async {
      tester.view.physicalSize = const Size(412, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final task = Task(
        id: 'golden-task-detail-standard',
        title: 'آماده‌سازی جلسه فردا',
        description: 'مرور موارد جلسه و آماده‌سازی مستندات موردنیاز',
        createdAt: DateTime(2026, 11, 1, 8, 0),
        updatedAt: DateTime(2026, 11, 4, 16, 30),
        dueDate: DateTime(2026, 11, 6, 9, 30),
        category: 'برنامه‌ریزی',
        tags: const ['جلسه', 'مهم'],
        templateTaskId: 'golden-template',
      );

      const boundaryKey = ValueKey('task-detail-golden-boundary');
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
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
                id: 'golden-project',
                title: 'پروژه نمونه',
                templateId: 'golden-template',
                templateNameSnapshot: 'الگوی جلسه',
              ),
              now: DateTime(2026, 11, 5, 9, 0),
              onEdit: (value) async => value,
              onTaskChanged: (value) async => value,
              onComplete: (value) async => value,
              onDelete: (value) async {},
            ),
          ),
        ),
      );
      // Task Details is a static review surface. Advance the initial route and
      // Material transitions deterministically, then assert the scheduler is
      // genuinely idle instead of waiting forever for an unrelated ticker.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      expect(
        tester.binding.hasScheduledFrame,
        isFalse,
        reason: 'Task Details must have no repeating frame source before golden capture.',
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Preserve a reviewable render even when the approved golden is absent
      // or differs. CI uploads this image; it must not auto-update the baseline.
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      final image = await boundary.toImage(pixelRatio: 1.0);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      expect(png, isNotNull);
      final actual = File('test/failures/task_detail_visual_actual.png');
      await actual.parent.create(recursive: true);
      await actual.writeAsBytes(
        png!.buffer.asUint8List(),
        flush: true,
      );

      // The checked-in baseline is deliberately fail-closed: do not run
      // --update-goldens in CI. Add/approve the PNG only after visual review.
      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('goldens/task_detail_visual_test.png'),
      );
    },
  );
}
