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

  test('default PDF renderer embeds bundled Vazirmatn UI FD font', () async {
    final report = const TaskReportProjection().project(
      [
        Task(
          id: 'vazirmatn-pdf-check',
          title: 'گزارش رسمی آروین',
          description: 'آزمون ارقام فارسی ۱۴۰۵/۰۷/۲۵',
          followUps: [
            FollowUp(
              id: 'vazirmatn-pdf-follow-up',
              dateTime: DateTime(2026, 10, 17, 10, 35),
              note: 'تماس با فروشنده',
              result: 'منتظر اعلام قیمت',
            ),
          ],
        ),
      ],
      generatedAt: DateTime.utc(2026, 10, 17),
      title: 'گزارش رسمی',
    );

    final bytes = await TaskReportPdfRenderer().build(report);
    final pdfText = String.fromCharCodes(bytes);

    expect(bytes.length, greaterThan(1000));
    expect(pdfText.substring(0, 4), '%PDF');
    expect(pdfText, contains('/FontFile2'));
    expect(pdfText, contains('Vazirmatn'));
  });

}
