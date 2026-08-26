import '../models/task.dart';

/// Canonical contract for the Wave X1 "waiting for response" state.
///
/// The state is stored in the existing latest [FollowUp.result] field instead
/// of adding a second Task status or persistence path. UI/persistence wiring can
/// build on this contract in a later slice.
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
    final latest = task.lastFollowUp;
    return latest != null && isWaitingResult(latest.result);
  }

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
        nextFollowUp: followUp.nextFollowUp,
      );

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
