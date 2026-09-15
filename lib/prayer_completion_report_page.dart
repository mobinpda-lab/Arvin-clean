import 'package:flutter/material.dart';

import 'services/persian_date_formatter.dart';
import 'services/prayer_completion_projection.dart';
import 'services/prayer_completion_report_projection.dart';
import 'services/prayer_completion_store.dart';
import 'widgets/persian_date_picker.dart';

enum PrayerReportScope { today, week, range }

class PrayerCompletionReportPage extends StatefulWidget {
  const PrayerCompletionReportPage({
    super.key,
    this.store = const PrayerCompletionStore(),
    this.now,
  });

  final PrayerCompletionStore store;
  final DateTime? now;

  @override
  State<PrayerCompletionReportPage> createState() =>
      _PrayerCompletionReportPageState();
}

class _PrayerCompletionReportPageState
    extends State<PrayerCompletionReportPage> {
  static const _formatter = PersianDateFormatter();
  static const _projection = PrayerCompletionReportProjection();

  late Future<List<PrayerCompletionRecord>> _recordsFuture;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;
  PrayerReportScope _scope = PrayerReportScope.today;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    final today = _day(_now);
    _rangeEnd = today;
    _rangeStart = today.subtract(const Duration(days: 29));
    _recordsFuture = widget.store.load();
  }

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

  ({DateTime start, DateTime end}) _activeRange() {
    final today = _day(_now);
    switch (_scope) {
      case PrayerReportScope.today:
        return (start: today, end: today);
      case PrayerReportScope.week:
        final daysSinceSaturday =
            (today.weekday - DateTime.saturday) % DateTime.daysPerWeek;
        final start = today.subtract(Duration(days: daysSinceSaturday));
        return (start: start, end: today);
      case PrayerReportScope.range:
        return (start: _rangeStart, end: _rangeEnd);
    }
  }

  Future<void> _pickStart() async {
    final selected = await showPersianDatePicker(
      context: context,
      initialDate: _rangeStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
      helpText: 'شروع بازه گزارش نماز',
    );
    if (selected == null || !mounted) return;
    setState(() {
      _rangeStart = _day(selected);
      if (_rangeEnd.isBefore(_rangeStart)) _rangeEnd = _rangeStart;
    });
  }

  Future<void> _pickEnd() async {
    final selected = await showPersianDatePicker(
      context: context,
      initialDate: _rangeEnd,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
      helpText: 'پایان بازه گزارش نماز',
    );
    if (selected == null || !mounted) return;
    setState(() {
      _rangeEnd = _day(selected);
      if (_rangeStart.isAfter(_rangeEnd)) _rangeStart = _rangeEnd;
    });
  }

  void _reload() {
    setState(() => _recordsFuture = widget.store.load());
  }

  String _date(DateTime value) =>
      _formatter.format(value, usePersianDate: true);

  String _count(int value) => _formatter.toPersianDigits('$value');

  String _prayerLabel(String prayerId) {
    if (prayerId.endsWith('-fajr')) return 'اذان صبح';
    if (prayerId.endsWith('-dhuhr')) return 'اذان ظهر';
    if (prayerId.endsWith('-asr')) return 'عصر';
    if (prayerId.endsWith('-maghrib')) return 'اذان مغرب';
    if (prayerId.endsWith('-isha')) return 'عشا';
    return 'نماز';
  }

  Widget _summaryCard({
    required Key key,
    required String label,
    required int value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        key: key,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(label),
              const SizedBox(height: 4),
              Text(
                _count(value),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('گزارش نماز'),
          actions: [
            IconButton(
              key: const ValueKey('prayer-report-refresh'),
              tooltip: 'تازه‌سازی',
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: FutureBuilder<List<PrayerCompletionRecord>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: FilledButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('بارگذاری دوباره گزارش'),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final range = _activeRange();
            final summary = _projection.build(
              snapshot.requireData,
              startDay: range.start,
              endDay: range.end,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                SegmentedButton<PrayerReportScope>(
                  key: const ValueKey('prayer-report-scope'),
                  segments: const [
                    ButtonSegment(
                      value: PrayerReportScope.today,
                      label: Text('امروز'),
                    ),
                    ButtonSegment(
                      value: PrayerReportScope.week,
                      label: Text('هفته'),
                    ),
                    ButtonSegment(
                      value: PrayerReportScope.range,
                      label: Text('بازه'),
                    ),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (value) {
                    setState(() => _scope = value.single);
                  },
                ),
                if (_scope == PrayerReportScope.range) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('prayer-report-range-start'),
                          onPressed: _pickStart,
                          icon: const Icon(Icons.date_range_outlined),
                          label: Text('از ${_date(_rangeStart)}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('prayer-report-range-end'),
                          onPressed: _pickEnd,
                          icon: const Icon(Icons.event_outlined),
                          label: Text('تا ${_date(_rangeEnd)}'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  '${_date(summary.startDay)} تا ${_date(summary.endDay)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _summaryCard(
                      key: const ValueKey('prayer-report-completed'),
                      label: 'ادا شد',
                      value: summary.completedCount,
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 8),
                    _summaryCard(
                      key: const ValueKey('prayer-report-missed'),
                      label: 'قضا شد',
                      value: summary.notCompletedCount,
                      icon: Icons.history_toggle_off_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'نمازهای قضا شده',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (summary.missed.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'نماز قضاشده‌ای در این بازه ثبت نشده است',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  for (final record in summary.missed)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.history_toggle_off_outlined),
                        title: Text(_prayerLabel(record.prayerId)),
                        subtitle: Text(_date(record.localDay)),
                        trailing: const Text('قضا شد'),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
