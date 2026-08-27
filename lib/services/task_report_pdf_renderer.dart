import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'persian_date_formatter.dart';
import 'task_report_projection.dart';

class TaskReportFonts {
  const TaskReportFonts({required this.base, required this.bold});

  final pw.Font base;
  final pw.Font bold;
}

typedef TaskReportFontLoader = Future<TaskReportFonts> Function();

class TaskReportPdfRenderer {
  TaskReportPdfRenderer({TaskReportFontLoader? fontLoader})
      : _fontLoader = fontLoader ?? _loadPersianFonts;

  static const _dateFormatter = PersianDateFormatter();
  final TaskReportFontLoader _fontLoader;

  static Future<TaskReportFonts> _loadPersianFonts() async {
    final results = await Future.wait<pw.Font>([
      PdfGoogleFonts.notoNaskhArabicRegular(),
      PdfGoogleFonts.notoNaskhArabicBold(),
    ]);
    return TaskReportFonts(base: results[0], bold: results[1]);
  }

  /// Canonical user-visible date/time format for PDF/Print/Share reports.
  ///
  /// All report dates are Jalali and all digits are Persian so export output
  /// follows the same calendar contract as the rest of Arvin.
  static String formatDateTime(DateTime value) {
    final date = _dateFormatter.format(value, usePersianDate: true);
    final time = _dateFormatter.toPersianDigits(
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
    );
    return '$date $time';
  }

  Future<Uint8List> build(
    TaskReport report, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final fonts = await _fontLoader();
    final document = pw.Document();
    final theme = pw.ThemeData.withFont(base: fonts.base, bold: fonts.bold);

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        textDirection: pw.TextDirection.rtl,
        theme: theme,
        margin: const pw.EdgeInsets.all(28),
        header: (_) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            report.title,
            style: pw.TextStyle(font: fonts.bold, fontSize: 16),
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text('${context.pageNumber} / ${context.pagesCount}'),
        ),
        build: (_) => [
          pw.Text(
            'تاریخ تولید: ${formatDateTime(report.generatedAt)}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          if (report.entries.isEmpty)
            pw.Text('موردی برای گزارش وجود ندارد')
          else
            ...report.entries.map((entry) => _entry(entry, fonts)),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _entry(TaskReportEntry entry, TaskReportFonts fonts) {
    final rows = <pw.Widget>[
      pw.Text(
        entry.title,
        style: pw.TextStyle(font: fonts.bold, fontSize: 13),
      ),
      if (entry.description.trim().isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(entry.description),
      ],
      pw.SizedBox(height: 6),
      pw.Text('وضعیت: ${entry.completed ? 'انجام‌شده' : 'باز'}'),
      if (entry.reminderDate != null)
        pw.Text('یادآوری: ${formatDateTime(entry.reminderDate!)}'),
      if (entry.tags.isNotEmpty) pw.Text('برچسب‌ها: ${entry.tags.join('، ')}'),
      if (entry.checklist.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text('چک‌لیست:', style: pw.TextStyle(font: fonts.bold)),
        ...entry.checklist.map((item) => pw.Text('• $item')),
      ],
      if (entry.followUps.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text('پیگیری‌ها:', style: pw.TextStyle(font: fonts.bold)),
        ...entry.followUps.map(
          (followUp) => pw.Text(
            '• ${formatDateTime(followUp.dateTime)} — ${followUp.note}${followUp.result == null ? '' : ' — ${followUp.result}'}',
          ),
        ),
      ],
    ];

    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: .5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }
}
