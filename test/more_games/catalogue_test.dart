import 'package:flutter_2048/domain/more_games/catalogue.dart';
import 'package:flutter_2048/domain/more_games/catalogue_fallback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsing', () {
    test('the built-in catalogue parses and contains this app', () {
      final apps = parseCatalogue(builtInCatalogue);
      expect(apps, isNotEmpty);
      expect(apps.map((a) => a.id), contains(selfAppId));
    });

    test('malformed JSON yields an empty list rather than throwing', () {
      // The catalogue is a remote file. A bad deploy must not crash the screen.
      expect(parseCatalogue('not json at all'), isEmpty);
      expect(parseCatalogue('{}'), isEmpty);
      expect(parseCatalogue('{"apps": "nope"}'), isEmpty);
    });

    test('an entry without an id or a play link is dropped', () {
      final apps = parseCatalogue('''
        {"apps": [
          {"name": "No id", "play": "https://play.google.com/x"},
          {"id": "a.b.c"},
          {"id": "d.e.f", "play": "https://play.google.com/ok"}
        ]}
      ''');
      expect(apps.map((a) => a.id), ['d.e.f']);
    });

    test('non-HTTPS URLs are refused', () {
      // A tampered catalogue must not be able to hand the app a link to open.
      final apps = parseCatalogue('''
        {"apps": [
          {"id": "a", "play": "http://play.google.com/insecure"},
          {"id": "b", "play": "javascript:alert(1)"},
          {"id": "c", "play": "market://details?id=c"},
          {"id": "d", "play": "https://play.google.com/fine",
           "icon": "http://insecure/icon.png"}
        ]}
      ''');
      expect(apps.map((a) => a.id), ['d']);
      expect(apps.single.icon, isNull, reason: 'insecure icon dropped');
    });

    test('a plain-string tagline is stored under English', () {
      final apps = parseCatalogue(
        '{"apps": [{"id": "a", "play": "https://x.example/a", '
        '"tagline": "Hello"}]}',
      );
      expect(apps.single.tagline('en'), 'Hello');
      expect(apps.single.tagline('ru'), 'Hello', reason: 'falls back to en');
    });

    test('a missing tagline language falls back, then to empty', () {
      final apps = parseCatalogue(
        '{"apps": [{"id": "a", "play": "https://x.example/a"}]}',
      );
      expect(apps.single.tagline('ru'), '');
    });

    test('hex colours parse in both lengths, and reject rubbish', () {
      expect(parseHexColor('#B8863B'), 0xFFB8863B);
      expect(parseHexColor('80B8863B'), 0x80B8863B);
      expect(parseHexColor('#FFF'), isNull);
      expect(parseHexColor('nope'), isNull);
      expect(parseHexColor(42), isNull);
    });
  });

  group('view', () {
    final apps = parseCatalogue('''
      {"apps": [
        {"id": "self", "name": "Us", "play": "https://x.example/self"},
        {"id": "other", "name": "Them", "play": "https://x.example/other"},
        {"id": "other", "name": "Dup", "play": "https://x.example/dup"},
        {"id": "ios-only", "name": "iOS", "play": "https://x.example/i",
         "appStore": "https://apps.apple.com/app/id1"}
      ]}
    ''');

    test('this app is the rate card, never a promoted row', () {
      final view = CatalogueView.of(
        apps,
        selfId: 'self',
        platform: StorePlatform.android,
      );
      expect(view.self?.id, 'self');
      expect(view.others.map((a) => a.id), isNot(contains('self')));
    });

    test('a duplicate id appears once', () {
      final view = CatalogueView.of(
        apps,
        selfId: 'self',
        platform: StorePlatform.android,
      );
      expect(view.others.where((a) => a.id == 'other'), hasLength(1));
    });

    test('only apps with a link for this platform are listed', () {
      final view = CatalogueView.of(
        apps,
        selfId: 'self',
        platform: StorePlatform.ios,
      );
      expect(view.others.map((a) => a.id), ['ios-only']);
    });

    test('an absent self entry is simply null', () {
      final view = CatalogueView.of(
        apps,
        selfId: 'nobody',
        platform: StorePlatform.android,
      );
      expect(view.self, isNull);
      expect(view.others, isNotEmpty);
    });
  });
}
