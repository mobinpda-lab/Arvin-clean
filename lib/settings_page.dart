import 'package:flutter/material.dart';

import 'services/app_settings_service.dart';
import 'user_guide_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.service,
    required this.onSettingsChanged,
    required this.onOpenBackup,
    this.onStartInteractiveGuide,
  });

  final AppSettingsService service;
  final ValueChanged<AppSettings> onSettingsChanged;
  final VoidCallback onOpenBackup;
  final VoidCallback? onStartInteractiveGuide;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AppSettings? settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await widget.service.load();
    if (!mounted) return;
    setState(() => settings = value);
  }

  Future<void> _setTheme(ThemeMode mode) async {
    final current = settings;
    if (current == null) return;
    await widget.service.saveThemeMode(mode);
    final next = current.copyWith(themeMode: mode);
    if (!mounted) return;
    setState(() => settings = next);
    widget.onSettingsChanged(next);
  }

  Future<void> _setPersianDate(bool value) async {
    final current = settings;
    if (current == null) return;
    await widget.service.saveUsePersianDate(value);
    final next = current.copyWith(usePersianDate: value);
    if (!mounted) return;
    setState(() => settings = next);
    widget.onSettingsChanged(next);
  }

  Future<void> _openUserGuide() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const UserGuidePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = settings;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تنظیمات')),
        body: current == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'نمایش',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('سیستم'),
                        icon: Icon(Icons.settings_suggest_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('روشن'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('تیره'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {current.themeMode},
                    onSelectionChanged: (selection) =>
                        _setTheme(selection.first),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('نمایش تاریخ فارسی'),
                    subtitle: const Text(
                      'ترجیح نمایش تاریخ را برای مسیرهای پشتیبانی‌شده نگه می‌دارد.',
                    ),
                    value: current.usePersianDate,
                    onChanged: _setPersianDate,
                  ),
                  const Divider(height: 32),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.text_fields),
                    title: const Text('فونت'),
                    subtitle: const Text(
                      'وزیرمتن فونت عمومی و پیش‌فرض آروین است؛ فونت دارای مجوز فقط از همین تنظیمات قابل توسعه خواهد بود.',
                    ),
                  ),
                  const Divider(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.menu_book_outlined),
                    title: const Text('راهنمای استفاده'),
                    subtitle: const Text('آموزش ساده و مرحله‌به‌مرحله کار با آروین'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: _openUserGuide,
                  ),
                  if (widget.onStartInteractiveGuide != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.slideshow_outlined),
                      title: const Text('راهنمای تعاملی صفحه اصلی'),
                      subtitle: const Text(
                        'دکمه‌های مهم را روی خود صفحه اصلی یکی‌یکی معرفی می‌کند',
                      ),
                      trailing: const Icon(Icons.play_arrow_rounded),
                      onTap: widget.onStartInteractiveGuide,
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('پشتیبان‌گیری و بازیابی'),
                    subtitle: const Text('استفاده از مسیر موجود Backup/Restore آروین'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: widget.onOpenBackup,
                  ),
                ],
              ),
      ),
    );
  }
}
