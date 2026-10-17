import 'dart:convert';
import 'dart:developer';

/// Store platforms the catalogue has links for.
enum StorePlatform { android, ios }

/// Tile shown while an icon loads or when it fails.
const int catalogueDefaultColor = 0xFFB8863B;
const String catalogueDefaultEmoji = '🎮';
const String catalogueFallbackLanguage = 'en';

/// This app's own id, so the catalogue can tell "us" from "them".
const String selfAppId = 'lets.play.game';

/// One app of the shared `apps.json` catalogue. Pure Dart, so the parsing
/// rules can be tested without a device or a network.
class CatalogueApp {
  const CatalogueApp({
    required this.id,
    required this.name,
    required this.taglines,
    required this.play,
    this.appStore,
    this.icon,
    this.color = catalogueDefaultColor,
    this.emoji = catalogueDefaultEmoji,
  });

  final String id;
  final String name;

  /// Tagline per language code; a plain-string tagline is stored under `en`.
  final Map<String, String> taglines;
  final String play;
  final String? appStore;
  final String? icon;

  /// ARGB colour of the fallback tile.
  final int color;
  final String emoji;

  /// The tagline for [language], else English, else any, else empty.
  String tagline(String language) =>
      taglines[language] ??
      taglines[catalogueFallbackLanguage] ??
      (taglines.isEmpty ? '' : taglines.values.first);

  /// The store link for [platform], or null when there is none.
  String? linkFor(StorePlatform platform) => switch (platform) {
    StorePlatform.android => play,
    StorePlatform.ios => appStore,
  };

  /// Parses one entry; null when `id` or `play` is missing or not a string.
  ///
  /// Every URL must be HTTPS. The catalogue is a remote file, so a bad or
  /// tampered entry must not be able to hand the app a `javascript:` or
  /// `market://` link it would then open.
  static CatalogueApp? tryParse(Object? json) {
    if (json is! Map) return null;
    final id = _text(json['id']);
    final play = _httpsUrl(json['play']);
    if (id == null || play == null) return null;
    return CatalogueApp(
      id: id,
      name: _text(json['name']) ?? id,
      taglines: _taglines(json['tagline']),
      play: play,
      appStore: _httpsUrl(json['appStore']),
      icon: _httpsUrl(json['icon']),
      color: parseHexColor(json['color']) ?? catalogueDefaultColor,
      emoji: _text(json['emoji']) ?? catalogueDefaultEmoji,
    );
  }

  static String? _text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;

  static String? _httpsUrl(Object? value) {
    final text = _text(value);
    if (text == null) return null;
    final uri = Uri.tryParse(text);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
        ? text
        : null;
  }

  static Map<String, String> _taglines(Object? value) {
    if (value is String) {
      final text = _text(value);
      return text == null ? const {} : {catalogueFallbackLanguage: text};
    }
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        if (entry.key is String && _text(entry.value) != null)
          entry.key as String: _text(entry.value)!,
    };
  }
}

/// `#RRGGBB` or `#AARRGGBB` as ARGB, or null when malformed.
int? parseHexColor(Object? value) {
  if (value is! String) return null;
  final hex = value.startsWith('#') ? value.substring(1) : value;
  if (hex.length != 6 && hex.length != 8) return null;
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return null;
  return hex.length == 6 ? 0xFF000000 | parsed : parsed;
}

/// Every valid app in [body]; empty (never throws) on malformed JSON.
List<CatalogueApp> parseCatalogue(String body) {
  try {
    final json = jsonDecode(body);
    final apps = json is Map ? json['apps'] : null;
    if (apps is! List) return const [];
    return apps.map(CatalogueApp.tryParse).nonNulls.toList();
  } on FormatException catch (e) {
    log('More games: catalogue is not valid JSON: $e', name: 'more_games');
    return const [];
  }
}

/// What the More games screen shows on [platform]: this app's own entry (for
/// the rate card) and the other apps that have a link there.
class CatalogueView {
  const CatalogueView({required this.self, required this.others});

  factory CatalogueView.of(
    List<CatalogueApp> apps, {
    required String selfId,
    required StorePlatform platform,
  }) {
    CatalogueApp? self;
    final others = <CatalogueApp>[];
    for (final app in apps) {
      if (app.id == selfId) {
        self ??= app;
      } else if (app.linkFor(platform) != null &&
          others.every((o) => o.id != app.id)) {
        others.add(app);
      }
    }
    return CatalogueView(self: self, others: others);
  }

  final CatalogueApp? self;
  final List<CatalogueApp> others;
}
