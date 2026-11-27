import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config.dart';
import '../core/l10n/languages.dart';
import 'models.dart';

/// Talks to the FastAPI backend (`GET /v1/feed`, `/v1/search`, `/v1/articles/{id}`),
/// caches the first page of every feed on device, and falls back to bundled samples
/// in debug builds so the UI is always demo-able.
class NewsRepository {
  NewsRepository({required this.prefs, http.Client? client})
      : _client = client ?? http.Client();

  final SharedPreferences prefs;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String?> query = const {}]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    return base.replace(
      path: path,
      queryParameters: {
        for (final e in query.entries)
          if (e.value != null && e.value!.isNotEmpty) e.key: e.value!,
      },
    );
  }

  Future<dynamic> _get(Uri uri) async {
    final res = await _client.get(uri).timeout(AppConfig.requestTimeout);
    if (res.statusCode != 200) {
      throw http.ClientException('HTTP ${res.statusCode}', uri);
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  String _cacheKey(String category, String lang, String? state) =>
      'feed_cache/$category/$lang/${state ?? '-'}';

  Future<FeedPage> feed({
    required String category,
    required String lang,
    String? state,
    String? cursor,
  }) async {
    final key = _cacheKey(category, lang, state);
    try {
      final json = await _get(_uri('/v1/feed', {
        'category': category,
        'lang': lang,
        'state': state,
        'cursor': cursor,
        'limit': '${AppConfig.pageSize}',
      })) as Map<String, dynamic>;
      final items = [
        for (final j in json['items'] as List) Article.fromJson(j as Map<String, dynamic>),
      ];
      if (cursor == null) await prefs.setString(key, jsonEncode([for (final a in items) a.toJson()]));
      return FeedPage(items: items, nextCursor: json['next_cursor'] as String?);
    } catch (_) {
      if (cursor != null) rethrow; // paging failures surface as "load more" errors
      final cached = prefs.getString(key);
      if (cached != null) {
        final items = [
          for (final j in jsonDecode(cached) as List) Article.fromJson(j as Map<String, dynamic>),
        ];
        return FeedPage(items: items, offline: true);
      }
      if (AppConfig.allowSampleFallback) {
        final all = await _samples(lang);
        final items = category == 'top' ? all : all.where((a) => a.category == category).toList();
        return FeedPage(items: items, offline: true);
      }
      rethrow;
    }
  }

  Future<List<Article>> search({
    required String query,
    required String lang,
    String? category,
  }) async {
    List<Article> filter(List<Article> l) => category == null || category == 'top'
        ? l
        : l.where((a) => a.category == category).toList();
    try {
      final json = await _get(_uri('/v1/search', {'q': query, 'lang': lang, 'limit': '50'}));
      return filter([
        for (final j in json as List) Article.fromJson(j as Map<String, dynamic>),
      ]);
    } catch (_) {
      if (!AppConfig.allowSampleFallback) rethrow;
      final q = query.toLowerCase();
      final all = await _samples(lang);
      return filter(all
          .where((a) => '${a.title} ${a.summary} ${a.source}'.toLowerCase().contains(q))
          .toList());
    }
  }

  Future<Article> article(String id) async {
    try {
      return Article.fromJson(
          await _get(_uri('/v1/articles/$id')) as Map<String, dynamic>);
    } catch (_) {
      for (final lang in [for (final l in kLanguages) l.code]) {
        final hit = (await _samples(lang)).where((a) => a.id == id);
        if (hit.isNotEmpty) return hit.first;
      }
      rethrow;
    }
  }

  List<dynamic>? _sampleJson;

  Future<List<Article>> _samples(String lang) async {
    _sampleJson ??=
        jsonDecode(await rootBundle.loadString('assets/sample/stories.json')) as List;
    return [
      for (final Map<String, dynamic> s in _sampleJson!.cast())
        Article(
          id: s['id'] as String,
          title: (s['title'][lang] ?? s['title']['en']) as String,
          summary: (s['summary'][lang] ?? s['summary']['en']) as String,
          source: s['source'] as String,
          url: s['url'] as String,
          category: s['category'] as String,
          language: lang,
          publishedAt: DateTime.parse(s['publishedAt'] as String),
          imageUrl: s['image'] as String?,
          imageCredit: s['credit'] as String?,
        ),
    ];
  }
}
