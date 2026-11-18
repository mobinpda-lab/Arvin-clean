import 'persian_date_formatter.dart';

/// Pure presentation helper for FollowUp elapsed/interval labels.
///
/// No elapsed value is persisted. Callers derive it from canonical
/// `FollowUp.dateTime` timestamps whenever the UI is rebuilt.
class FollowUpElapsedFormatter {
  const FollowUpElapsedFormatter();

  static const _digits = PersianDateFormatter();

  String since(DateTime latest, {DateTime? now}) {
    final current = now ?? DateTime.now();
    if (latest.isAfter(current)) return 'زمان پیگیری در آینده است';
    return '${format(current.difference(latest))} از آخرین پیگیری گذشته';
  }

  String interval(DateTime newer, DateTime older) {
    if (newer.isBefore(older)) {
      return format(older.difference(newer));
    }
    return format(newer.difference(older));
  }

  String format(Duration duration) {
    final minutes = duration.inMinutes.abs();
    if (minutes < 1) return 'کمتر از یک دقیقه';

    if (minutes < 60) {
      return '${_number(minutes)} دقیقه';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours < 24) {
      return _join(
        '${_number(hours)} ساعت',
        remainingMinutes == 0 ? null : '${_number(remainingMinutes)} دقیقه',
      );
    }

    final days = hours ~/ 24;
    final remainingHours = hours % 24;
    if (days < 7) {
      return _join(
        '${_number(days)} روز',
        remainingHours == 0 ? null : '${_number(remainingHours)} ساعت',
      );
    }

    if (days < 30) {
      final weeks = days ~/ 7;
      final remainingDays = days % 7;
      return _join(
        '${_number(weeks)} هفته',
        remainingDays == 0 ? null : '${_number(remainingDays)} روز',
      );
    }

    final months = days ~/ 30;
    final remainingDays = days % 30;
    return _join(
      '${_number(months)} ماه',
      remainingDays == 0 ? null : '${_number(remainingDays)} روز',
    );
  }

  String _number(int value) => _digits.toPersianDigits(value.toString());

  String _join(String primary, String? secondary) =>
      secondary == null ? primary : '$primary و $secondary';
}
