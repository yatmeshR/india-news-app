import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/news_theme.dart';
import '../../data/models.dart';
import '../../state/news_providers.dart';
import '../../state/settings_provider.dart';
import '../../widgets/common.dart';
import '../splash/splash_screen.dart';
import 'story_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(selectedCategoryProvider);
    final feed = ref.watch(feedProvider(category));

    return Column(children: [
      const _TopBar(),
      const _CategoryChips(),
      if (feed.valueOrNull?.offline ?? false) const OfflineBanner(),
      Expanded(
        child: feed.when(
          // Keep showing the previous list while a refresh is in flight.
          skipLoadingOnRefresh: true,
          loading: () => const _FeedSkeleton(),
          error: (e, _) => _FeedError(category: category),
          data: (state) => state.items.isEmpty
              ? _FeedEmpty(category: category)
              : StoryPager(key: ValueKey(category), category: category, state: state),
        ),
      ),
    ]);
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
      child: Row(children: [
        const Flexible(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Wordmark(),
          ),
        ),
        Flexible(
          flex: 2,
          child: TextButton.icon(
            onPressed: () => showStateSheet(context, ref),
            icon: const Icon(Icons.expand_more, size: 20),
            iconAlignment: IconAlignment.end,
            label: Text(
              settings.homeState == null
                  ? categoryBySlug('india').name(settings.language)
                  : stateLabel(settings.homeState!, settings.language),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
          ),
        ),
        IconButton(
          tooltip: s('search'),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: const Icon(Icons.search),
          onPressed: () => context.push(Routes.search),
        ),
      ]),
    );
  }
}

Future<void> showStateSheet(BuildContext context, WidgetRef ref) {
  final s = ref.read(stringsProvider);
  final settings = ref.read(settingsProvider);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .7,
      maxChildSize: .92,
      builder: (ctx, controller) => ListView(
        controller: controller,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(s('chooseState'), style: Theme.of(ctx).textTheme.headlineSmall),
          ),
          for (final st in <String?>[null, ...kStates])
            ListTile(
              minTileHeight: 48,
              title: Text(st == null ? s('all') : stateLabel(st, settings.language)),
              trailing: st == settings.homeState
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setHomeState(st);
                Navigator.pop(ctx);
              },
            ),
        ],
      ),
    ),
  );
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: kCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = kCategories[i];
          final isSel = c.slug == selected;
          return ChoiceChip(
            selected: isSel,
            showCheckmark: false,
            label: Text(c.name(lang)),
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSel ? scheme.surface : scheme.onSurface,
                ),
            selectedColor: scheme.onSurface,
            backgroundColor: scheme.surface,
            side: BorderSide(color: isSel ? scheme.onSurface : scheme.outlineVariant),
            shape: const StadiumBorder(),
            onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = c.slug,
          );
        },
      ),
    );
  }
}

class StoryPager extends ConsumerStatefulWidget {
  const StoryPager({super.key, required this.category, required this.state});
  final String category;
  final FeedState state;

  @override
  ConsumerState<StoryPager> createState() => _StoryPagerState();
}

class _StoryPagerState extends ConsumerState<StoryPager> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    _controller.animateToPage(
      page,
      duration: reduce ? Duration.zero : NewsTheme.storySlide,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final st = widget.state;
    final items = st.items;
    // One extra trailing page: spinner while paging, or the "all caught up" message.
    final count = items.length + 1;

    return Column(children: [
      Expanded(
        child: RefreshIndicator(
          onRefresh: () => ref.read(feedProvider(widget.category).notifier).refresh(),
          child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            itemCount: count,
            onPageChanged: (i) {
              setState(() => _page = i);
              if (i >= items.length - 3) {
                ref.read(feedProvider(widget.category).notifier).loadMore();
              }
            },
            itemBuilder: (context, i) {
              if (i < items.length) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: StoryCard(article: items[i]),
                );
              }
              return _EndPage(state: st, category: widget.category);
            },
          ),
        ),
      ),
      _HintBar(
        page: _page,
        count: count,
        onPrev: _page > 0 ? () => _go(_page - 1) : null,
        onNext: _page < count - 1 ? () => _go(_page + 1) : null,
        onRefresh: () => ref.read(feedProvider(widget.category).notifier).refresh(),
        hint: _page == 0 ? s('hint') : '${_page + 1} / ${items.length}',
      ),
    ]);
  }
}

class _HintBar extends ConsumerWidget {
  const _HintBar({
    required this.page,
    required this.count,
    required this.onPrev,
    required this.onNext,
    required this.onRefresh,
    required this.hint,
  });
  final int page;
  final int count;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onRefresh;
  final String hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return SizedBox(
      height: 48,
      child: Row(children: [
        IconButton(
          tooltip: s('previous'),
          onPressed: onPrev,
          icon: const Icon(Icons.keyboard_arrow_up),
        ),
        Expanded(
          child: Text(hint,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        IconButton(
          tooltip: s('refresh'),
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: s('next'),
          onPressed: onNext,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
      ]),
    );
  }
}

class _EndPage extends ConsumerWidget {
  const _EndPage({required this.state, required this.category});
  final FeedState state;
  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    if (state.hasMore) {
      if (state.loadMoreFailed) {
        return StateMessage(
          icon: Icons.wifi_off,
          title: s('errorTitle'),
          body: s('errorBody'),
          actionLabel: s('retry'),
          onAction: () => ref.read(feedProvider(category).notifier).loadMore(),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    return StateMessage(
      icon: Icons.check_circle_outline,
      title: s('emptyTitle'),
      body: s('emptyBody'),
      actionLabel: category == 'top' ? null : s('restore'),
      onAction: () => ref.read(selectedCategoryProvider.notifier).state = 'top',
    );
  }
}

class _FeedEmpty extends ConsumerWidget {
  const _FeedEmpty({required this.category});
  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final home = ref.watch(settingsProvider.select((x) => x.homeState));
    final local = home != null;
    return StateMessage(
      icon: Icons.inbox_outlined,
      title: local ? s('localEmpty') : s('emptyTitle'),
      body: local ? s('localEmptyBody') : s('emptyBody'),
      actionLabel: local ? s('all') : (category == 'top' ? null : s('restore')),
      onAction: () {
        if (local) ref.read(settingsProvider.notifier).setHomeState(null);
        ref.read(selectedCategoryProvider.notifier).state = 'top';
      },
    );
  }
}

class _FeedError extends ConsumerWidget {
  const _FeedError({required this.category});
  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return StateMessage(
      icon: Icons.wifi_off,
      title: s('errorTitle'),
      body: s('errorBody'),
      actionLabel: s('retry'),
      onAction: () => ref.invalidate(feedProvider(category)),
    );
  }
}

class _FeedSkeleton extends ConsumerWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: s('loading'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(NewsTheme.cardRadius),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Skeleton(height: 200, radius: 12),
              SizedBox(height: 20),
              Skeleton(height: 12, width: 120),
              SizedBox(height: 16),
              Skeleton(height: 24),
              SizedBox(height: 8),
              Skeleton(height: 24, width: 220),
              SizedBox(height: 20),
              Skeleton(height: 14),
              SizedBox(height: 8),
              Skeleton(height: 14),
              SizedBox(height: 8),
              Skeleton(height: 14),
              SizedBox(height: 8),
              Skeleton(height: 14, width: 160),
            ]),
          ),
        ),
      ),
    );
  }
}
