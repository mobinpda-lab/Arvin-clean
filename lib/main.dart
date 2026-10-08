// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, unused_field

import 'package:flutter/material.dart';

import 'arvin_colors.dart';

import 'android_follow_up_reminder_scheduler.dart';
import 'backup_manager.dart';
import 'backup_schedule_page.dart';
import 'backup_schedule.dart';
import 'calendar_page.dart';
import 'calendar_integration_settings_page.dart';
import 'models/goal_project.dart';
import 'models/task.dart';
import 'home/grouping/home_group.dart';
import 'home/home_filter_ui.dart';
import 'services/iran_clock.dart';
import 'notebook_page.dart';
import 'quick_capture_dialog.dart';
import 'report_center_page.dart';
import 'services/app_settings_service.dart';
import 'services/calendar_outbound_sync_service.dart';
import 'services/calendar_inbound_sync_service.dart';
import 'services/follow_up_calendar_projection.dart';

import 'services/calendar_provider_sync_executor.dart';
import 'services/calendar_sync_plan_service.dart';
import 'services/external_calendar_link_store.dart';

import 'services/home_search_projection.dart';
import 'services/task_due_scope_service.dart';
import 'services/task_list_scope_service.dart';
import 'services/task_list_sort_service.dart';
import 'services/task_move_to_today_service.dart';
import 'services/persian_date_formatter.dart';
import 'services/project_store.dart';
import 'services/arvin_route_observer.dart';
import 'services/task_edit_apply_service.dart';
import 'services/task_bulk_mutation_service.dart';
import 'services/task_bulk_selection_service.dart';
import 'services/task_store.dart';
import 'services/startup_permission_service.dart';
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
import 'widgets/home_my_tasks_sheet.dart';
import 'widgets/task_bulk_selection_bar.dart';
import 'widgets/taxonomy_icon_row.dart';

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
    usePersianDate: true,
    fontFamily: null,
    fontSize: 16.0,
  );

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StartupPermissionService().requestOnStartup();
    });
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
      navigatorObservers: [arvinRouteObserver],
      title: 'مدیریت کارها و پیگیری آروین',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4A4CAB),
        brightness: Brightness.light,
        fontFamily: settings.fontFamily == 'system' ? null : (settings.fontFamily ?? AppFonts.vazirharfFamily),
        textTheme: ThemeData.light().textTheme.apply(fontSizeFactor: settings.fontSize / 16.0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        fontFamily: settings.fontFamily == 'system' ? null : (settings.fontFamily ?? AppFonts.vazirharfFamily),
        textTheme: ThemeData.dark().textTheme.apply(fontSizeFactor: settings.fontSize / 16.0),
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
  final ProjectStore projectStore = ProjectStore();
  final Wave2ProductFastTrack wave2ProductFastTrack = Wave2ProductFastTrack();
  final ArvinBackupManager backupManager = ArvinBackupManager();
  final AppSettingsService appSettingsService = AppSettingsService();
  final FollowUpCalendarProjection calendarProjection =
      const FollowUpCalendarProjection();
  final CalendarOutboundSyncService calendarOutboundSyncService =
      CalendarOutboundSyncService();
  final HomeSearchProjection homeSearchProjection =
      const HomeSearchProjection();
  final TaskListScopeService taskListScopeService =
      const TaskListScopeService();
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

  List<Task> tasks = [];
  List<ProjectPlan> projects = [];
  final Set<String> selected = <String>{};
  bool loading = true;
  Object? loadFailure;
  bool selectionMode = false;
  String query = '';
  String filter = 'کل';
  TaskListScope _listScope = TaskListScope.all;
  TaskDueScope? _dueScope;
  String? _categoryFilter;
  String? _projectFilter;
  final Set<String> _tagFilters = <String>{};
  String _timeFilter = 'all';
  DateTime? _specificDateFilter;
  DateTime? _fromDateFilter;
  DateTime? _toDateFilter;
  TimeOfDay? _fromTimeFilter;
  TimeOfDay? _toTimeFilter;
  final Set<String> _collapsedGroups = <String>{};
  final TaskListSort _listSort = TaskListSort.date;
  final bool _sortDescending = false;

  String get _emptyVisibleLabel => filter == 'سطل زباله'
      ? 'سطل زباله خالی است'
      : 'بایگانی خالی است';


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
      final loadedProjects = await projectStore.load();
      if (!mounted) return;
      setState(() {
        tasks = List<Task>.of(value);
        projects = List<ProjectPlan>.of(loadedProjects);
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
  }

  List<Task> get _searchSource => List<Task>.of(tasks);

  List<String> get _homeCategories {
    final values =
        tasks
            .map((task) => task.category?.trim())
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return values;
  }

  Future<String?> _createCategory(String value) async {
    final name = value.trim();
    if (name.isEmpty) return null;
    return TaskStore().createCategory(name);
  }

  Future<String?> _createTag(String value) async {
    final name = value.trim();
    if (name.isEmpty) return null;
    return TaskStore().createTag(name);
  }

  Future<void> _save() async {
    if (loadFailure != null) {
      throw StateError(
        'Canonical task storage is unreadable; refusing Home write.',
      );
    }
    final snapshot = List<Task>.of(tasks);
    await taskStore.save(snapshot);
    try {
      await AndroidFollowUpReminderScheduler().reschedule();
    } catch (_) {
      // Canonical Task storage already succeeded; the existing alarm foundation
      // can retry on the next lifecycle/scheduler trigger.
    }
    try {
      await calendarOutboundSyncService.sync(
        calendarProjection.project(snapshot),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('همگام‌سازی کار با تقویم مقصد انجام نشد.'),
            action: SnackBarAction(
              label: 'تلاش دوباره',
              onPressed: () => _retryCalendarSync(snapshot),
            ),
            duration: const Duration(seconds: 6),
          ),
        );
    }
  }

  Future<void> _retryCalendarSync(List<Task> snapshot) async {
    try {
      await calendarOutboundSyncService.sync(
        calendarProjection.project(snapshot),
        force: true,
      );
      final now = DateTime.now().toLocal();
      final today = DateTime(now.year, now.month, now.day);
      final inbound = await CalendarInboundSyncService().reconcile(
        start: today.subtract(const Duration(days: 31)),
        end: today.add(const Duration(days: 62)),
      );
      if (inbound.changed) {
        await _load();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('همگام‌سازی دوباره انجام شد؛ تغییرات آروین و تقویم گوشی بررسی و به‌روزرسانی شد.'),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('همگام‌سازی انجام نشد؛ تنظیمات و دسترسی تقویم را بررسی کنید.'),
          ),
        );
    }
  }

  DateTime? _homeFollowUpDate(Task task) => task.lastFollowUp?.dateTime;

  String? _projectTitleForTask(Task task) {
    for (final project in projects) {
      if (project.itemIds.contains(task.id)) return project.title.trim();
    }
    return null;
  }

  bool _overdue(Task task) {
    final date = task.dueDate;
    return date != null && !task.completed && date.isBefore(DateTime.now());
  }

  bool get _homeFilterActive =>
      query.trim().isNotEmpty ||
      _timeFilter != 'all' ||
      _projectFilter != null ||
      _categoryFilter != null ||
      _tagFilters.isNotEmpty;

  String get _timeFilterLabel {
    if (_timeFilter == 'customRange') {
      final from = _fromDateFilter == null ? 'شروع' : _date(_fromDateFilter!);
      final to = _toDateFilter == null ? 'پایان' : _date(_toDateFilter!);
      return '$from تا $to';
    }
    switch (_timeFilter) {
      case 'today': return 'امروز';
      case 'tomorrow': return 'فردا';
      case 'next7': return '۷ روز آینده';
      case 'next30': return '۳۰ روز آینده';
      case 'custom': return _specificDateFilter == null ? 'تاریخ مشخص' : _date(_specificDateFilter!);
      case 'undated': return 'فاقد زمان';
      default: return 'همه';
    }
  }

  String? _projectTitle(String? id) {
    if (id == null) return null;
    for (final project in projects) {
      if (project.id == id) return project.title.trim();
    }
    return null;
  }

  bool _matchesTimeFilter(Task task) {
    final due = task.dueDate;
    if (_timeFilter == 'all') return true;
    if (_timeFilter == 'undated') return due == null;
    if (due == null) return false;
    final now = IranClock.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(due.year, due.month, due.day);
    if (_timeFilter == 'today') return day == today;
    if (_timeFilter == 'tomorrow') return day == today.add(const Duration(days: 1));
    if (_timeFilter == 'next7') return !day.isBefore(today) && day.isBefore(today.add(const Duration(days: 7)));
    if (_timeFilter == 'next30') return !day.isBefore(today) && day.isBefore(today.add(const Duration(days: 30)));
    if (_timeFilter == 'custom') {
      final selected = _specificDateFilter;
      if (selected == null) return true;
      return day == DateTime(selected.year, selected.month, selected.day);
    }
    if (_timeFilter == 'customRange') {
      final from = _fromDateFilter == null ? null : DateTime(_fromDateFilter!.year, _fromDateFilter!.month, _fromDateFilter!.day);
      final to = _toDateFilter == null ? null : DateTime(_toDateFilter!.year, _toDateFilter!.month, _toDateFilter!.day);
      final dayMatches = (from == null || !day.isBefore(from)) && (to == null || !day.isAfter(to));
      if (!dayMatches) return false;
      if (_fromTimeFilter != null) {
        final minutes = due.hour * 60 + due.minute;
        final fromMinutes = _fromTimeFilter!.hour * 60 + _fromTimeFilter!.minute;
        if (minutes < fromMinutes && (from == null || day == from)) return false;
      }
      if (_toTimeFilter != null) {
        final minutes = due.hour * 60 + due.minute;
        final toMinutes = _toTimeFilter!.hour * 60 + _toTimeFilter!.minute;
        if (minutes > toMinutes && (to == null || day == to)) return false;
      }
      return true;
    }
    return true;
  }


  List<Task> get visible {
    final searchActive = query.trim().isNotEmpty;
    final matchingIds = searchActive ? homeSearchProjection.matchingIds(_searchSource, query) : null;
    Iterable<Task> scoped = tasks;
    if (filter == 'کل') {
      scoped = scoped.where((task) => !task.archived && !task.trashed);
    } else if (filter == 'فعال') {
      scoped = scoped.where((task) => !task.archived && !task.trashed && !task.completed);
    } else if (filter == 'انجام‌شده') {
      scoped = scoped.where((task) => !task.archived && !task.trashed && task.completed);
    } else if (filter == 'بایگانی') {
      scoped = scoped.where((task) => task.archived && !task.trashed);
    } else if (filter == 'سطل زباله') {
      scoped = scoped.where((task) => task.trashed);
    }

    if (matchingIds != null) scoped = scoped.where((task) => matchingIds.contains(task.id));

    if (filter != 'بایگانی' && filter != 'سطل زباله') {
      scoped = scoped.where(_matchesTimeFilter);
      if (_categoryFilter != null) scoped = scoped.where((task) => task.category?.trim() == _categoryFilter);
      if (_projectFilter != null) {
        if (_projectFilter == '__no_project__') {
          final assigned = projects.expand((item) => item.itemIds).toSet();
          scoped = scoped.where((task) => !assigned.contains(task.id));
        } else {
          ProjectPlan? project;
          for (final item in projects) {
            if (item.id == _projectFilter) { project = item; break; }
          }
          if (project != null) {
            final ids = project.itemIds.toSet();
            scoped = scoped.where((task) => ids.contains(task.id));
          }
        }
      }
      if (_tagFilters.isNotEmpty) {
        scoped = scoped.where((task) {
          final tags = task.tags.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet();
          return _tagFilters.every(tags.contains);
        });
      }
    }

    return taskListSortService.sort(scoped.toList(growable: false), by: _listSort, descending: _sortDescending);
  }

  List<HomeGroup<Task>> get _homeGroups {
    if (filter == 'بایگانی' || filter == 'سطل زباله') {
      return [HomeGroup<Task>(id: 'filtered', title: filter, items: visible)];
    }
    final now = IranClock.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    DateTime dayOf(DateTime value) => DateTime(value.year, value.month, value.day);
    final grouped = <String, List<Task>>{
      'overdue': <Task>[], 'today': <Task>[], 'tomorrow': <Task>[], 'future': <Task>[], 'no_date': <Task>[],
    };
    for (final task in visible) {
      final due = task.dueDate;
      if (due == null) {
        grouped['no_date']!.add(task);
      } else {
        final day = dayOf(due);
        if (!task.completed && day.isBefore(today)) grouped['overdue']!.add(task);
        else if (day == today) grouped['today']!.add(task);
        else if (day == tomorrow) grouped['tomorrow']!.add(task);
        else grouped['future']!.add(task);
      }
    }
    return [
      HomeGroup<Task>(id: 'overdue', title: 'تاریخ‌گذشته', items: grouped['overdue']!),
      HomeGroup<Task>(id: 'today', title: 'امروز', items: grouped['today']!),
      HomeGroup<Task>(id: 'tomorrow', title: 'فردا', items: grouped['tomorrow']!),
      HomeGroup<Task>(id: 'future', title: 'آینده', items: grouped['future']!),
      HomeGroup<Task>(id: 'no_date', title: 'فاقد زمان', items: grouped['no_date']!),
    ];
  }


  Widget _homeFilterCards() {
    final projectLabel = _projectFilter == null ? 'همه' : (_projectTitle(_projectFilter) ?? 'بدون پروژه');
    final categoryLabel = _categoryFilter ?? 'همه';
    final tagLabel = _tagFilters.isEmpty ? 'همه' : '${_tagFilters.length} مورد';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          HomeFilterCard(dimension: HomeFilterDimension.time, title: 'زمان', value: _timeFilterLabel, accent: ArvinColors.time, soft: ArvinColors.timeSoft, icon: Icons.schedule_rounded, onTap: _showTimeFilterSheet),
          const SizedBox(width: 8),
          HomeFilterCard(dimension: HomeFilterDimension.project, title: 'پروژه', value: projectLabel, accent: ArvinColors.project, soft: ArvinColors.projectSoft, icon: Icons.folder_rounded, onTap: _showProjectFilterSheet),
          const SizedBox(width: 8),
          HomeFilterCard(dimension: HomeFilterDimension.category, title: 'دسته', value: categoryLabel, accent: ArvinColors.category, soft: ArvinColors.categorySoft, icon: Icons.layers_rounded, onTap: _showCategoryFilterSheet),
          const SizedBox(width: 8),
          HomeFilterCard(dimension: HomeFilterDimension.tags, title: 'برچسب‌ها', value: tagLabel, accent: ArvinColors.tag, soft: ArvinColors.tagSoft, icon: Icons.sell_rounded, onTap: _showTagFilterSheet),
        ],
      ),
    );
  }

  Widget _homeActiveFilterChips() {
    if (!_homeFilterActive) return const SizedBox.shrink();
    final chips = <Widget>[];
    if (_timeFilter != 'all') {
      chips.add(HomeFilterChip(
        label: _timeFilterLabel,
        accent: ArvinColors.time,
        soft: ArvinColors.timeSoft,
        icon: Icons.schedule_rounded,
        onRemove: () => setState(() {
          _timeFilter = 'all';
          _specificDateFilter = null;
        }),
      ));
    }
    if (_projectFilter != null) chips.add(HomeFilterChip(label: _projectTitle(_projectFilter) ?? 'بدون پروژه', accent: ArvinColors.project, soft: ArvinColors.projectSoft, icon: Icons.folder_rounded, onRemove: () => setState(() => _projectFilter = null)));
    if (_categoryFilter != null) chips.add(HomeFilterChip(label: _categoryFilter!, accent: ArvinColors.category, soft: ArvinColors.categorySoft, icon: Icons.layers_rounded, onRemove: () => setState(() => _categoryFilter = null)));
    for (final tag in _tagFilters) chips.add(HomeFilterChip(label: tag, accent: ArvinColors.tag, soft: ArvinColors.tagSoft, icon: Icons.sell_rounded, onRemove: () => setState(() => _tagFilters.remove(tag))));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(spacing: 6, runSpacing: 6, children: chips),
          Align(alignment: AlignmentDirectional.centerStart, child: TextButton(onPressed: _clearHomeFilters, child: const Text('پاک کردن فیلترها'))),
        ],
      ),
    );
  }

  void _clearHomeFilters() {
    setState(() {
      _timeFilter = 'all';
      _specificDateFilter = null;
      _fromDateFilter = null;
      _toDateFilter = null;
      _fromTimeFilter = null;
      _toTimeFilter = null;
      _projectFilter = null;
      _categoryFilter = null;
      _tagFilters.clear();
    });
  }

  Future<void> _showTimeFilterSheet() async {
    const options = <Map<String, Object>>[
      {'id': 'all', 'title': 'همه', 'icon': Icons.all_inclusive_rounded},
      {'id': 'today', 'title': 'امروز', 'icon': Icons.today_rounded},
      {'id': 'tomorrow', 'title': 'فردا', 'icon': Icons.event_rounded},
      {'id': 'next7', 'title': '۷ روز آینده', 'icon': Icons.date_range_rounded},
      {'id': 'next30', 'title': '۳۰ روز آینده', 'icon': Icons.calendar_month_rounded},
      {'id': 'custom', 'title': 'تاریخ مشخص', 'icon': Icons.event_rounded},
      {'id': 'undated', 'title': 'فاقد زمان', 'icon': Icons.event_busy_rounded},
    ];
    var fromDate = _fromDateFilter;
    var toDate = _toDateFilter;
    var fromTime = _fromTimeFilter;
    var toTime = _toTimeFilter;
    var selectedQuick = _timeFilter == 'customRange' ? 'all' : _timeFilter;

    await HomeFilterSheet.show<void>(
      context,
      title: 'انتخاب زمان',
      accent: ArvinColors.time,
      child: StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> pickFromDate() async {
            final picked = await showPersianDatePicker(
              context: sheetContext,
              initialDate: fromDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              helpText: 'از تاریخ',
            );
            if (picked != null) setSheetState(() => fromDate = picked);
          }
          Future<void> pickToDate() async {
            final picked = await showPersianDatePicker(
              context: sheetContext,
              initialDate: toDate ?? fromDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              helpText: 'تا تاریخ',
            );
            if (picked != null) setSheetState(() => toDate = picked);
          }
          Future<void> pickFromTime() async {
            final picked = await showTimePicker(context: sheetContext, initialTime: fromTime ?? TimeOfDay.now());
            if (picked != null) setSheetState(() => fromTime = picked);
          }
          Future<void> pickToTime() async {
            final picked = await showTimePicker(context: sheetContext, initialTime: toTime ?? TimeOfDay.now());
            if (picked != null) setSheetState(() => toTime = picked);
          }
          String dateLabel(DateTime? value, String empty) => value == null ? empty : _date(value);
          String timeLabel(TimeOfDay? value, String empty) => value == null ? empty : value.format(sheetContext);
          return ListView(
            padding: const EdgeInsets.only(bottom: 8),
            children: [
              for (final option in options)
                RadioListTile<String>(
                  value: option['id'] as String,
                  groupValue: selectedQuick,
                  activeColor: ArvinColors.time,
                  title: Text(option['title'] as String),
                  secondary: Icon(option['icon'] as IconData, color: ArvinColors.time),
                  onChanged: (value) async {
                    final next = value ?? 'all';
                    if (next == 'custom') {
                      final picked = await showPersianDatePicker(
                        context: sheetContext,
                        initialDate: _specificDateFilter ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        helpText: 'تاریخ مشخص',
                      );
                      if (picked == null) return;
                      setState(() {
                        _timeFilter = 'custom';
                        _specificDateFilter = picked;
                        _fromDateFilter = null;
                        _toDateFilter = null;
                        _fromTimeFilter = null;
                        _toTimeFilter = null;
                      });
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      return;
                    }
                    setState(() {
                      _timeFilter = next;
                      _specificDateFilter = null;
                      _fromDateFilter = null;
                      _toDateFilter = null;
                      _fromTimeFilter = null;
                      _toTimeFilter = null;
                    });
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const Divider(height: 18),
              ListTile(
                leading: const Icon(Icons.calendar_month_rounded, color: ArvinColors.time),
                title: const Text('از تاریخ'),
                subtitle: Text(dateLabel(fromDate, 'انتخاب نشده')),
                onTap: () { selectedQuick = 'all'; pickFromDate(); },
              ),
              ListTile(
                leading: const Icon(Icons.event_rounded, color: ArvinColors.time),
                title: const Text('تا تاریخ'),
                subtitle: Text(dateLabel(toDate, 'انتخاب نشده')),
                onTap: () { selectedQuick = 'all'; pickToDate(); },
              ),
              ListTile(
                leading: const Icon(Icons.schedule_rounded, color: ArvinColors.time),
                title: const Text('از ساعت'),
                subtitle: Text(timeLabel(fromTime, 'انتخاب نشده')),
                onTap: () { selectedQuick = 'all'; pickFromTime(); },
              ),
              ListTile(
                leading: const Icon(Icons.access_time_rounded, color: ArvinColors.time),
                title: const Text('تا ساعت'),
                subtitle: Text(timeLabel(toTime, 'انتخاب نشده')),
                onTap: () { selectedQuick = 'all'; pickToTime(); },
              ),
              if (fromDate != null || toDate != null || fromTime != null || toTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: ArvinColors.time),
                    onPressed: () {
                      setState(() {
                        _timeFilter = 'customRange';
                        _specificDateFilter = null;
                        _fromDateFilter = fromDate;
                        _toDateFilter = toDate;
                        _fromTimeFilter = fromTime;
                        _toTimeFilter = toTime;
                      });
                      Navigator.of(sheetContext).pop();
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('اعمال بازه'),
                  ),
                ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _timeFilter = 'all';
                    _specificDateFilter = null;
                    _fromDateFilter = null;
                    _toDateFilter = null;
                    _fromTimeFilter = null;
                    _toTimeFilter = null;
                  });
                  Navigator.of(sheetContext).pop();
                },
                child: const Text('پاک کردن'),
              ),

            ],
          );
        },
      ),
    );
  }

  Future<void> _showProjectFilterSheet() async {
    String search = '';
    final result = await HomeFilterSheet.show<String?>(context, title: 'انتخاب پروژه', accent: ArvinColors.project, child: StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final values = projects.where((p) => !p.isArchived).toList()..sort((a, b) => a.title.compareTo(b.title));
        final filtered = values.where((p) => p.title.toLowerCase().contains(search.toLowerCase())).toList();
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .58,
          child: Column(children: [
            TextField(onChanged: (v) => setSheetState(() => search = v), decoration: const InputDecoration(hintText: 'جستجو در پروژه‌ها...', prefixIcon: Icon(Icons.search_rounded))),
            Expanded(child: ListView(children: [
              ListTile(leading: const Icon(Icons.folder_open_rounded, color: ArvinColors.project), title: const Text('همه پروژه‌ها'), trailing: Icon(_projectFilter == null ? Icons.radio_button_checked : Icons.radio_button_off, color: ArvinColors.project), onTap: () => Navigator.of(sheetContext).pop('__all__')),
              for (final project in filtered)
                RadioListTile<String?>(value: project.id, groupValue: _projectFilter, activeColor: ArvinColors.project, title: Text(project.title), secondary: const Icon(Icons.folder_rounded), onChanged: (value) => Navigator.of(sheetContext).pop(value)),
            ])),
          ]),
        );
      },
    ));
    if (!mounted) return;
    setState(() => _projectFilter = result == '__all__' ? null : result);
  }

  Future<void> _showCategoryFilterSheet() async {
    final result = await HomeFilterSheet.show<String?>(context, title: 'انتخاب دسته', accent: ArvinColors.category, child: ListView(shrinkWrap: true, children: [
      ListTile(leading: const Icon(Icons.layers_rounded, color: ArvinColors.category), title: const Text('همه دسته‌ها'), trailing: Icon(_categoryFilter == null ? Icons.radio_button_checked : Icons.radio_button_off, color: ArvinColors.category), onTap: () => Navigator.of(context).pop('__all__')),
      for (final category in _homeCategories)
        RadioListTile<String?>(value: category, groupValue: _categoryFilter, activeColor: ArvinColors.category, title: Text(category), secondary: const Icon(Icons.layers_rounded), onChanged: (value) => Navigator.of(context).pop(value)),
    ]));
    if (!mounted) return;
    setState(() => _categoryFilter = result == '__all__' ? null : result);
  }

  Future<void> _showTagFilterSheet() async {
    final tags = tasks.expand((task) => task.tags).map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toSet().toList()..sort();
    final selectedTags = <String>{..._tagFilters};
    String search = '';
    await HomeFilterSheet.show<void>(context, title: 'انتخاب برچسب‌ها', accent: ArvinColors.tag, child: StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final filtered = tags.where((tag) => tag.toLowerCase().contains(search.toLowerCase())).toList();
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .58,
          child: Column(children: [
            TextField(onChanged: (value) => setSheetState(() => search = value), decoration: const InputDecoration(hintText: 'جستجو در برچسب‌ها...', prefixIcon: Icon(Icons.search_rounded))),
            Expanded(child: ListView(children: [
              ListTile(
                leading: const Icon(Icons.sell_outlined, color: ArvinColors.tag),
                title: const Text('همه برچسب‌ها'),
                trailing: Icon(selectedTags.isEmpty ? Icons.check_circle : Icons.circle_outlined, color: ArvinColors.tag),
                onTap: () => setSheetState(() { selectedTags.clear(); setState(() { _tagFilters.clear(); }); }),
              ),
              for (final tag in filtered)
                CheckboxListTile(
                  value: selectedTags.contains(tag),
                  activeColor: ArvinColors.tag,
                  title: Text(tag),
                  secondary: const Icon(Icons.sell_rounded, color: ArvinColors.tag),
                  onChanged: (checked) => setSheetState(() {
                    if (checked == true) selectedTags.add(tag); else selectedTags.remove(tag);
                    setState(() { _tagFilters..clear()..addAll(selectedTags); });
                  }),
                ),
            ])),
          ]),
        );
      },
    ));
  }




  Color _groupAccent(String id) {
    switch (id) {
      case 'overdue': return ArvinColors.error;
      case 'today': return ArvinColors.project;
      case 'tomorrow': return const Color(0xFF18A77B);
      case 'future': return const Color(0xFF5A55D6);
      case 'no_date': return ArvinColors.neutral;
      default: return ArvinColors.primary;
    }
  }

  Color _groupSoft(String id) {
    switch (id) {
      case 'overdue': return ArvinColors.errorSoft;
      case 'today': return const Color(0xFFEDF5FF);
      case 'tomorrow': return const Color(0xFFEAF9F4);
      case 'future': return const Color(0xFFF0EEFF);
      case 'no_date': return const Color(0xFFF3F4F7);
      default: return ArvinColors.primarySoft;
    }
  }

  IconData _groupIcon(String id) {
    switch (id) {
      case 'overdue': return Icons.warning_amber_rounded;
      case 'today': return Icons.wb_sunny_rounded;
      case 'tomorrow': return Icons.event_available_rounded;
      case 'future': return Icons.auto_awesome_rounded;
      case 'no_date': return Icons.schedule_rounded;
      default: return Icons.schedule_rounded;
    }
  }

  Widget _groupedTaskList() {
    final groups = _homeGroups.where((group) => !_homeFilterActive || group.items.isNotEmpty).toList(growable: false);
    if (groups.isEmpty || groups.every((group) => group.items.isEmpty)) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off_rounded, size: 38, color: ArvinColors.neutral),
          const SizedBox(height: 10),
          Text(
            (filter == 'سطل زباله' || filter == 'بایگانی')
                ? _emptyVisibleLabel
                : (_timeFilter == 'today' && filter == 'فعال'
                    ? 'کاری برای امروز وجود ندارد'
                    : (_homeFilterActive ? 'کاری با این فیلترها پیدا نشد' : 'کاری برای نمایش وجود ندارد')),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (_homeFilterActive) TextButton(onPressed: _clearHomeFilters, child: const Text('پاک کردن فیلترها')),
        ]),
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 96),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final collapsed = _collapsedGroups.contains(group.id);
        final accent = _groupAccent(group.id);
        final soft = _groupSoft(group.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Material(key: ValueKey('home-group-${group.id}'), color: soft, borderRadius: BorderRadius.circular(15), child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => setState(() { if (collapsed) _collapsedGroups.remove(group.id); else _collapsedGroups.add(group.id); }),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                child: Row(children: [
                  Icon(collapsed ? Icons.chevron_left_rounded : Icons.expand_more_rounded, size: 21, color: accent),
                  const SizedBox(width: 5),
                  Icon(_groupIcon(group.id), size: 18, color: accent),
                  const SizedBox(width: 7),
                  Expanded(child: Text(group.title, style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w800))),
                  Container(
                    constraints: const BoxConstraints(minWidth: 28),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(190), borderRadius: BorderRadius.circular(12)),
                    child: Text(persianDateFormatter.toPersianDigits('${group.items.length}'), textAlign: TextAlign.center, style: TextStyle(color: accent, fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
            )),
            if (!collapsed) ...[
              const SizedBox(height: 6),
              Material(color: ArvinColors.surface, borderRadius: BorderRadius.circular(14), child: Column(children: [
                for (var i = 0; i < group.items.length; i++) ...[
                  _taskCard(group.items[i]),
                  if (i != group.items.length - 1) Divider(height: 1, indent: 58, endIndent: 10, color: ArvinColors.border),
                ],
              ])),
            ],
          ]),
        );
      },
    );
  }




  String _date(DateTime date) => persianDateFormatter.format(
    date,
    usePersianDate: true,
  );

  String _time(DateTime date) => persianDateFormatter.toPersianDigits(
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
  );

  Future<Task?> _addFromCalendarEvent(CalendarReminder reminder) async {
    final editorContext = await wave2ProductFastTrack.prepareEditor(
      tasks: tasks,
    );
    if (!mounted) return null;
    String? selectedProjectId = editorContext.selectedProjectId;
    final rawTitle = reminder.title.split(' • ').first.trim();
    final task = await showDialog<Task>(
      context: context,
      builder: (_) => ArvinTaskEditorDialog(
        initialTitle: rawTitle,
        initialDescription: reminder.description,
        initialDueDate: reminder.date,
        projects: editorContext.projects,
        selectedProjectId: editorContext.selectedProjectId,
        onProjectChanged: (value) => selectedProjectId = value,
        onCreateProject: (title) => wave2ProductFastTrack.createProject(title),
        knownCategories: editorContext.knownCategories,
        knownTags: editorContext.knownTags,
        onCreateCategory: _createCategory,
        onCreateTag: _createTag,
      ),
    );
    if (task == null) return null;
    setState(() => tasks.add(task));
    await _save();
    await wave2ProductFastTrack.persistProjectSelection(
      taskId: task.id,
      projectId: selectedProjectId,
    );
    await _load();
    return task;
  }

  Future<Task?> _addForDate(DateTime date) async {
    final editorContext = await wave2ProductFastTrack.prepareEditor(
      tasks: tasks,
    );
    if (!mounted) return null;
    String? selectedProjectId = editorContext.selectedProjectId;
    final task = await showDialog<Task>(
      context: context,
      builder: (_) => ArvinTaskEditorDialog(
        initialDueDate: DateTime(date.year, date.month, date.day),
        projects: editorContext.projects,
        selectedProjectId: editorContext.selectedProjectId,
        onProjectChanged: (value) => selectedProjectId = value,
        onCreateProject: (title) => wave2ProductFastTrack.createProject(title),
        knownCategories: editorContext.knownCategories,
        knownTags: editorContext.knownTags,
        onCreateCategory: _createCategory,
        onCreateTag: _createTag,
      ),
    );
    if (task == null) return null;
    setState(() => tasks.add(task));
    await _save();
    await wave2ProductFastTrack.persistProjectSelection(
      taskId: task.id,
      projectId: selectedProjectId,
    );
    await _load();
    return task;
  }

  Future<void> _syncCalendarAfterQuickCapture(List<Task> snapshot) async {
    try {
      await calendarOutboundSyncService.sync(
        calendarProjection.project(snapshot),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('همگام‌سازی کار با تقویم مقصد انجام نشد.'),
            action: SnackBarAction(
              label: 'تلاش دوباره',
              onPressed: () => _retryCalendarSync(snapshot),
            ),
            duration: const Duration(seconds: 6),
          ),
        );
    }
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

    final editorContext = await wave2ProductFastTrack.prepareEditor(tasks: tasks);
    if (!mounted) return;
    String? selectedProjectId = editorContext.selectedProjectId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: true,
      builder: (_) => QuickCaptureDialog(
        projects: editorContext.projects,
        knownCategories: editorContext.knownCategories,
        knownTags: editorContext.knownTags,
        onCreateCategory: _createCategory,
        onCreateTag: _createTag,
        initialProjectId: selectedProjectId,
        onProjectChanged: (value) => selectedProjectId = value,
        onFullForm: (draft) async {
          final editedContext = await wave2ProductFastTrack.prepareEditor(
            tasks: tasks,
            task: draft,
          );
          if (!mounted) return false;
          final edited = await showDialog<Task>(
            context: context,
            builder: (_) => ArvinTaskEditorDialog(
              task: draft,
              projects: editedContext.projects,
              selectedProjectId: selectedProjectId ?? editedContext.selectedProjectId,
              onProjectChanged: (value) => selectedProjectId = value,
        onCreateProject: (title) => wave2ProductFastTrack.createProject(title),
              knownCategories: editedContext.knownCategories,
              knownTags: editedContext.knownTags,
            ),
          );
          if (edited == null) return false;
          await taskStore.mutate<void>((stored) {
            if (stored.any((task) => task.id == edited.id)) {
              throw StateError('Duplicate Task id: ${edited.id}');
            }
            stored.add(edited);
          });
          await wave2ProductFastTrack.persistProjectSelection(
            taskId: edited.id,
            projectId: selectedProjectId,
          );
          final refreshed = await taskStore.load();
          if (!mounted) return false;
          setState(() {
            tasks = List<Task>.of(refreshed);
            loadFailure = null;
            loading = false;
          });
          await _syncCalendarAfterQuickCapture(refreshed);
          return true;
        },
        onCaptured: (captured) async {
          await taskStore.mutate<void>((stored) {
            if (stored.any((task) => task.id == captured.id)) {
              throw StateError('Duplicate Task id: ${captured.id}');
            }
            stored.add(captured);
          });
          await wave2ProductFastTrack.persistProjectSelection(
            taskId: captured.id,
            projectId: selectedProjectId,
          );

          final refreshed = await taskStore.load();
          if (!mounted) return;
          setState(() {
            tasks = List<Task>.of(refreshed);
            loadFailure = null;
            loading = false;
          });
          await _syncCalendarAfterQuickCapture(refreshed);
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('«${captured.title}» ثبت شد')),
            );
        },
      ),
    );
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
        onCreateProject: (title) => wave2ProductFastTrack.createProject(title),
        knownCategories: editorContext.knownCategories,
        knownTags: editorContext.knownTags,
        onCreateCategory: _createCategory,
        onCreateTag: _createTag,
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

  Future<Task?> _checklistChangedFromDetail(
    Task task,
    List<String> checklist,
  ) async {
    final target = tasks.firstWhere((item) => item.id == task.id);
    target.checklist = List<String>.of(checklist);
    target.updatedAt = DateTime.now();
    await taskStore.save(List<Task>.of(tasks));
    try {
      await AndroidFollowUpReminderScheduler().reschedule();
    } catch (_) {
      // Canonical Task storage already succeeded; the existing alarm foundation
      // can retry on the next lifecycle/scheduler trigger.
    }
    final refreshed = await taskStore.load();
    if (!mounted) return target;
    setState(() => tasks = List<Task>.of(refreshed));
    return refreshed.firstWhere((item) => item.id == task.id);
  }

  Future<Task?> _completeFromDetail(Task task) async {
    // The detail action is a true toggle: a second tap returns the task to
    // the active/undone state. Done remains independent from archive/trash.
    task.completed = !task.completed;
    task.updatedAt = DateTime.now();
    await taskStore.save(List<Task>.of(tasks));
    try {
      await AndroidFollowUpReminderScheduler().reschedule();
    } catch (_) {
      // Canonical Task storage already succeeded; the existing alarm foundation
      // can retry on the next lifecycle/scheduler trigger.
    }
    final refreshed = await taskStore.load();
    if (!mounted) return task;
    setState(() => tasks = List<Task>.of(refreshed));
    await _syncCalendarAfterDetailTaskUpdate(refreshed);
    if (!mounted) return task;
    return refreshed.firstWhere((item) => item.id == task.id);
  }

  Future<void> _syncCalendarAfterDetailTaskUpdate(
    List<Task> snapshot,
  ) async {
    try {
      await calendarOutboundSyncService.sync(
        calendarProjection.project(snapshot),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('همگام‌سازی کار با تقویم مقصد انجام نشد.'),
            action: SnackBarAction(
              label: 'تلاش دوباره',
              onPressed: () => _retryCalendarSync(snapshot),
            ),
            duration: const Duration(seconds: 6),
          ),
        );
    }
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
          projectTitle: _projectTitleForTask(task),
          onEdit: _editFromDetail,
          onAddFollowUp: _addFollowUpFromDetail,
          onComplete: _completeFromDetail,
          onChecklistChanged: _checklistChangedFromDetail,
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
      filter = 'کل';
      _listScope = TaskListScope.all;
      _dueScope = null;
      _categoryFilter = null;
      selected.clear();
      selectionMode = false;
    });
    await _save();
  }

  void _selectHomeStat(String nextFilter) {
    setState(() {
      _listScope = TaskListScope.all;
      _categoryFilter = null;
      _projectFilter = null;
      _tagFilters.clear();
      _specificDateFilter = null;
      if (nextFilter == 'امروز') {
        filter = 'فعال';
        _timeFilter = 'today';
        _dueScope = TaskDueScope.today;
      } else if (nextFilter == 'عقب‌افتاده') {
        filter = 'فعال';
        _timeFilter = 'all';
        _dueScope = TaskDueScope.overdue;
      } else {
        filter = nextFilter;
        _timeFilter = 'all';
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
      _categoryFilter = null;
      selected.clear();
      selectionMode = false;
    });
  }

  void _selectDueScope(TaskDueScope scope) {
    setState(() {
      filter = 'کل';
      _listScope = TaskListScope.all;
      _dueScope = scope;
      _categoryFilter = null;
      selected.clear();
      selectionMode = false;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      filter = 'کل';
      _listScope = TaskListScope.all;
      _dueScope = null;
      _categoryFilter = category;
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

  Future<Map<String, dynamic>> _portableBackupSettings() async {
    final settings = await appSettingsService.load();
    final schedule = await BackupSchedule.load();
    return <String, dynamic>{
      ...appSettingsService.toPortableJson(settings),
      'backupSchedule': schedule.toPortableJson(),
    };
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
            const SnackBar(
              content: Text('ابتدا یک پوشه برای پشتیبان انتخاب کنید'),
            ),
          );
        }
        return;
      }

      final fileName = await backupManager.backupCanonicalTasks(
        await taskStore.load(),
        settings: await _portableBackupSettings(),
        projects: await ProjectStore().load(),
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
      final emergencyBackup = await backupManager.backupCanonicalTasks(
        await taskStore.load(),
        settings: await _portableBackupSettings(),
        projects: await ProjectStore().load(),
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
      try {
        await AndroidFollowUpReminderScheduler().reschedule();
      } catch (_) {
        // Canonical Task storage already succeeded; the existing alarm foundation
        // can retry on the next lifecycle/scheduler trigger.
      }
      await ProjectStore().save(candidate.projects);
      if (restoredSettings != null) {
        await appSettingsService.restorePortableJson(candidate.settings!);
        final rawSchedule = candidate.settings!['backupSchedule'];
        if (rawSchedule is Map) {
          final restoredSchedule = BackupSchedule.decodePortableJson(
            Map<String, dynamic>.from(rawSchedule),
          );
          await restoredSchedule.save();
        }
        final appliedSettings = await appSettingsService.load();
        if (mounted) widget.onSettingsChanged?.call(appliedSettings);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('بازیابی ناموفق بود: $error')));
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

  Future<List<Task>> _refreshCanonicalTasksForCalendar() async {
    await _load();
    return List<Task>.of(_searchSource);
  }
  Future<void> _registerTaskInDeviceCalendar(CalendarReminder reminder) async {
    if (!reminder.id.startsWith('task-due:')) return;
    var settings = await appSettingsService.load();
    var targetCalendarId = settings.calendarIntegration.targetCalendarId?.trim();
    if (targetCalendarId == null || targetCalendarId.isEmpty) {
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => CalendarIntegrationSettingsPage(
            service: appSettingsService,
          ),
        ),
      );
      if (!mounted) return;
      settings = await appSettingsService.load();
      targetCalendarId = settings.calendarIntegration.targetCalendarId?.trim();
    }
    if (targetCalendarId == null || targetCalendarId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا یک تقویم مقصد را انتخاب کنید.')),
      );
      return;
    }

    final taskId = reminder.id.substring('task-due:'.length);
    Task? task;
    for (final candidate in _searchSource) {
      if (candidate.id == taskId) {
        task = candidate;
        break;
      }
    }
    if (task == null) return;

    final canonical = CalendarReminder(
      id: reminder.id,
      title: task.title,
      date: task.dueDate ?? reminder.date,
      completed: task.completed,
      description: task.description,
    );
    try {
      final revision = await CalendarSyncRevisionService().fromReminder(canonical);
      final links = await ExternalCalendarLinkStore().load();
      final plan = const CalendarSyncPlanService().plan(
        revisions: <CalendarSyncRevision>[revision],
        links: links,
      );
      final result = await CalendarProviderSyncExecutor().execute(
        plan: plan,
        targetCalendarId: targetCalendarId,
      );
      if (!mounted) return;
      final message = result.created > 0
          ? 'کار در تقویم گوشی ثبت شد.'
          : result.updated > 0
          ? 'رویداد تقویم گوشی به‌روزرسانی شد.'
          : 'رویداد تقویم گوشی از قبل به‌روز بود.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ثبت در تقویم گوشی انجام نشد: $error')),
      );
    }
  }



  Future<void> _openPrimaryCalendar() async {
    if (!mounted) return;
    // Re-read canonical SQL before opening calendar/timeline so navigation never
    // depends on a stale in-memory Home snapshot after a write/migration.
    await _load();
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CanonicalCalendarLauncher(
          tasks: _searchSource,
          onRefreshTasks: _refreshCanonicalTasksForCalendar,
          onCreateTaskForDate: _addForDate,
          onCreateTaskFromCalendarEvent: _addFromCalendarEvent,
          onEditTask: (task) async { await _editFromDetail(task); },
          onRegisterTaskToDeviceCalendar: _registerTaskInDeviceCalendar,
          onRetryCalendarSync: () => _retryCalendarSync(tasks),
        ),
      ),
    );
    if (mounted) await _load();
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
            builder: (_) => CanonicalCalendarLauncher(
              tasks: _searchSource,
              onCreateTaskForDate: _addForDate,
              onCreateTaskFromCalendarEvent: _addFromCalendarEvent,
            ),
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
          onOpenBackupSchedule: () {
            Navigator.of(context).pop();
            Future<void>.delayed(
              Duration.zero,
              () {
                if (!mounted) return;
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => BackupSchedulePage(
                      loadTasks: () async => (await TaskStore().load())
                          .map((task) => task.toJson())
                          .toList(growable: false),
                    ),
                  ),
                );
              },
            );
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

  Future<void> _openMyTasks() async {
    final selection = await showHomeMyTasksSheet(
      context: context,
      categories: _homeCategories,
    );
    if (selection == null || !mounted) return;

    switch (selection.kind) {
      case HomeTaskFilterKind.all:
        _selectHomeStat('کل');
        return;
      case HomeTaskFilterKind.today:
        _selectDueScope(TaskDueScope.today);
        return;
      case HomeTaskFilterKind.followUp:
        _selectListScope(TaskListScope.followUpEnabled);
        return;
      case HomeTaskFilterKind.withoutFollowUp:
        _selectListScope(TaskListScope.simpleNotes);
        return;
      case HomeTaskFilterKind.completed:
        _selectHomeStat('انجام‌شده');
        return;
      case HomeTaskFilterKind.incomplete:
        _selectHomeStat('فعال');
        return;
      case HomeTaskFilterKind.category:
        final category = selection.category;
        if (category != null) _selectCategory(category);
        return;
    }
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
                    Navigator.of(sheetContext)
                        .pop(_HomeMoreAction.quickCapture),
              ),
              const Divider(),
              ListTile(
                key: const ValueKey('home-more-task-filters'),
                leading: const Icon(Icons.filter_list_outlined),
                title: const Text('فیلتر کارها'),
                subtitle: const Text('امروز، پیگیری، وضعیت و دسته‌ها'),
                onTap: () => Navigator.of(sheetContext).pop(_HomeMoreAction.myTasks),
              ),
              ListTile(
                leading: const Icon(Icons.today_outlined),
                title: const Text('امروز'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_HomeMoreAction.today),
              ),
              ListTile(
                key: const ValueKey('home-more-undated'),
                leading: const Icon(Icons.event_busy_outlined),
                title: const Text('کارهای فاقد زمان'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_HomeMoreAction.undated),
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('بایگانی'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_HomeMoreAction.archive),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('سطل زباله'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_HomeMoreAction.trash),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('پشتیبان‌گیری'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_HomeMoreAction.backup),
              ),
              ListTile(
                key: const ValueKey('home-more-next-action'),
                leading: const Icon(Icons.next_plan_outlined),
                title: const Text('اقدام بعدی'),
                subtitle: const Text('پیشنهاد بهترین کار بعدی'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_HomeMoreAction.nextAction),
              ),
              ListTile(
                key: const ValueKey('home-more-report'),
                leading: const Icon(Icons.assessment_outlined),
                title: const Text('گزارش‌ها'),
                subtitle: const Text('فیلتر، تحلیل و اشتراک‌گذاری کارها'),
                onTap: () => Navigator.of(sheetContext)
                    .pop(_HomeMoreAction.report),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('تنظیمات'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_HomeMoreAction.settings),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('درباره آروین'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_HomeMoreAction.about),
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
      case _HomeMoreAction.myTasks:
        await _openMyTasks();
        return;
      case _HomeMoreAction.today:
        Navigator.of(context).popUntil((route) => route.isFirst);
        _selectHomeStat('امروز');
        return;
      case _HomeMoreAction.undated:
        Navigator.of(context).popUntil((route) => route.isFirst);
        _selectDueScope(TaskDueScope.undated);
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
      case _HomeMoreAction.nextAction:
        await _openPrimaryNextAction();
        return;
      case _HomeMoreAction.report:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => ReportCenterPage(
              tasks: List<Task>.of(tasks),
              projects: List<ProjectPlan>.of(projects),
            ),
          ),
        );
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
      case TaskSwipeAction.convertToFollowUp:
        if (task.followUpEnabled) return false;
        await taskStore.convertToFollowUp(task.id);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('کار به کار پیگیری‌دار تبدیل شد')),
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
      TaskSwipeAction.convertToFollowUp => Icons.follow_the_signs_outlined,
      TaskSwipeAction.none => Icons.block,
    };
    final label = switch (action) {
      TaskSwipeAction.archive => 'بایگانی',
      TaskSwipeAction.trash => 'سطل زباله',
      TaskSwipeAction.moveToToday => 'انتقال به امروز',
      TaskSwipeAction.convertToFollowUp => 'تبدیل به کار پیگیری‌دار',
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

  String? _latestFollowUpPreview(Task task) {
    final followUp = task.lastFollowUp;
    if (followUp == null) return null;
    final note = followUp.note.trim();
    final result = (followUp.result ?? '').trim();
    if (result.isNotEmpty) return result;
    if (note.isNotEmpty) return note;
    return 'پیگیری ثبت‌شده';
  }

  Color _taskCardAccent(Task task) {
    final palette = <Color>[
      ArvinColors.time,
      ArvinColors.project,
      ArvinColors.category,
      ArvinColors.tag,
      ArvinColors.reminder,
    ];
    final key = task.id.trim().isEmpty ? task.title : task.id;
    final hash = key.codeUnits.fold<int>(0, (value, unit) => (value * 31 + unit) & 0x7fffffff);
    return palette[hash % palette.length];
  }

  Widget _homeChecklistProgress(Task task) {
    final total = task.checklist.length;
    final completed = task.checklist
        .where((item) => item.trimLeft().startsWith('[x]'))
        .length;
    final progress = total == 0 ? 0.0 : completed / total;
    return Column(
      key: ValueKey('task-card-checklist-progress-${task.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.checklist_rounded, size: 15, color: Color(0xFF4A4CAB)),
            const SizedBox(width: 4),
            Text(
              'چک‌لیست: ${persianDateFormatter.toPersianDigits('$completed از $total')}',
              style: const TextStyle(color: Color(0xFF80829C), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: Color(0xFFE9EAFF)),
        ),
      ],
    );
  }
  Widget _taskCard(Task task) {
    final followUpDate = _homeFollowUpDate(task);
    final late = _overdue(task);
    final colors = Theme.of(context).colorScheme;
    final preview = _latestFollowUpPreview(task);
    return Dismissible(
      key: ValueKey(task.id),
      direction: selectionMode
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: (direction) => _applySwipe(task, direction),
      background: task.trashed
          ? _swipeBackground(TaskSwipeAction.none)
          : _swipeBackground(widget.settings.swipeLeftAction),
      secondaryBackground: task.trashed
          ? _swipeBackground(TaskSwipeAction.trash)
          : _swipeBackground(widget.settings.swipeRightAction),
      child: Material(
        color: Color.alphaBlend(
          _taskCardAccent(task).withAlpha(22),
          ArvinColors.surface,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
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
                  final next = taskBulkSelectionService.toggle(
                    selected,
                    task.id,
                  );
                  selected
                    ..clear()
                    ..addAll(next);
                  selectionMode = selected.isNotEmpty;
                })
              : () => _openTaskDetail(task),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                selectionMode
                    ? Checkbox(
                        value: selected.contains(task.id),
                        onChanged: (_) => setState(() {
                          final next = taskBulkSelectionService.toggle(
                            selected,
                            task.id,
                          );
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: const Color(0xFF232433),
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (preview != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ArvinColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      if (task.checklist.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        _homeChecklistProgress(task),
                      ],
                      if (_projectTitleForTask(task) != null || task.category?.trim().isNotEmpty == true || task.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        TaxonomyIconRow(
                          project: _projectTitleForTask(task),
                          category: task.category,
                          tags: task.tags,
                          maxTags: 2,
                        ),
                      ],
                      if (task.priority != TaskPriority.none) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.flag_rounded, size: 13, color: ArvinColors.reminder),
                            const SizedBox(width: 4),
                            Text(
                              switch (task.priority) {
                                TaskPriority.high => 'اهمیت زیاد',
                                TaskPriority.medium => 'اهمیت متوسط',
                                TaskPriority.low => 'اهمیت کم',
                                TaskPriority.none => '',
                              },
                              style: const TextStyle(color: ArvinColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: late ? const Color(0xFFC62828) : const Color(0xFF80829C),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                late
                                    ? 'موعد گذشته: ${_date(task.dueDate!)} • ${_time(task.dueDate!)}'
                                    : 'موعد: ${_date(task.dueDate!)} • ${_time(task.dueDate!)}',
                                style: TextStyle(
                                  color: late ? const Color(0xFFC62828) : const Color(0xFF80829C),
                                  fontSize: 11,
                                  fontWeight: late ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              key: ValueKey('task-card-clear-due-${task.id}'),
                              tooltip: 'حذف موعد',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () async {
                                setState(() { task.dueDate = null; });
                                await _save();
                              },
                              icon: const Icon(Icons.close_rounded, size: 17),
                              color: late ? const Color(0xFFC62828) : const Color(0xFF80829C),
                            ),
                          ],
                        ),
                      ],                      if (followUpDate != null) ...[
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 15,
                              color: late
                                  ? const Color(0xFFDB8B23)
                                  : const Color(0xFF80829C),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'پیگیری: ${_date(followUpDate)} • ${_time(followUpDate)}',
                                style: TextStyle(
                                  color: late
                                      ? const Color(0xFFDB8B23)
                                      : const Color(0xFF80829C),
                                  fontSize: 11,
                                  fontWeight: late
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (task.trashed || task.archived)
                        TextButton(
                          onPressed: () => _restore(task),
                          child: const Text('بازگردانی به فعال'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compactHome = MediaQuery.sizeOf(context).height < 700;
    return Scaffold(
      backgroundColor: ArvinColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, compactHome ? 4 : 8, 16, 5),
            child: Row(children: [
              IconButton(key: const ValueKey('home-notifications'), tooltip: 'اعلان‌ها', onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اعلان‌ها در بخش اعلان‌های برنامه مدیریت می‌شوند'))), icon: const Icon(Icons.notifications_none_rounded)),
              Expanded(child: Column(children: const [
                Text('بسم الله الرحمن الرحیم', key: ValueKey('home-bismillah'), style: TextStyle(color: ArvinColors.primary, fontSize: 17, fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('مدیریت کارها و پیگیری آروین', key: ValueKey('home-title-block'), textAlign: TextAlign.center, style: TextStyle(color: ArvinColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
              ])),
              IconButton(key: const ValueKey('home-menu'), tooltip: 'منو', onPressed: _openPrimaryMore, icon: const Icon(Icons.menu_rounded)),
            ]),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, compactHome ? 6 : 8),
            child: TextField(
              key: const ValueKey('home-canonical-search'),
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'جستجو در کارها، پروژه‌ها، دسته‌ها و برچسب‌ها...',
                hintStyle: const TextStyle(color: ArvinColors.textSecondary, fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true, fillColor: ArvinColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: ArvinColors.primary, width: 1.2)),
              ),
            ),
          ),
          _homeFilterCards(),
          _homeActiveFilterChips(),
          Expanded(child: loading ? Center(child: CircularProgressIndicator(color: ArvinColors.primary)) : loadFailure != null
            ? SingleChildScrollView(padding: const EdgeInsets.all(24), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.storage_outlined, size: 40), SizedBox(height: 12),
                Text('داده‌های کارها قابل خواندن نیست', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('برای جلوگیری از از دست رفتن اطلاعات، تا بازیابی موفق هیچ تغییری ذخیره نمی‌شود.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(key: const ValueKey('home-storage-retry'), onPressed: () { setState(() => loading = true); _load(); }, icon: const Icon(Icons.refresh), label: const Text('تلاش دوباره')),
              ])))
            : _groupedTaskList()),
        ]),
      ),
      floatingActionButton: selected.isEmpty && loadFailure == null ? Padding(padding: const EdgeInsets.only(bottom: 2), child: KeyedSubtree(key: const ValueKey('home-canonical-add'), child: ArvinHomePrimaryAddButton(onPressed: _quickCapture))) : null,
      bottomNavigationBar: selected.isEmpty ? ArvinPrimaryNavigation(selected: ArvinPrimaryDestination.home, onSelected: _onPrimaryDestinationSelected) : TaskBulkSelectionBar(
        selectedCount: selected.length,
        allVisibleSelected: taskBulkSelectionService.allVisibleSelected(selected, visible),
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
  report,
  quickCapture,
  myTasks,
  today,
  undated,
  archive,
  trash,
  backup,
  settings,
  nextAction,
  about,
}

/// Backward-compatible public entry retained for existing callers/tests.
class TaskDialog extends StatelessWidget {
  const TaskDialog({super.key, this.task});

  final Task? task;

  @override
  Widget build(BuildContext context) => ArvinTaskEditorDialog(task: task);
}