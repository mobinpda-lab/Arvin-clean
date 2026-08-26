import 'package:flutter/material.dart';
import 'backup_manager.dart';
import 'models/task.dart';
import 'quick_capture_dialog.dart';
import 'services/app_settings_service.dart';
import 'services/home_search_projection.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_migration_reader.dart';
import 'services/task_migration_writer.dart';
import 'services/task_store.dart';
import 'services/widget_task_bridge.dart';
import 'services/widget_task_selection_service.dart';
import 'settings_page.dart';
import 'task_timeline_page.dart';
import 'widgets/canonical_calendar_launcher.dart';

void main() => runApp(const ArvinApp());

class ArvinApp extends StatefulWidget {
  const ArvinApp({super.key});

  @override
  State<ArvinApp> createState() => _ArvinAppState();
}

class _ArvinAppState extends State<ArvinApp> {
  final AppSettingsService settingsService = AppSettingsService();
  AppSettings settings = const AppSettings(
    themeMode: ThemeMode.system,
    usePersianDate: false,
    fontFamily: null,
  );

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final value = await settingsService.load();
    if (!mounted) return;
    setState(() => settings = value);
  }

  void _updateSettings(AppSettings value) {
    if (!mounted) return;
    setState(() => settings = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدیریت کارها وپیگیری آروین',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        fontFamily: settings.fontFamily,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        fontFamily: settings.fontFamily,
      ),
      themeMode: settings.themeMode,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(
          settings: settings,
          onSettingsChanged: _updateSettings,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.settings = const AppSettings(
      themeMode: ThemeMode.system,
      usePersianDate: false,
      fontFamily: null,
    ),
    this.onSettingsChanged,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings>? onSettingsChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskMigrationReader migrationReader = TaskMigrationReader();
  final TaskMigrationWriter migrationWriter = TaskMigrationWriter();
  final TaskStore taskStore = TaskStore();
  final ArvinBackupManager backupManager = ArvinBackupManager();
  final AppSettingsService appSettingsService = AppSettingsService();
  final HomeSearchProjection homeSearchProjection = const HomeSearchProjection();
  final PersianDateFormatter persianDateFormatter = const PersianDateFormatter();
  final WidgetTaskBridge widgetTaskBridge = WidgetTaskBridge();
  final WidgetTaskSelectionService widgetTaskSelectionService =
      WidgetTaskSelectionService();
  List<Task> tasks = [];
  final Set<String> selected = <String>{};
  bool loading = true;
  bool selectionMode = false;
  String query = '';
  String filter = 'فعال';

  @override
  void initState() {
    super.initState();
    widgetTaskBridge.listen(_openWidgetTask);
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _consumeInitialWidgetTask();
    });
  }

  @override
  void dispose() {
    widgetTaskBridge.dispose();
    super.dispose();
  }

  Future<void> _consumeInitialWidgetTask() async {
    final taskId = await widgetTaskBridge.consumeInitialTaskId();
    if (taskId != null) await _openWidgetTask(taskId);
  }

  Future<void> _openWidgetTask(String taskId) async {
    final task = await widgetTaskSelectionService.loadTask(taskId);
    if (!mounted) return;
    if (task == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('کار انتخاب‌شده از ویجت پیدا نشد')),
        );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskTimelinePage(task: task),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _load() async {
    try {
      final value = await migrationReader.load();
      if (!mounted) return;
      setState(() {
        tasks = List<Task>.of(value);
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        tasks = [];
        loading = false;
      });
    }
  }

  List<Task> get _searchSource => List<Task>.of(tasks);

  Future<void> _save() => migrationWriter.save(List<Task>.of(tasks));

  DateTime? _homeFollowUpDate(Task task) => task.legacyHomeFollowUpDate;

  bool _overdue(Task task) {
    final followUpDate = _homeFollowUpDate(task);
    return followUpDate != null &&
        !task.completed &&
        followUpDate.isBefore(DateTime.now());
  }

  List<Task> get visible {
    final matchingIds = query.trim().isEmpty
        ? null
        : homeSearchProjection.matchingIds(_searchSource, query);
    final result = tasks.where((task) {
      if (filter == 'فعال' && (task.archived || task.trashed)) return false;
      if (filter == 'بایگانی' && (!task.archived || task.trashed)) return false;
      if (filter == 'سطل زباله' && !task.trashed) return false;
      if (matchingIds != null && !matchingIds.contains(task.id)) return false;
      return true;
    }).toList();

    result.sort(
      (a, b) => (_homeFollowUpDate(a) ?? DateTime(9999))
          .compareTo(_homeFollowUpDate(b) ?? DateTime(9999)),
    );
    return result;
  }

  String _date(DateTime date) => persianDateFormatter.format(
        date,
        usePersianDate: widget.settings.usePersianDate,
      );

  Future<void> _add() async {
    final task = await showDialog<Task>(
      context: context,
      builder: (_) => const TaskDialog(),
    );
    if (task == null) return;
    setState(() => tasks.add(task));
    await _save();
  }

  Future<void> _quickCapture() async {
    final captured = await showDialog<Task>(
      context: context,
      builder: (_) => const QuickCaptureDialog(),
    );
    if (captured == null) return;

    try {
      await migrationWriter.save([..._searchSource, captured]);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('«${captured.title}» با ثبت سریع اضافه شد')),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('ثبت سریع انجام نشد؛ دوباره تلاش کنید')),
        );
    }
  }

  Future<void> _edit(Task old) async {
    final edited = await showDialog<Task>(
      context: context,
      builder: (_) => TaskDialog(task: old),
    );
    if (edited == null) return;
    setState(() {
      old.title = edited.title;
      old.description = edited.description;
      old.followUpEnabled = edited.followUpEnabled;
      old.followUpDate = edited.followUpDate;
      old.tags = List<String>.of(edited.tags);
      old.updatedAt = DateTime.now();
    });
    await _save();
  }

  Future<void> _archiveSelected() async {
    setState(() {
      for (final task in tasks) {
        if (selected.contains(task.id)) task.archived = true;
      }
      selected.clear();
      selectionMode = false;
    });
    await _save();
  }

  Future<void> _trashSelected() async {
    setState(() {
      for (final task in tasks) {
        if (selected.contains(task.id)) task.trashed = true;
      }
      selected.clear();
      selectionMode = false;
    });
    await _save();
  }

  Future<void> _restore(Task task) async {
    setState(() {
      task.trashed = false;
      task.archived = false;
    });
    await _save();
  }

  void _openFilter(BuildContext drawerContext, String nextFilter) {
    Navigator.pop(drawerContext);
    setState(() {
      filter = nextFilter;
      selected.clear();
      selectionMode = false;
    });
  }

  Future<bool> _confirmDeleteForever(Task task) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف دائمی'),
        content: Text(
          '«${task.title}» برای همیشه حذف شود؟ این کار قابل بازگشت نیست.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف برای همیشه'),
          ),
        ],
      ),
    );
    return approved == true;
  }

  Future<void> _deleteForever(Task task) async {
    setState(() => tasks.removeWhere((item) => item.id == task.id));
    await _save();
  }

  Future<void> _toggle(Task task) async {
    setState(() => task.completed = !task.completed);
    await _save();
  }

  Future<void> _chooseBackupDirectory() async {
    try {
      final uri = await backupManager.chooseAndRememberDirectory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uri == null
                ? 'انتخاب پوشه لغو شد'
                : 'پوشه پشتیبان با موفقیت انتخاب شد',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('انتخاب پوشه ناموفق بود: $error')),
        );
      }
    }
  }

  Future<void> _backupToFolder() async {
    try {
      var directory = await backupManager.getDirectory();
      if (directory == null || directory.isEmpty) {
        directory = await backupManager.chooseAndRememberDirectory();
      }
      if (directory == null || directory.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ابتدا یک پوشه برای پشتیبان انتخاب کنید')),
          );
        }
        return;
      }

      final fileName = await backupManager.backupCanonicalTasks(_searchSource);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fileName == null
                ? 'پشتیبان‌گیری انجام نشد'
                : 'پشتیبان ذخیره شد: $fileName',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('پشتیبان‌گیری ناموفق بود: $error')),
        );
      }
    }
  }

  Future<void> _restoreFromFile() async {
    try {
      final list = await backupManager.restoreCanonicalTasks();
      if (list == null) return;

      final emergencyBackup =
          await backupManager.backupCanonicalTasks(_searchSource);

      if (!mounted) return;
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('بازیابی اطلاعات'),
          content: Text(
            'تعداد ${list.length} کار از پشتیبان آماده بازیابی است.\n\n'
            '${emergencyBackup == null ? '' : 'قبل از بازیابی، یک پشتیبان اضطراری کامل نیز ساخته شد.'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('لغو'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('بازیابی'),
            ),
          ],
        ),
      );
      if (approved != true) return;

      await taskStore.save(List<Task>.of(list));
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${list.length} کار با همه جزئیات بازیابی شد')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('بازیابی ناموفق بود: $error')),
        );
      }
    }
  }

  Future<void> _backupMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('انتخاب پوشه پشتیبان'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _chooseBackupDirectory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('ایجاد Backup'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _backupToFolder();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Restore از فایل'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _restoreFromFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCalendar(BuildContext drawerContext) async {
    Navigator.pop(drawerContext);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: CanonicalCalendarLauncher(tasks: _searchSource),
        ),
      ),
    );
  }

  Future<void> _openSettings(BuildContext drawerContext) async {
    Navigator.pop(drawerContext);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          service: appSettingsService,
          onSettingsChanged: (value) {
            widget.onSettingsChanged?.call(value);
          },
          onOpenBackup: () {
            Navigator.of(context).pop();
            Future<void>.delayed(Duration.zero, _backupMenu);
          },
        ),
      ),
    );
  }

  Widget _taskCard(Task task) {
    final followUpDate = _homeFollowUpDate(task);
    final late = _overdue(task);
    return Dismissible(
      key: ValueKey(task.id),
      direction: selectionMode
          ? DismissDirection.none
          : DismissDirection.endToStart,
      confirmDismiss: (_) async {
        if (task.trashed) {
          final approved = await _confirmDeleteForever(task);
          if (!approved) return false;
          await _deleteForever(task);
        } else {
          setState(() => task.trashed = true);
          await _save();
        }
        return true;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Icon(Icons.delete_outline),
      ),
      child: Card(
        child: ListTile(
          onLongPress: () => setState(() {
            selectionMode = true;
            selected.add(task.id);
          }),
          onTap: selectionMode
              ? () => setState(() {
                    if (selected.contains(task.id)) {
                      selected.remove(task.id);
                    } else {
                      selected.add(task.id);
                    }
                  })
              : () => _edit(task),
          leading: selectionMode
              ? Checkbox(
                  value: selected.contains(task.id),
                  onChanged: (_) => setState(() {
                    if (selected.contains(task.id)) {
                      selected.remove(task.id);
                    } else {
                      selected.add(task.id);
                    }
                  }),
                )
              : IconButton(
                  onPressed: () => _toggle(task),
                  icon: Icon(
                    task.completed
                        ? Icons.check_circle
                        : late
                            ? Icons.warning_amber
                            : Icons.radio_button_unchecked,
                  ),
                ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) Text(task.description),
              if (task.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: task.tags.map<Widget>((tag) {
                    return Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              if (followUpDate != null)
                Text(
                  'پیگیری: ${_date(followUpDate)}${late ? '  •  عقب‌افتاده' : ''}',
                ),
              if (task.trashed || task.archived)
                TextButton(
                  onPressed: () => _restore(task),
                  child: const Text('بازگردانی به فعال'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final item in ['فعال', 'بایگانی', 'سطل زباله']) {
      chips.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: ChoiceChip(
            label: Text(item),
            selected: filter == item,
            onSelected: (_) => setState(() => filter = item),
          ),
        ),
      );
    }

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Builder(
            builder: (drawerContext) => ListView(
              padding: EdgeInsets.zero,
              children: [
                const ListTile(
                  leading: Icon(Icons.dashboard_outlined),
                  title: Text(
                    'آروین',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('مدیریت کارها و پیگیری‌ها'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('تقویم'),
                  onTap: () => _openCalendar(drawerContext),
                ),
                ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: const Text('بایگانی'),
                  onTap: () => _openFilter(drawerContext, 'بایگانی'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('سطل زباله'),
                  onTap: () => _openFilter(drawerContext, 'سطل زباله'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('تنظیمات'),
                  onTap: () => _openSettings(drawerContext),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 3),
            Text(
              'مدیریت کارها وپیگیری آروین',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: loading || selectionMode ? null : _quickCapture,
            tooltip: 'ثبت سریع',
            icon: const Icon(Icons.bolt_outlined),
          ),
          IconButton(
            onPressed: _backupMenu,
            tooltip: 'پشتیبان',
            icon: const Icon(Icons.backup_outlined),
          ),
          IconButton(
            onPressed: () => setState(() {
              selectionMode = !selectionMode;
              if (!selectionMode) selected.clear();
            }),
            icon: Icon(selectionMode ? Icons.close : Icons.checklist),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'جست‌وجو',
                    ),
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: chips,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          'کل',
                          tasks.where((t) => !t.trashed).length,
                          Icons.list_alt,
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          'فعال',
                          tasks
                              .where((t) =>
                                  !t.archived && !t.trashed && !t.completed)
                              .length,
                          Icons.pending_actions,
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          'انجام‌شده',
                          tasks.where((t) => t.completed && !t.trashed).length,
                          Icons.check_circle,
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          'عقب‌افتاده',
                          tasks.where(_overdue).length,
                          Icons.warning_amber,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Text(
                            filter == 'سطل زباله'
                                ? 'سطل زباله خالی است'
                                : filter == 'بایگانی'
                                    ? 'بایگانی خالی است'
                                    : 'کاری برای نمایش وجود ندارد',
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, index) => _taskCard(visible[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: selected.isEmpty
          ? FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('کار جدید'),
            )
          : null,
      bottomNavigationBar: selected.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.icon(
                      onPressed: _archiveSelected,
                      icon: const Icon(Icons.archive_outlined),
                      label: const Text('بایگانی'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _trashSelected,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('حذف'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon);
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Icon(icon, size: 20),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class TaskDialog extends StatefulWidget {
  const TaskDialog({super.key, this.task});
  final Task? task;
  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late final TextEditingController title;
  late final TextEditingController desc;
  late final TextEditingController tag;
  DateTime? followUpDate;
  late List<String> tags;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    title = TextEditingController(text: task?.title ?? '');
    desc = TextEditingController(text: task?.description ?? '');
    tag = TextEditingController();
    followUpDate = task?.legacyHomeFollowUpDate;
    tags = List<String>.of(task?.tags ?? const []);
  }

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    tag.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: followUpDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'انتخاب تاریخ پیگیری',
      cancelText: 'لغو',
      confirmText: 'تأیید',
    );
    if (date != null) setState(() => followUpDate = date);
  }

  void _addTag() {
    final value = tag.text.trim();
    if (value.isEmpty || tags.contains(value)) return;
    setState(() {
      tags.add(value);
      tag.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'کار جدید' : 'ویرایش کار'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'عنوان'),
            ),
            TextField(
              controller: desc,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'توضیحات'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tag,
                    decoration: const InputDecoration(labelText: 'تگ'),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
              ],
            ),
            if (tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: tags
                    .map((item) => InputChip(
                          label: Text(item),
                          onDeleted: () => setState(() => tags.remove(item)),
                        ))
                    .toList(),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(
                followUpDate == null
                    ? 'بدون تاریخ پیگیری'
                    : 'پیگیری: ${_dateText(followUpDate!)}',
              ),
              onTap: _pickDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('لغو'),
        ),
        FilledButton(
          onPressed: () {
            final now = DateTime.now();
            final id =
                widget.task?.id ?? now.microsecondsSinceEpoch.toString();
            Navigator.pop(
              context,
              Task(
                id: id,
                title: title.text.trim().isEmpty
                    ? 'بدون عنوان'
                    : title.text.trim(),
                description: desc.text.trim(),
                followUpEnabled: followUpDate != null,
                followUpDate: followUpDate,
                tags: List<String>.of(tags),
                createdAt: widget.task?.createdAt ?? now,
                updatedAt: now,
              ),
            );
          },
          child: const Text('ذخیره'),
        ),
      ],
    );
  }
}

String _dateText(DateTime date) =>
    '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
