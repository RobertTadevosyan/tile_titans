import 'package:flutter_2048/config/ad_region.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('country resolution', () {
    test('a Yandex-region clock zone wins over the locale', () {
      // The case this rule exists for: a phone physically in Moscow whose
      // owner reads the app in English. The locale would route to AdMob,
      // which cannot serve there, and the player would see no ads at all.
      expect(
        resolveCountry(timeZone: 'Europe/Moscow', localeCountry: 'US'),
        'RU',
      );
    });

    test('falls back to the locale region outside the Yandex zones', () {
      expect(
        resolveCountry(timeZone: 'Europe/Berlin', localeCountry: 'DE'),
        'DE',
      );
    });

    test('ignores a malformed locale region', () {
      expect(resolveCountry(localeCountry: 'Deutschland'), isNull);
      expect(resolveCountry(localeCountry: ''), isNull);
    });

    test('normalises case and whitespace', () {
      expect(resolveCountry(localeCountry: ' de '), 'DE');
    });

    test('is null when nothing is known', () {
      expect(resolveCountry(), isNull);
    });
  });

  group('network choice', () {
    test('every Yandex country routes to Yandex', () {
      for (final country in yandexCountries) {
        expect(
          chooseAdNetwork(localeCountry: country),
          AdNetwork.yandex,
          reason: '$country should use Yandex',
        );
      }
    });

    test('the large AdMob markets route to AdMob', () {
      for (final country in ['US', 'GB', 'DE', 'FR', 'IN', 'BR', 'JP']) {
        expect(
          chooseAdNetwork(localeCountry: country),
          AdNetwork.admob,
          reason: '$country should use AdMob',
        );
      }
    });

    test('an unknown country falls to AdMob', () {
      // AdMob serves more of the world, and an unfilled slot earns nothing.
      expect(chooseAdNetwork(), AdNetwork.admob);
    });

    test('a Russian clock zone routes to Yandex whatever the locale says', () {
      expect(
        chooseAdNetwork(timeZone: 'Asia/Vladivostok', localeCountry: 'GB'),
        AdNetwork.yandex,
      );
    });

    test('every mapped time zone resolves to a Yandex country', () {
      // Guards the two tables against drifting apart: a zone added to one
      // without the other would silently route that region to AdMob.
      for (final entry in yandexTimeZones.entries) {
        expect(
          yandexCountries.contains(entry.value),
          isTrue,
          reason: '${entry.key} maps to ${entry.value}, which is not routed',
        );
        expect(chooseAdNetwork(timeZone: entry.key), AdNetwork.yandex);
      }
    });
  });
}
