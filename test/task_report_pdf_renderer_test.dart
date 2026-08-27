import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_report_pdf_renderer.dart';
import 'package:arvin/services/task_report_projection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('report date/time is Jalali with Persian digits', () {
    expect(
      TaskReportPdfRenderer.formatDateTime(DateTime(2026, 8, 26, 10, 35)),
      '۱۴۰۵/۰۶/۰۴ ۱۰:۳۵',
    );
  });

  test('shared renderer produces real PDF bytes without platform printing', () async {
    final report = const TaskReportProjection().project(
      [
        Task(
          id: '1',
          title: 'Release report',
          description: 'Evidence',
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
      title: 'Arvin Report',
    );
    final renderer = TaskReportPdfRenderer(
      fontLoader: () async => TaskReportFonts(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );

    final bytes = await renderer.build(report);
    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
