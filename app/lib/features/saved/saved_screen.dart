import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/models.dart';
import '../../state/news_providers.dart';
import '../../state/saved_provider.dart';
import '../../state/settings_provider.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/common.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final saved = ref.watch(savedProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
        child: Row(children: [
          Expanded(child: Text(s('saved'), style: t.headlineSmall)),
          IconButton(
            tooltip: s('search'),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.search),
            onPressed: () => context.push(Routes.search),
          ),
        ]),
      ),
      Expanded(
        child: saved.isEmpty
            ? StateMessage(
                icon: Icons.bookmark_border,
                illustration: SvgPicture.asset(
                  dark ? 'assets/images/saved-empty-dark.svg' : 'assets/images/saved-empty.svg',
                  width: 160,
                  excludeFromSemantics: true,
                ),
                title: s('savedEmpty'),
                body: s('savedEmptyBody'),
                actionLabel: s('browse'),
                onAction: () {
                  ref.read(selectedCategoryProvider.notifier).state = 'top';
                  context.go(Routes.feed);
                },
              )
            : ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: saved.length + 1,
                separatorBuilder: (_, i) =>
                    i == 0 ? const SizedBox.shrink() : const Divider(height: 1, indent: 20, endIndent: 20),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s('savedTitle'), style: t.headlineLarge),
                        const SizedBox(height: 8),
                        Text(s('savedSubtitle'),
                            style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      ]),
                    );
                  }
                  final a = saved[i - 1];
                  return Dismissible(
                    key: ValueKey(a.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: scheme.primaryContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: Icon(Icons.delete_outline, color: scheme.onPrimaryContainer),
                    ),
                    onDismissed: (_) => _remove(context, ref, a, i - 1),
                    child: ArticleTile(
                      article: a,
                      cached: true,
                      trailing: IconButton(
                        tooltip: s('remove'),
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _remove(context, ref, a, i - 1),
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  void _remove(BuildContext context, WidgetRef ref, Article a, int index) {
    final s = ref.read(stringsProvider);
    final notifier = ref.read(savedProvider.notifier);
    notifier.remove(a.id);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(s('removed')),
        action: SnackBarAction(label: s('undo'), onPressed: () => notifier.restore(a, index)),
      ));
  }
}
