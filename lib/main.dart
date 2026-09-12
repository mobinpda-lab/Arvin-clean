import 'package:flutter/material.dart';

import 'android_follow_up_reminder_scheduler.dart';
import 'backup_manager.dart';
import 'models/task.dart';
import 'notebook_page.dart';
import 'quick_capture_dialog.dart';
import 'services/app_settings_service.dart';
import 'services/home_search_projection.dart';
import 'services/home_today_projection.dart';
import 'services/interactive_guide_service.dart';
import 'services/task_due_scope_service.dart';
import 'services/task_list_scope_service.dart';
import 'services/task_list_sort_service.dart';
import 'services/task_move_to_today_service.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_edit_apply_service.dart';
import 'services/task_bulk_mutation_service.dart';
import 'services/task_bulk_selection_service.dart';
import 'services/task_store.dart';
import 'services/wave2_product_fast_track.dart';
import 'services/widget_task_bridge.dart';
import 'services/widget_task_selection_service.dart';
import 'settings_page.dart';
import 'task_detail_page.dart';
import 'task_editor_dialog.dart';
import 'task_next_action_page.dart';
import 'task_report_page.dart';
import 'theme/app_fonts.dart';
import 'widgets/arvin_primary_navigation.dart';
import 'widgets/arvin_home_primary_add_button.dart';
import 'widgets/canonical_calendar_launcher.dart';
import 'widgets/home_interactive_guide.dart';
import 'widgets/task_bulk_selection_bar.dart';

void main() => runApp(const ArvinApp(enableFirstRunGuide: true));

class ArvinApp extends StatefulWidget {
  const ArvinApp({
    super.key,
    this.enableFirstRunGuide = false,
  });

  final bool enableFirstRunGuide;

  @override
  State<ArvinApp> createState() => _ArvinAppState();
}

class _ArvinAppState extends State<ArvinApp> {
  final AppSettingsService settingsService = AppSettingsService();
  AppSettings settings = const AppSettings(
    themeMode: ThemeMode.system,
    usePersianDate: true,
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
        fontFamily: settings.fontFamily ?? AppFonts.vazirharfFamily,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        fontFamily: settings.fontFamily ?? AppFonts.vazirharfFamily,
      ),
      themeMode: settings.themeMode,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(
          settings: settings,
          onSettingsChanged: _updateSettings,
          enableFirstRunGuide: widget.enableFirstRunGuide,
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
      usePersianDate: true,
      fontFamily: null,
    ),
    this.onSettingsChanged,
    this.enableFirstRunGuide = false,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings>? onSettingsChanged;
  final bool enableFirstRunGuide;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskEditApplyService taskEditApplyService = TaskEditApplyService();
  final TaskStore taskStore = TaskStore();
  final Wave2ProductFastTrack wave2ProductFastTrack = Wave2ProductFastTrack();
  final ArvinBackupManager backupManager = ArvinBackupManager();
  final AppSettingsService appSettingsService = AppSettingsService();
  final InteractiveGuideService interactiveGuideService =
      InteractiveGuideService();
  final HomeSearchProjection homeSearchProjection = const HomeSearchProjection();
  final HomeTodayProjection homeTodayProjection = const HomeTodayProjection();
  final TaskListScopeService taskListScopeService = const TaskListScopeService();
  final TaskDueScopeService taskDueScopeService = const TaskDueScopeService();
  final TaskListSortService taskListSortService = const TaskListSortService();
  final PersianDateFormatter persianDateFormatter = const PersianDateFormatter();
  final WidgetTaskBridge widgetTaskBridge = WidgetTaskBridge();
  final WidgetTaskSelectionService widgetTaskSelectionService =
      WidgetTaskSelectionService();
  final TaskBulkSelectionService taskBulkSelectionService =
      const TaskBulkSelectionService();
  final TaskBulkMutationService taskBulkMutationService =
      TaskBulkMutationService();

  final GlobalKey _searchGuideKey =
      GlobalKey(debugLabel: 'home-guide-search');
  final GlobalKey _filtersGuideKey =
      GlobalKey(debugLabel: 'home-guide-filters');
  final GlobalKey _newTaskGuideKey =
      GlobalKey(debugLabel: 'home-guide-new-task');

  List<Task> tasks = [];
  final Set<String> selected = <String>{};
  bool loading = true;
  Object? loadFailure;
  bool selectionMode = false;
  bool _firstRunGuideChecked = false;
  bool _interactiveGuideRunning = false;
  String query = '';
  String filter = 'کل';
  TaskListScope _listScope = TaskListScope.all;
  TaskDueScope? _dueScope;
  TaskListSort _listSort = TaskListSort.date;
  bool _sortDescending = false;

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

