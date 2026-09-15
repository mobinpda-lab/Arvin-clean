from pathlib import Path


def replace_once(path, old, new):
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(
            f"{path}: expected one match, found {count}: {old[:80]!r}"
        )
    p.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_count(path, old, new, expected):
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    count = text.count(old)
    if count != expected:
        raise SystemExit(
            f"{path}: expected {expected} matches, found {count}: {old[:80]!r}"
        )
    p.write_text(text.replace(old, new), encoding="utf-8")


# CalendarPage: row-level mutability and long-press date creation.
replace_once(
    "lib/calendar_page.dart",
    """    this.onEditReminder,\n    this.onConvertReminderToTask,\n  });\n\n  final List<CalendarReminder> reminders;\n  final DateTime? initialSelectedDay;\n  final Future<void> Function(CalendarReminder reminder)? onCompleteReminder;\n  final Future<void> Function(CalendarReminder reminder)? onSnoozeReminder;\n  final Future<void> Function(CalendarReminder reminder)? onEditReminder;\n  final Future<void> Function(CalendarReminder reminder)? onConvertReminderToTask;\n""",
    """    this.onEditReminder,\n    this.onConvertReminderToTask,\n    this.canMutateReminder,\n    this.onCreateTaskForDate,\n  });\n\n  final List<CalendarReminder> reminders;\n  final DateTime? initialSelectedDay;\n  final Future<void> Function(CalendarReminder reminder)? onCompleteReminder;\n  final Future<void> Function(CalendarReminder reminder)? onSnoozeReminder;\n  final Future<void> Function(CalendarReminder reminder)? onEditReminder;\n  final Future<void> Function(CalendarReminder reminder)? onConvertReminderToTask;\n\n  /// Generic Task/FollowUp actions are shown only when this reminder resolves\n  /// to an exact canonical mutation target. Read-only provider rows stay inert.\n  final bool Function(CalendarReminder reminder)? canMutateReminder;\n\n  /// Creates a canonical Task for the pressed calendar date.\n  final Future<void> Function(DateTime date)? onCreateTaskForDate;\n""",
)
replace_count(
    "lib/calendar_page.dart",
    """                      onTap: () => _selectDay(date),\n""",
    """                      onTap: () => _selectDay(date),\n                      onLongPress: widget.onCreateTaskForDate == null\n                          ? null\n                          : () => widget.onCreateTaskForDate!(date),\n""",
    2,
)
replace_once(
    "lib/calendar_page.dart",
    """              onHorizontalDragEnd: _handleHorizontalSwipe,\n              child: AnimatedSwitcher(\n""",
    """              onHorizontalDragEnd: _handleHorizontalSwipe,\n              onLongPress: _viewMode == _CalendarViewMode.day &&\n                      widget.onCreateTaskForDate != null\n                  ? () => widget.onCreateTaskForDate!(_selectedDay)\n                  : null,\n              child: AnimatedSwitcher(\n""",
)
replace_once(
    "lib/calendar_page.dart",
    """                            onComplete: widget.onCompleteReminder,\n                            onSnooze: widget.onSnoozeReminder,\n                            onEdit: widget.onEditReminder,\n                            onConvertToTask: widget.onConvertReminderToTask,\n""",
    """                            onComplete:\n                                (widget.canMutateReminder?.call(\n                                              selectedReminders[index],\n                                            ) ??\n                                            true)\n                                    ? widget.onCompleteReminder\n                                    : null,\n                            onSnooze:\n                                (widget.canMutateReminder?.call(\n                                              selectedReminders[index],\n                                            ) ??\n                                            true)\n                                    ? widget.onSnoozeReminder\n                                    : null,\n                            onEdit:\n                                (widget.canMutateReminder?.call(\n                                              selectedReminders[index],\n                                            ) ??\n                                            true)\n                                    ? widget.onEditReminder\n                                    : null,\n                            onConvertToTask: widget.onConvertReminderToTask,\n""",
)

