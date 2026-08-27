import 'package:flutter/material.dart';

import 'models/task.dart';
import 'services/task_people_service.dart';

class TaskPeoplePage extends StatefulWidget {
  TaskPeoplePage({
    super.key,
    required this.taskId,
    TaskPeopleService? service,
  }) : service = service ?? TaskPeopleService();

  final String taskId;
  final TaskPeopleService service;

  @override
  State<TaskPeoplePage> createState() => _TaskPeoplePageState();
}

class _TaskPeoplePageState extends State<TaskPeoplePage> {
  Task? task;
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final value = await widget.service.loadRequiredTask(widget.taskId);
      if (!mounted) return;
      setState(() {
        task = value;
        loading = false;
        errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = 'اطلاعات افراد این کار در دسترس نیست';
      });
    }
  }

  Future<String?> _askForName() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('افزودن شخص'),
          content: TextField(
            key: const ValueKey('people-name-input'),
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'نام نمایشی',
              hintText: 'مثلاً علی رضایی',
            ),
            onSubmitted: (value) => Navigator.pop(dialogContext, value),
          ),
          actions: [
            TextButton(
              key: const ValueKey('people-add-cancel'),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('لغو'),
            ),
            FilledButton(
              key: const ValueKey('people-add-save'),
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('افزودن'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _addPerson() async {
    final name = await _askForName();
    if (name == null) return;
    try {
      final updated = await widget.service.addLocalPerson(
        taskId: widget.taskId,
        displayName: name,
      );
      if (!mounted) return;
      setState(() => task = updated);
    } on ArgumentError {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('نام شخص را وارد کنید')),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('افزودن شخص انجام نشد؛ دوباره تلاش کنید')),
        );
    }
  }

  Future<bool> _confirmRemove(String displayName) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف ارتباط'),
          content: Text('«$displayName» از این کار حذف شود؟'),
          actions: [
            TextButton(
              key: const ValueKey('people-remove-cancel'),
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('لغو'),
            ),
            FilledButton(
              key: const ValueKey('people-remove-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
    return approved == true;
  }

  Future<void> _removePerson(String id, String displayName) async {
    if (!await _confirmRemove(displayName)) return;
    try {
      final updated = await widget.service.removePerson(
        taskId: widget.taskId,
        personId: id,
      );
      if (!mounted) return;
      setState(() => task = updated);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('حذف ارتباط انجام نشد؛ دوباره تلاش کنید')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final people = task?.people ?? const [];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('افراد مرتبط')),
        floatingActionButton: loading || errorMessage != null
            ? null
            : FloatingActionButton.extended(
                key: const ValueKey('people-add'),
                onPressed: _addPerson,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('افزودن شخص'),
              ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : people.isEmpty
                    ? const Center(
                        key: ValueKey('people-empty'),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'هنوز شخصی به این کار مرتبط نشده است',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        itemCount: people.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final person = people[index];
                          return Card(
                            child: ListTile(
                              key: ValueKey('people-row-${person.id}'),
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text(person.displayName),
                              subtitle: const Text('شناسه محلی آروین'),
                              trailing: IconButton(
                                key: ValueKey('people-remove-${person.id}'),
                                tooltip: 'حذف ارتباط',
                                onPressed: () => _removePerson(
                                  person.id,
                                  person.displayName,
                                ),
                                icon: const Icon(Icons.link_off_outlined),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
