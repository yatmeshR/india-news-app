import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/news_theme.dart';
import '../data/models.dart';
import '../state/saved_provider.dart';
import '../state/settings_provider.dart';

Future<void> openOriginal(BuildContext context, WidgetRef ref, Article a) async {
  final ok = await launchUrl(Uri.parse(a.url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ref.read(stringsProvider)('retry'))),
    );
  }
}

Future<void> shareArticle(Article a) => SharePlus.instance.share(
      ShareParams(text: '${a.title}\n${a.source}\n${a.url}', subject: a.title),
    );

/// Toggles a bookmark and shows the "Saved for offline reading" snackbar with Undo on removal.
void toggleSave(BuildContext context, WidgetRef ref, Article a) {
  final s = ref.read(stringsProvider);
  final notifier = ref.read(savedProvider.notifier);
  final index = ref.read(savedProvider).indexWhere((e) => e.id == a.id);
  final nowSaved = notifier.toggle(a);
  final m = ScaffoldMessenger.of(context)..clearSnackBars();
  m.showSnackBar(SnackBar(
    content: Text(nowSaved ? s('savedToast') : s('removed')),
    duration: const Duration(seconds: 3),
    action: nowSaved
        ? null
        : SnackBarAction(label: s('undo'), onPressed: () => notifier.restore(a, index)),
  ));
}

/// Photo with a calm placeholder when the image is missing or fails to load.
class NewsImage extends ConsumerWidget {
  const NewsImage(this.article, {super.key, this.fit = BoxFit.cover});
  final Article article;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final url = article.imageUrl;
    Widget placeholder() => _ImagePlaceholder(label: s('imageFailed'));
    if (url == null || url.isEmpty) return placeholder();
    final scheme = Theme.of(context).colorScheme;
    return Image(
      image: article.imageIsAsset
          ? AssetImage(url) as ImageProvider
          : NetworkImage(url),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: article.title,
      errorBuilder: (_, _, _) => placeholder(),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : ColoredBox(color: scheme.outlineVariant.withValues(alpha: .5)),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.primaryContainer,
      child: Center(
        child: LayoutBuilder(builder: (context, c) {
          final icon = Icon(Icons.image_not_supported_outlined, color: scheme.onSurfaceVariant);
          if (c.maxHeight < 96) return icon;
          return Column(mainAxisSize: MainAxisSize.min, children: [
            icon,
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ]);
        }),
      ),
    );
  }
}

/// Bookmark icon with the 160 ms fill animation from the design.
class BookmarkButton extends ConsumerWidget {
  const BookmarkButton(this.article, {super.key, this.onPrimary = false});
  final Article article;
  final bool onPrimary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final saved = ref.watch(isSavedProvider(article.id));
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: saved ? s('unsave') : s('save'),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: () => toggleSave(context, ref, article),
      icon: AnimatedSwitcher(
        duration: NewsTheme.bookmarkFill,
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: Icon(
          saved ? Icons.bookmark : Icons.bookmark_border,
          key: ValueKey(saved),
          color: saved ? scheme.primary : null,
        ),
      ),
    );
  }
}

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: scheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Icon(Icons.cloud_off_outlined, size: 18, color: scheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(s('offline'), style: Theme.of(context).textTheme.bodySmall),
          ),
        ]),
      ),
    );
  }
}

/// Empty / error / no-results message with an optional action.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.illustration,
  });
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          illustration ?? Icon(icon, size: 48, color: scheme.onSurfaceVariant),
          const SizedBox(height: 20),
          Text(title, style: t.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(body,
              style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 24),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ]),
      ),
    );
  }
}

/// Pulsing placeholder block for loading skeletons (cheap: one opacity animation).
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.height, this.width, this.radius = 8});
  final double? height;
  final double? width;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return FadeTransition(
      opacity: reduce ? const AlwaysStoppedAnimation(.7) : Tween(begin: .45, end: .9).animate(_c),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Small red caps label above a headline, e.g. "SPORTS".
class CategoryTag extends ConsumerWidget {
  const CategoryTag(this.slug, {super.key});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    return Text(
      categoryBySlug(slug).name(lang).toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 12,
            letterSpacing: lang == 'hi' ? 0 : 1,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