# Official provider shell threads capability/create-date callbacks.
replace_once(
    "lib/official_calendar_page.dart",
    """    this.onEditReminder,\n    this.onConvertReminderToTask,\n  });\n""",
    """    this.onEditReminder,\n    this.onConvertReminderToTask,\n    this.canMutateReminder,\n    this.onCreateTaskForDate,\n  });\n""",
)
replace_once(
    "lib/official_calendar_page.dart",
    """  final Future<void> Function(CalendarReminder reminder)? onEditReminder;\n  final Future<void> Function(CalendarReminder reminder)? onConvertReminderToTask;\n""",
    """  final Future<void> Function(CalendarReminder reminder)? onEditReminder;\n  final Future<void> Function(CalendarReminder reminder)? onConvertReminderToTask;\n  final bool Function(CalendarReminder reminder)? canMutateReminder;\n  final Future<void> Function(DateTime date)? onCreateTaskForDate;\n""",
)
replace_once(
    "lib/official_calendar_page.dart",
    """    super.onEditReminder,\n    super.onConvertReminderToTask,\n  }) : super(\n""",
    """    super.onEditReminder,\n    super.onConvertReminderToTask,\n    super.canMutateReminder,\n    super.onCreateTaskForDate,\n  }) : super(\n""",
)
replace_once(
    "lib/official_calendar_page.dart",
    """          onEditReminder: widget.onEditReminder,\n          onConvertReminderToTask: widget.onConvertReminderToTask,\n        );\n""",
    """          onEditReminder: widget.onEditReminder,\n          onConvertReminderToTask: widget.onConvertReminderToTask,\n          canMutateReminder: widget.canMutateReminder,\n          onCreateTaskForDate: widget.onCreateTaskForDate,\n        );\n""",
)

# Launcher resolves canonical mutation targets and refreshes its projection when
# Home returns a newly-created Task.
replace_once(
    "lib/widgets/canonical_calendar_launcher.dart",
    """    this.reschedulingAdvisor = const CalendarReschedulingAdvisor(),\n    this.rescheduleApplyService,\n  });\n\n  final List<Task> tasks;\n  final FollowUpCalendarProjection projection;\n  final CalendarReschedulingAdvisor reschedulingAdvisor;\n  final CalendarRescheduleApplyService? rescheduleApplyService;\n""",
    """    this.reschedulingAdvisor = const CalendarReschedulingAdvisor(),\n    this.rescheduleApplyService,\n    this.onCreateTaskForDate,\n  });\n\n  final List<Task> tasks;\n  final FollowUpCalendarProjection projection;\n  final CalendarReschedulingAdvisor reschedulingAdvisor;\n  final CalendarRescheduleApplyService? rescheduleApplyService;\n  final Future<Task?> Function(DateTime date)? onCreateTaskForDate;\n""",
)
replace_once(
    "lib/widgets/canonical_calendar_launcher.dart",
    """  FollowUpCalendarTarget? _targetFor(CalendarReminder reminder) =>\n      widget.projection.resolveTarget(_tasks, reminder.id);\n\n  Future<void> _completeReminder(CalendarReminder reminder) async {\n""",
    """  FollowUpCalendarTarget? _targetFor(CalendarReminder reminder) =>\n      widget.projection.resolveTarget(_tasks, reminder.id);\n\n  bool _canMutateReminder(CalendarReminder reminder) =>\n      _targetFor(reminder) != null;\n\n  Future<void> _createTaskForDate(DateTime date) async {\n    final task = await widget.onCreateTaskForDate?.call(date);\n    if (task == null || !mounted || _tasks.any((item) => item.id == task.id)) {\n      return;\n    }\n    setState(() => _tasks.add(task));\n  }\n\n  Future<void> _completeReminder(CalendarReminder reminder) async {\n""",
)
replace_once(
    "lib/widgets/canonical_calendar_launcher.dart",
    """            reminders: reminders,\n            onCompleteReminder: _completeReminder,\n            onSnoozeReminder: _snoozeReminder,\n            onEditReminder: _editReminder,\n          ),\n""",
    """            reminders: reminders,\n            onCompleteReminder: _completeReminder,\n            onSnoozeReminder: _snoozeReminder,\n            onEditReminder: _editReminder,\n            canMutateReminder: _canMutateReminder,\n            onCreateTaskForDate: widget.onCreateTaskForDate == null\n                ? null\n                : _createTaskForDate,\n          ),\n""",
)

# Existing Task editor accepts a selected Calendar date only for new Tasks.
replace_once(
    "lib/task_editor_dialog.dart",
    """    super.key,\n    this.task,\n    this.projects = const [],\n""",
    """    super.key,\n    this.task,\n    this.initialDueDate,\n    this.projects = const [],\n""",
)
replace_once(
    "lib/task_editor_dialog.dart",
    """  final Task? task;\n\n  /// First-class Projects remain independent from Task category and tags.\n""",
    """  final Task? task;\n  final DateTime? initialDueDate;\n\n  /// First-class Projects remain independent from Task category and tags.\n""",
)
replace_once(
    "lib/task_editor_dialog.dart",
    """    _dueDateTime = task?.dueDate;\n""",
    """    _dueDateTime = task?.dueDate ?? widget.initialDueDate;\n""",
)

