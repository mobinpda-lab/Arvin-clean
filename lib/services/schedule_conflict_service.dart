/// A transient schedule interval used only for conflict analysis.
///
/// This is deliberately not persisted. Product adapters may project canonical
/// Task/FollowUp/Calendar data into these intervals without creating another
/// source of truth.
class ScheduleInterval {
  ScheduleInterval({
    required this.id,
    required this.start,
    required this.end,
    this.ownerId,
  }) {
    if (!end.isAfter(start)) {
      throw ArgumentError.value(
        end,
        'end',
        'Schedule interval end must be after start.',
      );
    }
  }

  final String id;
  final String? ownerId;
  final DateTime start;
  final DateTime end;
}

class ScheduleConflict {
  const ScheduleConflict({
    required this.first,
    required this.second,
    required this.overlapStart,
    required this.overlapEnd,
  });

  final ScheduleInterval first;
  final ScheduleInterval second;
  final DateTime overlapStart;
  final DateTime overlapEnd;

  Duration get overlap => overlapEnd.difference(overlapStart);
}

/// Deterministic, side-effect-free overlap detection for schedule projections.
///
/// Intervals are treated as half-open ranges `[start, end)`, so one interval
/// ending exactly when another starts is not a conflict. No storage, scheduler,
/// notification, or UI state is owned by this service.
class ScheduleConflictService {
  const ScheduleConflictService();

  List<ScheduleConflict> findConflicts(Iterable<ScheduleInterval> intervals) {
    final ordered = intervals.toList()
      ..sort((a, b) {
        final byStart = a.start.compareTo(b.start);
        if (byStart != 0) return byStart;
        final byEnd = a.end.compareTo(b.end);
        if (byEnd != 0) return byEnd;
        return a.id.compareTo(b.id);
      });

    final conflicts = <ScheduleConflict>[];

    for (var i = 0; i < ordered.length; i++) {
      final first = ordered[i];
      for (var j = i + 1; j < ordered.length; j++) {
        final second = ordered[j];

        if (!second.start.isBefore(first.end)) {
          break;
        }

        final overlapStart = second.start.isAfter(first.start)
            ? second.start
            : first.start;
        final overlapEnd = second.end.isBefore(first.end)
            ? second.end
            : first.end;

        if (overlapStart.isBefore(overlapEnd)) {
          conflicts.add(
            ScheduleConflict(
              first: first,
              second: second,
              overlapStart: overlapStart,
              overlapEnd: overlapEnd,
            ),
          );
        }
      }
    }

    return conflicts;
  }
}
