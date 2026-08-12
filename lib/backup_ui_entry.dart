import 'package:flutter/material.dart';

import 'backup_page.dart';

/// Small navigation helper kept separate from the existing home page.
void openBackupPage(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const BackupPage()),
  );
}
