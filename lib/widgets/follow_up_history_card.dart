import 'package:flutter/material.dart';

import '../models/task.dart';

/// Compact task-card section for the latest follow-up.
///
/// Kept as a standalone widget so the existing task list can adopt it without
/// changing persistence code in the same commit.
class FollowUpHistoryCard extends StatelessWidget {
  const FollowUpHistoryCard({super.key, required this.task});

  final ArvinTask task;

  String _two(int value) => value.toString().padLeft(2, '0');

  String _dateTime(DateTime value) {
    return '${value.year}/${_two(value.month)}/${_two(value.day)}'
        '  ${_two(value.hour)}:${_two(value.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final latest = task.lastFollowUp;
    if (latest == null) return const SizedBox.shrink();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            itemCount: task.followUps.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final item = [...task.followUps]
                ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
              final followUp = item[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(_dateTime(followUp.dateTime)),
                subtitle: followUp.note.isEmpty ? null : Text(followUp.note),
              );
            },
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(top: 8),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.update),
          title: const Text('آخرین پیگیری'),
          subtitle: Text(_dateTime(latest.dateTime)),
          trailing: const Icon(Icons.chevron_left),
        ),
      ),
    );
  }
}
