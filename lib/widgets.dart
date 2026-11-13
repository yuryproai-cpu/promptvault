import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'models.dart';

void copyText(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скопировано')));
}

void showExport(BuildContext context) {
  final data = appState.exportJson();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Экспорт базы (JSON)'),
      content: SingleChildScrollView(child: SelectableText(data, style: const TextStyle(fontSize: 10))),
      actions: [
        TextButton(onPressed: () => copyText(context, data), child: const Text('Копировать')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
      ],
    ),
  );
}

void showImport(BuildContext context) {
  final ctrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Импорт базы'),
      content: TextField(controller: ctrl, maxLines: 8, decoration: const InputDecoration(hintText: 'Вставь сюда JSON из экспорта')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        TextButton(
          onPressed: () {
            final ok = appState.importJson(ctrl.text.trim());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Импорт успешен' : 'Ошибка: неверный JSON')));
          },
          child: const Text('Импортировать'),
        ),
      ],
    ),
  );
}

Widget mediaPreview(String? path, bool isVideo) {
  if (path == null) return const SizedBox.shrink();
  if (isVideo) return VideoBox(path: path);
  return Image.file(File(path), fit: BoxFit.cover);
}

class VideoBox extends StatefulWidget {
  final String path;
  const VideoBox({super.key, required this.path});
  @override
  State<VideoBox> createState() => _VideoBoxState();
}

class _VideoBoxState extends State<VideoBox> {
  late VideoPlayerController _c;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.file(File(widget.path));
    _c.initialize().then((_) { if (mounted) setState(() => _ready = true); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Container(height: 200, color: Colors.black12, child: const Center(child: CircularProgressIndicator()));
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200, width: double.infinity,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(width: _c.value.size.width, height: _c.value.size.height, child: VideoPlayer(_c)),
          ),
        ),
        IconButton(
          iconSize: 48,
          icon: Icon(_c.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white),
          onPressed: () => setState(() { _c.value.isPlaying ? _c.pause() : _c.play(); }),
        ),
      ],
    );
  }
}
