import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

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
          reminders: [TaskReminder(id: 'r1', title: 'یادآوری', date: DateTime(2026, 8, 30, 9, 30), sequence: 1)],
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
    expect(text, contains('یادآورها:'));
    expect(text, contains('یادآوری:'));
    expect(text, isNot(contains('2026')));
  });

  test('report projection includes canonical Reminders but not legacy schedule fields', () {
    final task = Task(
      id: 'report-task',
      title: 'گزارش',
      reminderDate: DateTime(2026, 8, 30, 8),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 30, 9),
      taskReminders: [
        TaskReminder(id: 'canonical-r1', title: 'یادآور معتبر', date: DateTime(2026, 8, 30, 10), sequence: 1),
      ],
      followUps: [
        FollowUp(
          id: 'history-f1',
          dateTime: DateTime(2026, 8, 29, 10),
          nextFollowUp: DateTime(2026, 8, 30, 11),
          reminderDate: DateTime(2026, 8, 30, 12),
          note: 'سابقه تاریخی',
        ),
      ],
    );
    final report = const TaskReportProjection().project([task]);
    expect(report.entries.single.reminders.map((item) => item.id), ['canonical-r1']);
    final rendered = renderer.render(report);
    expect(rendered, contains('یادآور معتبر'));
    expect(rendered, isNot(contains('08:00')));
    expect(rendered, isNot(contains('11:00')));
    expect(rendered, isNot(contains('12:00')));
    expect(rendered, contains('سابقه تاریخی'));
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
          reminders: [],
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
}
