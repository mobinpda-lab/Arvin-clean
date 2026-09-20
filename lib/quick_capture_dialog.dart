import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/quick_capture_service.dart';

/// Compact Persian quick-capture surface backed by the canonical parser.
///
/// This widget owns no persistence. When [onCaptured] is supplied, every
/// canonical [Task] is handed to the caller for persistence and the dialog
/// remains open for the next entry. Without it, the legacy single-capture
/// behavior is preserved and the task is returned through Navigator.pop.
class QuickCaptureDialog extends StatefulWidget {
  const QuickCaptureDialog({
    super.key,
    this.service = const QuickCaptureService(),
    this.idFactory,
    this.now,
    this.onCaptured,
    this.onFullForm,
  });

  final QuickCaptureService service;
  final String Function()? idFactory;
  final DateTime Function()? now;
  final Future<void> Function(Task task)? onCaptured;
  final Future<bool> Function(Task draft)? onFullForm;

  @override
  State<QuickCaptureDialog> createState() => _QuickCaptureDialogState();
}

class _QuickCaptureDialogState extends State<QuickCaptureDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  bool _saving = false;
  DateTime? _dueDate;
  DateTime? _reminderDate;
  bool _followUp = false;
  TaskPriority _priority = TaskPriority.none;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    final createdAt = widget.now?.call() ?? DateTime.now();
    final task = widget.service.capture(
      _controller.text,
      id: widget.idFactory?.call() ??
          createdAt.microsecondsSinceEpoch.toString(),
      createdAt: createdAt,
    );
    if (task != null) {
      task.dueDate = _dueDate;
      task.reminderDate = _reminderDate;
      task.followUpEnabled = _followUp;
      task.followUpDate = _followUp ? (task.followUpDate ?? createdAt) : null;
      task.priority = _priority;
    }

    if (task == null) {
      setState(() => _error = 'یک متن کوتاه برای ثبت وارد کنید');
      return;
    }

    final onCaptured = widget.onCaptured;
    if (onCaptured == null) {
      Navigator.of(context).pop(task);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await onCaptured(task);
      if (!mounted) return;
      _controller.clear();
      setState(() => _saving = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'ثبت انجام نشد؛ دوباره تلاش کنید';
      });
    }
  }

  Future<void> _openFullForm() async {
    if (_saving) return;
    final createdAt = widget.now?.call() ?? DateTime.now();
    final draft = widget.service.capture(
      _controller.text,
      id: widget.idFactory?.call() ??
          createdAt.microsecondsSinceEpoch.toString(),
      createdAt: createdAt,
    );
    if (draft == null) {
      setState(() => _error = 'یک متن کوتاه برای ادامه وارد کنید');
      return;
    }
    final onFullForm = widget.onFullForm;
    if (onFullForm == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await onFullForm(draft);
      if (!mounted) return;
      if (saved) _controller.clear();
      setState(() => _saving = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'باز کردن فرم کامل انجام نشد؛ دوباره تلاش کنید';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          key: const ValueKey('quick-capture-sheet'),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset),
          decoration: const BoxDecoration(
            color: Color(0xFFFDFDFE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFFD9DAE3),
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'ثبت سریع کار',
                          style: TextStyle(
                            color: Color(0xFF232433),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('quick-capture-close'),
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'بستن',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'عنوان برای ثبت کافی است',
                    style: TextStyle(
                      color: Color(0xFF80829C),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey('quick-capture-input'),
                    controller: _controller,
                    autofocus: true,
                    enabled: !_saving,
                    textInputAction: TextInputAction.done,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Color(0xFF232433),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFF4A4CAB),
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'عنوان کار را وارد کنید',
                      errorText: _error,
                      filled: true,
                      fillColor: const Color(0xFFF6F6FA),
                      hintStyle: const TextStyle(color: Color(0xFF8B8C9E)),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF4A4CAB),
                          width: 1.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _quickChip(
                        'امروز',
                        Icons.today_rounded,
                        selected: _dueDate != null,
                        onPressed: _setToday,
                      ),
                      _quickChip(
                        'فوری',
                        Icons.bolt_rounded,
                        selected: _priority == TaskPriority.high,
                        onPressed: _toggleUrgent,
                      ),
                      _quickChip(
                        'پیگیری',
                        Icons.sync_rounded,
                        selected: _followUp,
                        onPressed: _toggleFollowUp,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (widget.onFullForm != null)
                        Expanded(
                          child: OutlinedButton(
                            key: const ValueKey('quick-capture-full-form'),
                            onPressed: _saving ? null : _openFullForm,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('فرم کامل'),
                          ),
                        ),
                      if (widget.onFullForm != null) const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          key: const ValueKey('quick-capture-submit'),
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(_saving ? 'در حال ثبت…' : 'ثبت کار'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setToday() {
    final now = widget.now?.call() ?? DateTime.now();
    setState(() {
      _dueDate = DateTime(now.year, now.month, now.day);
      _error = null;
    });
  }

  void _toggleUrgent() {
    setState(() {
      _priority = _priority == TaskPriority.high
          ? TaskPriority.none
          : TaskPriority.high;
      _error = null;
    });
  }

  void _toggleFollowUp() {
    setState(() {
      _followUp = !_followUp;
      _error = null;
    });
  }

  Widget _quickChip(
    String label,
    IconData icon, {
    required VoidCallback onPressed,
    bool selected = false,
  }) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(icon, size: 17),
      onPressed: _saving ? null : onPressed,
      backgroundColor: selected ? const Color(0xFFE9EAFF) : null,
      side: BorderSide(
        color: selected ? const Color(0xFF4A4CAB) : const Color(0xFFE5E7ED),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
