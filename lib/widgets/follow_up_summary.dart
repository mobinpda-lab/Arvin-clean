import 'package:flutter/material.dart';

import '../models/task.dart';

/// Compact presentation of the latest follow-up for a task.
///
/// The widget intentionally depends only on [ArvinTask], so it can be reused
/// by the task list and the task details page without duplicating date logic.
class FollowUpSummary extends StatelessWidget {
  const FollowUpSummary({super.key, required this.task});

  final ArvinTask task;

  String _dateTime(DateTime value) {
    final date = '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
    final time = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
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
              'آخرین پیگیری: ${_dateTime(followUp.dateTime)}${followUp.note.isEmpty ? '' : ' • ${followUp.note}'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
