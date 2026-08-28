import 'package:flutter/material.dart';

import 'backup_manager.dart';
import 'models/task.dart';
import 'notebook_page.dart';
import 'quick_capture_dialog.dart';
import 'services/app_settings_service.dart';
import 'services/home_search_projection.dart';
import 'services/home_today_projection.dart';
import 'services/interactive_guide_service.dart';
import 'services/persian_date_formatter.dart';
import 'services/task_migration_reader.dart';
import 'services/task_migration_writer.dart';
import 'services/task_edit_apply_service.dart';
import 'services/task_store.dart';
import 'services/widget_task_bridge.dart';
import 'services/widget_task_selection_service.dart';
import 'settings_page.dart';
import 'task_detail_page.dart';
import 'task_editor_dialog.dart';
import 'task_next_action_page.dart';
import 'theme/app_fonts.dart';
import 'widgets/arvin_primary_navigation.dart';
import 'widgets/canonical_calendar_launcher.dart';
import 'widgets/home_interactive_guide.dart';

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
        fontFamily: settings.fontFamily ?? AppFonts.vazirmatnFamily,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        fontFamily: settings.fontFamily ?? AppFonts.vazirmatnFamily,
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
  final TaskMigrationReader migrationReader = TaskMigrationReader();
  final TaskMigrationWriter migrationWriter = TaskMigrationWriter();
  final TaskEditApplyService taskEditApplyService = TaskEditApplyService();
  final TaskStore taskStore = TaskStore();
  final ArvinBackupManager backupManager = ArvinBackupManager();
  final AppSettingsService appSettingsService = AppSettingsService();
  final InteractiveGuideService interactiveGuideService =
      InteractiveGuideService();
  final HomeSearchProjection homeSearchProjection = const HomeSearchProjection();
  final HomeTodayProjection homeTodayProjection = const HomeTodayProjection();
  final PersianDateFormatter persianDateFormatter = const PersianDateFormatter();
  final WidgetTaskBridge widgetTaskBridge = WidgetTaskBridge();
  final WidgetTaskSelectionService widgetTaskSelectionService =
      WidgetTaskSelectionService();

  final GlobalKey _quickCaptureGuideKey =
      GlobalKey(debugLabel: 'home-guide-quick-capture');
  final GlobalKey _searchGuideKey =
      GlobalKey(debugLabel: 'home-guide-search');
  final GlobalKey _filtersGuideKey =
      GlobalKey(debugLabel: 'home-guide-filters');
  final GlobalKey _newTaskGuideKey =
      GlobalKey(debugLabel: 'home-guide-new-task');

  List<Task> tasks = [];
  final Set<String> selected = <String>{};
  bool loading = true;
  bool selectionMode = false;
  bool _firstRunGuideChecked = false;
  bool _interactiveGuideRunning = false;
  String query = '';
  String filter = 'کل';

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
          key: _quickCaptureGuideKey,
          title: 'ثبت سریع',
          description:
              'وقتی عجله دارید، این دکمه را بزنید و فقط متن کار را سریع ثبت کنید. جزئیات را بعداً می‌توانید کامل کنید.',
          icon: Icons.bolt_outlined,
        ),
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

  Future<void> _save() => migrationWriter.save(List<Task>.of(tasks));

  DateTime? _homeFollowUpDate(Task task) => task.legacyHomeFollowUpDate;

  bool _overdue(Task task) {
    final date = _homeFollowUpDate(task);
    return date != null && !task.completed && date.isBefore(DateTime.now());
  }

  List<Task> get visible {
    final matchingIds = query.trim().isEmpty
        ? null
        : homeSearchProjection.matchingIds(_searchSource, query);
    final todayIds = filter == 'امروز'
        ? homeTodayProjection.select(_searchSource).map((task) => task.id).toSet()
        : null;

    final result = tasks.where((task) {
      if (filter == 'کل' && (task.archived || task.trashed)) return false;
      if (filter == 'فعال' &&
          (task.archived || task.trashed || task.completed)) {
        return false;
      }
      if (filter == 'انجام‌شده' &&
          (task.archived || task.trashed || !task.completed)) {
        return false;
      }
      if (filter == 'عقب‌افتاده' &&
          (task.archived || task.trashed || !_overdue(task))) {
        return false;
      }
      if (filter == 'بایگانی' && (!task.archived || task.trashed)) return false;
      if (filter == 'سطل زباله' && !task.trashed) return false;
      if (filter == 'امروز' && (task.archived || task.trashed)) return false;
      if (todayIds != null && !todayIds.contains(task.id)) return false;
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

  String _time(DateTime date) => persianDateFormatter.toPersianDigits(
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
      );

  Future<void> _add() async {
    final task = await showDialog<Task>(
      context: context,
      builder: (_) => const ArvinTaskEditorDialog(),
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
      builder: (_) => ArvinTaskEditorDialog(task: old),
    );
    if (edited == null) return;
    setState(() => taskEditApplyService.apply(old, edited));
    await _save();
  }

  Future<Task?> _editFromDetail(Task task) async {
    await _edit(task);
    return task;
  }

  Future<Task> _addFollowUpFromDetail(Task task, FollowUp followUp) async {
    await taskStore.addFollowUp(task.id, followUp);
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
    _selectHomeStat(nextFilter);
  }

  void _selectHomeStat(String nextFilter) {
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

  Future<void> _openBackup(BuildContext drawerContext) async {
    Navigator.pop(drawerContext);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    await _backupMenu();
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

  Future<void> _openCalendar(BuildContext drawerContext) async {
    Navigator.pop(drawerContext);
    await Future<void>.delayed(Duration.zero);
    await _openPrimaryCalendar();
  }

  Future<void> _openSettings(BuildContext drawerContext) async {
    Navigator.pop(drawerContext);
    await Future<void>.delayed(Duration.zero);
    await _openPrimarySettings();
  }

  Future<void> _openAbout(BuildContext drawerContext) async {
    Navigator.pop(drawerContext);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    _showAbout();
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
      case TaskSwipeAction.none:
        return false;
    }
  }

  Widget _swipeBackground(TaskSwipeAction action) {
    final colors = Theme.of(context).colorScheme;
    final icon = switch (action) {
      TaskSwipeAction.archive => Icons.archive_outlined,
      TaskSwipeAction.trash => Icons.delete_outline,
      TaskSwipeAction.none => Icons.block,
    };
    final label = switch (action) {
      TaskSwipeAction.archive => 'بایگانی',
      TaskSwipeAction.trash => 'سطل زباله',
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

    return Dismissible(
      key: ValueKey(task.id),
      direction: selectionMode ? DismissDirection.none : DismissDirection.horizontal,
      confirmDismiss: (direction) => _applySwipe(task, direction),
      background: task.trashed
          ? _swipeBackground(TaskSwipeAction.none)
          : _swipeBackground(widget.settings.swipeLeftAction),
      secondaryBackground: task.trashed
          ? _swipeBackground(TaskSwipeAction.trash)
          : _swipeBackground(widget.settings.swipeRightAction),
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
              : () => _openTaskDetail(task),
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
                  children: task.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              if (followUpDate != null)
                Text(
                  'پیگیری: ${_date(followUpDate)} • ساعت ${_time(followUpDate)}${late ? '  •  عقب‌افتاده' : ''}',
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
            onSelected: (_) => _selectHomeStat(item),
          ),
        ),
      );
    }

    final activeTasks = tasks
        .where((task) => !task.archived && !task.trashed && !task.completed)
        .length;
    final allTasks = tasks.where((task) => !task.archived && !task.trashed).length;
    final doneTasks = tasks
        .where((task) => !task.archived && !task.trashed && task.completed)
        .length;
    final overdueTasks = tasks
        .where((task) => !task.archived && !task.trashed && _overdue(task))
        .length;

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
                  leading: const Icon(Icons.today_outlined),
                  title: const Text('امروز'),
                  onTap: () => _openFilter(drawerContext, 'امروز'),
                ),
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
                  key: const ValueKey('drawer-backup'),
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('پشتیبان‌گیری و بازیابی'),
                  onTap: () => _openBackup(drawerContext),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('تنظیمات'),
                  onTap: () => _openSettings(drawerContext),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('درباره آروین'),
                  onTap: () => _openAbout(drawerContext),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 78,
        title: const Padding(
          key: ValueKey('home-title-block'),
          padding: EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'بسم الله الرحمن الرحیم',
                key: ValueKey('home-bismillah'),
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'مدیریت کارها و پیگیری آروین',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            key: _quickCaptureGuideKey,
            onPressed: loading || selectionMode ? null : _quickCapture,
            tooltip: 'ثبت سریع',
            icon: const Icon(Icons.bolt_outlined),
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
                    key: _searchGuideKey,
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'جست‌وجو',
                    ),
                  ),
                ),
                SizedBox(
                  key: _filtersGuideKey,
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
                          allTasks,
                          Icons.list_alt,
                          semanticKey: const ValueKey('home-stat-all'),
                          selected: filter == 'کل',
                          onTap: () => _selectHomeStat('کل'),
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          'فعال',
                          activeTasks,
                          Icons.pending_actions,
                          semanticKey: const ValueKey('home-stat-active'),
                          selected: filter == 'فعال',
                          onTap: () => _selectHomeStat('فعال'),
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          'انجام‌شده',
                          doneTasks,
                          Icons.check_circle,
                          semanticKey: const ValueKey('home-stat-done'),
                          selected: filter == 'انجام‌شده',
                          onTap: () => _selectHomeStat('انجام‌شده'),
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          'عقب‌افتاده',
                          overdueTasks,
                          Icons.warning_amber,
                          semanticKey: const ValueKey('home-stat-overdue'),
                          selected: filter == 'عقب‌افتاده',
                          onTap: () => _selectHomeStat('عقب‌افتاده'),
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
                                    : filter == 'امروز'
                                        ? 'کاری برای امروز وجود ندارد'
                                        : filter == 'انجام‌شده'
                                            ? 'کار انجام‌شده‌ای وجود ندارد'
                                            : filter == 'عقب‌افتاده'
                                                ? 'کار عقب‌افتاده‌ای وجود ندارد'
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
              key: _newTaskGuideKey,
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('کار جدید'),
            )
          : null,
      bottomNavigationBar: selected.isEmpty
          ? ArvinPrimaryNavigation(
              selected: ArvinPrimaryDestination.home,
              onSelected: _onPrimaryDestinationSelected,
            )
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

enum _HomeMoreAction {
  today,
  archive,
  trash,
  backup,
  settings,
  about,
}

class _Stat extends StatelessWidget {
  const _Stat(
    this.label,
    this.value,
    this.icon, {
    required this.semanticKey,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Key semanticKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      key: semanticKey,
      button: true,
      selected: selected,
      label: 'فیلتر $label، $value مورد',
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: selected ? colors.secondaryContainer : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: selected
              ? BorderSide(color: colors.primary, width: 1.4)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? colors.primary : null,
                ),
                const SizedBox(height: 2),
                Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Backward-compatible public entry retained for existing callers/tests.
/// The live implementation is the Home-aligned Arvin task editor.
class TaskDialog extends StatelessWidget {
  const TaskDialog({super.key, this.task});

  final Task? task;

  @override
  Widget build(BuildContext context) => ArvinTaskEditorDialog(task: task);
}
