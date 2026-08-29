import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'persian_date_formatter.dart';
import 'task_report_projection.dart';
import 'work_agenda_projection.dart';
import 'work_agenda_report_adapter.dart';

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
  static const _regularFontAsset =
      'assets/fonts/vazirmatn/Vazirmatn-UI-FD-Regular.ttf';
  static const _boldFontAsset =
      'assets/fonts/vazirmatn/Vazirmatn-UI-FD-Bold.ttf';

  final TaskReportFontLoader _fontLoader;

  static Future<TaskReportFonts> _loadPersianFonts() async {
    final results = await Future.wait<ByteData>([
      rootBundle.load(_regularFontAsset),
      rootBundle.load(_boldFontAsset),
    ]);
    return TaskReportFonts(
      base: pw.Font.ttf(results[0]),
      bold: pw.Font.ttf(results[1]),
    );
  }

  static String formatDateTime(DateTime value) {
    final date = _dateFormatter.format(value, usePersianDate: true);
    final time = _dateFormatter.toPersianDigits(
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
    );
    return '$date $time';
  }

  static String formatDay(DateTime value) =>
      _dateFormatter.format(value, usePersianDate: true);

  static String agendaEventLabel(WorkAgendaEvent event) {
    final label = switch (event.kind) {
      WorkAgendaEventKind.taskDue => 'موعد کار',
      WorkAgendaEventKind.taskReminder => 'یادآوری کار',
      WorkAgendaEventKind.followUpSchedule => 'زمان پیگیری',
      WorkAgendaEventKind.followUpReminder => 'یادآوری پیگیری',
    };
    return '$label: ${formatDateTime(event.at)}';
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
        header: (_) => _header(report.title, fonts),
        footer: _footer,
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

  Future<Uint8List> buildWorkAgenda(
    WorkAgendaReport report, {
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
        header: (_) => _header(report.title, fonts),
        footer: _footer,
        build: (_) => [
          pw.Text(
            'تاریخ تولید: ${formatDateTime(report.generatedAt)}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          if (report.days.isEmpty)
            pw.Text('کاری برای این روز یا بازه وجود ندارد')
          else
            ...report.days.expand(
              (day) => <pw.Widget>[
                pw.Container(
                  width: double.infinity,
                  margin: const pw.EdgeInsets.only(top: 6, bottom: 8),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  child: pw.Text(
                    formatDay(day.day),
                    style: pw.TextStyle(font: fonts.bold, fontSize: 12),
                  ),
                ),
                ...day.items.map((item) => _agendaEntry(item, fonts)),
              ],
            ),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _header(String title, TaskReportFonts fonts) => pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          title,
          style: pw.TextStyle(font: fonts.bold, fontSize: 16),
        ),
      );

  pw.Widget _footer(pw.Context context) => pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('${context.pageNumber} / ${context.pagesCount}'),
      );

  pw.Widget _agendaEntry(WorkAgendaReportItem item, TaskReportFonts fonts) {
    final eventRows = item.events
        .map((event) => pw.Text('• ${agendaEventLabel(event)}'))
        .toList(growable: false);
    return _entry(
      item.entry,
      fonts,
      leadingRows: [
        pw.Text('دلایل حضور در برنامه:', style: pw.TextStyle(font: fonts.bold)),
        ...eventRows,
        pw.SizedBox(height: 5),
      ],
    );
  }

  pw.Widget _entry(
    TaskReportEntry entry,
    TaskReportFonts fonts, {
    List<pw.Widget> leadingRows = const [],
  }) {
    final rows = <pw.Widget>[
      pw.Text(entry.title, style: pw.TextStyle(font: fonts.bold, fontSize: 13)),
      if (entry.description.trim().isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(entry.description),
      ],
      pw.SizedBox(height: 6),
      ...leadingRows,
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
