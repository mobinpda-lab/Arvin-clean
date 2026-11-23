import '../models/task.dart';
import 'task_report_projection.dart';

/// Reuses the canonical Task report projection for bulk list actions.
///
/// It owns no PDF renderer, sharing implementation, selection state or
/// persistence. UI surfaces can pass the same [TaskReport] to the existing
/// PDF/Print/Share path so single, selected and visible/all scopes cannot drift.
class TaskBulkReportService {
  const TaskBulkReportService({
    this.projection = const TaskReportProjection(),
  });

  final TaskReportProjection projection;

  TaskReport selected(
    Iterable<Task> canonicalTasks,
    Iterable<String> selectedIds, {
    DateTime? generatedAt,
    String title = 'گزارش موارد انتخاب‌شده',
  }) {
    return projection.project(
      canonicalTasks,
      selectedIds: selectedIds.toSet(),
      generatedAt: generatedAt,
      title: title,
    );
  }

  TaskReport visible(
    Iterable<Task> visibleTasks, {
    DateTime? generatedAt,
    String title = 'گزارش موارد نمایش‌داده‌شده',
  }) {
    return projection.project(
      visibleTasks,
      generatedAt: generatedAt,
      title: title,
    );
  }
}
