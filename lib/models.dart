import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

String newId() => DateTime.now().millisecondsSinceEpoch.toString();

class Category {
  String id, name, desc;
  Category({required this.id, required this.name, this.desc = ''});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'desc': desc};
  factory Category.fromJson(Map<String, dynamic> j) =>
      Category(id: j['id'] ?? '', name: j['name'] ?? '', desc: j['desc'] ?? '');
}

class SubCategory {
  String id, parentId, name, desc;
  SubCategory({required this.id, required this.parentId, required this.name, this.desc = ''});
  Map<String, dynamic> toJson() => {'id': id, 'parentId': parentId, 'name': name, 'desc': desc};
  factory SubCategory.fromJson(Map<String, dynamic> j) => SubCategory(
      id: j['id'] ?? '', parentId: j['parentId'] ?? '', name: j['name'] ?? '', desc: j['desc'] ?? '');
}

class PromptItem {
  final String id;
  String title, text;
  String? mediaPath, categoryId, subCategoryId;
  bool isVideo;
  List<String> tags;
  String notes;
  final int createdAt;
  PromptItem({
    required this.id, required this.title, required this.text,
    this.mediaPath, this.categoryId, this.subCategoryId,
    this.isVideo = false, this.tags = const [], this.notes = '', required this.createdAt,
  });
  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'text': text, 'mediaPath': mediaPath, 'isVideo': isVideo,
    'categoryId': categoryId, 'subCategoryId': subCategoryId, 'tags': tags, 'notes': notes, 'createdAt': createdAt,
  };
  factory PromptItem.fromJson(Map<String, dynamic> j) => PromptItem(
    id: j['id'] ?? '', title: j['title'] ?? '', text: j['text'] ?? '',
    mediaPath: j['mediaPath'], isVideo: j['isVideo'] ?? false,
    categoryId: j['categoryId'], subCategoryId: j['subCategoryId'],
    tags: (j['tags'] as List? ?? []).map((e) => e.toString()).toList(),
    notes: j['notes'] ?? '', createdAt: j['createdAt'] ?? 0,
  );
}

class AppState extends ChangeNotifier {
  List<Category> categories = [];
  List<SubCategory> subs = [];
  List<PromptItem> prompts = [];
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    load();
  }

  void load() {
    final s = _prefs.getString('data_v1');
    if (s == null) return;
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      categories = (m['categories'] as List? ?? []).map((e) => Category.fromJson(e)).toList();
      subs = (m['subcategories'] as List? ?? []).map((e) => SubCategory.fromJson(e)).toList();
      prompts = (m['prompts'] as List? ?? []).map((e) => PromptItem.fromJson(e)).toList();
    } catch (_) {}
  }

  void save() {
    final data = {
      'categories': categories.map((e) => e.toJson()).toList(),
      'subcategories': subs.map((e) => e.toJson()).toList(),
      'prompts': prompts.map((e) => e.toJson()).toList(),
    };
    _prefs.setString('data_v1', jsonEncode(data));
    notifyListeners();
  }

  String categoryName(String? id) {
    if (id == null) return '—';
    for (final c in categories) if (c.id == id) return c.name;
    return '—';
  }

  String subName(String? id) {
    if (id == null) return '—';
    for (final s in subs) if (s.id == id) return s.name;
    return '—';
  }

  String exportJson() => jsonEncode({
    'categories': categories.map((e) => e.toJson()).toList(),
    'subcategories': subs.map((e) => e.toJson()).toList(),
    'prompts': prompts.map((e) => e.toJson()).toList(),
  });

  bool importJson(String s) {
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      categories = (m['categories'] as List? ?? []).map((e) => Category.fromJson(e)).toList();
      subs = (m['subcategories'] as List? ?? []).map((e) => SubCategory.fromJson(e)).toList();
      prompts = (m['prompts'] as List? ?? []).map((e) => PromptItem.fromJson(e)).toList();
      save();
      return true;
    } catch (_) { return false; }
  }
}

final appState = AppState();
