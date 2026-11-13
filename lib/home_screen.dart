import 'dart:io';
import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets.dart';
import 'detail_screen.dart';
import 'form_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  bool _searching = false;
  String? _catFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _search, autofocus: true,
                decoration: const InputDecoration(hintText: 'Поиск...'),
                onChanged: (_) => setState(() {}))
            : const Text('PromptVault'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () => setState(() { _searching = !_searching; if (!_searching) _search.clear(); })),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'admin') Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
              if (v == 'export') showExport(context);
              if (v == 'import') showImport(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'admin', child: Text('Админ: категории')),
              PopupMenuItem(value: 'export', child: Text('Экспорт базы')),
              PopupMenuItem(value: 'import', child: Text('Импорт базы')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              const Text('Категория:', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true, value: _catFilter,
                  hint: const Text('Все', style: TextStyle(fontSize: 12)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Все', style: TextStyle(fontSize: 12))),
                    ...appState.categories.map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (v) => setState(() => _catFilter = v),
                ),
              ),
            ]),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: appState,
              builder: (context, _) {
                final q = _search.text.trim().toLowerCase();
                final list = appState.prompts.where((p) {
                  final okCat = _catFilter == null || p.categoryId == _catFilter;
                  final okQ = q.isEmpty || p.title.toLowerCase().contains(q) ||
                      p.text.toLowerCase().contains(q) || p.tags.any((t) => t.toLowerCase().contains(q));
                  return okCat && okQ;
                }).toList();
                list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                if (list.isEmpty) {
                  return const Center(child: Text('Пока пусто.\nНажми + чтобы добавить первый промпт.', textAlign: TextAlign.center));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return ListTile(
                      leading: SizedBox(
                        width: 56, height: 56,
                        child: p.mediaPath != null
                            ? (p.isVideo
                                ? Container(color: Colors.black26, child: const Icon(Icons.play_circle_outline))
                                : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(p.mediaPath!), fit: BoxFit.cover)))
                            : const Icon(Icons.text_snippet_outlined),
                      ),
                      title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                          '${appState.categoryName(p.categoryId)} · ${DateTime.fromMillisecondsSinceEpoch(p.createdAt).day}.${DateTime.fromMillisecondsSinceEpoch(p.createdAt).month}',
                          style: const TextStyle(fontSize: 11)),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(promptId: p.id))),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PromptFormScreen(prompt: null))),
      ),
    );
  }
}
