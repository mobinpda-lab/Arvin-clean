import 'package:arvin/models/task.dart';
import 'package:arvin/services/today_focus_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('focus selection is explicit and independent from due-today', () {
    final dueTodayNotSelected = Task(
      id: 'due-today',
      title: 'موعد امروز',
      dueDate: DateTime(2026, 11, 8, 9),
    );
    final selectedDueLater = Task(
      id: 'selected-later',
      title: 'برگزیده با موعد آینده',
      dueDate: DateTime(2026, 11, 12, 9),
      isSelectedForToday: true,
    );
    final favoriteOnly = Task(
      id: 'favorite-only',
      title: 'فقط علاقه‌مندی',
      isFavorite: true,
    );
    final archived = Task(
      id: 'archived',
      title: 'بایگانی',
      isSelectedForToday: true,
      archived: true,
    );
    final trashed = Task(
      id: 'trashed',
      title: 'حذف‌شده',
      isSelectedForToday: true,
      trashed: true,
    );

    final result = const TodayFocusProjection().select([
      dueTodayNotSelected, favoriteOnly, selectedDueLater, archived, trashed,
    ]);

    expect(result.map((task) => task.id), ['selected-later']);
  });
}
