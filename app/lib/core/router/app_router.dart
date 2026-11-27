import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models.dart';
import '../../features/discover/discover_screen.dart';
import '../../features/feed/feed_screen.dart';
import '../../features/reader/reader_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../state/settings_provider.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const feed = '/feed';
  static const discover = '/discover';
  static const saved = '/saved';
  static const settings = '/settings';
  static const search = '/search';
  static String article(String id) => '/article/$id';
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Single GoRouter for the app. It re-evaluates `redirect` whenever onboarding state changes.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(settingsProvider.select((s) => s.onboarded), (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final onboarded = ref.read(settingsProvider).onboarded;
      final loc = state.matchedLocation;
      if (loc == Routes.splash) return null; // splash decides after its delay
      if (!onboarded && loc != Routes.welcome) return Routes.welcome;
      if (onboarded && loc == Routes.welcome) return Routes.feed;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.feed, builder: (_, _) => const FeedScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.discover, builder: (_, _) => const DiscoverScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.saved, builder: (_, _) => const SavedScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: Routes.search,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: '/article/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => ReaderScreen(
          articleId: state.pathParameters['id']!,
          article: state.extra as Article?,
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