    await _openTaskDetail(task);
  }

  Future<void> _load() async {
    try {
      final value = await taskStore.load();
      if (!mounted) return;
      setState(() {
        tasks = List<Task>.of(value);
        loadFailure = null;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loadFailure = error;
        loading = false;
      });
    }
    await _maybeShowFirstRunGuide();
  }

  Future<void> _maybeShowFirstRunGuide() async {
    if (!widget.enableFirstRunGuide || _firstRunGuideChecked) return;
    _firstRunGuideChecked = true;
    final shouldShow = await interactiveGuideService.shouldShow();
    if (!mounted || !shouldShow) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startInteractiveGuide();
    });
  }

  Future<void> _startInteractiveGuide() async {
    if (!mounted || loading || _interactiveGuideRunning) return;
    _interactiveGuideRunning = true;
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      _interactiveGuideRunning = false;
      return;
    }

    final finished = await showHomeInteractiveGuide(
      context: context,
      targets: [
        HomeGuideTarget(
          key: _searchGuideKey,
          title: 'جست‌وجو',
          description:
              'بخشی از عنوان، توضیح یا برچسب را بنویسید تا آروین کار موردنظر را سریع پیدا کند.',
          icon: Icons.search,
        ),
        HomeGuideTarget(
          key: _filtersGuideKey,
          title: 'فیلتر کارها',
          description:
              'با این بخش بین کارهای فعال، بایگانی و سطل زباله جابه‌جا می‌شوید.',
          icon: Icons.filter_alt_outlined,
        ),
        HomeGuideTarget(
          key: _newTaskGuideKey,
          title: 'ساخت کار جدید',
          description:
              'برای ثبت یک کار کامل با عنوان، توضیحات، برچسب، تاریخ و ساعت پیگیری از این دکمه استفاده کنید.',
          icon: Icons.add_circle_outline,
        ),
      ],
    );

    if (finished) await interactiveGuideService.markSeen();
    _interactiveGuideRunning = false;
  }

  List<Task> get _searchSource => List<Task>.of(tasks);

  Future<void> _save() {
    if (loadFailure != null) {
      throw StateError(
        'Canonical task storage is unreadable; refusing Home write.',
      );
    }
    return taskStore.save(List<Task>.of(tasks));
  }

  DateTime? _homeFollowUpDate(Task task) => task.legacyHomeFollowUpDate;

  bool _overdue(Task task) {
    final date = _homeFollowUpDate(task);
    return date != null && !task.completed && date.isBefore(DateTime.now());
  }

  List<Task> get visible {
    final matchingIds = query.trim().isEmpty
        ? null
        : homeSearchProjection.matchingIds(_searchSource, query);

    Iterable<Task> scoped = tasks;
    if (filter != 'بایگانی' && filter != 'سطل زباله') {
      scoped = taskListScopeService.project(scoped, scope: _listScope);
      final dueScope = _dueScope;
      if (dueScope != null) {
        scoped = taskDueScopeService.project(
          scoped,
          now: DateTime.now(),
          scope: dueScope,
        );
      }
    }

    final result = scoped.where((task) {
      if (filter == 'کل' && (task.archived || task.trashed)) return false;
      if (filter == 'فعال' &&
          (task.archived || task.trashed || task.completed)) {
        return false;
      }
      if (filter == 'انجام‌شده' &&
          (task.archived || task.trashed || !task.completed)) {
        return false;
      }
      if (filter == 'بایگانی' && (!task.archived || task.trashed)) return false;
      if (filter == 'سطل زباله' && !task.trashed) return false;
      if (matchingIds != null && !matchingIds.contains(task.id)) return false;
      return true;
    }).toList(growable: false);

    return taskListSortService.sort(
      result,
      by: _listSort,
      descending: _sortDescending,
    );
  }

  String get _emptyVisibleLabel {
    if (filter == 'سطل زباله') return 'سطل زباله خالی است';
    if (filter == 'بایگانی') return 'بایگانی خالی است';
    if (_dueScope == TaskDueScope.today) return 'کاری برای امروز وجود ندارد';
    if (_dueScope == TaskDueScope.future) return 'کار آینده‌ای وجود ندارد';
    if (_dueScope == TaskDueScope.overdue) return 'کار عقب‌افتاده‌ای وجود ندارد';
    if (_listScope == TaskListScope.simpleNotes) {
      return 'یادداشتی برای نمایش وجود ندارد';
    }
    if (_listScope == TaskListScope.followUpEnabled) {
      return 'کار دارای پیگیری برای نمایش وجود ندارد';
    }
    if (filter == 'انجام‌شده') return 'کار انجام‌شده‌ای وجود ندارد';
    return 'کاری برای نمایش وجود ندارد';
  }

  String _sortLabel(TaskListSort sort) => switch (sort) {
        TaskListSort.date => 'تاریخ کار',
        TaskListSort.latest => 'آخرین تغییر',
        TaskListSort.lastFollowUp => 'آخرین پیگیری',
        TaskListSort.title => 'عنوان',
      };

  String _date(DateTime date) => persianDateFormatter.format(
        date,
        usePersianDate: widget.settings.usePersianDate,
      );

  String _time(DateTime date) => persianDateFormatter.toPersianDigits(
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
      );

  Future<void> _add() async {
    final editorContext = await wave2ProductFastTrack.prepareEditor(tasks: tasks);
    if (!mounted) return;
    String? selectedProjectId = editorContext.selectedProjectId;
    final task = await showDialog<Task>(
      context: context,
      builder: (_) => ArvinTaskEditorDialog(
        projects: editorContext.projects,
        selectedProjectId: editorContext.selectedProjectId,
        onProjectChanged: (value) => selectedProjectId = value,
        knownCategories: editorContext.knownCategories,
      ),
    );
    if (task == null) return;
    setState(() => tasks.add(task));
    await _save();
    await wave2ProductFastTrack.persistProjectSelection(
      taskId: task.id,
      projectId: selectedProjectId,
    );
  }

  Future<void> _quickCapture() async {
    if (loadFailure != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'داده‌های کارها قابل خواندن نیست؛ ابتدا «تلاش دوباره» را بزنید.',
            ),
          ),
        );
      return;
    }

    final captured = await showDialog<Task>(
      context: context,
      builder: (_) => const QuickCaptureDialog(),
    );
    if (captured == null) return;

    try {
      await taskStore.mutate<void>((stored) {
        if (stored.any((task) => task.id == captured.id)) {
          throw StateError('Duplicate Task id: ${captured.id}');
        }
        stored.add(captured);
      });
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
    final editorContext = await wave2ProductFastTrack.prepareEditor(
      tasks: tasks,
      task: old,
    );
    if (!mounted) return;
    String? selectedProjectId = editorContext.selectedProjectId;
    final edited = await showDialog<Task>(
      context: context,
      builder: (_) => ArvinTaskEditorDialog(
        task: old,
        projects: editorContext.projects,
        selectedProjectId: editorContext.selectedProjectId,
        onProjectChanged: (value) => selectedProjectId = value,
        knownCategories: editorContext.knownCategories,
      ),
    );
    if (edited == null) return;
    setState(() => taskEditApplyService.apply(old, edited));
    await _save();
    await wave2ProductFastTrack.persistProjectSelection(
      taskId: edited.id,
      projectId: selectedProjectId,
    );
  }

  Future<Task?> _editFromDetail(Task task) async {
    await _edit(task);
    return task;
  }

  Future<Task> _addFollowUpFromDetail(Task task, FollowUp followUp) async {
    await taskStore.addFollowUp(task.id, followUp);
    try {
      await AndroidFollowUpReminderScheduler().reschedule();
    } catch (_) {
      // Canonical write already succeeded; scheduler retries from TaskStore.
    }
    final updatedTasks = await taskStore.load();
    final updated = updatedTasks.firstWhere((item) => item.id == task.id);
    if (mounted) {
      setState(() => tasks = List<Task>.of(updatedTasks));
    }
    return updated;
  }

  Future<void> _openTaskDetail(Task task) async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskDetailPage(
          task: task,
          onEdit: _editFromDetail,
          onAddFollowUp: _addFollowUpFromDetail,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _archiveSelected() async {
    setState(() {
      for (final task in tasks) {
        if (selected.contains(task.id)) {
          task.archived = true;
          task.trashed = false;
        }
      }
      selected.clear();
      selectionMode = false;
    });
    await _save();
  }

  Future<void> _trashSelected() async {
    setState(() {
      for (final task in tasks) {
        if (selected.contains(task.id)) {
          task.trashed = true;
          task.archived = false;
        }
      }
      selected.clear();
      selectionMode = false;
    });
    await _save();
  }

  void _toggleAllVisibleSelection() {
    setState(() {
      final next = taskBulkSelectionService.selectAll(selected, visible);
      selected
        ..clear()
        ..addAll(next);
      selectionMode = selected.isNotEmpty;
    });
  }

  void _clearBulkSelection() {
    setState(() {
      selected.clear();
      selectionMode = false;
    });
  }

  Future<void> _openSelectedReport() async {
    final selectedIds = Set<String>.of(selected);
    if (selectedIds.isEmpty) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskReportPage(
          tasks: List<Task>.of(tasks),
          initialSelectedIds: selectedIds,
        ),
      ),
    );
  }

  Future<void> _moveSelectedToCategory() async {
    if (selected.isEmpty) return;
    var value = '';
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تغییر دسته موارد انتخاب‌شده'),
        content: TextFormField(
          key: const ValueKey('task-bulk-category-input'),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'نام دسته',
            hintText: 'برای بدون دسته خالی بگذارید',
            border: OutlineInputBorder(),
          ),
          onChanged: (next) => value = next,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لغو'),
          ),
          FilledButton(
            key: const ValueKey('task-bulk-category-apply'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('اعمال'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;

    final changed = taskBulkMutationService.moveToCategory(
      tasks,
      selected,
      value,
    );
    if (changed == 0) return;

    setState(() {
      selected.clear();
      selectionMode = false;
    });
    await _save();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('دسته برای $changed مورد به‌روز شد')),
      );
  }

  Future<void> _addTagsToSelected() async {
    if (selected.isEmpty) return;
    var value = '';
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('افزودن برچسب به موارد انتخاب‌شده'),
        content: TextFormField(
          key: const ValueKey('task-bulk-tags-input'),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'برچسب‌ها',
            hintText: 'با ویرگول جدا کنید',
            border: OutlineInputBorder(),
          ),
          onChanged: (next) => value = next,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لغو'),
          ),
          FilledButton(
            key: const ValueKey('task-bulk-tags-apply'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('اعمال'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;

    final tags = value
        .split(RegExp(r'[,،]'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty);
    final changed = taskBulkMutationService.addTags(tasks, selected, tags);
    if (changed == 0) return;

    setState(() {
      selected.clear();
      selectionMode = false;
    });
    await _save();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('برچسب‌ها برای $changed مورد به‌روز شد')),
      );
  }

  Future<void> _restore(Task task) async {
    setState(() {
      task.trashed = false;
      task.archived = false;
    });
    await _save();
  }

  void _selectHomeStat(String nextFilter) {
    setState(() {
      _listScope = TaskListScope.all;
      if (nextFilter == 'امروز') {
        filter = 'کل';
        _dueScope = TaskDueScope.today;
      } else if (nextFilter == 'عقب‌افتاده') {
        filter = 'کل';
        _dueScope = TaskDueScope.overdue;
      } else {
        filter = nextFilter;
        _dueScope = null;
      }
      selected.clear();
      selectionMode = false;
    });
  }

  void _selectListScope(TaskListScope scope) {
    setState(() {
      filter = 'کل';
      _listScope = scope;
      _dueScope = null;
      selected.clear();
      selectionMode = false;
    });
  }

  void _selectDueScope(TaskDueScope scope) {
    setState(() {
      filter = 'کل';
      _listScope = TaskListScope.all;
      _dueScope = scope;
      selected.clear();
      selectionMode = false;
    });
  }

  void _setListSort(TaskListSort sort) {
    setState(() => _listSort = sort);
  }

  void _toggleSortDirection() {
    setState(() => _sortDescending = !_sortDescending);
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
            uri == null ? 'انتخاب پوشه لغو شد' : 'پوشه پشتیبان با موفقیت انتخاب شد',
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

      final settings = await appSettingsService.load();
      final fileName = await backupManager.backupCanonicalTasks(
        _searchSource,
        settings: appSettingsService.toPortableJson(settings),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fileName == null
                ? 'پشتیبان‌گیری انجام نشد'
                : 'پشتیبان کامل ذخیره شد: $fileName',
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
      final candidate = await backupManager.restoreCanonicalBackup();
      if (candidate == null) return;

      final list = candidate.tasks;
      final restoredSettings = candidate.settings == null
          ? null
          : appSettingsService.decodePortableJson(candidate.settings!);
      final currentSettings = await appSettingsService.load();
      final emergencyBackup = await backupManager.backupCanonicalTasks(
        _searchSource,
        settings: appSettingsService.toPortableJson(currentSettings),
      );

      if (!mounted) return;
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('بازیابی اطلاعات'),
          content: Text(
            'تعداد ${list.length} کار از پشتیبان آماده بازیابی است.\n'
            '${restoredSettings == null ? 'این پشتیبان تنظیمات برنامه ندارد.' : 'تنظیمات برنامه نیز همراه این پشتیبان بازیابی می‌شود.'}\n\n'
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
      if (restoredSettings != null) {
        await appSettingsService.saveSettings(restoredSettings);
        if (mounted) widget.onSettingsChanged?.call(restoredSettings);
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${list.length} کار${restoredSettings == null ? '' : ' و تنظیمات برنامه'} با همه جزئیات بازیابی شد',
            ),
          ),
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
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
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
      ),
    );
  }

  Future<void> _openPrimaryCalendar() async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CanonicalCalendarLauncher(tasks: _searchSource),
      ),
    );
  }

  Widget _primaryNotebookShell() {
    return ArvinPrimaryPageShell(
      selected: ArvinPrimaryDestination.notebook,
      onSelected: (destination) => _onPrimaryChildDestinationSelected(
        destination,
        current: ArvinPrimaryDestination.notebook,
      ),
      child: NotebookPage(),
    );
  }

  Widget _primaryNextActionShell() {
    return ArvinPrimaryPageShell(
      selected: ArvinPrimaryDestination.nextAction,
      onSelected: (destination) => _onPrimaryChildDestinationSelected(
        destination,
        current: ArvinPrimaryDestination.nextAction,
      ),
      child: TaskNextActionPage(tasks: _searchSource),
    );
  }

  Future<void> _openPrimaryNotebook() async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => _primaryNotebookShell()),
    );
  }

  Future<void> _openPrimaryNextAction() async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => _primaryNextActionShell()),
    );
  }

  void _onPrimaryChildDestinationSelected(
    ArvinPrimaryDestination destination, {
    required ArvinPrimaryDestination current,
  }) {
    if (destination == current) return;

    switch (destination) {
      case ArvinPrimaryDestination.home:
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      case ArvinPrimaryDestination.calendar:
        Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(
            builder: (_) => CanonicalCalendarLauncher(tasks: _searchSource),
          ),
        );
        return;
      case ArvinPrimaryDestination.notebook:
        Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(builder: (_) => _primaryNotebookShell()),
        );
        return;
      case ArvinPrimaryDestination.nextAction:
        Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(builder: (_) => _primaryNextActionShell()),
        );
        return;
      case ArvinPrimaryDestination.more:
        _openPrimaryMore();
        return;
    }
  }

  Future<void> _openPrimarySettings() async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          service: appSettingsService,
          onSettingsChanged: (value) => widget.onSettingsChanged?.call(value),
          onOpenBackup: () {
            Navigator.of(context).pop();
            Future<void>.delayed(Duration.zero, _backupMenu);
          },
          onStartInteractiveGuide: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Future<void>.delayed(Duration.zero, _startInteractiveGuide);
          },
        ),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'آروین',
      applicationLegalese: 'مدیریت کارها و پیگیری‌ها',
    );
  }

  Future<void> _openPrimaryMore() async {
    final action = await showModalBottomSheet<_HomeMoreAction>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            children: [
              ListTile(
                key: const ValueKey('home-more-quick-capture'),
                leading: const Icon(Icons.bolt_outlined),
                title: const Text('ثبت سریع'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_HomeMoreAction.quickCapture),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.today_outlined),
                title: const Text('امروز'),
                onTap: () => Navigator.of(sheetContext).pop(_HomeMoreAction.today),
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('بایگانی'),
                onTap: () => Navigator.of(sheetContext).pop(_HomeMoreAction.archive),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('سطل زباله'),
                onTap: () => Navigator.of(sheetContext).pop(_HomeMoreAction.trash),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('پشتیبان‌گیری'),
                onTap: () => Navigator.of(sheetContext).pop(_HomeMoreAction.backup),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('تنظیمات'),
                onTap: () => Navigator.of(sheetContext).pop(_HomeMoreAction.settings),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('درباره آروین'),
                onTap: () => Navigator.of(sheetContext).pop(_HomeMoreAction.about),
              ),
            ],
          ),
        ),
      ),
    );

    if (action == null || !mounted) return;
    switch (action) {
      case _HomeMoreAction.quickCapture:
        await _quickCapture();
        return;
      case _HomeMoreAction.today:
        Navigator.of(context).popUntil((route) => route.isFirst);
        _selectHomeStat('امروز');
        return;
      case _HomeMoreAction.archive:
        Navigator.of(context).popUntil((route) => route.isFirst);
        _selectHomeStat('بایگانی');
        return;
      case _HomeMoreAction.trash:
        Navigator.of(context).popUntil((route) => route.isFirst);
        _selectHomeStat('سطل زباله');
        return;
      case _HomeMoreAction.backup:
        await _backupMenu();
        return;
      case _HomeMoreAction.settings:
        await _openPrimarySettings();
        return;
      case _HomeMoreAction.about:
        _showAbout();
        return;
    }
  }

  void _onPrimaryDestinationSelected(ArvinPrimaryDestination destination) {
    switch (destination) {
      case ArvinPrimaryDestination.home:
        return;
      case ArvinPrimaryDestination.calendar:
        _openPrimaryCalendar();
        return;
      case ArvinPrimaryDestination.notebook:
        _openPrimaryNotebook();
        return;
      case ArvinPrimaryDestination.nextAction:
        _openPrimaryNextAction();
        return;
      case ArvinPrimaryDestination.more:
        _openPrimaryMore();
        return;
    }
  }

  TaskSwipeAction _actionForSwipe(DismissDirection direction) {
    return switch (direction) {
      DismissDirection.endToStart => widget.settings.swipeRightAction,
      DismissDirection.startToEnd => widget.settings.swipeLeftAction,
      _ => TaskSwipeAction.none,
    };
  }

  Future<bool> _applySwipe(Task task, DismissDirection direction) async {
    if (task.trashed) {
      if (direction != DismissDirection.endToStart) return false;
      final approved = await _confirmDeleteForever(task);
      if (!approved) return false;
      await _deleteForever(task);
      return true;
    }

    final action = _actionForSwipe(direction);
    switch (action) {
      case TaskSwipeAction.archive:
        if (task.archived) return false;
        setState(() {
          task.archived = true;
          task.trashed = false;
        });
        await _save();
        return true;
      case TaskSwipeAction.trash:
        setState(() {
          task.trashed = true;
          task.archived = false;
        });
        await _save();
        return true;
      case TaskSwipeAction.moveToToday:
        await TaskMoveToTodayService(store: taskStore).move(task.id);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('«${task.title}» به امروز منتقل شد')),
            );
        }
        return false;
      case TaskSwipeAction.none:
        return false;
    }
  }

  Widget _swipeBackground(TaskSwipeAction action) {
    final colors = Theme.of(context).colorScheme;
    final icon = switch (action) {
      TaskSwipeAction.archive => Icons.archive_outlined,
      TaskSwipeAction.trash => Icons.delete_outline,
      TaskSwipeAction.moveToToday => Icons.today_outlined,
      TaskSwipeAction.none => Icons.block,
    };
    final label = switch (action) {
      TaskSwipeAction.archive => 'بایگانی',
      TaskSwipeAction.trash => 'سطل زباله',
      TaskSwipeAction.moveToToday => 'انتقال به امروز',
      TaskSwipeAction.none => 'بدون عمل',
    };
    return Container(
      color: action == TaskSwipeAction.trash
          ? colors.errorContainer
          : colors.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _taskCard(Task task) {
    final followUpDate = _homeFollowUpDate(task);
    final late = _overdue(task);
    final colors = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(task.id),
      direction: selectionMode ? DismissDirection.none : DismissDirection.horizontal,
      confirmDismiss: (direction) => _applySwipe(task, direction),
      background: task.trashed ? _swipeBackground(TaskSwipeAction.none) : _swipeBackground(widget.settings.swipeLeftAction),
      secondaryBackground: task.trashed ? _swipeBackground(TaskSwipeAction.trash) : _swipeBackground(widget.settings.swipeRightAction),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: () => setState(() {
            selectionMode = true;
            selected
              ..clear()
              ..addAll(taskBulkSelectionService.toggle(selected, task.id));
          }),
          onTap: selectionMode
              ? () => setState(() {
                    final next =
                        taskBulkSelectionService.toggle(selected, task.id);
                    selected
                      ..clear()
                      ..addAll(next);
                    selectionMode = selected.isNotEmpty;
                  })
              : () => _openTaskDetail(task),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              selectionMode
                  ? Checkbox(
                      value: selected.contains(task.id),
                      onChanged: (_) => setState(() {
                        final next =
                            taskBulkSelectionService.toggle(selected, task.id);
                        selected
                          ..clear()
                          ..addAll(next);
                        selectionMode = selected.isNotEmpty;
                      }),
                    )
                  : IconButton(
                      onPressed: () => _toggle(task),
                      icon: Icon(
                        task.completed
                            ? Icons.check_circle_rounded
                            : late
                                ? Icons.warning_amber_rounded
                                : Icons.radio_button_unchecked_rounded,
                        color: task.completed
                            ? const Color(0xFF409B51)
                            : late
                                ? const Color(0xFFDB8B23)
                                : colors.primary,
                      ),
                    ),
              const SizedBox(width: 4),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF232433), fontWeight: FontWeight.w700, fontSize: 15, decoration: task.completed ? TextDecoration.lineThrough : null)),
                if (task.description.isNotEmpty) ...[const SizedBox(height: 4), Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF80829C), fontSize: 12))],
                if (task.tags.isNotEmpty) ...[const SizedBox(height: 6), Wrap(spacing: 4, runSpacing: 4, children: task.tags.map((tag) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFE9EAFF), borderRadius: BorderRadius.circular(10)), child: Text(tag, style: const TextStyle(color: Color(0xFF4A4CAB), fontSize: 10)))).toList())],
                if (followUpDate != null) ...[const SizedBox(height: 7), Row(children: [Icon(Icons.event_outlined, size: 15, color: late ? const Color(0xFFDB8B23) : const Color(0xFF80829C)), const SizedBox(width: 4), Flexible(child: Text('پیگیری: ${_date(followUpDate)} • ${_time(followUpDate)}', style: TextStyle(color: late ? const Color(0xFFDB8B23) : const Color(0xFF80829C), fontSize: 11, fontWeight: late ? FontWeight.w600 : FontWeight.w400)))])],
                if (task.trashed || task.archived) TextButton(onPressed: () => _restore(task), child: const Text('بازگردانی به فعال')),
              ])),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = tasks
        .where((task) => !task.archived && !task.trashed && !task.completed)
        .length;
    final allTasks =
        tasks.where((task) => !task.archived && !task.trashed).length;
    final doneTasks = tasks
        .where((task) => !task.archived && !task.trashed && task.completed)
        .length;
    final overdueTasks = taskDueScopeService
        .project(
          tasks,
          now: DateTime.now(),
          scope: TaskDueScope.overdue,
        )
        .length;

    Widget stat(
      String label,
      int value,
      IconData icon,
      String target,
      Color accent,
      String keyName,
    ) {
      final isSelected = target == 'عقب‌افتاده'
          ? _dueScope == TaskDueScope.overdue
          : filter == target &&
              _dueScope == null &&
              _listScope == TaskListScope.all;
      return Semantics(
        key: ValueKey(keyName),
        button: true,
        selected: isSelected,
        label: 'فیلتر $label، $value مورد',
        child: Material(
          color: isSelected
              ? const Color(0xFFE9EAFF)
              : const Color(0xFFFDFDFE),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selectHomeStat(target),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A4CAB)
                      : const Color(0xFFE5E7ED),
                  width: isSelected ? 1.3 : 0.8,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, size: 19, color: accent),
                  const SizedBox(height: 4),
                  Text(
                    '$value',
                    style: const TextStyle(
                      color: Color(0xFF232433),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF80829C),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    key: const ValueKey('home-notifications'),
                    tooltip: 'اعلان‌ها',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'اعلان‌ها در بخش اعلان‌های برنامه مدیریت می‌شوند',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F0F6),
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              'بسم الله الرحمن الرحیم',
                              key: ValueKey('home-bismillah'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF80829C),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'مدیریت کارها و پیگیری آروین',
                          key: ValueKey('home-title-block'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF232433),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('home-menu'),
                    tooltip: 'منو',
                    onPressed: _openPrimaryMore,
                    icon: const Icon(Icons.menu_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: KeyedSubtree(
                key: const ValueKey('home-canonical-search'),
                child: TextField(
                  key: _searchGuideKey,
                  onChanged: (value) => setState(() => query = value),
                  decoration: InputDecoration(
                    hintText: 'جست‌وجو در کارها',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFFDFDFE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7ED)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7ED)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF4A4CAB),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              key: _filtersGuideKey,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: stat(
                      'کل',
                      allTasks,
                      Icons.list_alt_rounded,
                      'کل',
                      const Color(0xFF4A4CAB),
                      'home-stat-all',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: stat(
                      'فعال',
                      activeTasks,
                      Icons.pending_actions_rounded,
                      'فعال',
                      const Color(0xFF2F80ED),
                      'home-stat-active',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: stat(
                      'انجام‌شده',
                      doneTasks,
                      Icons.check_circle_rounded,
                      'انجام‌شده',
                      const Color(0xFF409B51),
                      'home-stat-done',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: stat(
                      'عقب‌افتاده',
                      overdueTasks,
                      Icons.warning_amber_rounded,
                      'عقب‌افتاده',
                      const Color(0xFFDB8B23),
                      'home-stat-overdue',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 48,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'کارهای من',
                      style: TextStyle(
                        color: Color(0xFF232433),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilterChip(
                      key: const ValueKey('home-scope-all'),
                      label: const Text('همه'),
                      selected: _listScope == TaskListScope.all && _dueScope == null,
                      onSelected: (_) => _selectListScope(TaskListScope.all),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      key: const ValueKey('home-scope-notes'),
                      label: const Text('یادداشت‌ها'),
                      selected: _listScope == TaskListScope.simpleNotes && _dueScope == null,
                      onSelected: (_) => _selectListScope(TaskListScope.simpleNotes),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      key: const ValueKey('home-scope-followups'),
                      label: const Text('دارای پیگیری'),
                      selected: _listScope == TaskListScope.followUpEnabled && _dueScope == null,
                      onSelected: (_) => _selectListScope(TaskListScope.followUpEnabled),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      key: const ValueKey('home-scope-today'),
                      label: const Text('امروز'),
                      selected: _dueScope == TaskDueScope.today,
                      onSelected: (_) => _selectDueScope(TaskDueScope.today),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      key: const ValueKey('home-scope-future'),
                      label: const Text('آینده'),
                      selected: _dueScope == TaskDueScope.future,
                      onSelected: (_) => _selectDueScope(TaskDueScope.future),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      key: const ValueKey('home-scope-overdue'),
                      label: const Text('عقب‌افتاده'),
                      selected: _dueScope == TaskDueScope.overdue,
                      onSelected: (_) => _selectDueScope(TaskDueScope.overdue),
                    ),
                    const SizedBox(width: 12),
                    const Text('مرتب‌سازی:'),
                    const SizedBox(width: 6),
                    DropdownButton<TaskListSort>(
                      key: const ValueKey('home-sort-selector'),
                      value: _listSort,
                      items: TaskListSort.values
                          .map(
                            (sort) => DropdownMenuItem<TaskListSort>(
                              value: sort,
                              child: Text(_sortLabel(sort)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (sort) {
                        if (sort != null) _setListSort(sort);
                      },
                    ),
                    IconButton(
                      key: const ValueKey('home-sort-direction'),
                      tooltip: _sortDescending
                          ? 'مرتب‌سازی صعودی'
                          : 'مرتب‌سازی نزولی',
                      onPressed: _toggleSortDirection,
                      icon: Icon(
                        _sortDescending
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                      ),
                    ),
                    if (filter != 'کل') ...[
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => _selectHomeStat('کل'),
                        child: const Text('مشاهده همه'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : loadFailure != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.storage_outlined, size: 40),
                                const SizedBox(height: 12),
                                const Text(
                                  'داده‌های کارها قابل خواندن نیست',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'برای جلوگیری از از دست رفتن اطلاعات، تا بازیابی موفق هیچ تغییری ذخیره نمی‌شود.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  key: const ValueKey('home-storage-retry'),
                                  onPressed: () {
                                    setState(() => loading = true);
                                    _load();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('تلاش دوباره'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : visible.isEmpty
                          ? Center(
                              child: Text(
                                _emptyVisibleLabel,
                              ),
                            )
                          : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: visible.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) => _taskCard(visible[index]),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: selected.isEmpty && loadFailure == null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: KeyedSubtree(
                key: const ValueKey('home-canonical-add'),
                child: KeyedSubtree(
                  key: _newTaskGuideKey,
                  child: ArvinHomePrimaryAddButton(onPressed: _add),
                ),
              ),
            )
          : null,
      bottomNavigationBar: selected.isEmpty
          ? ArvinPrimaryNavigation(
              selected: ArvinPrimaryDestination.home,
              onSelected: _onPrimaryDestinationSelected,
            )
          : TaskBulkSelectionBar(
              selectedCount: selected.length,
              allVisibleSelected: taskBulkSelectionService.allVisibleSelected(
                selected,
                visible,
              ),
              onToggleAll: _toggleAllVisibleSelection,
              onClearSelection: _clearBulkSelection,
              onArchive: _archiveSelected,
              onTrash: _trashSelected,
              onCategory: _moveSelectedToCategory,
              onTags: _addTagsToSelected,
              onShare: _openSelectedReport,
            ),
    );
  }
}

enum _HomeMoreAction {
  quickCapture,
  today,
  archive,
  trash,
  backup,
  settings,
  about,
}


/// Backward-compatible public entry retained for existing callers/tests.
/// The live implementation is the Home-aligned Arvin task editor.
class TaskDialog extends StatelessWidget {
  const TaskDialog({super.key, this.task});

  final Task? task;

  @override
  Widget build(BuildContext context) => ArvinTaskEditorDialog(task: task);
}