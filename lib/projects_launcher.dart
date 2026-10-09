import 'package:flutter/material.dart';

import 'models/goal_project.dart';
import 'projects_page.dart';
import 'services/project_store.dart';
import 'services/arvin_route_observer.dart';

/// Loads the canonical Project collection before opening the existing
/// [ProjectsPage], then persists every Project lifecycle change through the
/// single canonical [ProjectStore].
class ProjectsLauncher extends StatefulWidget {
  const ProjectsLauncher({
    super.key,
    this.store,
  });

  final ProjectStore? store;

  @override
  State<ProjectsLauncher> createState() => _ProjectsLauncherState();
}

class _ProjectsLauncherState extends State<ProjectsLauncher> with RouteAware {
  ModalRoute<void>? _route;
  late final ProjectStore _store = widget.store ?? ProjectStore();
  List<ProjectPlan>? _projects;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route == null || route == _route) return;
    if (_route != null) arvinRouteObserver.unsubscribe(this);
    _route = route;
    arvinRouteObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    _load();
  }

  @override
  void dispose() {
    arvinRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final projects = await _store.load();
      if (!mounted) return;
      setState(() {
        _projects = List<ProjectPlan>.of(projects);
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _projects = null;
        _loadError = error;
      });
    }
  }

  Future<void> _persist(List<ProjectPlan> projects) async {
    final snapshot = List<ProjectPlan>.of(projects);
    // Do not publish the optimistic list as saved. The page awaits this
    // Future and only commits its visible state after SQLite confirms success.
    await _store.save(snapshot);
    if (!mounted) return;
    setState(() => _projects = snapshot);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('پروژه‌ها')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('خواندن پروژه‌ها انجام نشد.'),
              const SizedBox(height: 12),
              FilledButton.tonal(
                key: const ValueKey('projects-retry-load'),
                onPressed: _load,
                child: const Text('تلاش دوباره'),
              ),
            ],
          ),
        ),
      );
    }

    final projects = _projects;
    if (projects == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ProjectsPage(
      projects: projects,
      onChanged: (next) {
        _persist(next);
      },
    );
  }
}
