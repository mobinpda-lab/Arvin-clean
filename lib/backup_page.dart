import 'package:flutter/material.dart';

import 'backup_manager.dart';

/// UI for portable Backup/Restore. The page receives the current task data
/// through callbacks so it does not duplicate TaskRepository logic.
class BackupPage extends StatefulWidget {
  const BackupPage({
    super.key,
    required this.loadTasks,
    required this.replaceTasks,
    this.manager,
  });

  final Future<List<Map<String, dynamic>>> Function() loadTasks;
  final Future<void> Function(List<Map<String, dynamic>> tasks) replaceTasks;
  final ArvinBackupManager? manager;

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  late final ArvinBackupManager manager;
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

  Future<void> _restore({String? passphrase}) async {
    setState(() => busy = true);
    try {
      final document = await manager.restoreBackup(passphrase: passphrase);
      if (document == null) return;
      final tasks = (document['tasks'] as List<dynamic>)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      await widget.replaceTasks(tasks);
      if (mounted) _message('اطلاعات با موفقیت بازیابی شد');
    } catch (_) {
      if (mounted) {
        _message(
          passphrase == null
              ? 'بازیابی از فایل پشتیبان انجام نشد'
              : 'بازیابی رمزگذاری‌شده انجام نشد؛ رمز نادرست است یا فایل معتبر نیست',
        );
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
