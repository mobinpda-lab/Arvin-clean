import '../models/task.dart';
import 'follow_up_elapsed_formatter.dart';
import 'persian_date_formatter.dart';

class HomeFollowUpPresentation {
  const HomeFollowUpPresentation({
    required this.followUpId,
    required this.title,
    required this.dateTime,
    required this.exactDateTime,
    this.relative,
  });

  final String followUpId;
  final String title;
  final DateTime dateTime;
  final String exactDateTime;
  final String? relative;
}

/// Read-only Home presentation over the latest *real* canonical FollowUp.
///
/// Legacy `Task.followUpDate` is deliberately ignored here: it may still be
/// used by legacy scheduling/due projections, but it must never fabricate a
/// FollowUp history entry on Home.
class HomeFollowUpPresentationService {
  const HomeFollowUpPresentationService();

  static const _dateFormatter = PersianDateFormatter();
  static const _elapsedFormatter = FollowUpElapsedFormatter();

  HomeFollowUpPresentation? project(Task task, {DateTime? now}) {
    final followUp = task.lastFollowUp;
    if (followUp == null) return null;

    final date = _dateFormatter.format(
      followUp.dateTime,
      usePersianDate: true,
    );
    final time = _dateFormatter.toPersianDigits(
      '${followUp.dateTime.hour.toString().padLeft(2, '0')}:${followUp.dateTime.minute.toString().padLeft(2, '0')}',
    );
    final current = now ?? DateTime.now();
    final relative = followUp.dateTime.isAfter(current)
        ? null
        : '${_elapsedFormatter.format(current.difference(followUp.dateTime))} پیش';
    final note = followUp.note.trim();

    return HomeFollowUpPresentation(
      followUpId: followUp.id,
      title: note.isEmpty ? 'پیگیری' : note,
      dateTime: followUp.dateTime,
      exactDateTime: '$date • ساعت $time',
      relative: relative,
    );
  }
}
