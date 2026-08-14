import 'models/follow_up.dart';

/// Presentation helpers for FollowUp history.
///
/// Keeps ordering and "next follow-up" selection out of widgets so the UI
/// remains deterministic and easy to test.
class FollowUpHistoryPresenter {
  const FollowUpHistoryPresenter();

  List<FollowUp> sorted(List<FollowUp> items) {
    final result = List<FollowUp>.of(items);
    result.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return List<FollowUp>.unmodifiable(result);
  }

  FollowUp? latest(List<FollowUp> items) {
    if (items.isEmpty) return null;
    return sorted(items).first;
  }

  FollowUp? next(List<FollowUp> items, {DateTime? from}) {
    final now = from ?? DateTime.now();
    final candidates = items
        .where((item) => item.nextFollowUp != null && item.nextFollowUp!.isAfter(now))
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a.nextFollowUp!.compareTo(b.nextFollowUp!));
    return candidates.first;
  }
}
