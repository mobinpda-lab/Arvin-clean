import 'package:flutter/material.dart';

import 'models/person_reference.dart';
import 'services/task_store.dart';

/// Lightweight directory for stable Arvin-owned Person identities.
/// Names are labels, never identity keys. Merge is intentionally unavailable
/// until a transactional, auditable and undoable merge contract exists.
class PersonDirectoryPage extends StatefulWidget {
  const PersonDirectoryPage({super.key, this.store});

  final TaskStore? store;

  @override
  State<PersonDirectoryPage> createState() => _PersonDirectoryPageState();
}

class _PersonDirectoryPageState extends State<PersonDirectoryPage> {
  late final TaskStore _store;
  final TextEditingController _search = TextEditingController();
  List<PersonReference> _people = const [];
  List<dynamic> _tasks = const [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? TaskStore();
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll(RegExp(r'\s+'), ' ');

  List<PersonReference> get _visiblePeople {
    final query = _normalize(_search.text);
    if (query.isEmpty) return _people;
    return _people
        .where((person) => _normalize(person.displayName).contains(query))
        .toList(growable: false);
  }

  Future<void> _reload() async {
    try {
      final people = await _store.loadPeopleDirectory();
      final tasks = await _store.load();
      if (!mounted) return;
      setState(() {
        _people = people;
        _tasks = tasks;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بارگذاری دفترچه اشخاص انجام نشد.')),
      );
    }
  }

  Future<String?> _askName({String? initial}) => showDialog<String>(
        context: context,
        builder: (_) => _PersonNameDialog(initial: initial),
      );

  Future<void> _edit([PersonReference? existing]) async {
    final name = await _askName(initial: existing?.displayName);
    if (name == null || name.trim().isEmpty || !mounted) return;
    final normalized = _normalize(name);
    final duplicates = _people
        .where((person) =>
            person.id != existing?.id &&
            _normalize(person.displayName) == normalized)
        .toList(growable: false);
    if (duplicates.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('نام مشابه وجود دارد'),
          content: Text(
            'شخصی با نام «${duplicates.first.displayName}» ثبت شده است. '
            'نام، شناسه هویتی نیست؛ اگر این فرد شخص دیگری است می‌توانید با شناسه مستقل ثبتش کنید.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('بازبینی نام'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ثبت شخص جداگانه'),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    setState(() => _saving = true);
    try {
      final person = PersonReference(
        id: existing?.id ?? 'person-${DateTime.now().microsecondsSinceEpoch}',
        displayName: name,
      );
      final next = <String, PersonReference>{
        for (final item in _people) item.id: item,
        person.id: person,
      };
      await _store.savePeopleDirectory(next.values);
      await _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ذخیره شخص انجام نشد.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _isReferenced(String personId) {
    for (final task in _tasks) {
      if (task.people.any((person) => person.id == personId)) return true;
      if (task.followUps.any((followUp) => followUp.personIds.contains(personId))) {
        return true;
      }
    }
    return false;
  }

  Future<void> _delete(PersonReference person) async {
    final referenced = _isReferenced(person.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف شخص از دفترچه'),
        content: Text(
          referenced
              ? '«${person.displayName}» در سوابق کار یا پیگیری استفاده شده است. '
                  'حذف فقط این شخص را از دفترچه اشخاص خارج می‌کند؛ شناسه و ارتباط‌های تاریخی Task و Follow-up حفظ می‌شوند.'
              : '«${person.displayName}» از دفترچه اشخاص حذف شود؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف از دفترچه'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await _store.savePeopleDirectory(
        _people.where((item) => item.id != person.id),
      );
      await _reload();
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
          onPressed: _saving ? null : () => _edit(),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('افزودن شخص'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  const Text(
                    'هر شخص شناسه مستقل دارد. نام‌های تکراری فقط هشدار ایجاد می‌کنند و باعث ادغام اشخاص نمی‌شوند.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'جست‌وجوی اشخاص',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_saving) const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                  if (people.isEmpty)
                    const Center(child: Text('هنوز شخصی ثبت نشده است.'))
                  else
                    ...people.map(
                      (person) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_outline),
                          ),
                          title: Text(person.displayName),
                          subtitle: Text(person.id),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                tooltip: 'ویرایش',
                                onPressed: _saving ? null : () => _edit(person),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'حذف',
                                onPressed: _saving ? null : () => _delete(person),
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

class _PersonNameDialog extends StatefulWidget {
  const _PersonNameDialog({this.initial});

  final String? initial;

  @override
  State<_PersonNameDialog> createState() => _PersonNameDialogState();
}

class _PersonNameDialogState extends State<_PersonNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.initial == null ? 'افزودن شخص' : 'ویرایش شخص'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(labelText: 'نام شخص'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _controller.text.trim()),
            child: const Text('ذخیره'),
          ),
        ],
      );
}
