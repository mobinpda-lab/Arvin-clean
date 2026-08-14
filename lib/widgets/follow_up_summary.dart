import 'package:flutter/material.dart';

import '../models/task.dart';

/// Compact, reusable presentation of the newest follow-up for a task.
///
/// This widget is intentionally presentation-only: it does not mutate the
/// task, storage, Calendar, or the existing HomePage UI.
class FollowUpSummary extends StatelessWidget {
  const FollowUpSummary({super.key, required this.task});

  final ArvinTask task;

  String _digits(String value) {
    const western = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    var result = value;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], persian[i]);
    }
    return result;
  }

  String _dateTime(DateTime value) {
    final date = _digits(
      '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}',
    );
    final time = _digits(
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
    );
    return '$date • $time';
  }

  @override
  Widget build(BuildContext context) {
    final followUp = task.lastFollowUp;
    if (followUp == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.history, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'آخرین پیگیری: ${_dateTime(followUp.dateTime)}'
              '${followUp.note.isEmpty ? '' : ' • ${followUp.note}'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
