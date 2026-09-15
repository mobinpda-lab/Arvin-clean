from pathlib import Path

path = Path('.github/scripts/apply_calendar_1032.py')
text = path.read_text(encoding='utf-8')
old = '''replace_count(\n    "lib/calendar_page.dart",\n    """                      onTap: () => _selectDay(date),\\n""",\n    """                      onTap: () => _selectDay(date),\\n                      onLongPress: widget.onCreateTaskForDate == null\\n                          ? null\\n                          : () => widget.onCreateTaskForDate!(date),\\n""",\n    2,\n)\n'''
new = '''replace_once(\n    "lib/calendar_page.dart",\n    """                      onTap: () => _selectDay(date),\\n""",\n    """                      onTap: () => _selectDay(date),\\n                      onLongPress: widget.onCreateTaskForDate == null\\n                          ? null\\n                          : () => widget.onCreateTaskForDate!(date),\\n""",\n)\nreplace_once(\n    "lib/calendar_page.dart",\n    """                  key: ValueKey('calendar-month-day-$day'),\\n                  borderRadius: BorderRadius.circular(10),\\n                  onTap: () => _selectDay(date),\\n                  child: Container(\\n""",\n    """                  key: ValueKey('calendar-month-day-$day'),\\n                  borderRadius: BorderRadius.circular(10),\\n                  onTap: () => _selectDay(date),\\n                  onLongPress: widget.onCreateTaskForDate == null\\n                      ? null\\n                      : () => widget.onCreateTaskForDate!(date),\\n                  child: Container(\\n""",\n)\n'''
if text.count(old) != 1:
    raise SystemExit(f'expected old matcher once, found {text.count(old)}')
path.write_text(text.replace(old, new, 1), encoding='utf-8')
