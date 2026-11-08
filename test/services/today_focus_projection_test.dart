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
  test('focusDate is a date-only canonical value and expires after the local day', () {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    final selectedYesterday = Task(
      id: 'yesterday-focus',
      title: 'انتخاب روز قبل',
      focusDate: yesterday,
      dueDate: DateTime(2031, 4, 12, 8),
      isFavorite: true,
    );

    expect(selectedYesterday.isSelectedForToday, isFalse);
    final json = selectedYesterday.toJson();
    expect(json['focusDate'], isA<String>());
    expect(json.containsKey('isSelectedForToday'), isFalse);

    final restored = Task.fromJson(json);
    expect(restored.focusDate, yesterday);
    expect(restored.isSelectedForToday, isFalse);
    expect(restored.dueDate, selectedYesterday.dueDate);
    expect(restored.isFavorite, isTrue);
  });

  test('legacy boolean focus payload migrates to one date-only value', () {
    final migrated = Task.fromJson({
      'id': 'legacy-focus',
      'title': 'انتخاب قدیمی',
      'isSelectedForToday': true,
    });

    expect(migrated.isSelectedForToday, isTrue);
    expect(migrated.focusDate, isNotNull);
    expect(migrated.toJson().containsKey('isSelectedForToday'), isFalse);
    expect(migrated.toJson()['focusDate'], isA<String>());
  });

}
