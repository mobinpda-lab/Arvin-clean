import 'calendar_page.dart';
import 'models/follow_up.dart';

/// Bridges FollowUp history into the Calendar reminder surface.
class CalendarFollowUpAdapter {
  const CalendarFollowUpAdapter();

  List<CalendarReminder> remindersFor(
    String taskId,
    String taskTitle,
    List<FollowUp> followUps,
  ) {
    return List<CalendarReminder>.unmodifiable(
      followUps.map(
        (followUp) => CalendarReminder(
          id: '$taskId:${followUp.id}',
          title: taskTitle,
          date: followUp.nextFollowUp ?? followUp.dateTime,
        ),
      ),
    );
  }
}
