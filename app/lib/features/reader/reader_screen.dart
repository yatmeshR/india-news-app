import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models.dart';
import '../../state/news_providers.dart';
import '../../state/saved_provider.dart';
import '../../state/settings_provider.dart';
import '../../widgets/common.dart';

/// Article reader. The publisher owns the full text, so this shows the source, the 60-word brief
/// (flexible text size) and a prominent "Open in browser" action — as in the Paper handoff.
class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, required this.articleId, this.article});
  final String articleId;
  final Article? article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    // Prefer the object passed from the list; otherwise saved copy; otherwise fetch by id.
    final known = article ??
        ref.watch(savedProvider).where((a) => a.id == articleId).firstOrNull;
    if (known != null) return _ReaderBody(article: known);

    return ref.watch(articleProvider(articleId)).when(
          data: (a) => _ReaderBody(article: a),
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => Scaffold(
            appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
            body: StateMessage(
              icon: Icons.wifi_off,
              title: s('errorTitle'),
              body: s('readerOffline'),
              actionLabel: s('retry'),
              onAction: () => ref.invalidate(articleProvider(articleId)),
            ),
          ),
        );
  }
}

class _ReaderBody extends ConsumerWidget {
  const _ReaderBody({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: s('back'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(article.source, style: t.labelLarge, overflow: TextOverflow.ellipsis),
          Text(article.domain,
              style: t.bodySmall?.copyWith(color: scheme.secondary),
              overflow: TextOverflow.ellipsis),
        ]),
        actions: [
          IconButton(
            tooltip: s('share'),
            icon: const Icon(Icons.share_outlined),
            onPressed: () => shareArticle(article),
          ),
          BookmarkButton(article),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: scheme.primary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s('readerNotice'), style: t.labelLarge),
              const SizedBox(height: 8),
              Text(s('readerBody'), style: t.bodyMedium),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => openOriginal(context, ref, article),
                  child: Text(s('external')),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              CategoryTag(article.category),
              Text(article.source, style: t.bodySmall),
              Text('· ${s.relative(article.publishedAt)}', style: t.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Semantics(header: true, child: Text(article.title, style: t.headlineLarge)),
          const SizedBox(height: 20),
          if (article.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(aspectRatio: 16 / 10, child: NewsImage(article)),
            ),
          if (article.imageCredit != null) ...[
            const SizedBox(height: 6),
            Text(article.imageCredit!, style: t.bodySmall),
          ],
          const SizedBox(height: 24),
          Text(
            s('summaryLabel').toUpperCase(),
            style: t.labelLarge?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(article.summary, style: t.bodyLarge?.copyWith(fontSize: 18, height: 1.6)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(children: [
            TextButton(
              onPressed: () => openOriginal(context, ref, article),
              style: TextButton.styleFrom(foregroundColor: scheme.secondary),
              child: Text(s('external')),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(foregroundColor: scheme.secondary),
              child: Text(s('close')),
            ),
          ]),
        ),
      ),
    );
  }
}
