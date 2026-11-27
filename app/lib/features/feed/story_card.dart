import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/news_theme.dart';
import '../../data/models.dart';
import '../../state/settings_provider.dart';
import '../../widgets/common.dart';

/// Photo-top story card (direction A of the Paper design).
///
/// Overflow policy from the handoff: shrink the photo, then drop it, and only then let the text
/// area scroll. The summary is never clipped.
class StoryCard extends ConsumerWidget {
  const StoryCard({super.key, required this.article});
  final Article article;

  static const _imageMin = 72.0;
  static const _imageMax = 280.0;
  static const _hPad = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final scheme = theme.colorScheme;
    final scaler = MediaQuery.textScalerOf(context);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(NewsTheme.cardRadius),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, c) {
        final textWidth = c.maxWidth - _hPad * 2;
        double measure(String text, TextStyle? style, {int? maxLines}) {
          final p = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.ltr,
            textScaler: scaler,
            maxLines: maxLines,
          )..layout(maxWidth: textWidth);
          final h = p.height;
          p.dispose();
          return h;
        }

        // meta row + gaps + footer (48 px buttons) + vertical padding.
        final textHeight = 20 +
            8 +
            measure(article.title, t.headlineSmall, maxLines: 3) +
            12 +
            measure(article.summary, t.bodyLarge) +
            12 +
            48 +
            16;
        final room = c.maxHeight - textHeight;
        final imageHeight = room >= _imageMin ? room.clamp(_imageMin, _imageMax) : 0.0;

        return SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (imageHeight > 0)
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(fit: StackFit.expand, children: [
                  NewsImage(article),
                  if (article.imageCredit != null)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.imageCredit!,
                          style: t.bodySmall?.copyWith(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(_hPad, 16, _hPad, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    CategoryTag(article.category),
                    Text(article.source,
                        style: t.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                    Text('· ${s.relative(article.publishedAt)}', style: t.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                Semantics(
                  header: true,
                  child: Text(article.title,
                      maxLines: 3, overflow: TextOverflow.ellipsis, style: t.headlineSmall),
                ),
                const SizedBox(height: 12),
                Text(article.summary, style: t.bodyLarge),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () => context.push(Routes.article(article.id), extra: article),
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.secondary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 48),
                        ),
                        child: Text(
                          s('read'),
                          style: t.labelLarge?.copyWith(
                            color: scheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  BookmarkButton(article),
                  IconButton(
                    tooltip: s('share'),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => shareArticle(article),
                  ),
                ]),
                const SizedBox(height: 4),
              ]),
            ),
          ]),
        );
      }),
    );
  }
}
