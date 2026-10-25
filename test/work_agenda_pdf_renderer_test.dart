import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_report_pdf_renderer.dart';
import 'package:arvin/services/work_agenda_projection.dart';
import 'package:arvin/services/work_agenda_report_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('agenda reason labels stay explicit and Jalali/Persian', () {
    final event = WorkAgendaEvent(
      kind: WorkAgendaEventKind.taskReminder,
      at: DateTime(2026, 8, 29, 9, 15),
      reminderId: 'r-1',
    );

    expect(
      TaskReportPdfRenderer.agendaEventLabel(event),
      'یادآوری کار: ۱۴۰۵/۰۶/۰۷ ۰۹:۱۵',
    );
  });

  test('existing PDF renderer builds grouped Work Agenda bytes', () async {
    final task = Task(
      id: 'task-1',
      title: 'تحویل قرارداد',
      description: 'نسخه نهایی',
      dueDate: DateTime(2026, 8, 29, 10),
      taskReminders: [
        TaskReminder(
          id: 'r-1',
          title: 'یادآوری قرارداد',
          date: DateTime(2026, 8, 29, 9),
          sequence: 1,
        ),
      ],
    );
    final report = const WorkAgendaReportAdapter().forDay(
      [task],
      day: DateTime(2026, 8, 29),
      generatedAt: DateTime(2026, 8, 29, 8),
    );
    expect(report.days, hasLength(1));
    expect(report.days.single.items.single.events, hasLength(2));

    final renderer = TaskReportPdfRenderer(
      fontLoader: () async => TaskReportFonts(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );
    final bytes = await renderer.buildWorkAgenda(report);

    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
