import '../models/task.dart';

/// Canonical contract for the Wave X1 "waiting for response" state.
///
/// The state is stored in the latest [FollowUp.result] field instead of adding
/// a second Task status or persistence path. FollowUpOfficePage exposes the
/// waiting-only list through the existing canonical Task/FollowUp store.
class WaitingForResponseService {
  const WaitingForResponseService();

  static const String canonicalResult = 'waiting_for_response';

  static const Set<String> _waitingAliases = {
    canonicalResult,
    'waiting',
    'waiting for response',
    'منتظر پاسخ',
    'در انتظار پاسخ',
  };

  bool isWaiting(Task task) {
    if (task.completed || task.archived || task.trashed) return false;
    return task.followUps.any(isWaitingFollowUp);
  }

  /// A valid active waiting relationship always identifies at least one Person.
  bool isWaitingFollowUp(FollowUp followUp) =>
      followUp.waitingForResponse &&
      !followUp.completed &&
      followUp.personIds.isNotEmpty;

  bool isWaitingResult(String? result) {
    if (result == null) return false;
    return _waitingAliases.contains(_normalize(result));
  }

  String? canonicalizeResult(String? result) {
    if (result == null) return null;
    final trimmed = result.trim();
    if (trimmed.isEmpty) return null;
    return isWaitingResult(trimmed) ? canonicalResult : trimmed;
  }

  FollowUp markWaiting(FollowUp followUp) => FollowUp(
        id: followUp.id,
        dateTime: followUp.dateTime,
        note: followUp.note,
        result: canonicalResult,
        reminderDate: followUp.reminderDate,
        nextFollowUp: followUp.nextFollowUp,
        completed: followUp.completed,
        waitingForResponse: true,
        personIds: followUp.personIds,
      );

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
