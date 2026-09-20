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

  Future<void> _submit({bool closeAfter = false}) async {
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
      if (closeAfter && mounted) Navigator.of(context).pop();
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

  Future<bool> _handleBack() async {
    if (_saving) return false;
    if (_controller.text.trim().isEmpty) return true;

    final navigator = Navigator.of(context);
    final decision = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ثبت سریع'),
        content: const Text('پیش‌نویس ثبت‌نشده دارید. چه کاری انجام شود؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'continue'),
            child: const Text('ادامه نوشتن'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'discard'),
            child: const Text('خروج بدون ثبت'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'save'),
            child: const Text('ثبت و خروج'),
          ),
        ],
      ),
    );
    if (decision == 'discard') return true;
    if (decision == 'save') {
      await _submit(closeAfter: true);
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _handleBack() && mounted) Navigator.of(context).pop();
      },
      child: KeyedSubtree(
        key: const ValueKey('quick-capture-sheet'),
        child: Material(
          color: const Color(0xFFFDFDFE),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D7E2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'ثبت سریع کار',
                    key: ValueKey('quick-capture-title'),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF232433),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('quick-capture-input'),
                    controller: _controller,
                    autofocus: true,
                    enabled: !_saving,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(
                      color: Color(0xFF232433),
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                    cursorColor: const Color(0xFF4A4CAB),
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'عنوان کار',
                      hintText: 'مثلاً تماس با علی',
                      errorText: _error,
                      filled: true,
                      fillColor: const Color(0xFFF8F8FB),
                      labelStyle: const TextStyle(
                        color: Color(0xFF232433),
                        fontWeight: FontWeight.w600,
                      ),
                      hintStyle: const TextStyle(color: Color(0xFF80829C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE5E7ED)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.onFullForm != null)
                        OutlinedButton.icon(
                          key: const ValueKey('quick-capture-full-form'),
                          onPressed: _saving ? null : _openFullForm,
                          icon: const Icon(Icons.tune_outlined, size: 18),
                          label: const Text('جزئیات بیشتر'),
                        ),
                      OutlinedButton.icon(
                        key: const ValueKey('quick-capture-tags-hint'),
                        onPressed: _saving
                            ? null
                            : () => _controller.text += ' #',
                        icon: const Icon(Icons.sell_outlined, size: 18),
                        label: const Text('برچسب'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    key: const ValueKey('quick-capture-submit'),
                    onPressed: _saving ? null : _submit,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(_saving ? 'در حال ثبت…' : 'ثبت کار'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
