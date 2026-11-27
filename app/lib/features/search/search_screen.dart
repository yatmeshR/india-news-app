import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/languages.dart';
import '../../data/models.dart';
import '../../state/news_providers.dart';
import '../../state/settings_provider.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/common.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start fresh each time the screen opens.
    Future.microtask(() {
      if (mounted) ref.invalidate(searchQueryProvider);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit(String q) {
    ref.read(searchQueryProvider.notifier).setText(q);
    ref.read(recentSearchesProvider.notifier).add(q);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final query = ref.watch(searchQueryProvider);
    final appLang = ref.watch(settingsProvider.select((x) => x.language));
    final results = ref.watch(searchResultsProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: s('back'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(s('search'), style: t.headlineSmall),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: TextField(
            controller: _text,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: _submit,
            style: t.bodyLarge,
            decoration: InputDecoration(
              hintText: s('searchPlaceholder'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ValueListenableBuilder(
                valueListenable: _text,
                builder: (_, v, _) => v.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: s('clear'),
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _text.clear();
                          ref.read(searchQueryProvider.notifier).setText('');
                        },
                      ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(color: scheme.secondary, width: 2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
              child: _Filter<String>(
                value: query.category,
                items: [
                  for (final c in kCategories)
                    DropdownMenuItem(
                      value: c.slug,
                      child: Text(c.slug == 'top' ? s('allCategories') : c.name(appLang)),
                    ),
                ],
                onChanged: (v) => ref.read(searchQueryProvider.notifier).setCategory(v ?? 'top'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Filter<String?>(
                value: query.language,
                items: [
                  DropdownMenuItem(value: null, child: Text(s('anyLanguage'))),
                  for (final l in kLanguages)
                    DropdownMenuItem(value: l.code, child: Text(l.native)),
                ],
                onChanged: (v) => ref.read(searchQueryProvider.notifier).setLanguage(v),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: results.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => StateMessage(
              icon: Icons.wifi_off,
              title: s('errorTitle'),
              body: s('errorBody'),
              actionLabel: s('retry'),
              onAction: () => ref.invalidate(searchResultsProvider),
            ),
            data: (list) {
              if (list == null) {
                return _Recent(onPick: (q) {
                  _text.text = q;
                  _submit(q);
                });
              }
              if (list.isEmpty) {
                return StateMessage(
                  icon: Icons.search_off,
                  title: s('noResults'),
                  body: s('noResultsBody'),
                );
              }
              return ListView.separated(
                itemCount: list.length + 1,
                separatorBuilder: (_, i) =>
                    i == 0 ? const SizedBox.shrink() : const Divider(height: 1, indent: 20, endIndent: 20),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Text(
                        '${s('results').toUpperCase()} · ${list.length}',
                        style: t.labelLarge?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1),
                      ),
                    );
                  }
                  final a = list[i - 1];
                  return ArticleTile(
                    article: a,
                    trailing: BookmarkButton(a),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _Filter<T> extends StatelessWidget {
  const _Filter({required this.value, required this.items, required this.onChanged});
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}

class _Recent extends ConsumerWidget {
  const _Recent({required this.onPick});
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final recent = ref.watch(recentSearchesProvider);
    final t = Theme.of(context).textTheme;
    if (recent.isEmpty) {
      return StateMessage(
        icon: Icons.search,
        title: s('searchEmpty'),
        body: s('searchEmptyBody'),
      );
    }
    return ListView(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
        child: Row(children: [
          Expanded(child: Text(s('recent'), style: t.labelLarge)),
          TextButton(
            onPressed: ref.read(recentSearchesProvider.notifier).clear,
            child: Text(s('clear')),
          ),
        ]),
      ),
      for (final q in recent)
        ListTile(
          minTileHeight: 48,
          leading: const Icon(Icons.history),
          title: Text(q),
          onTap: () => onPick(q),
        ),
    ]);
  }
}
