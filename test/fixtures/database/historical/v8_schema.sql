-- Independent historical SQLite v8 fixture DDL.

-- Source commit: 874dd8b567fdceae7ed62f01a93804dcea1a5473

-- Source blob: f4d488fa3f972c4ce123df6089b66569b9c8849c

-- Extracted from lib/services/g1_drift_schema.dart; not generated from current schema.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS tasks (
  id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0, title TEXT NOT NULL, description TEXT NOT NULL,
  created_at TEXT NULL, updated_at TEXT NULL, due_date TEXT NULL,
  follow_up_enabled INTEGER NOT NULL, follow_up_date TEXT NULL, category TEXT NULL,
  notebook_kind TEXT NULL, reminder_date TEXT NULL, priority TEXT NOT NULL,
  archived INTEGER NOT NULL, trashed INTEGER NOT NULL, completed INTEGER NOT NULL,
  completed_at TEXT NULL, recurrence_json TEXT NULL, legacy_payload_json TEXT NULL);

CREATE TABLE IF NOT EXISTS follow_ups (
  id TEXT NOT NULL PRIMARY KEY, task_id TEXT NOT NULL REFERENCES tasks(id),
  date_time TEXT NOT NULL, title TEXT NULL, note TEXT NOT NULL, result TEXT NULL,
  reminder_date TEXT NULL, next_follow_up TEXT NULL, completed INTEGER NOT NULL,
  waiting_for_response INTEGER NOT NULL DEFAULT 0,
  ordinal INTEGER NOT NULL, UNIQUE (task_id, ordinal));

CREATE TABLE IF NOT EXISTS centers (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  is_archived INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS project_templates (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  is_archived INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS project_template_tasks (
  id TEXT NOT NULL PRIMARY KEY, template_id TEXT NOT NULL REFERENCES project_templates(id),
  title TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', category TEXT NULL,
  tags_json TEXT NOT NULL DEFAULT '[]', checklist_json TEXT NOT NULL DEFAULT '[]', ordinal INTEGER NOT NULL,
  UNIQUE(template_id, ordinal));

CREATE TABLE IF NOT EXISTS projects (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  color_value INTEGER NOT NULL DEFAULT 4283059371, is_archived INTEGER NOT NULL DEFAULT 0,
  center_id TEXT NULL REFERENCES centers(id), template_id TEXT NULL,
  template_name_snapshot TEXT NULL, legacy_payload_json TEXT NULL);

CREATE TABLE IF NOT EXISTS project_items (
  project_id TEXT NOT NULL REFERENCES projects(id), task_id TEXT NOT NULL REFERENCES tasks(id),
  ordinal INTEGER NOT NULL, PRIMARY KEY (project_id, task_id));

CREATE TABLE IF NOT EXISTS template_task_applications (
  template_task_id TEXT NOT NULL, project_id TEXT NOT NULL REFERENCES projects(id),
  task_id TEXT NOT NULL UNIQUE REFERENCES tasks(id), PRIMARY KEY(template_task_id, project_id));

CREATE TABLE IF NOT EXISTS taxonomy_categories (
  name TEXT NOT NULL PRIMARY KEY, created_at TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS tags (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS task_tags (
  task_id TEXT NOT NULL REFERENCES tasks(id), tag_id TEXT NOT NULL REFERENCES tags(id),
  ordinal INTEGER NOT NULL, PRIMARY KEY (task_id, tag_id));

CREATE TABLE IF NOT EXISTS checklist_items (
  task_id TEXT NOT NULL REFERENCES tasks(id), ordinal INTEGER NOT NULL,
  value TEXT NOT NULL, PRIMARY KEY (task_id, ordinal));

CREATE TABLE IF NOT EXISTS task_people (
  task_id TEXT NOT NULL REFERENCES tasks(id), person_id TEXT NOT NULL,
  person_json TEXT NOT NULL, ordinal INTEGER NOT NULL, PRIMARY KEY (task_id, person_id));

CREATE TABLE IF NOT EXISTS people (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS follow_up_people (
  follow_up_id TEXT NOT NULL REFERENCES follow_ups(id), person_id TEXT NOT NULL,
  ordinal INTEGER NOT NULL, PRIMARY KEY (follow_up_id, person_id));

CREATE TABLE IF NOT EXISTS arvin_storage_meta (
  key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);

CREATE UNIQUE INDEX IF NOT EXISTS idx_projects_active_template_center ON projects(template_id, center_id) WHERE template_id IS NOT NULL AND center_id IS NOT NULL AND is_archived = 0;
