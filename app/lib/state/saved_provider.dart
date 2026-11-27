import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import 'settings_provider.dart';

/// Bookmarked stories, stored in full so they open offline.
class SavedNotifier extends Notifier<List<Article>> {
  static const _key = 'saved_articles';

  @override
  List<Article> build() {
    final raw = ref.watch(sharedPrefsProvider).getString(_key);
    if (raw == null) return const [];
    try {
      return [
        for (final j in jsonDecode(raw) as List) Article.fromJson(j as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  void _persist() => ref
      .read(sharedPrefsProvider)
      .setString(_key, jsonEncode([for (final a in state) a.toJson()]));

  bool isSaved(String id) => state.any((a) => a.id == id);

  /// Returns true when the story is now saved.
  bool toggle(Article a) {
    if (isSaved(a.id)) {
      remove(a.id);
      return false;
    }
    state = [a, ...state];
    _persist();
    return true;
  }

  void remove(String id) {
    state = [for (final a in state) if (a.id != id) a];
    _persist();
  }

  /// Re-insert at [index] (used by Undo).
  void restore(Article a, int index) {
    if (isSaved(a.id)) return;
    final next = [...state];
    next.insert(index.clamp(0, next.length), a);
    state = next;
    _persist();
  }
}

final savedProvider = NotifierProvider<SavedNotifier, List<Article>>(SavedNotifier.new);

/// Cheap per-article lookup so only the bookmark icon rebuilds.
final isSavedProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(savedProvider.select((l) => l.any((a) => a.id == id))),
);
