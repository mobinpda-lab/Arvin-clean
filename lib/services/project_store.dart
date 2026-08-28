import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal_project.dart';
import 'project_plan_codec.dart';

/// Canonical local persistence for Arvin Projects.
///
/// Project membership stores only canonical Task ids through [ProjectPlan].
/// This deliberately does not touch TaskStore or duplicate Task payloads.
class ProjectStore {
  ProjectStore({this.codec = const ProjectPlanCodec()});

  static const String key = 'arvin.projects';

  final ProjectPlanCodec codec;

  Future<List<ProjectPlan>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    return codec.decodeList(decoded);
  }

  Future<void> save(Iterable<ProjectPlan> projects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(codec.encodeList(projects)));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
