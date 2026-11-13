import 'package:flutter/material.dart';
import 'models.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Админ: категории'),
          bottom: const TabBar(tabs: [Tab(text: 'Категории'), Tab(text: 'Подкатегории')]),
        ),
        body: AnimatedBuilder(
          animation: appState,
          builder: (context, _) => TabBarView(children: [_CatList(), _SubList()]),
        ),
      ),
    );
  }
}

class _CatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appState.categories.isEmpty
          ? const Center(child: Text('Категорий пока нет.\nСоздай первую кнопкой +'))
          : ListView.builder(
              itemCount: appState.categories.length,
              itemBuilder: (context, i) {
                final c = appState.categories[i];
                return ListTile(
                  title: Text(c.name),
                  subtitle: c.desc.isNotEmpty ? Text(c.desc) : null,
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _addCatDialog(context, cat: c)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () { appState.categories.removeAt(i); appState.save(); }),
                  ]),
                );
              }),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), onPressed: () => _addCatDialog(context)),
    );
  }
}

class _SubList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appState.subs.isEmpty
          ? const Center(child: Text('Подкатегорий пока нет.\nСоздай первую кнопкой +'))
          : ListView.builder(
              itemCount: appState.subs.length,
              itemBuilder: (context, i) {
                final s = appState.subs[i];
                return ListTile(
                  title: Text(s.name),
                  subtitle: Text('Категория: ${appState.categoryName(s.parentId)}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _addSubDialog(context, sub: s)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () { appState.subs.removeAt(i); appState.save(); }),
                  ]),
                );
              }),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), onPressed: () => _addSubDialog(context)),
    );
  }
}

Future<void> _addCatDialog(BuildContext context, {Category? cat}) async {
  final name = TextEditingController(text: cat?.name ?? '');
  final desc = TextEditingController(text: cat?.desc ?? '');
  final res = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(cat == null ? 'Новая категория' : 'Редактировать'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Название')),
        const SizedBox(height: 8),
        TextField(controller: desc, decoration: const InputDecoration(labelText: 'Описание (необязательно)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
      ],
    ),
  );
  if (res == true && name.text.trim().isNotEmpty) {
    if (cat == null) {
      appState.categories.add(Category(id: newId(), name: name.text.trim(), desc: desc.text.trim()));
    } else {
      cat.name = name.text.trim();
      cat.desc = desc.text.trim();
    }
    appState.save();
  }
}

Future<void> _addSubDialog(BuildContext context, {SubCategory? sub}) async {
  final name = TextEditingController(text: sub?.name ?? '');
  String? parentId = sub?.parentId;
  final res = await showDialog<bool>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(sub == null ? 'Новая подкатегория' : 'Редактировать'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String?>(
            value: parentId,
            decoration: const InputDecoration(labelText: 'Родительская категория', border: OutlineInputBorder()),
            items: appState.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (v) => setDialogState(() => parentId = v)),
          const SizedBox(height: 8),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Название')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
        ],
      ),
    ),
  );
  if (res == true && name.text.trim().isNotEmpty && parentId != null) {
    if (sub == null) {
      appState.subs.add(SubCategory(id: newId(), parentId: parentId!, name: name.text.trim()));
    } else {
      sub.name = name.text.trim();
      sub.parentId = parentId!;
    }
    appState.save();
  }
}