# Home creates through the canonical editor/store and reloads after Calendar.
replace_once(
    "lib/main.dart",
    """  Future<void> _quickCapture() async {\n""",
    """  Future<Task?> _addForDate(DateTime date) async {\n    final editorContext = await wave2ProductFastTrack.prepareEditor(tasks: tasks);\n    if (!mounted) return null;\n    String? selectedProjectId = editorContext.selectedProjectId;\n    final task = await showDialog<Task>(\n      context: context,\n      builder: (_) => ArvinTaskEditorDialog(\n        initialDueDate: DateTime(date.year, date.month, date.day),\n        projects: editorContext.projects,\n        selectedProjectId: editorContext.selectedProjectId,\n        onProjectChanged: (value) => selectedProjectId = value,\n        knownCategories: editorContext.knownCategories,\n      ),\n    );\n    if (task == null) return null;\n    setState(() => tasks.add(task));\n    await _save();\n    await wave2ProductFastTrack.persistProjectSelection(\n      taskId: task.id,\n      projectId: selectedProjectId,\n    );\n    await _load();\n    return task;\n  }\n\n  Future<void> _quickCapture() async {\n""",
)
replace_once(
    "lib/main.dart",
    """        builder: (_) => CanonicalCalendarLauncher(tasks: _searchSource),\n      ),\n    );\n  }\n\n  Widget _primaryNotebookShell() {\n""",
    """        builder: (_) => CanonicalCalendarLauncher(\n          tasks: _searchSource,\n          onCreateTaskForDate: _addForDate,\n        ),\n      ),\n    );\n    if (mounted) await _load();\n  }\n\n  Widget _primaryNotebookShell() {\n""",
)
replace_once(
    "lib/main.dart",
    """            builder: (_) => CanonicalCalendarLauncher(tasks: _searchSource),\n          ),\n""",
    """            builder: (_) => CanonicalCalendarLauncher(\n              tasks: _searchSource,\n              onCreateTaskForDate: _addForDate,\n            ),\n          ),\n""",
)

Path("test/calendar_runtime_actions_fast_track_test.dart").write_text(
    r'''import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';

void main() {
  testWidgets('read-only provider rows never expose generic Task actions',
      (tester) async {
    final day = DateTime(2026, 9, 15, 9);
    final prayer = CalendarReminder(
      id: 'prayer-tehran-2026-09-15-fajr',
      title: 'نماز صبح',
      date: day,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [prayer],
          canMutateReminder: (_) => false,
          onCompleteReminder: (_) async {},
          onSnoozeReminder: (_) async {},
          onEditReminder: (_) async {},
        ),
      ),
    );

    await tester.tap(find.byKey(ValueKey('reminder-card-${prayer.id}')));
    await tester.pump();

    expect(find.byKey(ValueKey('reminder-actions-${prayer.id}')), findsNothing);
    expect(find.byKey(ValueKey('reminder-complete-${prayer.id}')), findsNothing);
    expect(find.byKey(ValueKey('reminder-snooze-${prayer.id}')), findsNothing);
    expect(find.byKey(ValueKey('reminder-edit-${prayer.id}')), findsNothing);
  });

  testWidgets('canonical follow-up row keeps generic Task actions',
      (tester) async {
    final day = DateTime(2026, 9, 15, 9);
    final reminder = CalendarReminder(
      id: 'followup:task-1:fu-1',
      title: 'پیگیری قرارداد',
      date: day,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: [reminder],
          canMutateReminder: (_) => true,
          onCompleteReminder: (_) async {},
          onSnoozeReminder: (_) async {},
          onEditReminder: (_) async {},
        ),
      ),
    );

    await tester.tap(find.byKey(ValueKey('reminder-card-${reminder.id}')));
    await tester.pump();

    expect(find.byKey(ValueKey('reminder-complete-${reminder.id}')), findsOneWidget);
    expect(find.byKey(ValueKey('reminder-snooze-${reminder.id}')), findsOneWidget);
    expect(find.byKey(ValueKey('reminder-edit-${reminder.id}')), findsOneWidget);
  });

  testWidgets('long press on a week date forwards the exact selected date',
      (tester) async {
    final day = DateTime(2026, 9, 15);
    DateTime? requestedDate;

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarPage(
          initialSelectedDay: day,
          reminders: const [],
          onCreateTaskForDate: (date) async => requestedDate = date,
        ),
      ),
    );

    await tester.longPress(
      find.byKey(const ValueKey('calendar-week-day-2026-9-15')),
    );
    await tester.pump();

    expect(requestedDate, DateTime(2026, 9, 15));
  });
}
''',
    encoding="utf-8",
)
