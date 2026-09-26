import 'package:flutter/material.dart';

import 'backup_schedule_page.dart';
import 'calendar_integration_settings_page.dart';
import 'projects_launcher.dart';
import 'services/app_settings_service.dart';
import 'theme/app_fonts.dart';
import 'task_taxonomy_management_page.dart';
import 'user_guide_page.dart';
import 'widgets/contextual_help.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.service, required this.onSettingsChanged, required this.onOpenBackup, this.onOpenBackupSchedule, this.onStartInteractiveGuide});
  final AppSettingsService service;
  final ValueChanged<AppSettings> onSettingsChanged;
  final VoidCallback onOpenBackup;
  final VoidCallback? onOpenBackupSchedule;
  final VoidCallback? onStartInteractiveGuide;
  @override State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _backupHelpSteps = <ContextualHelpStep>[
    ContextualHelpStep(icon: Icons.folder_outlined, title: 'اول پوشه را انتخاب کنید', body: 'یک پوشه امن برای فایل‌های پشتیبان انتخاب کنید تا آروین بداند نسخه‌ها را کجا نگه دارد.'),
    ContextualHelpStep(icon: Icons.backup_outlined, title: 'پشتیبان بسازید', body: 'گزینه «ایجاد Backup» یک نسخه قابل انتقال از اطلاعات فعلی شما می‌سازد.'),
    ContextualHelpStep(icon: Icons.lock_outline, title: 'رمزگذاری اختیاری است', body: 'اگر از پشتیبان رمزگذاری‌شده استفاده می‌کنید، رمز را جای امن نگه دارید؛ آروین آن را ذخیره نمی‌کند.'),
    ContextualHelpStep(icon: Icons.restore, title: 'بازیابی با دقت', body: 'برای برگرداندن اطلاعات، فایل درست را انتخاب کنید. آروین قبل از جایگزینی اطلاعات مسیر بازیابی را کنترل می‌کند.'),
  ];
  AppSettings? settings;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final value = await widget.service.load(); if (!mounted) return; setState(() => settings = value); }
  Future<void> _setTheme(ThemeMode mode) async { final current = settings; if (current == null) return; await widget.service.saveThemeMode(mode); final next = current.copyWith(themeMode: mode); if (!mounted) return; setState(() => settings = next); widget.onSettingsChanged(next); }
  Future<void> _setPersianDate(bool value) async { final current = settings; if (current == null) return; await widget.service.saveUsePersianDate(value); final next = current.copyWith(usePersianDate: value); if (!mounted) return; setState(() => settings = next); widget.onSettingsChanged(next); }
  Future<void> _setFontFamily(String? family) async { final current = settings; if (current == null) return; await widget.service.saveFontFamily(family); final next = current.copyWith(fontFamily: family, clearFontFamily: family == null); if (!mounted) return; setState(() => settings = next); widget.onSettingsChanged(next); }
  Future<void> _showFontPicker() async {
    final current = settings;
    if (current == null) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('انتخاب فونت'),
        content: RadioGroup<String>(
          groupValue: current.fontFamily ?? 'system',
          onChanged: (value) { if (value != null) Navigator.of(context).pop(value); },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(value: 'VazirHarf', title: Text('VazirHarf'), subtitle: Text('فونت پیش‌فرض و عمومی آروین')),
              RadioListTile<String>(value: 'system', title: Text('فونت دستگاه'), subtitle: Text('بدون افزودن فونت جدید به برنامه')),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return;
    await _setFontFamily(choice == 'system' ? null : AppFonts.vazirharfFamily);
  }
  Future<void> _setSwipeAction({required bool rightSide, required TaskSwipeAction action}) async { final current = settings; if (current == null) return; final next = rightSide ? current.copyWith(swipeRightAction: action) : current.copyWith(swipeLeftAction: action); await widget.service.saveSwipeActions(right: next.swipeRightAction, left: next.swipeLeftAction); if (!mounted) return; setState(() => settings = next); widget.onSettingsChanged(next); }
  String _swipeActionLabel(TaskSwipeAction action) => switch (action) { TaskSwipeAction.archive => 'بایگانی', TaskSwipeAction.trash => 'سطل زباله', TaskSwipeAction.moveToToday => 'انتقال به امروز', TaskSwipeAction.none => 'بدون عمل' };
  IconData _swipeActionIcon(TaskSwipeAction action) => switch (action) { TaskSwipeAction.archive => Icons.archive_outlined, TaskSwipeAction.trash => Icons.delete_outline, TaskSwipeAction.moveToToday => Icons.today_outlined, TaskSwipeAction.none => Icons.block };
  List<DropdownMenuItem<TaskSwipeAction>> _swipeItems() => TaskSwipeAction.values.map((action) => DropdownMenuItem<TaskSwipeAction>(value: action, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_swipeActionIcon(action), size: 20), const SizedBox(width: 8), Text(_swipeActionLabel(action))]))).toList();
  Future<void> _openUserGuide() async { await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => const UserGuidePage())); }
  Future<void> _openBackupSchedule() async { await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => BackupSchedulePage())); }
  Future<void> _openCalendarIntegrationSettings() async { await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => CalendarIntegrationSettingsPage(service: widget.service))); await _load(); }
  Future<void> _openProjectsManagement() async { await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => const ProjectsLauncher())); }
  Future<void> _openTaxonomyManagement() async { await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => const TaskTaxonomyManagementPage())); }
  Future<void> _showBackupHelp() => showContextualHelp(context, title: 'راهنمای پشتیبان‌گیری', steps: _backupHelpSteps);
  @override Widget build(BuildContext context) {
    final current = settings;
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: const Text('تنظیمات')), body: current == null ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
      const Text('ظاهر و نمایش', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      SegmentedButton<ThemeMode>(segments: const [ButtonSegment(value: ThemeMode.system, label: Text('سیستم'), icon: Icon(Icons.settings_suggest_outlined)), ButtonSegment(value: ThemeMode.light, label: Text('روشن'), icon: Icon(Icons.light_mode_outlined)), ButtonSegment(value: ThemeMode.dark, label: Text('تیره'), icon: Icon(Icons.dark_mode_outlined))], selected: {current.themeMode}, onSelectionChanged: (selection) => _setTheme(selection.first)),
      const SizedBox(height: 16), SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('نمایش تاریخ فارسی'), subtitle: const Text('تاریخ فارسی پیش‌فرض آروین است؛ انتخاب تاریخ پیگیری همیشه با تقویم شمسی انجام می‌شود.'), value: current.usePersianDate, onChanged: _setPersianDate),
      const SizedBox(height: 20), const Divider(height: 32), const Text('کارها و حرکت کارت‌ها', key: ValueKey('swipe-settings-title'), style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('عمل کشیدن کارت به راست و چپ را جداگانه تعیین کنید.'), const SizedBox(height: 12),
      DropdownButtonFormField<TaskSwipeAction>(key: const ValueKey('swipe-right-action'), initialValue: current.swipeRightAction, decoration: const InputDecoration(labelText: 'کشیدن به راست', prefixIcon: Icon(Icons.swipe_right_outlined), border: OutlineInputBorder()), items: _swipeItems(), onChanged: (action) { if (action != null) _setSwipeAction(rightSide: true, action: action); }),
      const SizedBox(height: 12), DropdownButtonFormField<TaskSwipeAction>(key: const ValueKey('swipe-left-action'), initialValue: current.swipeLeftAction, decoration: const InputDecoration(labelText: 'کشیدن به چپ', prefixIcon: Icon(Icons.swipe_left_outlined), border: OutlineInputBorder()), items: _swipeItems(), onChanged: (action) { if (action != null) _setSwipeAction(rightSide: false, action: action); }),
      const Divider(height: 32), ListTile(key: const ValueKey('font-settings-entry'), contentPadding: EdgeInsets.zero, leading: const Icon(Icons.text_fields), title: const Text('فونت'), subtitle: Text(current.fontFamily == null ? 'فونت دستگاه' : 'VazirHarf'), trailing: const Icon(Icons.chevron_left), onTap: _showFontPicker),
      const SizedBox(height: 20), const Text('پروژه و دسته‌بندی', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ListTile(key: const ValueKey('projects-settings-entry'), contentPadding: EdgeInsets.zero, leading: const Icon(Icons.account_tree_outlined), title: const Text('پروژه‌ها'), subtitle: const Text('ساخت، ویرایش، بایگانی و حذف امن پروژه‌ها'), trailing: const Icon(Icons.chevron_left), onTap: _openProjectsManagement),
      const Divider(height: 24), ListTile(key: const ValueKey('taxonomy-settings-entry'), contentPadding: EdgeInsets.zero, leading: const Icon(Icons.sell_outlined), title: const Text('دسته‌ها و برچسب‌ها'), subtitle: const Text('تغییر نام و حذف امن روی همان کارها و یادداشت‌ها'), trailing: const Icon(Icons.chevron_left), onTap: _openTaxonomyManagement),
      const SizedBox(height: 20), const Text('تقویم و همگام‌سازی', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ListTile(key: const ValueKey('calendar-integration-settings-entry'), contentPadding: EdgeInsets.zero, leading: const Icon(Icons.sync_outlined), title: const Text('تقویم و همگام‌سازی'), subtitle: Text(current.calendarIntegration.enabled ? 'اتصال تقویم دستگاه فعال است' : 'اتصال تقویم دستگاه خاموش است'), trailing: const Icon(Icons.chevron_left), onTap: _openCalendarIntegrationSettings),
      const SizedBox(height: 20), const Text('عمومی و پشتیبان‌گیری', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.menu_book_outlined), title: const Text('راهنمای استفاده'), subtitle: const Text('آموزش ساده و مرحله‌به‌مرحله کار با آروین'), trailing: const Icon(Icons.chevron_left), onTap: _openUserGuide),
      if (widget.onStartInteractiveGuide != null) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.slideshow_outlined), title: const Text('راهنمای تعاملی صفحه اصلی'), subtitle: const Text('دکمه‌های مهم را روی خود صفحه اصلی یکی‌یکی معرفی می‌کند'), trailing: const Icon(Icons.play_arrow_rounded), onTap: widget.onStartInteractiveGuide),
      ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule_outlined), title: const Text('زمان‌بندی پشتیبان‌گیری'), subtitle: const Text('روزانه، هفتگی یا ماهانه'), trailing: const Icon(Icons.chevron_left), onTap: widget.onOpenBackupSchedule ?? _openBackupSchedule),
      ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.backup_outlined), title: const Text('پشتیبان‌گیری و بازیابی'), subtitle: const Text('استفاده از مسیر موجود Backup/Restore آروین'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(key: const ValueKey('backup-context-help'), tooltip: 'راهنمای پشتیبان‌گیری', onPressed: _showBackupHelp, icon: const Icon(Icons.help_outline)), const Icon(Icons.chevron_left)]), onTap: widget.onOpenBackup),
    ])));
  }
}