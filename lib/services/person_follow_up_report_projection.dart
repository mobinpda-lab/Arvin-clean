import '../models/person_reference.dart';
import '../models/task.dart';

/// A read-only row for one canonical Follow-up that is actively waiting on a
/// response from one or more people. Multiple Follow-ups on one Task produce
/// independent rows.
class PersonFollowUpReportRow {
  const PersonFollowUpReportRow({
    required this.task,
    required this.followUp,
    required this.people,
  });

  final Task task;
  final FollowUp followUp;
  final List<PersonReference> people;

  DateTime? get nextFollowUp => followUp.nextFollowUp;

  /// Deliberately independent from [nextFollowUp].
  DateTime? get reminderDate => followUp.reminderDate;
}

/// Projects active waiting rows from canonical Task/Follow-up data only.
/// Legacy task flags and free-form result text are not treated as waiting state.
class PersonFollowUpReportProjection {
  const PersonFollowUpReportProjection();

  List<PersonFollowUpReportRow> project(
    Iterable<Task> tasks, {
    required Iterable<PersonReference> people,
    String? personId,
    DateTime? nextActionDueBy,
  }) {
    final directory = <String, PersonReference>{
      for (final person in people) person.id: person,
    };
    if (personId != null && !directory.containsKey(personId)) {
      return const <PersonFollowUpReportRow>[];
    }

    final rows = <PersonFollowUpReportRow>[];
    for (final task in tasks) {
      if (task.trashed || task.completed || task.archived) continue;
      for (final followUp in task.followUps) {
        if (!followUp.waitingForResponse || followUp.completed) continue;
        final associated = followUp.personIds
            .where(directory.containsKey)
            .map((id) => directory[id]!)
            .where((person) => personId == null || person.id == personId)
            .toList(growable: false);
        // Empty, removed, or dangling directory associations are not active
        // person-waiting rows.
        if (associated.isEmpty) continue;
        final nextAction = followUp.nextFollowUp;
        if (nextActionDueBy != null &&
            (nextAction == null || nextAction.isAfter(nextActionDueBy))) {
          continue;
        }
        rows.add(PersonFollowUpReportRow(
          task: task,
          followUp: followUp,
          people: List<PersonReference>.unmodifiable(associated),
        ));
      }
    }
    return List<PersonFollowUpReportRow>.unmodifiable(rows);
  }
}
