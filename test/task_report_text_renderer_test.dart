import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/task_report_projection.dart';
import 'package:arvin/services/task_report_text_renderer.dart';

void main() {
  const renderer = TaskReportTextRenderer();

  test('renders canonical report fields as deterministic plain text', () {
    final report = TaskReport(
      title: 'گزارش آزمایشی',
      generatedAt: DateTime(2026, 8, 29, 10, 5),
      entries: [
        TaskReportEntry(
          id: '1',
          title: 'تماس با مشتری',
          description: 'پیگیری وضعیت قرارداد',
          tags: const ['فروش', 'مهم'],
          checklist: const ['تماس', 'ثبت نتیجه'],
          followUps: const [],
          completed: false,
          reminderDate: DateTime(2026, 8, 30, 9, 30),
        ),
      ],
    );

    final text = renderer.render(report);

    expect(text, contains('گزارش آزمایشی'));
    expect(text, contains('تاریخ تولید:'));
    expect(text, contains('1. تماس با مشتری'));
    expect(text, contains('وضعیت: باز'));
    expect(text, contains('توضیحات: پیگیری وضعیت قرارداد'));
    expect(text, contains('برچسب‌ها: فروش، مهم'));
    expect(text, contains('چک‌لیست:'));
    expect(text, contains('• تماس'));
    expect(text, contains('• ثبت نتیجه'));
    expect(text, contains('یادآوری:'));
    expect(text, isNot(contains('2026')));
  });

  test('renders an explicit empty-report message', () {
    final report = TaskReport(
      title: 'گزارش آروین',
      generatedAt: DateTime(2026, 8, 29),
      entries: const [],
    );

    expect(
      renderer.render(report),
      contains('موردی برای گزارش وجود ندارد'),
    );
  });

  test('omits blank optional sections', () {
    final report = TaskReport(
      title: 'گزارش آروین',
      generatedAt: DateTime(2026, 8, 29),
      entries: const [
        TaskReportEntry(
          id: '1',
          title: 'کار ساده',
          description: '   ',
          tags: [],
          checklist: [],
          followUps: [],
          completed: true,
        ),
      ],
    );

    final text = renderer.render(report);

    expect(text, contains('وضعیت: انجام‌شده'));
    expect(text, isNot(contains('توضیحات:')));
    expect(text, isNot(contains('برچسب‌ها:')));
    expect(text, isNot(contains('چک‌لیست:')));
    expect(text, isNot(contains('پیگیری‌ها:')));
  });
  test('plain-text output groups tasks by P1 through P4', () {
    final report = const TaskReportProjection().project([
      Task(id: 'p3', title: 'کار P3', priority: TaskPriority.low),
      Task(id: 'p1', title: 'کار P1', priority: TaskPriority.high),
      Task(id: 'p4', title: 'کار P4', priority: TaskPriority.none),
      Task(id: 'p2', title: 'کار P2', priority: TaskPriority.medium),
    ]);
    final output = renderer.render(report);
    final p1 = output.indexOf('P1 — فوری و مهم');
    final p2 = output.indexOf('P2 — مهم، غیرفوری');
    final p3 = output.indexOf('P3 — فوری، غیرمهم');
    final p4 = output.indexOf('P4 — غیرفوری و غیرمهم');
    expect(p1, greaterThanOrEqualTo(0));
    expect(p1, lessThan(p2));
    expect(p2, lessThan(p3));
    expect(p3, lessThan(p4));
  });

}
