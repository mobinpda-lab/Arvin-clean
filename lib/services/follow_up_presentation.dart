import '../models/task.dart';

class FollowUpPresentation {
  const FollowUpPresentation({
    required this.date,
    required this.time,
    required this.note,
  });

  final String date;
  final String time;
  final String note;

  bool get isEmpty => date.isEmpty && time.isEmpty && note.isEmpty;
}

class FollowUpPresentationService {
  const FollowUpPresentationService();

  FollowUpPresentation fromHistory(List<FollowUp> history) {
    if (history.isEmpty) {
      return const FollowUpPresentation(date: '', time: '', note: '');
    }

    final latest = history.reduce(
      (a, b) => a.dateTime.isAfter(b.dateTime) ? a : b,
    );

    final local = latest.dateTime.toLocal();
    final date = '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return FollowUpPresentation(date: date, time: time, note: latest.note);
  }
}
