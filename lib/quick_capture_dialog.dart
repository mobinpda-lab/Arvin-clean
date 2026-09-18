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
    return AlertDialog(
      key: const ValueKey('quick-capture-dialog'),
      title: const Text('ثبت سریع'),
      content: TextField(
        key: const ValueKey('quick-capture-input'),
        controller: _controller,
        autofocus: true,
        enabled: !_saving,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: 'کار و #برچسب‌ها',
          hintText: 'مثلاً تماس با علی #مشتری #فوری',
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('quick-capture-cancel'),
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('بستن'),
        ),
        if (widget.onFullForm != null)
          TextButton(
            key: const ValueKey('quick-capture-full-form'),
            onPressed: _saving ? null : _openFullForm,
            child: const Text('فرم کامل'),
          ),
        FilledButton(
          key: const ValueKey('quick-capture-submit'),
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'در حال ثبت…' : 'ثبت'),
        ),
      ],
    );
  }
}
