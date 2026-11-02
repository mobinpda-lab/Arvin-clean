import 'package:flutter/material.dart';
import 'models/arvin_center.dart';
import 'services/center_store.dart';

class CenterManagementPage extends StatefulWidget {
  const CenterManagementPage({super.key, this.store});
  final CenterStore? store;
  @override State<CenterManagementPage> createState() => _CenterManagementPageState();
}
class _CenterManagementPageState extends State<CenterManagementPage> {
  late final CenterStore _store = widget.store ?? CenterStore();
  List<ArvinCenter> _centers = const [];
  bool _loading = true, _saving = false;
  Object? _error;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final values = await _store.load(); if (!mounted) return; setState(() { _centers = values; _loading = false; _error = null; }); }
    catch (error) { if (!mounted) return; setState(() { _loading = false; _error = error; }); }
  }
  Future<void> _edit({ArvinCenter? center}) async {
    final controller = TextEditingController(text: center?.name ?? '');
    final name = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(center == null ? 'مرکز جدید' : 'ویرایش مرکز'),
      content: TextField(key: const ValueKey('center-name-input'), controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'نام مرکز')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لغو')),
        FilledButton(key: const ValueKey('center-save'), onPressed: () { final value = controller.text.trim(); if (value.isNotEmpty) Navigator.pop(ctx, value); }, child: const Text('ذخیره')),
      ],
    ));
    controller.dispose(); if (name == null || !mounted) return;
    setState(() => _saving = true);
    try {
      if (center == null) await _store.create(id: 'center-${DateTime.now().microsecondsSinceEpoch}', name: name);
      else await _store.rename(id: center.id, name: name);
      await _load();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ذخیره مرکز انجام نشد: $error')));
    } finally { if (mounted) setState(() => _saving = false); }
  }
  Future<void> _archive(ArvinCenter center) async {
    setState(() => _saving = true);
    try { await _store.setArchived(id: center.id, archived: !center.isArchived); await _load(); }
    catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تغییر وضعیت مرکز انجام نشد: $error'))); }
    finally { if (mounted) setState(() => _saving = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('مراکز')),
    floatingActionButton: FloatingActionButton.extended(key: const ValueKey('center-add'), onPressed: _saving ? null : () => _edit(), icon: const Icon(Icons.add), label: const Text('مرکز جدید')),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _error != null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('خواندن مراکز انجام نشد.'), TextButton(onPressed: _load, child: const Text('تلاش دوباره'))]))
      : _centers.isEmpty ? const Center(child: Text('هنوز مرکزی ثبت نشده است.'))
      : ListView.separated(padding: const EdgeInsets.all(16), itemCount: _centers.length, separatorBuilder: (_, __) => const Divider(), itemBuilder: (ctx, i) {
          final center = _centers[i];
          return ListTile(key: ValueKey('center-row-${center.id}'), title: Text(center.name), subtitle: Text(center.isArchived ? 'بایگانی‌شده' : 'فعال'),
            trailing: Wrap(mainAxisSize: MainAxisSize.min, children: [
              IconButton(key: ValueKey('center-edit-${center.id}'), tooltip: 'ویرایش نام مرکز', onPressed: _saving ? null : () => _edit(center: center), icon: const Icon(Icons.edit_outlined)),
              IconButton(key: ValueKey('center-archive-${center.id}'), tooltip: center.isArchived ? 'فعال‌سازی' : 'بایگانی', onPressed: _saving ? null : () => _archive(center), icon: Icon(center.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined)),
            ]),
          );
        }),
  );
}
