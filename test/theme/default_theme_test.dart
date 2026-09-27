import 'package:flutter_2048/core/theme/app_theme.dart';
import 'package:flutter_2048/core/theme/theme_provider.dart';
import 'package:flutter_2048/domain/prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The default theme is stated in one place and every fallback defers to it.
///
/// It was not: Prefs.getCurrentTheme returned Classic on its own, so changing
/// the default anywhere else had no visible effect at all — a fresh install
/// still opened green.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Forge is the default', () {
    expect(kDefaultTheme, AppTheme.Forge);
  });

  test('a player who has chosen nothing gets the default', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await Prefs().getCurrentTheme(), kDefaultTheme.name);
  });

  test('a player who has chosen keeps their choice', () async {
    SharedPreferences.setMockInitialValues({'theme': AppTheme.Ocean.name});
    expect(await Prefs().getCurrentTheme(), AppTheme.Ocean.name);
  });
}
