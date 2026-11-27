import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/models.dart';
import '../../state/news_providers.dart';
import '../../state/settings_provider.dart';
import '../welcome/welcome_screen.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final settings = ref.watch(settingsProvider);
    final selected = ref.watch(selectedCategoryProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
          child: Row(children: [
            Expanded(child: Text(s('discover'), style: t.headlineSmall)),
            IconButton(
              tooltip: s('search'),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.search),
              onPressed: () => context.push(Routes.search),
            ),
          ]),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s('discoverSub'), style: t.headlineLarge),
            const SizedBox(height: 8),
            Text(
              s('discoverCount'),
              style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ]),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            // padding 32 + icon 24 + gap 8 + two lines of text, growing with the text scale.
            mainAxisExtent: 72 + 2 * MediaQuery.textScalerOf(context).scale(24),
          ),
          itemCount: kCategories.length,
          itemBuilder: (context, i) {
            final c = kCategories[i];
            return _CategoryTile(
              category: c,
              label: c.name(settings.language),
              selected: c.slug == selected,
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = c.slug;
                context.go(Routes.feed);
              },
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s('nearby'), style: t.headlineSmall),
            const SizedBox(height: 12),
            Text(s('state'), style: t.labelLarge),
            const SizedBox(height: 8),
            StatePicker(
              value: settings.homeState,
              language: settings.language,
              allLabel: s('all'),
              onChanged: ref.read(settingsProvider.notifier).setHomeState,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.read(selectedCategoryProvider.notifier).state = 'top';
                  context.go(Routes.feed);
                },
                child: Text(s('apply')),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final NewsCategory category;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? scheme.primaryContainer : scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(category.icon, color: scheme.primary),
                Text(label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
