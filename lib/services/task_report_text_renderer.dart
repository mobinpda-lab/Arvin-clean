import 'persian_date_formatter.dart';
import 'task_report_projection.dart';

/// Pure plain-text renderer over the canonical [TaskReport] projection.
///
/// This renderer owns no selection, persistence, sharing plugin or UI state.
/// Callers can reuse the exact same [TaskReport] that feeds PDF/Print.
class TaskReportTextRenderer {
  const TaskReportTextRenderer();

  static const _dateFormatter = PersianDateFormatter();

  String render(TaskReport report) {
    final buffer = StringBuffer()
      ..writeln(report.title)
      ..writeln('تاریخ تولید: ${formatDateTime(report.generatedAt)}');

    if (report.entries.isEmpty) {
      buffer
        ..writeln()
        ..write('موردی برای گزارش وجود ندارد');
      return buffer.toString();
    }

    for (var index = 0; index < report.entries.length; index++) {
      final entry = report.entries[index];
      buffer
        ..writeln()
        ..writeln('${index + 1}. ${entry.title}')
        ..writeln('وضعیت: ${entry.completed ? 'انجام‌شده' : 'باز'}');

      if (entry.description.trim().isNotEmpty) {
        buffer.writeln('توضیحات: ${entry.description.trim()}');
      }
      if (entry.reminderDate != null) {
        buffer.writeln('یادآوری: ${formatDateTime(entry.reminderDate!)}');
      }
      if (entry.tags.isNotEmpty) {
        buffer.writeln('برچسب‌ها: ${entry.tags.join('، ')}');
      }
      if (entry.checklist.isNotEmpty) {
        buffer.writeln('چک‌لیست:');
        for (final item in entry.checklist) {
          buffer.writeln('• $item');
        }
      }
      if (entry.followUps.isNotEmpty) {
        buffer.writeln('پیگیری‌ها:');
        for (final followUp in entry.followUps) {
          final result = followUp.result == null ? '' : ' — ${followUp.result}';
          buffer.writeln(
            '• ${formatDateTime(followUp.dateTime)} — ${followUp.note}$result',
          );
        }
      }
    }

    return buffer.toString().trimRight();
  }

  static String formatDateTime(DateTime value) {
    final date = _dateFormatter.format(value, usePersianDate: true);
    final time = _dateFormatter.toPersianDigits(
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
    );
    return '$date $time';
  }
}
