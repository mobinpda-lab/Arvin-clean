import 'package:flutter/material.dart';

import 'backup_schedule.dart';
import 'backup_manager.dart';
import 'services/app_settings_service.dart';
import 'services/daily_content_preferences_service.dart';
import 'models/person_reference.dart';
import 'models/task.dart';
import 'models/goal_project.dart';
import 'services/external_calendar_link_store.dart';
import 'services/calendar_sync_plan_service.dart';
import 'services/project_store.dart';
import 'services/task_store.dart';

/// UI for portable Backup/Restore. The page receives the current task data
/// through callbacks so it does not duplicate TaskRepository logic.
class BackupPage extends StatefulWidget {
  const BackupPage({
    super.key,
    required this.loadTasks,
    required this.replaceTasks,
    this.manager,
    this.restoreStageHook,
  });

  final Future<List<Map<String, dynamic>>> Function() loadTasks;
  final Future<void> Function(List<Map<String, dynamic>> tasks) replaceTasks;
  final ArvinBackupManager? manager;

  /// Test-only seam for injecting failures at real restore mutation boundaries.
  /// Production callers leave this unset.
  final Future<void> Function(String stage)? restoreStageHook;

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  late final ArvinBackupManager manager;
  final AppSettingsService settingsService = AppSettingsService();
  String? directory;
  bool busy = false;
  bool encryptBackup = false;

  @override
  void initState() {
    super.initState();
    manager = widget.manager ?? ArvinBackupManager();
    _loadDirectory();
  }

  Future<void> _loadDirectory() async {
    final value = await manager.getDirectory();
    if (!mounted) return;
    setState(() => directory = value);
  }

