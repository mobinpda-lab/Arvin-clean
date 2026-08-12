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

  Future<void> _backup() async {
    setState(() => busy = true);
    try {
      final tasks = await widget.loadTasks();
      final fileName = await manager.backupTasks(tasks);
      if (!mounted) return;
      _message(
        fileName == null
            ? 'ابتدا پوشه پشتیبان را انتخاب کنید'
            : 'پشتیبان ساخته شد: $fileName',
      );
    } catch (error) {
      if (mounted) _message('پشتیبان‌گیری ناموفق بود: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => busy = true);
    try {
      final document = await manager.restoreBackup();
      if (document == null) return;
      final tasks = (document['tasks'] as List<dynamic>)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      await widget.replaceTasks(tasks);
      if (mounted) _message('اطلاعات با موفقیت بازیابی شد');
    } catch (error) {
      if (mounted) _message('بازیابی ناموفق بود: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
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
          FilledButton.icon(
            onPressed: busy ? null : _backup,
            icon: const Icon(Icons.backup_outlined),
            label: const Text('ایجاد پشتیبان'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: busy ? null : _restore,
            icon: const Icon(Icons.restore),
            label: const Text('بازیابی از فایل پشتیبان'),
          ),
          if (busy) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 20),
          const Text(
            'فایل پشتیبان قابل انتقال به گوشی دیگر است و برای بازیابی باید فایل JSON پشتیبان را انتخاب کنید.',
          ),
        ],
      ),
    );
  }
}
