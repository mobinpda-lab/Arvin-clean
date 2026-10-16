import '../models/person_reference.dart';
import '../models/task.dart';

/// A read-only row for one canonical Follow-up linked to one or more people.
/// Multiple Follow-ups on one Task produce independent rows.
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

/// Projects person-linked rows from canonical Task/Follow-up data only.
/// Waiting-only mode reads only [FollowUp.waitingForResponse]; legacy task
/// flags and free-form result text are never used to infer waiting state.
class PersonFollowUpReportProjection {
  const PersonFollowUpReportProjection();

  List<PersonFollowUpReportRow> project(
    Iterable<Task> tasks, {
    required Iterable<PersonReference> people,
    String? personId,
    Set<String> personIds = const <String>{},
    bool waitingForResponseOnly = true,
    bool includeDanglingPeople = true,
    DateTime? nextActionDueBy,
  }) {
    final directory = <String, PersonReference>{
      for (final person in people) person.id: person,
    };
    final selectedPersonIds = <String>{
      ...personIds,
      if (personId != null) personId,
    };
    if (selectedPersonIds.isNotEmpty &&
        selectedPersonIds.every((id) => !directory.containsKey(id)) &&
        !includeDanglingPeople) {
      return const <PersonFollowUpReportRow>[];
    }

    final rows = <PersonFollowUpReportRow>[];
    for (final task in tasks) {
      if (task.trashed ||
          (waitingForResponseOnly && (task.completed || task.archived))) {
        continue;
      }
      for (final followUp in task.followUps) {
        if (waitingForResponseOnly &&
            (!followUp.waitingForResponse || followUp.completed)) {
          continue;
        }
        if (selectedPersonIds.isNotEmpty &&
            !followUp.personIds.any(selectedPersonIds.contains)) {
          continue;
        }
        final associated = followUp.personIds
            .where((id) =>
                selectedPersonIds.isEmpty || selectedPersonIds.contains(id))
            .map(
              (id) =>
                  directory[id] ??
                  (includeDanglingPeople
                      ? PersonReference(id: id, displayName: 'شخص حذف‌شده')
                      : null),
            )
            .whereType<PersonReference>()
            .toList(growable: false);
        // Keep the Follow-up row visible even when its Person directory entry
        // was deleted. A stable placeholder preserves history without reviving
        // the deleted Person record or creating a parallel directory.
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
