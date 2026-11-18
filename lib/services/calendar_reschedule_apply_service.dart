import '../models/task.dart';
import 'follow_up_calendar_projection.dart';
import 'follow_up_write_coordinator.dart';

/// Canonical write boundary for a reschedule that the user has already
/// explicitly confirmed in the UI.
///
/// This service does not decide whether a suggestion should be applied and it
/// owns no persistence. It preserves FollowUp identity/metadata and delegates
/// the update to the existing FollowUpWriteCoordinator so canonical storage
/// and automatic alarm rescheduling stay on the established path.
class CalendarRescheduleApplyService {
  const CalendarRescheduleApplyService({required this.writer});

  final FollowUpWriteCoordinator writer;

  Future<FollowUp> applyConfirmed({
    required FollowUpCalendarTarget target,
    required DateTime dateTime,
  }) async {
    final current = target.followUp;
    final updated = FollowUp(
      id: current.id,
      dateTime: dateTime,
      note: current.note,
      result: current.result,
      nextFollowUp: current.nextFollowUp,
    );

    await writer.update(target.taskId, updated);
    return updated;
  }
}
