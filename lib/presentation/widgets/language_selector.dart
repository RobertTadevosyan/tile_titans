import 'package:flutter/material.dart';
import 'package:flutter_2048/domain/locale_manager.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
    final bool isTablet;

  const LanguageSelector({
    super.key,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final localeManager = Provider.of<LocaleManager>(context);
    final currentLocale = localeManager.locale?.languageCode ?? 'en';
    final textStyle =  TextStyle(
      color: Color.fromARGB(255, 58, 115, 179),
      fontWeight: FontWeight.w900,
      fontSize: isTablet ? 26 : 16,
    );
    return DropdownButton<String>(
      value: currentLocale,
      onChanged: (newLangCode) {
        if (newLangCode != null && currentLocale != newLangCode) {
          localeManager.setLocale(Locale(newLangCode));
        }
      },
      items: [
        DropdownMenuItem(
          value: 'en',
          child: Text('🇺🇸 English', style: textStyle),
        ),
        DropdownMenuItem(
          value: 'hy',
          child: Text('🇦🇲 Հայերեն', style: textStyle),
        ),
        DropdownMenuItem(
          value: 'ru',
          child: Text('🇷🇺 Русский', style: textStyle),
        ),
        DropdownMenuItem(
          value: 'es',
          child: Text('🇪🇸 Español', style: textStyle),
        ),
      ],
    );
  }
}
