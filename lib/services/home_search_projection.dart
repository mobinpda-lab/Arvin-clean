import '../models/task.dart';
import 'task_search_service.dart';

/// Bridges canonical Task search results back to the transitional Home view by
/// stable task id. This keeps SearchService on the unified model without
/// introducing a parallel repository, storage path, or search engine.
class HomeSearchProjection {
  const HomeSearchProjection({this.searchService = const TaskSearchService()});

  final TaskSearchService searchService;

  Set<String> matchingIds(Iterable<Task> canonicalTasks, String query) {
    return searchService
        .search(canonicalTasks, query)
        .map((task) => task.id)
        .toSet();
  }
}
