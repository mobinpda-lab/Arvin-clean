import 'models/task.dart';

/// Creates the default values used when a user starts recording a follow-up.
///
/// The current system date/time is supplied automatically. The returned
/// [FollowUp] remains editable by the UI before persistence. `nextFollowUp`
/// is deliberately independent from the recorded follow-up timestamp.
class FollowUpDraft {
  const FollowUpDraft._();

  static FollowUp create({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return FollowUp(
      id: timestamp.microsecondsSinceEpoch.toString(),
      dateTime: timestamp,
    );
  }

  static FollowUp updateDateTime(FollowUp source, DateTime dateTime) {
    return FollowUp(
      id: source.id,
      dateTime: dateTime,
      note: source.note,
      result: source.result,
      nextFollowUp: source.nextFollowUp,
    );
  }

  static FollowUp updateNextFollowUp(FollowUp source, DateTime? nextFollowUp) {
    return FollowUp(
      id: source.id,
      dateTime: source.dateTime,
      note: source.note,
      result: source.result,
      nextFollowUp: nextFollowUp,
    );
  }
}
