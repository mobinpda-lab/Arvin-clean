import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'models/task.dart';
import 'services/task_report_pdf_renderer.dart';
import 'services/task_report_projection.dart';
import 'services/task_report_text_renderer.dart';

class TaskReportPage extends StatefulWidget {
  TaskReportPage({
    super.key,
    required this.tasks,
    this.initialSelectedIds = const <String>{},
    TaskReportProjection? projection,
    TaskReportPdfRenderer? renderer,
    TaskReportTextRenderer? textRenderer,
  })  : projection = projection ?? const TaskReportProjection(),
        renderer = renderer ?? TaskReportPdfRenderer(),
        textRenderer = textRenderer ?? const TaskReportTextRenderer();

  final List<Task> tasks;
  final Set<String> initialSelectedIds;
  final TaskReportProjection projection;
  final TaskReportPdfRenderer renderer;
  final TaskReportTextRenderer textRenderer;

  @override
  State<TaskReportPage> createState() => _TaskReportPageState();
}

class _TaskReportPageState extends State<TaskReportPage> {
  late final Set<String> _selected;

  List<Task> get _available =>
      widget.tasks.where((task) => !task.trashed).toList(growable: false);

  @override
  void initState() {
    super.initState();
    final availableIds = _available.map((task) => task.id).toSet();
    _selected = widget.initialSelectedIds
        .where(availableIds.contains)
        .toSet();
  }

  TaskReport _buildReport({
    Set<String>? selectedIds,
    String title = 'گزارش آروین',
  }) =>
      widget.projection.project(
        widget.tasks,
        selectedIds: selectedIds,
        title: title,
      );

  Future<void> _copyText(
    BuildContext context, {
    Set<String>? selectedIds,
    String title = 'گزارش آروین',
  }) async {
    final report = _buildReport(selectedIds: selectedIds, title: title);
    if (report.entries.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('موردی برای گزارش انتخاب نشده است')));
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: widget.textRenderer.render(report)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('متن گزارش کپی شد')));
  }

  Future<void> _preview(
    BuildContext context, {
    Set<String>? selectedIds,
    String title = 'گزارش آروین',
  }) async {
    final report = _buildReport(selectedIds: selectedIds, title: title);
    if (report.entries.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('موردی برای گزارش انتخاب نشده است')));
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: Text(title)),
            body: PdfPreview(
              canChangePageFormat: false,
              allowPrinting: true,
              allowSharing: true,
              build: (_) => widget.renderer.build(
                report,
                pageFormat: PdfPageFormat.a4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _available;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('PDF و چاپ')),
        body: tasks.isEmpty
            ? const Center(child: Text('کاری برای گزارش وجود ندارد'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 112),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return CheckboxListTile(
                    key: ValueKey('report-task-${task.id}'),
                    value: _selected.contains(task.id),
                    onChanged: (value) => setState(() {
                      if (value == true) {
                        _selected.add(task.id);
                      } else {
                        _selected.remove(task.id);
                      }
                    }),
                    title: Text(task.title.trim().isEmpty ? 'بدون عنوان' : task.title),
                    subtitle: Text(task.completed ? 'انجام‌شده' : 'باز'),
                    secondary: Wrap(
                      spacing: 2,
                      children: [
                        IconButton(
                          key: ValueKey('report-copy-${task.id}'),
                          tooltip: 'کپی متن همین مورد',
                          onPressed: () => _copyText(
                            context,
                            selectedIds: {task.id},
                            title: 'گزارش ${task.title.trim().isEmpty ? 'بدون عنوان' : task.title}',
                          ),
                          icon: const Icon(Icons.content_copy_outlined),
                        ),
                        IconButton(
                          key: ValueKey('report-single-${task.id}'),
                          tooltip: 'PDF/چاپ همین مورد',
                          onPressed: () => _preview(
                            context,
                            selectedIds: {task.id},
                            title: 'گزارش ${task.title.trim().isEmpty ? 'بدون عنوان' : task.title}',
                          ),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                        ),
                      ],
                    ),
                  );
                },
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('report-copy-all'),
                        onPressed: tasks.isEmpty ? null : () => _copyText(context),
                        icon: const Icon(Icons.content_copy_outlined),
                        label: const Text('کپی متن همه'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('report-copy-selected'),
                        onPressed: _selected.isEmpty
                            ? null
                            : () => _copyText(
                                  context,
                                  selectedIds: Set<String>.of(_selected),
                                  title: 'گزارش موارد انتخاب‌شده',
                                ),
                        icon: const Icon(Icons.content_copy_outlined),
                        label: Text('کپی انتخاب‌شده (${_selected.length})'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        key: const ValueKey('report-all'),
                        onPressed: tasks.isEmpty ? null : () => _preview(context),
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('همه'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        key: const ValueKey('report-selected'),
                        onPressed: _selected.isEmpty
                            ? null
                            : () => _preview(
                                  context,
                                  selectedIds: Set<String>.of(_selected),
                                  title: 'گزارش موارد انتخاب‌شده',
                                ),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: Text('انتخاب‌شده (${_selected.length})'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
