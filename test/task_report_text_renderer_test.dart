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
}
