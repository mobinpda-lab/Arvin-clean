import 'dart:io';

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
          title: 'گزارش رسمی آروین — پیگیری مشتری و برنامه‌ریزی اقدام بعدی',
          description:
              'آزمون اتصال حروف فارسی، جهت راست‌به‌چپ، ارقام فارسی ۱۴۰۵/۰۷/۲۵ و شکست خودکار خطوط در متن طولانی. این متن برای بررسی چیدمان گزارش و حفظ خوانایی در چند سطر قرار گرفته است.',
          tags: ['مهم', 'مشتری', 'پیگیری'],
          checklistEnabled: true,
          checklist: [
            'بررسی پیش‌فاکتور و ثبت نتیجه تماس',
            'ارسال پاسخ به مشتری پس از دریافت قیمت و تأیید نهایی',
          ],
          reminderDate: DateTime(2026, 10, 18, 9, 5),
          followUps: [
            FollowUp(
              id: 'vazirmatn-pdf-follow-up',
              dateTime: DateTime(2026, 10, 17, 10, 35),
              title: 'تماس با فروشنده',
              note: 'تماس با فروشنده درباره پیش‌فاکتور و شرایط تحویل',
              result: 'منتظر اعلام قیمت و تأیید شرایط نهایی',
              reminderDate: DateTime(2026, 10, 18, 9, 5),
              nextFollowUp: DateTime(2026, 10, 19, 11, 20),
              waitingForResponse: true,
              personIds: ['person-vendor'],
            ),
          ],
        ),
      ],
      generatedAt: DateTime.utc(2026, 10, 17),
      title: 'گزارش رسمی',
    );

    final bytes = await TaskReportPdfRenderer().build(report);
    final previewPath = Platform.environment['ARVIN_PDF_PREVIEW_OUTPUT'];
    if (previewPath != null && previewPath.isNotEmpty) {
      final preview = File(previewPath);
      await preview.parent.create(recursive: true);
      await preview.writeAsBytes(bytes, flush: true);
    }
    final pdfText = String.fromCharCodes(bytes);

    expect(bytes.length, greaterThan(1000));
    expect(pdfText.substring(0, 4), '%PDF');
    expect(pdfText, contains('/FontFile2'));
    expect(pdfText, contains('Vazirmatn'));
  });

}
