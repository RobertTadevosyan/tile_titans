import 'package:flutter/material.dart';
import 'package:flutter_2048/domain/locale_manager.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// One entry per supported language.
///
/// Names are written in the language itself — a player looking for Japanese
/// scans for 日本語, not for "Japanese" spelled in whatever locale the app
/// happens to be showing.
const Map<String, String> supportedLanguageNames = {
  'en': '🇺🇸 English',
  'de': '🇩🇪 Deutsch',
  'es': '🇪🇸 Español',
  'fr': '🇫🇷 Français',
  'it': '🇮🇹 Italiano',
  'pt': '🇵🇹 Português',
  'tr': '🇹🇷 Türkçe',
  'ru': '🇷🇺 Русский',
  'hy': '🇦🇲 Հայերեն',
  'ja': '🇯🇵 日本語',
};

class LanguageSelector extends StatelessWidget {
  final bool isTablet;

  const LanguageSelector({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final localeManager = Provider.of<LocaleManager>(context);
    final current = localeManager.locale?.languageCode ?? 'en';

    // Only offer languages the app actually ships translations for, so the
    // list cannot drift out of step with the .arb files.
    final available = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .where(supportedLanguageNames.containsKey)
        .toList();

    final style = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: isTablet ? 22 : 15,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return DropdownButton<String>(
      value: available.contains(current) ? current : 'en',
      isDense: true,
      // Ten entries do not fit on a phone; the menu scrolls.
      menuMaxHeight: 360,
      underline: const SizedBox.shrink(),
      onChanged: (code) {
        if (code == null || code == current) return;
        localeManager.setLocale(Locale(code));
      },
      items: [
        for (final code in available)
          DropdownMenuItem(
            value: code,
            child: Text(supportedLanguageNames[code]!, style: style),
          ),
      ],
    );
  }
}
