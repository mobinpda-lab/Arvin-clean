import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_report_pdf_renderer.dart';
import 'package:arvin/services/task_report_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('report date/time is Jalali with Persian digits', () {
    expect(
      TaskReportPdfRenderer.formatDateTime(DateTime(2026, 8, 26, 10, 35)),
      '۱۴۰۵/۰۶/۰۴ ۱۰:۳۵',
    );
  });

  test('shared renderer loads bundled Vazirmatn assets and produces PDF bytes', () async {
    final report = const TaskReportProjection().project(
      [
        Task(
          id: '1',
          title: 'گزارش آروین',
          description: 'متن فارسی با نیم‌فاصله و اعداد ۱۴۰۵',
          reminderDate: DateTime(2026, 8, 27, 9, 5),
          followUps: [
            FollowUp(
              id: 'f1',
              dateTime: DateTime(2026, 8, 26, 10, 35),
              note: 'پیگیری نمونه',
            ),
          ],
        ),
      ],
      generatedAt: DateTime.utc(2026, 8, 26),
      title: 'گزارش آروین',
    );

    // Use the production loader. Do not inject a system/Helvetica font here:
    // this test must fail if either bundled Vazirmatn PDF asset is missing.
    final bytes = await TaskReportPdfRenderer().build(report);
    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
