import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../data/models.dart';
import '../state/settings_provider.dart';
import 'common.dart';

/// Row used by Search results and the Saved list: text on the left, thumbnail + action on the right.
class ArticleTile extends ConsumerWidget {
  const ArticleTile({super.key, required this.article, required this.trailing, this.cached = false});
  final Article article;
  final Widget trailing;
  final bool cached;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push(Routes.article(article.id), extra: article),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CategoryTag(article.category),
              const SizedBox(height: 6),
              Text(article.title,
                  style: t.titleMedium, maxLines: 4, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('${article.source} · ${s.relative(article.publishedAt)}', style: t.bodySmall),
              const SizedBox(height: 4),
              Text(
                s('read'),
                style: t.bodySmall?.copyWith(
                  color: scheme.secondary,
                  decoration: TextDecoration.underline,
                  decorationColor: scheme.secondary,
                ),
              ),
              if (cached) ...[
                const SizedBox(height: 8),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(s('cached'), style: t.bodySmall),
                ]),
              ],
            ]),
          ),
          const SizedBox(width: 16),
          Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(width: 88, height: 88, child: NewsImage(article)),
            ),
            const SizedBox(height: 4),
            trailing,
          ]),
        ]),
      ),
    );
  }
}
