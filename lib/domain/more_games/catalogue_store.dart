import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_2048/domain/more_games/catalogue.dart';
import 'package:flutter_2048/domain/more_games/catalogue_fallback.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared catalogue of the developer's apps (privacy repo, GitHub Pages).
const String moreGamesCatalogueUrl =
    'https://roberttadevosyan.github.io/privacy/apps.json';
const Duration moreGamesFetchTimeout = Duration(seconds: 6);
const String _cacheKey = 'more_games_catalogue';

/// Downloads the raw catalogue JSON; the app uses HTTPS, tests a stub.
abstract class CatalogueFetcher {
  Future<String> fetch();
}

class HttpCatalogueFetcher implements CatalogueFetcher {
  HttpCatalogueFetcher({Uri? url, this.timeout = moreGamesFetchTimeout})
    : url = url ?? Uri.parse(moreGamesCatalogueUrl);

  final Uri url;
  final Duration timeout;

  @override
  Future<String> fetch() async {
    if (url.scheme != 'https') {
      throw ArgumentError.value(url, 'url', 'catalogue must use HTTPS');
    }
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final response = await (await client.getUrl(url)).close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${response.statusCode}', uri: url);
      }
      return await response.transform(utf8.decoder).join().timeout(timeout);
    } finally {
      client.close(force: true);
    }
  }
}

/// Returns a canned body, or throws when [body] is null (offline).
@visibleForTesting
class StubCatalogueFetcher implements CatalogueFetcher {
  StubCatalogueFetcher(this.body);

  final String? body;
  int calls = 0;

  @override
  Future<String> fetch() async {
    calls++;
    final body = this.body;
    if (body == null) throw const SocketException('offline');
    return body;
  }
}

/// The catalogue, newest first: the cached (or built-in) list straight away,
/// replaced by the downloaded one when the fetch succeeds.
///
/// The screen never waits on the network. Showing four known apps instantly
/// and correcting them a second later is better than a spinner over a list
/// that barely changes between releases.
class CatalogueStore extends ChangeNotifier {
  CatalogueStore({CatalogueFetcher? fetcher})
    : _fetcher = fetcher ?? HttpCatalogueFetcher();

  final CatalogueFetcher _fetcher;
  List<CatalogueApp> _apps = const [];
  bool _disposed = false;

  List<CatalogueApp> get apps => _apps;

  /// Loads the cache, then refreshes from the network in the background.
  Future<void> load() async {
    _apps = parseCatalogue(await _cached() ?? builtInCatalogue);
    _notify();
    await _refresh();
  }

  Future<String?> _cached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final body = prefs.getString(_cacheKey);
      // An empty cache is worse than none: fall through to the built-in copy.
      return (body != null && parseCatalogue(body).isNotEmpty) ? body : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _refresh() async {
    try {
      final body = await _fetcher.fetch();
      final apps = parseCatalogue(body);
      if (apps.isEmpty) {
        log('More games: downloaded catalogue has no apps', name: 'more_games');
        return;
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, body);
      } catch (_) {
        // Caching is an optimisation; failing to write it changes nothing.
      }
      _apps = apps;
      _notify();
    } catch (error) {
      // Offline or GitHub Pages down: keep showing what we already have.
      log(
        'More games: catalogue fetch failed',
        name: 'more_games',
        error: error,
      );
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
