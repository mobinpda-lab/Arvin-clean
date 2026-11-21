import 'dart:convert';
import 'dart:io';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('independent historical v8 DDL fixture matches fingerprint and executes all tables', () async {
    final fixture = File(
      'test/fixtures/database/historical/v8_schema.sql',
    );
    final bytes = await fixture.readAsBytes();
    final fingerprint = (await Sha256().hash(bytes))
        .bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    expect(
      fingerprint,
      '9a11f8952cf1d11bebd020a785021e7f051410580762a6b78276b7b0f89dc2ba',
    );

    final database = NativeDatabase.memory();
    try {
      // Open only the low-level executor. No current-schema installer is run;
      // every application table below comes from the historical SQL fixture.
      await database.ensureOpen(G1DriftSchema());
      final sql = utf8.decode(bytes);
      final statements = sql.split(';').map((raw) {
        final sourceLines = raw
            .split('\n')
            .where((line) => !line.trimLeft().startsWith('--'));
        return sourceLines.join('\n').trim();
      }).where((statement) => statement.isNotEmpty);
      for (final statement in statements) {
        await database.runCustom(statement);
      }

      final tables = await database.runSelect(
        """SELECT name FROM sqlite_master
           WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
           ORDER BY name""",
        const [],
      );
      expect(tables.map((row) => row['name']), <String>[
        'arvin_storage_meta',
        'centers',
        'checklist_items',
        'follow_up_people',
        'follow_ups',
        'people',
        'project_items',
        'project_template_tasks',
        'project_templates',
        'projects',
        'tags',
        'task_people',
        'task_tags',
        'tasks',
        'taxonomy_categories',
        'template_task_applications',
      ]);

      final projectCenterForeignKey = await database.runSelect(
        "PRAGMA foreign_key_list('projects')",
        const [],
      );
      expect(
        projectCenterForeignKey.any(
          (row) => row['table'] == 'centers' && row['from'] == 'center_id',
        ),
        isTrue,
      );
      final templateForeignKey = await database.runSelect(
        "PRAGMA foreign_key_list('project_template_tasks')",
        const [],
      );
      expect(
        templateForeignKey.any(
          (row) => row['table'] == 'project_templates',
        ),
        isTrue,
      );

      final partialIndex = await database.runSelect(
        """SELECT sql FROM sqlite_master
           WHERE type = 'index'
             AND name = 'idx_projects_active_template_center'""",
        const [],
      );
      expect(partialIndex, hasLength(1));
      expect(partialIndex.single['sql'], contains(' WHERE '));
      expect(
        partialIndex.single['sql'],
        contains('is_archived = 0'),
      );
    } finally {
      await database.close();
    }
  });
}
