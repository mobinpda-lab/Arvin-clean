import '../models/person_reference.dart';
import '../models/task.dart';

/// One projected Follow-up row for the Person / waiting-response report.
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
  DateTime? get reminderDate => followUp.reminderDate;
}

/// Canonical read-only projection for Person-linked Follow-ups.
/// It owns no storage and never infers waiting state from free-form result text.
class PersonFollowUpReportProjection {
  const PersonFollowUpReportProjection();

  List<PersonFollowUpReportRow> project(
    Iterable<Task> tasks, {
    required Iterable<PersonReference> people,
    Set<String> personIds = const <String>{},
    String? personId,
    bool waitingForResponseOnly = true,
    bool includeDanglingPeople = false,
    DateTime? nextActionDueBy,
  }) {
    final selectedIds = <String>{
      ...personIds,
      if (personId != null) personId,
    };
    final directory = <String, PersonReference>{
      for (final person in people) person.id: person,
    };
    if (selectedIds.isNotEmpty &&
        selectedIds.every((id) => !directory.containsKey(id)) &&
        !includeDanglingPeople) {
      return const <PersonFollowUpReportRow>[];
    }

    final rows = <PersonFollowUpReportRow>[];
    for (final task in tasks) {
      if (task.trashed) continue;
      if (waitingForResponseOnly && (task.completed || task.archived)) continue;
      for (final followUp in task.followUps) {
        if (waitingForResponseOnly &&
            (followUp.completed ||
                !followUp.waitingForResponse ||
                followUp.personIds.isEmpty)) {
          continue;
        }
        if (selectedIds.isNotEmpty &&
            !followUp.personIds.any(selectedIds.contains)) {
          continue;
        }
        final nextAction = followUp.nextFollowUp;
        if (nextActionDueBy != null &&
            (nextAction == null || nextAction.isAfter(nextActionDueBy))) {
          continue;
        }
        final associatedIds = followUp.personIds
            .where((id) => selectedIds.isEmpty || selectedIds.contains(id))
            .toSet();
        if (associatedIds.isEmpty) continue;
        final associated = <PersonReference>[];
        for (final id in associatedIds) {
          final person = directory[id];
          if (person != null) {
            associated.add(person);
          } else if (includeDanglingPeople) {
            associated.add(PersonReference(id: id, displayName: 'شخص حذف‌شده'));
          }
        }
        if (associated.isEmpty) continue;
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