  Future<void> _chooseDirectory() async {
    setState(() => busy = true);
    try {
      final value = await manager.chooseAndRememberDirectory();
      if (!mounted) return;
      setState(() => directory = value);
      _message(value == null ? 'پوشه‌ای انتخاب نشد' : 'پوشه پشتیبان انتخاب شد');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<String?> _requestNewPassphrase() {
    var passphrase = '';
    var confirmation = '';

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('رمز پشتیبان'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اگر این رمز را فراموش کنید، فایل رمزگذاری‌شده قابل بازیابی نخواهد بود. آروین رمز را ذخیره نمی‌کند.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('backup_passphrase_field'),
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (value) => passphrase = value,
                    decoration: const InputDecoration(
                      labelText: 'رمز',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('backup_passphrase_confirm_field'),
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (value) => confirmation = value,
                    decoration: const InputDecoration(
                      labelText: 'تکرار رمز',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText!,
                      key: const Key('backup_passphrase_error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                key: const Key('backup_passphrase_cancel'),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('انصراف'),
              ),
              FilledButton(
                key: const Key('backup_passphrase_confirm'),
                onPressed: () {
                  if (passphrase.trim().isEmpty) {
                    setDialogState(() => errorText = 'رمز نمی‌تواند خالی باشد');
                    return;
                  }
                  if (passphrase != confirmation) {
                    setDialogState(() => errorText = 'دو رمز یکسان نیستند');
                    return;
                  }
                  Navigator.of(dialogContext).pop(passphrase);
                },
                child: const Text('ادامه'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _requestRestorePassphrase() {
    var passphrase = '';

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('رمز فایل پشتیبان'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'رمزی را وارد کنید که هنگام ساخت این فایل استفاده شده است.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('restore_passphrase_field'),
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (value) => passphrase = value,
                    decoration: const InputDecoration(
                      labelText: 'رمز',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText!,
                      key: const Key('restore_passphrase_error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                key: const Key('restore_passphrase_cancel'),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('انصراف'),
              ),
              FilledButton(
                key: const Key('restore_passphrase_confirm'),
                onPressed: () {
                  if (passphrase.trim().isEmpty) {
                    setDialogState(() => errorText = 'رمز را وارد کنید');
                    return;
                  }
                  Navigator.of(dialogContext).pop(passphrase);
                },
                child: const Text('انتخاب فایل'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _portableBackupSettings() async {
    final settings = await settingsService.load();
    final schedule = await BackupSchedule.load();
    final dailyContentService = DailyContentPreferencesService();
    final dailyContent = await dailyContentService.load();
    return <String, dynamic>{
      ...settingsService.toPortableJson(settings),
      'backupSchedule': schedule.toPortableJson(),
      'dailyContentPreferences': dailyContentService.toPortableJson(dailyContent),
    };
  }

  Future<void> _backup() async {
    if (directory == null || directory!.isEmpty) {
      _message('ابتدا پوشه پشتیبان را انتخاب کنید');
      return;
    }

    String? passphrase;
    if (encryptBackup) {
      passphrase = await _requestNewPassphrase();
      if (passphrase == null || !mounted) return;
    }

    setState(() => busy = true);
    try {
      final tasks = await widget.loadTasks();
      final fileName = await manager.backupTasks(
        tasks,
        settings: await _portableBackupSettings(),
        calendarLinks: (await ExternalCalendarLinkStore().load())
            .map((link) => link.toJson())
            .toList(growable: false),
        projects: manager.projectCodec.encodeList(await ProjectStore().load()),
        categories: await TaskStore().loadCategories(),
        tags: await TaskStore().loadTags(),
        peopleDirectory: (await TaskStore().loadPeopleDirectory())
            .map((person) => person.toJson())
            .toList(growable: false),
        encryptionPassphrase: passphrase,
      );
      if (!mounted) return;
      _message(
        fileName == null
            ? 'ابتدا پوشه پشتیبان را انتخاب کنید'
            : encryptBackup
                ? 'پشتیبان رمزگذاری‌شده ساخته شد: $fileName'
                : 'پشتیبان ساخته شد: $fileName',
      );
    } catch (_) {
      if (mounted) {
        _message(
          encryptBackup
              ? 'ساخت پشتیبان رمزگذاری‌شده انجام نشد'
              : 'پشتیبان‌گیری انجام نشد',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<bool> _confirmRestore(
    int taskCount, {
    required bool hasSettings,
    required bool hasCalendarLinks,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأیید بازیابی'),
        content: Text(
          'از $taskCount مورد موجود در پشتیبان، ابتدا اطلاعات فعلی با فایل بر اساس شناسه‌های اصلی مقایسه می‌شود. موارد هم‌شناسه به‌روز می‌شوند، موارد موجود در پشتیبان اضافه می‌شوند و مواردی که فقط روی این دستگاه هستند حفظ می‌شوند؛ عنوان یا تاریخ مبنای تطبیق نیست.${hasSettings ? ' فقط تنظیمات موجود در فایل پشتیبان به‌روز می‌شوند.' : ' چون این فایل تنظیمات ندارد، تنظیمات فعلی حفظ می‌شوند.'}${hasCalendarLinks ? ' پیوندهای تقویم ادغام می‌شوند؛ پیوندهای این دستگاه اولویت دارند.' : ' پیوندهای فعلیِ تقویم حفظ می‌شوند.'} پیش از تغییر، از اطلاعات فعلی پشتیبان اضطراری ساخته می‌شود.',
        ),
        actions: [
          TextButton(
            key: const Key('restore_confirm_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            key: const Key('restore_confirm_apply'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('بازیابی'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _restore({String? passphrase}) async {
    setState(() => busy = true);
    List<Map<String, dynamic>>? previousTasks;
    List<ProjectPlan>? previousProjects;
    List<ExternalCalendarEventLink>? previousCalendarLinks;
    List<String>? previousCategories;
    List<String>? previousTags;
    List<PersonReference>? previousPeople;
    Map<String, dynamic>? previousSettings;
    try {
      final candidate = await manager.restoreCanonicalBackup(
        passphrase: passphrase,
      );
      if (candidate == null) return;
      if (candidate.settings != null) {
        settingsService.decodePortableJson(candidate.settings!);
        final rawSchedule = candidate.settings!['backupSchedule'];
        if (rawSchedule != null && rawSchedule is! Map) {
          throw const FormatException('Arvin backup schedule settings are invalid');
        }
        if (rawSchedule is Map) {
          BackupSchedule.decodePortableJson(
            Map<String, dynamic>.from(rawSchedule),
          );
        }
        final rawDailyContent = candidate.settings!['dailyContentPreferences'];
        if (rawDailyContent != null && rawDailyContent is! Map) {
          throw const FormatException('Daily Content preferences are invalid');
        }
        if (rawDailyContent is Map) {
          DailyContentPreferencesService.validatePortableJson(
            Map<String, dynamic>.from(rawDailyContent),
          );
        }
      }
      if (!mounted) return;
      final confirmed = await _confirmRestore(
        candidate.tasks.length,
        hasSettings: candidate.settings != null,
        hasCalendarLinks: candidate.calendarLinks != null,
      );
      if (!confirmed || !mounted) return;

      // Snapshot every store this restore flow can mutate before the first write.
      final tasksBeforeRestore = (await widget.loadTasks())
          .map((value) => Map<String, dynamic>.from(value))
          .toList(growable: false);
      previousTasks = tasksBeforeRestore;
      previousProjects = await ProjectStore().load();
      previousCalendarLinks = await ExternalCalendarLinkStore().load();
      previousCategories = await TaskStore().loadCategories();
      previousTags = await TaskStore().loadTags();
      previousPeople = await TaskStore().loadPeopleDirectory();
      previousSettings = await _portableBackupSettings();
      final currentTasks = tasksBeforeRestore
          .map((value) => Task.fromJson(value))
          .toList(growable: false);
      final emergencyBackup = await manager.backupCanonicalTasks(
        currentTasks,
        settings: previousSettings,
        projects: await ProjectStore().load(),
        calendarLinks: previousCalendarLinks,
        categories: previousCategories,
        tags: previousTags,
        people: previousPeople,
      );
      if (emergencyBackup == null) {
        if (mounted) {
          _message(
            'برای حفظ اطلاعات فعلی، پشتیبان اضطراری ساخته نشد؛ بازیابی لغو شد',
          );
        }
        return;
      }

      final backupTaskIds = candidate.tasks.map((task) => task.id).toSet();
      final localOnlyTaskIds = currentTasks
          .map((task) => task.id)
          .where((id) => !backupTaskIds.contains(id))
          .toSet();
      final reconciledTasks = ArvinBackupManager.reconcileTasksById(
        current: currentTasks,
        backup: candidate.tasks,
      );
      final reconciledProjects = candidate.hasProjects
          ? ArvinBackupManager.reconcileProjectsById(
              current: previousProjects,
              backup: candidate.projects,
              localOnlyTaskIds: localOnlyTaskIds,
            )
          : previousProjects;
      final reconciledPeople = candidate.hasPeople
          ? ArvinBackupManager.reconcilePeopleById(
              current: previousPeople,
              backup: candidate.people ?? const <PersonReference>[],
            )
          : previousPeople;

      await runRestoreWithRollback<void>(
        recoveryBackup: emergencyBackup,
        apply: () async {
          await widget.replaceTasks(
            reconciledTasks.map((task) => task.toJson()).toList(growable: false),
          );
          await widget.restoreStageHook?.call('tasks');
          if (candidate.hasProjects) {
            await ProjectStore().save(reconciledProjects);
          }
          await widget.restoreStageHook?.call('projects');
          await ExternalCalendarLinkStore().restoreForTasks(
            restoredTaskIds: candidate.tasks.map((task) => task.id),
            backupLinks: candidate.calendarLinks ?? const [],
            currentLinks: previousCalendarLinks!,
          );
          await widget.restoreStageHook?.call('calendar-links');
          if (candidate.settings != null) {
            final mergedSettings = AppSettingsService.mergePortableJson(
              current: previousSettings!,
              incoming: candidate.settings!,
            );
            await settingsService.restorePortableJson(mergedSettings);
            final rawSchedule = mergedSettings['backupSchedule'];
            if (rawSchedule is Map) {
              final restoredSchedule = BackupSchedule.decodePortableJson(
                Map<String, dynamic>.from(rawSchedule),
              );
              await restoredSchedule.save();
            }
            final rawDailyContent = mergedSettings['dailyContentPreferences'];
            if (rawDailyContent is Map) {
              await DailyContentPreferencesService().restorePortableJson(
                Map<String, dynamic>.from(rawDailyContent),
              );
            }
          }
          await widget.restoreStageHook?.call('settings');
          // TaskStore commits both catalogs together; they are applied last.
          await TaskStore().mergeCatalogs(
            categories: candidate.categories ?? const <String>[],
            tags: candidate.tags ?? const <String>[],
          );
          await widget.restoreStageHook?.call('catalogs');
          if (candidate.hasPeople) {
            await TaskStore().savePeopleDirectory(reconciledPeople);
          }
          await widget.restoreStageHook?.call('people-directory');
        },
        rollback: () async {
          await widget.replaceTasks(previousTasks!);
          await ProjectStore().save(previousProjects!);
          await ExternalCalendarLinkStore().save(previousCalendarLinks!);
          await settingsService.restorePortableJson(previousSettings!);
          final oldSchedule = previousSettings!['backupSchedule'];
          if (oldSchedule is Map) {
            await BackupSchedule.decodePortableJson(
              Map<String, dynamic>.from(oldSchedule),
            ).save();
          }
          final oldDailyContent = previousSettings!['dailyContentPreferences'];
          if (oldDailyContent is Map) {
            await DailyContentPreferencesService().restorePortableJson(
              Map<String, dynamic>.from(oldDailyContent),
            );
          }
          for (final category in (candidate.categories ?? const <String>[])
              .map((value) => value.trim()).toSet()) {
            if (!previousCategories!.contains(category)) {
              await TaskStore().deleteCategoryCatalog(category);
            }
          }
          for (final tag in (candidate.tags ?? const <String>[])
              .map((value) => value.trim()).toSet()) {
            if (!previousTags!.contains(tag)) {
              await TaskStore().deleteTagCatalog(tag);
            }
          }
          await TaskStore().savePeopleDirectory(previousPeople!);
        },
      );
      if (mounted) {
        _message(
          'بازیابی انجام شد: اطلاعات هم‌شناسه به‌روز شد، موارد پشتیبان اضافه شد و اطلاعات فقط-محلی حفظ شد${candidate.settings == null ? '؛ تنظیمات فعلی حفظ شدند' : '؛ تنظیمات موجود در پشتیبان اعمال شدند'}${candidate.calendarLinks == null ? '؛ پیوندهای فعلی تقویم حفظ شدند' : '؛ پیوندهای تقویم ادغام شدند'}${candidate.hasPeople ? '؛ فهرست افراد بازیابی شد' : '؛ فهرست افراد فعلی حفظ شد'}',
        );
      }
    } catch (error) {
      if (mounted) {
        if (error is RestoreExecutionFailure) {
          _message(
            error.rolledBack
                ? 'بازیابی کامل نشد؛ اطلاعات قبلی به حالت پیشین بازگردانده شد.'
                : 'بازیابی کامل نشد و بازگردانی خودکار هم کامل نشد؛ فایل پشتیبان اضطراری را نگه دارید و از همین صفحه بازیابی کنید: ${error.recoveryBackup}',
          );
        } else {
          _message(
            passphrase == null
                ? 'بازیابی از فایل پشتیبان انجام نشد؛ اطلاعات قبلی دست‌نخورده باقی ماند.'
                : 'بازیابی رمزگذاری‌شده انجام نشد؛ رمز نادرست است یا فایل معتبر نیست',
          );
        }
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _restoreEncrypted() async {
    final passphrase = await _requestRestorePassphrase();
    if (passphrase == null || !mounted) return;
    await _restore(passphrase: passphrase);
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پشتیبان‌گیری و بازیابی')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('پوشه پشتیبان'),
              subtitle: Text(
                directory == null ? 'انتخاب نشده است' : 'پوشه انتخاب شده است',
              ),
              trailing: const Icon(Icons.chevron_left),
              onTap: busy ? null : _chooseDirectory,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              key: const Key('backup_encryption_toggle'),
              secondary: const Icon(Icons.lock_outline),
              value: encryptBackup,
              onChanged: busy
                  ? null
                  : (value) => setState(() => encryptBackup = value),
              title: const Text('رمزگذاری پشتیبان'),
              subtitle: const Text(
                'اختیاری؛ رمز فقط برای همین عملیات استفاده می‌شود و ذخیره نمی‌شود.',
              ),
            ),
          ),
          if (encryptBackup) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.warning_amber_rounded),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'رمز را در جای امن نگه دارید. بدون آن، بازیابی فایل رمزگذاری‌شده ممکن نیست.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('create_backup_button'),
            onPressed: busy ? null : _backup,
            icon: Icon(encryptBackup ? Icons.lock : Icons.backup_outlined),
            label: Text(
              encryptBackup ? 'ایجاد پشتیبان رمزگذاری‌شده' : 'ایجاد پشتیبان',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('restore_plain_backup_button'),
            onPressed: busy ? null : _restore,
            icon: const Icon(Icons.restore),
            label: const Text('بازیابی از فایل پشتیبان'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('restore_encrypted_backup_button'),
            onPressed: busy ? null : _restoreEncrypted,
            icon: const Icon(Icons.lock_open_outlined),
            label: const Text('بازیابی فایل رمزگذاری‌شده'),
          ),
          if (busy) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 20),
          const Text(
            'فایل پشتیبان قابل انتقال به گوشی دیگر است. برای فایل رمزگذاری‌شده، رمز فقط نزد شماست و آروین آن را ذخیره نمی‌کند.',
          ),
        ],
      ),
    );
  }
}
