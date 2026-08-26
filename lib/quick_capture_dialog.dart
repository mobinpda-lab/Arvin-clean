import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/quick_capture_service.dart';

/// Compact Persian quick-capture surface backed by the canonical parser.
///
/// This widget owns no persistence. Its caller remains responsible for saving
/// the returned [Task] through Arvin's existing canonical Home write path.
class QuickCaptureDialog extends StatefulWidget {
  const QuickCaptureDialog({
    super.key,
    this.service = const QuickCaptureService(),
    this.idFactory,
    this.now,
  });

  final QuickCaptureService service;
  final String Function()? idFactory;
  final DateTime Function()? now;

  @override
  State<QuickCaptureDialog> createState() => _QuickCaptureDialogState();
}

class _QuickCaptureDialogState extends State<QuickCaptureDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
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

    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ثبت سریع'),
      content: TextField(
        controller: _controller,
        autofocus: true,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('لغو'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('ثبت'),
        ),
      ],
    );
  }
}
