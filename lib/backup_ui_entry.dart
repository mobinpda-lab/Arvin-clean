import 'package:flutter/material.dart';

import 'backup_page.dart';

/// Navigation helper. The caller supplies the app's current task repository
/// callbacks so BackupPage never owns or duplicates task persistence logic.
void openBackupPage(
  BuildContext context, {
  required Future<List<Map<String, dynamic>>> Function() loadTasks,
  required Future<void> Function(List<Map<String, dynamic>> tasks) replaceTasks,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BackupPage(
        loadTasks: loadTasks,
        replaceTasks: replaceTasks,
      ),
    ),
  );
}
