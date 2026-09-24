import 'package:flutter/material.dart';

import 'android_follow_up_reminder_scheduler.dart';
import 'backup_manager.dart';
import 'backup_schedule.dart';
import 'calendar_page.dart';
import 'models/goal_project.dart';
import 'models/task.dart';
import 'home/grouping/home_group.dart';
import 'home/grouping/home_group_mode.dart';
import 'home/grouping/home_grouping_service.dart';
import 'notebook_page.dart';
import 'projects_launcher.dart';
import 'widgets/arvin_radio_box.dart';
import 'quick_capture_dialog.dart';
import 'services/app_settings_service.dart';
import 'services/home_search_projection.dart';
import 'services/home_today_projection.dart';
import 'services/task_due_scope_service.dart';
import 'services/task_list_scope_service.dart';
import 'services/task_list_sort_service.dart';
import 'services/task_move_to_today_service.dart';
import 'services/persian_date_formatter.dart';
import 'services/project_store.dart';
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
import 'task_taxonomy_management_page.dart';
import 'theme/app_fonts.dart';
import 'widgets/arvin_primary_navigation.dart';
import 'widgets/arvin_home_primary_add_button.dart';
import 'widgets/canonical_calendar_launcher.dart';
import 'widgets/home_my_tasks_sheet.dart';
import 'widgets/task_bulk_selection_bar.dart';

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
  final HomeGroupingService homeGroupingService = const HomeGroupingService();
  final Wave2ProductFastTrack wave2ProductFastTrack = Wave2ProductFastTrack();
  final ArvinBackupManager backupManager = ArvinBackupManager();
  final AppSettingsService appSettingsService = AppSettingsService();
  final HomeSearchProjection homeSearchProjection =
      const HomeSearchProjection();
  final HomeTodayProjection homeTodayProjection = const HomeTodayProjection();
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
  HomeGroupMode _homeGroupMode = HomeGroupMode.time;
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
  String? _tagFilter;
  final Set<String> _collapsedGroups = <String>{};
  final TaskListSort _listSort = TaskListSort.date;
  final bool _sortDescending = false;

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

  Future<void> _save() {
    if (loadFailure != null) {
      throw StateError(
        'Canonical task storage is unreadable; refusing Home write.',
      );
    }
    return taskStore.save(List<Task>.of(tasks));
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
      final category = _categoryFilter;
      if (category != null) {
        scoped = scoped.where((task) => task.category?.trim() == category);
      }
      final projectId = _projectFilter;
      if (projectId != null) {
        if (projectId == '__no_project__') {
          final assigned = projects.expand((item) => item.itemIds).toSet();
          scoped = scoped.where((task) => !assigned.contains(task.id));
        } else {
          final matchingProjects = projects.where((item) => item.id == projectId).toList(growable: false);
          final project = matchingProjects.isEmpty ? null : matchingProjects.first;
          if (project != null) {
            final ids = project.itemIds.toSet();
            scoped = scoped.where((task) => ids.contains(task.id));
          }
        }
      }
      final tag = _tagFilter;
      if (tag != null) scoped = scoped.where((task) => task.tags.map((value) => value.trim()).contains(tag));
    }

    final result = scoped
        .where((task) {
          if (filter == 'کل' && (task.archived || task.trashed)) return false;
          if (filter == 'فعال' &&
              (task.archived || task.trashed || task.completed)) {
            return false;
          }
          if (filter == 'انجام‌شده' &&
              (task.archived || task.trashed || !task.completed)) {
            return false;
          }
          if (filter == 'بایگانی' && (!task.archived || task.trashed)) {
            return false;
          }
          if (filter == 'سطل زباله' && !task.trashed) return false;
          if (matchingIds != null && !matchingIds.contains(task.id)) {
            return false;
          }
          return true;
        })
        .toList(growable: false);

    return taskListSortService.sort(
      result,
      by: _listSort,
      descending: _sortDescending,
    );
  }

  List<HomeGroup<Task>> get _homeGroups {
    if (filter == 'بایگانی' || filter == 'سطل زباله') {
      return [HomeGroup<Task>(id: 'filtered', title: filter, items: visible)];
    }
    return homeGroupingService.buildGroups(
      _homeGroupMode,
      visible,
      projects: projects,
    );
  }

  Widget _homeGroupButton({
    required HomeGroupMode mode,
    required String label,
    required IconData icon,
    required Color accent,
    required Color softAccent,
  }) {
    final selectedMode = _homeGroupMode == mode;
    return Expanded(
      child: ArvinRadioBox(
        key: ValueKey('home-group-${mode.name}'),
        label: label,
        icon: icon,
        accent: accent,
        selected: selectedMode,
        onTap: () => _selectHomeGroupMode(mode),
      ),
    );
  }

  Widget _homeGroupSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _homeGroupButton(
            mode: HomeGroupMode.time,
            label: 'زمان',
            icon: Icons.calendar_month_rounded,
            accent: const Color(0xFFE39A4A),
            softAccent: const Color(0xFFFFF0E3),
          ),
          const SizedBox(width: 7),
          _homeGroupButton(
            mode: HomeGroupMode.projects,
            label: 'پروژه‌ها',
            icon: Icons.folder_rounded,
            accent: const Color(0xFF4B8FE8),
            softAccent: const Color(0xFFEAF3FF),
          ),
          const SizedBox(width: 7),
          _homeGroupButton(
            mode: HomeGroupMode.categories,
            label: 'دسته‌ها',
            icon: Icons.grid_view_rounded,
            accent: const Color(0xFF8C68D9),
            softAccent: const Color(0xFFF2ECFF),
          ),
          const SizedBox(width: 7),
          _homeGroupButton(
            mode: HomeGroupMode.labels,
            label: 'برچسب‌ها',
            icon: Icons.sell_rounded,
            accent: const Color(0xFF38A89B),
            softAccent: const Color(0xFFE8F8F5),
          ),
        ],
      ),
    );
  }

  void _selectHomeGroupMode(HomeGroupMode mode) {
    setState(() {
      _homeGroupMode = mode;
      filter = 'کل';
      _listScope = TaskListScope.all;
      _dueScope = null;
      _categoryFilter = null;
      _projectFilter = null;
      _tagFilter = null;
      _collapsedGroups.clear();
      selected.clear();
      selectionMode = false;
    });
  }

  List<String> get _homeTags => tasks.expand((task) => task.tags).map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toSet().toList()..sort();

  Widget _homeFilterBar() {
    final chips = <Widget>[];
    void addChip(String label, bool selected, VoidCallback onSelected, {IconData? icon, Color accent = const Color(0xFF4A4CAB), bool newOption = false}) => chips.add(ArvinRadioBox(label: label, selected: selected, onTap: onSelected, icon: icon, accent: accent, newOption: newOption));
    if (_homeGroupMode == HomeGroupMode.time) {
      addChip('همه', _dueScope == null, () => setState(() => _dueScope = null));
      addChip('عقب‌افتاده', _dueScope == TaskDueScope.overdue, () => setState(() => _dueScope = TaskDueScope.overdue));
      addChip('امروز', _dueScope == TaskDueScope.today, () => setState(() => _dueScope = TaskDueScope.today));
      addChip('آینده', _dueScope == TaskDueScope.future, () => setState(() => _dueScope = TaskDueScope.future));
      addChip('بدون موعد', _dueScope == TaskDueScope.undated, () => setState(() => _dueScope = TaskDueScope.undated));
    } else if (_homeGroupMode == HomeGroupMode.projects) {
      addChip('همه پروژه‌ها', _projectFilter == null, () => setState(() => _projectFilter = null), icon: Icons.folder_outlined, accent: const Color(0xFF4B8FE8));
      for (final project in projects.where((item) => !item.isArchived)) {
        addChip(project.title, _projectFilter == project.id, () => setState(() => _projectFilter = project.id), icon: Icons.folder_outlined, accent: Color(project.colorValue));
      }
      addChip('بدون پروژه', _projectFilter == '__no_project__', () => setState(() => _projectFilter = '__no_project__'), icon: Icons.folder_off_outlined, accent: const Color(0xFF8A8B9C));
      chips.add(ArvinRadioBox(label: 'گزینه جدید', selected: false, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProjectsLauncher())), newOption: true));
    } else if (_homeGroupMode == HomeGroupMode.categories) {
      addChip('همه دسته‌ها', _categoryFilter == null, () => setState(() => _categoryFilter = null), icon: Icons.grid_view_rounded, accent: const Color(0xFF8C68D9));
      for (final category in _homeCategories) {
        addChip(category, _categoryFilter == category, () => setState(() => _categoryFilter = category), icon: Icons.folder_outlined, accent: const Color(0xFF8C68D9));
      }
      chips.add(ArvinRadioBox(label: 'گزینه جدید', selected: false, onTap: _openTaxonomyManagement, newOption: true, accent: const Color(0xFF8C68D9)));
    } else {
      addChip('همه برچسب‌ها', _tagFilter == null, () => setState(() => _tagFilter = null), icon: Icons.sell_outlined, accent: const Color(0xFF38A89B));
      for (final tag in _homeTags) {
        addChip(tag, _tagFilter == tag, () => setState(() => _tagFilter = tag), icon: Icons.sell_outlined, accent: const Color(0xFF38A89B));
      }
      chips.add(ArvinRadioBox(label: 'گزینه جدید', selected: false, onTap: _openTaxonomyManagement, newOption: true, accent: const Color(0xFF38A89B)));
    }
    return Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: Wrap(textDirection: TextDirection.rtl, spacing: 6, runSpacing: 6, children: chips));
  }
  Future<void> _addToProject(String projectId) async {
    final editorContext = await wave2ProductFastTrack.prepareEditor(
      tasks: tasks,
    );
    if (!mounted) return;
    String? selectedProjectId = projectId;
    final task = await showDialog<Task>(
      context: context,
      builder: (_) => ArvinTaskEditorDialog(
        projects: editorContext.projects,
        selectedProjectId: projectId,
        onProjectChanged: (value) => selectedProjectId = value,
                knownCategories: editorContext.knownCategories,
        knownTags: editorContext.knownTags,
      ),
    );
    if (task == null) return;
    setState(() => tasks.add(task));
    await _save();
    await wave2ProductFastTrack.persistProjectSelection(
      taskId: task.id,
      projectId: selectedProjectId,
    );
    await _load();
  }

  Widget _groupedTaskList() {
    final groups = _homeGroups
        .where(
          (group) =>
              group.items.isNotEmpty ||
              _homeGroupMode == HomeGroupMode.projects,
        )
        .toList(growable: false);
    if (groups.every((group) => group.items.isEmpty)) {
      return Center(child: Text(_emptyVisibleLabel));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        final projectGroup =
            _homeGroupMode == HomeGroupMode.projects &&
            group.id != 'no_project' &&
            projects.any((project) => project.id == group.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() {
                  if (_collapsedGroups.contains(group.id)) { _collapsedGroups.remove(group.id); } else { _collapsedGroups.add(group.id); }
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(_collapsedGroups.contains(group.id) ? Icons.chevron_left_rounded : Icons.expand_more_rounded, size: 20, color: const Color(0xFF80829C)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(group.title, style: const TextStyle(color: Color(0xFF232433), fontSize: 14, fontWeight: FontWeight.w800))),
                      Text('${group.items.length}', style: const TextStyle(color: Color(0xFF80829C), fontSize: 12)),
                      if (projectGroup) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          key: ValueKey('home-project-add-${group.id}'),
                          tooltip: 'افزودن کار به ${group.title}',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _addToProject(group.id),
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                        ),
                      ],
                    ],
                  ),
                ),
              ),              const SizedBox(height: 6),
              if (_collapsedGroups.contains(group.id))
                const SizedBox.shrink()
              else
              if (group.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'کاری در این گروه وجود ندارد',
                    style: TextStyle(color: Color(0xFF80829C), fontSize: 12),
                  ),
                )
              else ...[
                for (var index = 0; index < group.items.length; index++) ...[
                  _taskCard(group.items[index]),
                  if (index != group.items.length - 1)
                    const SizedBox(height: 8),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  String get _emptyVisibleLabel {
    if (filter == 'سطل زباله') return 'سطل زباله خالی است';
    if (filter == 'بایگانی') return 'بایگانی خالی است';
    if (_categoryFilter != null) {
      return 'کاری در دسته «$_categoryFilter» وجود ندارد';
    }
    if (_dueScope == TaskDueScope.today) return 'کاری برای امروز وجود ندارد';
    if (_dueScope == TaskDueScope.future) return 'کار آینده‌ای وجود ندارد';
    if (_dueScope == TaskDueScope.overdue) {
      return 'کار عقب‌افتاده‌ای وجود ندارد';
    }
    if (_dueScope == TaskDueScope.undated) {
      return 'کار فاقد زمانی برای نمایش وجود ندارد';
    }
    if (_listScope == TaskListScope.simpleNotes) {
      return 'کار بدون پیگیری برای نمایش وجود ندارد';
    }
    if (_listScope == TaskListScope.followUpEnabled) {
      return 'کار پیگیری‌دار برای نمایش وجود ندارد';
    }
    if (filter == 'انجام‌شده') return 'کار انجام‌شده‌ای وجود ندارد';
    return 'کاری برای نمایش وجود ندارد';
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

  Future<Task?> _completeFromDetail(Task task) async {
    task.completed = true;
    task.updatedAt = DateTime.now();
    await taskStore.save(List<Task>.of(tasks));
    final refreshed = await taskStore.load();
    if (!mounted) return task;
    setState(() => tasks = List<Task>.of(refreshed));
    return refreshed.firstWhere((item) => item.id == task.id);
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
          onComplete: _completeFromDetail,
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

  Future<void> _openPrimaryCalendar() async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CanonicalCalendarLauncher(
          tasks: _searchSource,
          onCreateTaskForDate: _addForDate,
          onCreateTaskFromCalendarEvent: _addFromCalendarEvent,
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
        ),
      ),
    );
  }

  Future<void> _openTaxonomyManagement() async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const TaskTaxonomyManagementPage(),
      ),
    );
    if (mounted) await _load();
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
                key: const ValueKey('home-more-taxonomy'),
                leading: const Icon(Icons.category_outlined),
                title: const Text('دسته‌ها و برچسب‌ها'),
                subtitle: const Text('مدیریت دسته‌ها و برچسب‌های کارها'),
                onTap: () => Navigator.of(sheetContext)
                    .pop(_HomeMoreAction.taxonomy),
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
      case _HomeMoreAction.taxonomy:
        await _openTaxonomyManagement();
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

  String? _latestFollowUpPreview(Task task) {
    final followUp = task.lastFollowUp;
    if (followUp == null) return null;
    final note = followUp.note.trim();
    final result = (followUp.result ?? '').trim();
    if (result.isNotEmpty) return result;
    if (note.isNotEmpty) return note;
    return 'پیگیری ثبت‌شده';
  }

  Widget _homeBadge(String label, Color background, Color foreground) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(9)), child: Text(label, style: TextStyle(color: foreground, fontSize: 9.5, fontWeight: FontWeight.w700)));

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
        color: const Color(0xFFFDFDFE),
        elevation: 1,
        shadowColor: const Color(0x14000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7ED)),
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
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF232433),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (preview != null || task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          preview ?? task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF80829C),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (_projectTitleForTask(task) != null) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.folder_outlined, size: 15, color: Color(0xFF4B8FE8)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _projectTitleForTask(task)!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFF4B8FE8), fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (task.priority != TaskPriority.none || task.category?.trim().isNotEmpty == true || task.tags.isNotEmpty || task.completed) ...[
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 4,
                          runSpacing: 3,
                          children: [
                            if (task.completed) _homeBadge('انجام‌شده', const Color(0xFFE8F5E9), const Color(0xFF409B51)),
                            if (task.priority != TaskPriority.none) _homeBadge(
                              switch (task.priority) { TaskPriority.high => 'اهمیت زیاد', TaskPriority.medium => 'اهمیت متوسط', TaskPriority.low => 'اهمیت کم', TaskPriority.none => '' },
                              const Color(0xFFFFF0E3),
                              const Color(0xFFDB8B23),
                            ),
                            if (task.category?.trim().isNotEmpty == true) _homeBadge(
                              task.category!.trim(),
                              const Color(0xFFF2ECFF),
                              const Color(0xFF8C68D9),
                            ),
                            for (final tag in task.tags.take(3))
                              _homeBadge('#${tag.trim()}', const Color(0xFFE8F8F5), const Color(0xFF38A89B)),
                          ],
                        ),
                      ],
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 15,
                              color: Color(0xFF80829C),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'موعد: ${_date(task.dueDate!)} • ${_time(task.dueDate!)}',
                                style: const TextStyle(
                                  color: Color(0xFF80829C),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (followUpDate != null) ...[
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
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                compactHome ? 2 : 4,
                12,
                compactHome ? 2 : 4,
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    key: const ValueKey('home-notifications'),
                    tooltip: 'اعلان‌ها',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('اعلان‌ها در بخش اعلان‌های برنامه مدیریت می‌شوند'),
                      ),
                    ),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9EAFF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        SizedBox(height: compactHome ? 4 : 7),
                        const Text(
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
              padding: EdgeInsets.fromLTRB(
                16,
                compactHome ? 1 : 4,
                16,
                compactHome ? 5 : 10,
              ),
              child: TextField(
                key: const ValueKey('home-canonical-search'),
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
            _homeGroupSelector(),
            _homeFilterBar(),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : loadFailure != null
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Center(
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
                      : _groupedTaskList(),
            ),
          ],
        ),
      ),
      floatingActionButton: selected.isEmpty && loadFailure == null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: KeyedSubtree(
                key: const ValueKey('home-canonical-add'),
                child: ArvinHomePrimaryAddButton(onPressed: _quickCapture),
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
  myTasks,
  today,
  undated,
  archive,
  trash,
  backup,
  settings,
  taxonomy,
  about,
}

/// Backward-compatible public entry retained for existing callers/tests.
class TaskDialog extends StatelessWidget {
  const TaskDialog({super.key, this.task});

  final Task? task;

  @override
  Widget build(BuildContext context) => ArvinTaskEditorDialog(task: task);
}
