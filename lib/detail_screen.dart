import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets.dart';
import 'form_screen.dart';

class DetailScreen extends StatelessWidget {
  final String promptId;
  const DetailScreen({super.key, required this.promptId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          PromptItem? found;
          for (final x in appState.prompts) { if (x.id == promptId) { found = x; break; } }
          if (found == null) return const Center(child: Text('Промпт удалён'));
          final p = found;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220, pinned: true,
                title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                flexibleSpace: FlexibleSpaceBar(background: p.mediaPath != null ? mediaPreview(p.mediaPath, p.isVideo) : null),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PromptFormScreen(prompt: p)))),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Удалить промпт?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Нет')),
                          TextButton(
                            onPressed: () {
                              appState.prompts.removeWhere((x) => x.id == promptId);
                              appState.save();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Да')),
                        ],
                      ))),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, children: [
                        Chip(label: Text('Кат: ${appState.categoryName(p.categoryId)}')),
                        Chip(label: Text('Подкат: ${appState.subName(p.subCategoryId)}')),
                      ]),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, children: p.tags.map((t) => Chip(label: Text('#$t'))).toList()),
                      const SizedBox(height: 16),
                      const Text('ПРОМПТ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                        child: SelectableText(p.text),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.copy), label: const Text('Скопировать промпт'),
                        onPressed: () => copyText(context, p.text)),
                      const SizedBox(height: 16),
                      if (p.notes.isNotEmpty) ...[
                        const Text('ЗАМЕТКИ / РАЗБОР', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(p.notes),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
