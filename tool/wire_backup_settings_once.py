from pathlib import Path

path = Path('lib/main.dart')
source = path.read_text()

backup_start = source.index('  Future<void> _backupToFolder() async {')
restore_start = source.index('  Future<void> _restoreFromFile() async {', backup_start)
backup_method = """  Future<void> _backupToFolder() async {
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

"""
source = source[:backup_start] + backup_method + source[restore_start:]

restore_start = source.index('  Future<void> _restoreFromFile() async {')
backup_menu_start = source.index('  Future<void> _backupMenu() async {', restore_start)
restore_method = """  Future<void> _restoreFromFile() async {
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
            'تعداد ${list.length} کار از پشتیبان آماده بازیابی است.\\n'
            '${restoredSettings == null ? 'این پشتیبان تنظیمات برنامه ندارد.' : 'تنظیمات برنامه نیز همراه این پشتیبان بازیابی می‌شود.'}\\n\\n'
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
        if (mounted) {
          widget.onSettingsChanged?.call(restoredSettings);
        }
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

"""
source = source[:restore_start] + restore_method + source[backup_menu_start:]
path.write_text(source)
