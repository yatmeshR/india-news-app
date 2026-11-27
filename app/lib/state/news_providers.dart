import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/news_repository.dart';
import 'settings_provider.dart';

final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => NewsRepository(prefs: ref.watch(sharedPrefsProvider)),
);

/// Category chosen on the feed chips or Discover tiles.
final selectedCategoryProvider = StateProvider<String>((ref) => 'top');

class FeedState {
  const FeedState({
    required this.items,
    this.nextCursor,
    this.offline = false,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });
  final List<Article> items;
  final String? nextCursor;
  final bool offline;
  final bool loadingMore;
  final bool loadMoreFailed;

  bool get hasMore => nextCursor != null;

  FeedState copyWith({
    List<Article>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? loadingMore,
    bool? loadMoreFailed,
  }) =>
      FeedState(
        items: items ?? this.items,
        nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
        offline: offline,
        loadingMore: loadingMore ?? this.loadingMore,
        loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      );
}

/// One feed per category slug. Rebuilds (re-fetches) when language or home state change.
class FeedNotifier extends FamilyAsyncNotifier<FeedState, String> {
  @override
  Future<FeedState> build(String category) async {
    final s = ref.watch(settingsProvider.select((s) => (s.language, s.homeState)));
    final page = await ref
        .read(newsRepositoryProvider)
        .feed(category: category, lang: s.$1, state: s.$2);
    return FeedState(items: page.items, nextCursor: page.nextCursor, offline: page.offline);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, loadMoreFailed: false));
    final s = ref.read(settingsProvider);
    try {
      final page = await ref.read(newsRepositoryProvider).feed(
            category: arg,
            lang: s.language,
            state: s.homeState,
            cursor: current.nextCursor,
          );
      final seen = {for (final a in current.items) a.id};
      state = AsyncData(current.copyWith(
        items: [...current.items, ...page.items.where((a) => !seen.contains(a.id))],
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false, loadMoreFailed: true));
    }
  }
}

final feedProvider =
    AsyncNotifierProvider.family<FeedNotifier, FeedState, String>(FeedNotifier.new);

// ---- Search ----------------------------------------------------------------

class SearchQuery {
  const SearchQuery({this.text = '', this.category = 'top', this.language});
  final String text;
  final String category;

  /// null = follow the app language.
  final String? language;

  SearchQuery copyWith({String? text, String? category, String? language, bool anyLanguage = false}) =>
      SearchQuery(
        text: text ?? this.text,
        category: category ?? this.category,
        language: anyLanguage ? null : (language ?? this.language),
      );
}

class SearchQueryNotifier extends Notifier<SearchQuery> {
  @override
  SearchQuery build() => const SearchQuery();
  void setText(String t) => state = state.copyWith(text: t.trim());
  void setCategory(String c) => state = state.copyWith(category: c);
  void setLanguage(String? l) => state = l == null
      ? state.copyWith(anyLanguage: true)
      : state.copyWith(language: l);
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, SearchQuery>(SearchQueryNotifier.new);

final searchResultsProvider = FutureProvider.autoDispose<List<Article>?>((ref) async {
  final q = ref.watch(searchQueryProvider);
  final appLang = ref.watch(settingsProvider.select((s) => s.language));
  if (q.text.length < 2) return null; // null = nothing searched yet
  return ref.read(newsRepositoryProvider).search(
        query: q.text,
        lang: q.language ?? appLang,
        category: q.category,
      );
});

class RecentSearchesNotifier extends Notifier<List<String>> {
  static const _key = 'recent_searches';
  @override
  List<String> build() => ref.watch(sharedPrefsProvider).getStringList(_key) ?? const [];

  void add(String q) {
    final t = q.trim();
    if (t.length < 2) return;
    state = [t, ...state.where((e) => e.toLowerCase() != t.toLowerCase())].take(8).toList();
    ref.read(sharedPrefsProvider).setStringList(_key, state);
  }

  void clear() {
    state = const [];
    ref.read(sharedPrefsProvider).remove(_key);
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(RecentSearchesNotifier.new);

/// Used by the reader when opened by id (deep link / notification).
final articleProvider = FutureProvider.family<Article, String>(
  (ref, id) => ref.read(newsRepositoryProvider).article(id),
);
