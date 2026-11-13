import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';
import 'widgets.dart';

class PromptFormScreen extends StatefulWidget {
  final PromptItem? prompt;
  const PromptFormScreen({super.key, this.prompt});
  @override
  State<PromptFormScreen> createState() => _PromptFormScreenState();
}

class _PromptFormScreenState extends State<PromptFormScreen> {
  late TextEditingController _title, _text, _tags, _notes;
  String? _catId, _subId, _mediaPath;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    final p = widget.prompt;
    _title = TextEditingController(text: p?.title ?? '');
    _text = TextEditingController(text: p?.text ?? '');
    _tags = TextEditingController(text: p?.tags.join(', ') ?? '');
    _notes = TextEditingController(text: p?.notes ?? '');
    _catId = p?.categoryId;
    _subId = p?.subCategoryId;
    _mediaPath = p?.mediaPath;
    _isVideo = p?.isVideo ?? false;
  }

  @override
  void dispose() { _title.dispose(); _text.dispose(); _tags.dispose(); _notes.dispose(); super.dispose(); }

  Future<void> _pick() async {
    try {
      final x = await ImagePicker().pickMedia();
      if (x == null) return;
      final ext = x.name.contains('.') ? x.name.split('.').last.toLowerCase() : 'jpg';
      final dir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${dir.path}/media');
      await mediaDir.create(recursive: true);
      final dest = '${mediaDir.path}/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(x.path).copy(dest);
      setState(() { _mediaPath = dest; _isVideo = ['mp4', 'mov', 'mkv', 'avi', 'webm'].contains(ext); });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  void _save() {
    if (_title.text.trim().isEmpty || _text.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполни название и текст промпта')));
      return;
    }
    final tags = _tags.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final p = widget.prompt;
    if (p == null) {
      appState.prompts.add(PromptItem(
        id: newId(), title: _title.text.trim(), text: _text.text.trim(),
        mediaPath: _mediaPath, isVideo: _isVideo, categoryId: _catId, subCategoryId: _subId,
        tags: tags, notes: _notes.text.trim(), createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    } else {
      p.title = _title.text.trim();
      p.text = _text.text.trim();
      p.mediaPath = _mediaPath;
      p.isVideo = _isVideo;
      p.categoryId = _catId;
      p.subCategoryId = _subId;
      p.tags = tags;
      p.notes = _notes.text.trim();
    }
    appState.save();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final subList = appState.subs.where((s) => s.parentId == _catId).toList();
    return Scaffold(
      appBar: AppBar(title: Text(widget.prompt == null ? 'Новый промпт' : 'Редактировать')),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_mediaPath != null)
              SizedBox(height: 180, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: mediaPreview(_mediaPath, _isVideo))),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(_mediaPath == null ? 'Прикрепить фото/видео' : 'Заменить фото/видео'),
              onPressed: _pick),
            if (_mediaPath != null)
              TextButton(onPressed: () => setState(() => _mediaPath = null), child: const Text('Убрать вложение')),
            const SizedBox(height: 16),
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Название промпта', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _text, maxLines: 6, decoration: const InputDecoration(labelText: 'Текст промпта', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _catId,
              decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text('— не выбрана —')),
                ...appState.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              ],
              onChanged: (v) => setState(() { _catId = v; _subId = null; })),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _subId,
              decoration: const InputDecoration(labelText: 'Подкатегория', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text('— не выбрана —')),
                ...subList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
              ],
              onChanged: (v) => setState(() => _subId = v)),
            const SizedBox(height: 12),
            TextField(controller: _tags, decoration: const InputDecoration(labelText: 'Теги (через запятую)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _notes, maxLines: 4, decoration: const InputDecoration(labelText: 'Заметки / разбор промпта', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text('Сохранить')),
            const SizedBox(height: 30),
            const Text(
              'Нет нужной категории?\nГлавный экран → три точки справа вверху → Админ: категории',
              style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
