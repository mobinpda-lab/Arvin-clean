import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'g1_drift_schema.dart';
import 'project_plan_codec.dart';
import 'project_store.dart';

/// One-way migration writer for the canonical ProjectPlan storage.
///
/// Project membership remains owned by ProjectPlan.itemIds. This migration
/// moves only project metadata and canonical Task-id membership into SQL; it
/// never adds a projectId to Task and never creates a second project store.
class SqlProjectMigrationWriter {
  const SqlProjectMigrationWriter({this.codec = const ProjectPlanCodec()});

  final ProjectPlanCodec codec;

  Future<SqlProjectMigrationReport> migrateFromPreferences({
    required QueryExecutor executor,
    required SharedPreferences preferences,
  }) async {
    await G1DriftSchema.install(executor);

    final raw = preferences.getString(ProjectStore.key);
    if (raw == null || raw.trim().isEmpty) {
      return const SqlProjectMigrationReport();
    }

    final decoded = jsonDecode(raw);
    final projects = codec.decodeList(decoded);
    var inserted = 0;
    var skippedExisting = 0;

    await executor.runCustom('BEGIN');
    try {
      for (final project in projects) {
        final exists = await executor.runSelect(
          'SELECT id FROM projects WHERE id = ? LIMIT 1',
          <Object?>[project.id],
        );
        if (exists.isNotEmpty) {
          skippedExisting++;
          continue;
        }

        await executor.runInsert(
          '''INSERT INTO projects (id, name)
             VALUES (?, ?)''',
          <Object?>[project.id, project.title],
        );

        for (var ordinal = 0; ordinal < project.itemIds.length; ordinal++) {
          await executor.runInsert(
            '''INSERT INTO project_items (project_id, task_id, ordinal)
               VALUES (?, ?, ?)''',
            <Object?>[project.id, project.itemIds[ordinal], ordinal],
          );
        }
        inserted++;
      }

      await executor.runCustom('COMMIT');
    } catch (_) {
      await executor.runCustom('ROLLBACK');
      rethrow;
    }

    final countRows = await executor.runSelect(
      'SELECT COUNT(*) AS count FROM projects',
      const [],
    );

    return SqlProjectMigrationReport(
      sourceCount: projects.length,
      insertedCount: inserted,
      skippedExistingCount: skippedExisting,
      sqlProjectCount: (countRows.single['count'] as num).toInt(),
    );
  }
}

class SqlProjectMigrationReport {
  const SqlProjectMigrationReport({
    this.sourceCount = 0,
    this.insertedCount = 0,
    this.skippedExistingCount = 0,
    this.sqlProjectCount = 0,
  });

  final int sourceCount;
  final int insertedCount;
  final int skippedExistingCount;
  final int sqlProjectCount;
}
