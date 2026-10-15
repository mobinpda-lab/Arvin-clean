import 'package:flutter/material.dart';

import 'models/person_reference.dart';
import 'services/task_store.dart';

/// Lightweight, reusable Person directory. It stores Arvin-owned IDs and
/// display names only; it is not a CRM or a device-contacts mirror.
class PersonDirectoryPage extends StatefulWidget {
  const PersonDirectoryPage({super.key, this.store});

  final TaskStore? store;

  @override
  State<PersonDirectoryPage> createState() => _PersonDirectoryPageState();
}

class _PersonDirectoryPageState extends State<PersonDirectoryPage> {
  late final TaskStore _store;
  final TextEditingController _searchController = TextEditingController();
  List<PersonReference> _people = const <PersonReference>[];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? TaskStore();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final people = await _store.loadPeopleDirectory();
      if (!mounted) return;
      setState(() {
        _people = people;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'دفترچه اشخاص بارگذاری نشد.';
      });
    }
  }

  List<PersonReference> get _visiblePeople {
    final query = _normalize(_searchController.text);
    if (query.isEmpty) return _people;
    return _people
        .where((person) => _normalize(person.displayName).contains(query))
        .toList(growable: false);
  }

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll(RegExp(r'\s+'), ' ');

  Future<void> _editPerson([PersonReference? existing]) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _PersonNameDialog(existingName: existing?.displayName),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;

    setState(() => _saving = true);
    try {
      final person = PersonReference(
        id: existing?.id ?? 'person-${DateTime.now().microsecondsSinceEpoch}',
        displayName: name,
      );
      await _store.savePersonDirectoryEntry(person);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اطلاعات شخص ذخیره شد.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ذخیره انجام نشد؛ نام تکراری است یا خطای ذخیره‌سازی رخ داده است.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deletePerson(PersonReference person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف شخص'),
        content: Text(
          '«${person.displayName}» از دفترچه حذف و ارتباط او از پیگیری‌ها جدا می‌شود. خود کارها و پیگیری‌ها حذف نمی‌شوند.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف شخص'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await _store.deletePersonDirectoryEntry(person.id);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حذف شخص انجام نشد.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final people = _visiblePeople;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اشخاص')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saving ? null : () => _editPerson(),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('افزودن شخص'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const Text(
              'دفترچه‌ای سبک برای اتصال اشخاص به پیگیری‌ها و گزارش‌ها؛ بدون مدیریت مشتریان یا کپی اطلاعات مخاطبان گوشی.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'جست‌وجوی اشخاص',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            if (_saving) const LinearProgressIndicator(),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))
            else if (people.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: Text('هنوز شخصی ثبت نشده است.')),
              )
            else
              ...people.map(
                (person) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                    title: Text(person.displayName),
                    trailing: Wrap(
                      spacing: 0,
                      children: [
                        IconButton(
                          tooltip: 'ویرایش',
                          onPressed: _saving ? null : () => _editPerson(person),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'حذف',
                          onPressed: _saving ? null : () => _deletePerson(person),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


/// Owns the text controller for the full lifetime of the dialog route,
/// including its reverse transition after the user taps Save or Cancel.
class _PersonNameDialog extends StatefulWidget {
  const _PersonNameDialog({this.existingName});

  final String? existingName;

  @override
  State<_PersonNameDialog> createState() => _PersonNameDialogState();
}

class _PersonNameDialogState extends State<_PersonNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.existingName == null ? 'افزودن شخص' : 'ویرایش شخص'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            labelText: 'نام شخص',
            hintText: 'مثلاً سارا احمدی',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
            child: const Text('ذخیره'),
          ),
        ],
      );
}
