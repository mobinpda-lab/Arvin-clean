import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/persian_date_formatter.dart';
import '../services/task_recurrence_repository.dart';

/// Shared UI for the canonical checklist snapshot belonging to one recurrence
/// occurrence. Both Task Details and Repeat use the same repository contract.
class OccurrenceChecklistEditor extends StatefulWidget {
  OccurrenceChecklistEditor({
    super.key,
    required this.task,
    TaskRecurrenceRepository? repository,
    this.onTaskUpdated,
  }) : repository = repository ?? TaskRecurrenceRepository();

  final Task task;
  final TaskRecurrenceRepository repository;
  final Future<void> Function(Task task)? onTaskUpdated;

  @override
  State<OccurrenceChecklistEditor> createState() =>
      _OccurrenceChecklistEditorState();
}

class _OccurrenceChecklistEditorState extends State<OccurrenceChecklistEditor> {
  String? _selectedKey;
  List<String> _items = const [];
  bool _busy = false;
  String? _error;

  @override
  void didUpdateWidget(covariant OccurrenceChecklistEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.task, widget.task)) {
      final selected = _selectedKey;
      if (selected != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedKey == selected) {
            unawaited(_selectOccurrence(selected));
          }
        });
      }
    }
  }

  List<DateTime> _choices() {
    final task = widget.task;
    final rule = task.recurrence;
    if (rule == null) return const [];

    final values = <String, DateTime>{};
    for (final key in task.checklistOccurrences.keys) {
      final parsed = DateTime.tryParse(key);
      if (parsed != null) values[key] = parsed;
    }
    for (final key in task.occurrenceHistory.keys) {
      final parsed = DateTime.tryParse(key);
      if (parsed != null) values[key] = parsed;
    }

    final now = widget.repository.now();
    var cursor = rule.startDate ?? task.reminderDate ?? now;
    for (var guard = 0; guard < 400; guard++) {
      if (rule.endDate != null && !cursor.isBefore(rule.endDate!)) break;
      values[cursor.toIso8601String()] = cursor;
      if (cursor.isAfter(now.add(const Duration(days: 90)))) break;
      final next = rule.nextOccurrence(cursor);
      if (!next.isAfter(cursor)) break;
      cursor = next;
    }
    final result = values.values.toList()
      ..sort((a, b) => a.compareTo(b));
    return result;
  }

  String _date(DateTime value) =>
      const PersianDateFormatter().format(value, usePersianDate: true);

  Future<void> _selectOccurrence(String key) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final date = DateTime.tryParse(key);
      if (date == null) {
        throw const FormatException('Invalid occurrence key');
      }
      final items = await widget.repository.checklistForOccurrence(
        widget.task.id,
        date,
      );
      if (!mounted) return;
      setState(() {
        _selectedKey = key;
        _items = List<String>.of(items);
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'خواندن چک‌لیست این نوبت انجام نشد');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggle(int index, bool? checked) {
    final label = _items[index].replaceFirst(RegExp(r'^\[(x| )\]\s*'), '');
    setState(() {
      _items = List<String>.of(_items)
        ..[index] = '${checked == true ? '[x]' : '[ ]'} $label';
    });
  }

  Future<void> _save() async {
    final key = _selectedKey;
    if (key == null || _busy) return;
    final occurrence = DateTime.tryParse(key);
    if (occurrence == null) {
      setState(() => _error = 'کلید این نوبت معتبر نیست؛ داده حذف نشده است.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await widget.repository.setChecklistForOccurrence(
        widget.task.id,
        occurrence,
        _items,
      );
      final persisted = await widget.repository.checklistForOccurrence(
        widget.task.id,
        occurrence,
      );
      if (!mounted) return;
      setState(() => _items = List<String>.of(persisted));
      await widget.onTaskUpdated?.call(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('چک‌لیست همین نوبت ذخیره شد')),
      );
    } catch (_) {
      if (mounted) setState(() => _error = 'ذخیره چک‌لیست نوبت انجام نشد');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    if (task.recurrence == null || !task.checklistEnabled || task.checklist.isEmpty) {
      return const SizedBox.shrink();
    }
    final choices = _choices();
    final selected = _selectedKey;
    return Card(
      key: const ValueKey('occurrence-checklist-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'چک‌لیست مستقل هر نوبت',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (choices.isEmpty)
              const Text('برای این کار نوبت معتبر قابل انتخابی پیدا نشد.')
            else
              DropdownButtonFormField<String>(
                key: ValueKey('occurrence-checklist-picker-${task.id}'),
                initialValue: selected != null &&
                        choices.any((date) => date.toIso8601String() == selected)
                    ? selected
                    : null,
                decoration: const InputDecoration(labelText: 'نوبت موردنظر'),
                items: [
                  for (final date in choices)
                    DropdownMenuItem(
                      value: date.toIso8601String(),
                      child: Text(_date(date)),
                    ),
                ],
                onChanged: _busy ? null : (key) {
                  if (key != null) _selectOccurrence(key);
                },
              ),
            if (_busy) const LinearProgressIndicator(),
            if (selected != null) ...[
              const SizedBox(height: 8),
              for (var index = 0; index < _items.length; index++)
                CheckboxListTile(
                  key: ValueKey('occurrence-checklist-item-${task.id}-${selected}-$index'),
                  contentPadding: EdgeInsets.zero,
                  value: _items[index].startsWith('[x]'),
                  title: Text(_items[index].replaceFirst(RegExp(r'^\[(x| )\]\s*'), '')),
                  onChanged: _busy ? null : (value) => _toggle(index, value),
                ),
              FilledButton.icon(
                key: const ValueKey('occurrence-checklist-save'),
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('ذخیره چک‌لیست این نوبت'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
