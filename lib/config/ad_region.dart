import 'dart:ui';

/// Which network serves this player.
enum AdNetwork { admob, yandex }

/// Countries served by Yandex Ads; everywhere else uses AdMob.
///
/// AdMob does not serve in Russia and fills poorly in the neighbouring
/// markets, so the choice is regional rather than a preference.
const Set<String> yandexCountries = {
  'RU',
  'BY',
  'KZ',
  'UZ',
  'KG',
  'TJ',
  'AM',
  'AZ',
  'GE',
  'MD',
  'TM',
};

/// IANA time zones of the Yandex countries.
///
/// The clock's zone says where the phone physically is: neither a VPN nor the
/// Region setting changes it, which makes it a better signal than the locale
/// for deciding which network can actually serve.
const Map<String, String> yandexTimeZones = {
  'Europe/Moscow': 'RU',
  'Europe/Kaliningrad': 'RU',
  'Europe/Simferopol': 'RU',
  'Europe/Kirov': 'RU',
  'Europe/Volgograd': 'RU',
  'Europe/Astrakhan': 'RU',
  'Europe/Saratov': 'RU',
  'Europe/Ulyanovsk': 'RU',
  'Europe/Samara': 'RU',
  'Asia/Yekaterinburg': 'RU',
  'Asia/Omsk': 'RU',
  'Asia/Novosibirsk': 'RU',
  'Asia/Barnaul': 'RU',
  'Asia/Tomsk': 'RU',
  'Asia/Novokuznetsk': 'RU',
  'Asia/Krasnoyarsk': 'RU',
  'Asia/Irkutsk': 'RU',
  'Asia/Chita': 'RU',
  'Asia/Yakutsk': 'RU',
  'Asia/Khandyga': 'RU',
  'Asia/Vladivostok': 'RU',
  'Asia/Ust-Nera': 'RU',
  'Asia/Magadan': 'RU',
  'Asia/Sakhalin': 'RU',
  'Asia/Srednekolymsk': 'RU',
  'Asia/Kamchatka': 'RU',
  'Asia/Anadyr': 'RU',
  'W-SU': 'RU',
  'Europe/Minsk': 'BY',
  'Asia/Almaty': 'KZ',
  'Asia/Qyzylorda': 'KZ',
  'Asia/Qostanay': 'KZ',
  'Asia/Aqtobe': 'KZ',
  'Asia/Aqtau': 'KZ',
  'Asia/Atyrau': 'KZ',
  'Asia/Oral': 'KZ',
  'Asia/Tashkent': 'UZ',
  'Asia/Samarkand': 'UZ',
  'Asia/Bishkek': 'KG',
  'Asia/Dushanbe': 'TJ',
  'Asia/Yerevan': 'AM',
  'Asia/Baku': 'AZ',
  'Asia/Tbilisi': 'GE',
  'Europe/Chisinau': 'MD',
  'Europe/Tiraspol': 'MD',
  'Asia/Ashgabat': 'TM',
  'Asia/Ashkhabad': 'TM',
};

/// The player's country as the routing sees it: the clock zone's when that
/// zone is in the Yandex region, otherwise the locale region; null when
/// neither is known.
String? resolveCountry({String? timeZone, String? localeCountry}) =>
    yandexTimeZones[timeZone?.trim()] ?? _normalise(localeCountry);

String? _normalise(String? code) {
  if (code == null) return null;
  final trimmed = code.trim().toUpperCase();
  return trimmed.length == 2 ? trimmed : null;
}

/// Pure routing rule, so it can be tested without a device.
///
/// Unknown country falls to AdMob: it serves in more of the world, and an
/// unfilled Yandex slot earns nothing.
AdNetwork chooseAdNetwork({String? timeZone, String? localeCountry}) {
  final country = resolveCountry(
    timeZone: timeZone,
    localeCountry: localeCountry,
  );
  if (country == null) return AdNetwork.admob;
  return yandexCountries.contains(country) ? AdNetwork.yandex : AdNetwork.admob;
}

String? localeCountry() => PlatformDispatcher.instance.locale.countryCode;
