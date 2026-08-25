import 'package:flutter/material.dart';

import '../models/task.dart';
import '../official_calendar_page.dart';
import '../services/follow_up_calendar_projection.dart';

/// Small UI boundary that keeps Home unaware of calendar projection details.
///
/// It accepts canonical tasks, projects their follow-ups into the existing
/// CalendarReminder presentation model, and opens the official Iranian
/// calendar with those reminders. No storage is owned or mutated here.
class CanonicalCalendarLauncher extends StatelessWidget {
  const CanonicalCalendarLauncher({
    super.key,
    required this.tasks,
    this.projection = const FollowUpCalendarProjection(),
  });

  final List<Task> tasks;
  final FollowUpCalendarProjection projection;

  @override
  Widget build(BuildContext context) {
    final reminders = projection.project(tasks);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: IranianOfficialCalendarPage(reminders: reminders),
    );
  }
}
