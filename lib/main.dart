import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/config/ad_policy.dart';
import 'package:flutter_2048/config/interstitial_service.dart';
import 'package:flutter_2048/domain/locale_manager.dart';
import 'package:flutter_2048/domain/prefs.dart';
import 'package:flutter_2048/firebase_options.dart';
import 'package:flutter_2048/presentation/controllers/game_controller.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/presentation/screens/home_screen.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/themes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  } else {
    await Firebase.initializeApp();
  }
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  final localeManager = LocaleManager();
  await localeManager.loadLocale();

  // Counting the session here, before any screen builds, keeps the ad-free
  // grace period honest across the whole app rather than per screen.
  final adPolicy = AdPolicy();
  await adPolicy.startSession();
  final interstitials = InterstitialService(adPolicy)..preload();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => localeManager),
        ChangeNotifierProvider(create: (_) => Prefs()),
        Provider<AdPolicy>.value(value: adPolicy),
        Provider<InterstitialService>.value(value: interstitials),
        // Statistics, achievements and trial records. Loaded eagerly so the
        // home screen can show rank and progress on first frame.
        ChangeNotifierProvider(create: (_) => ProgressStore()..load()),
        // The controller files finished runs into the progress store, so it is
        // handed the store rather than reaching for one itself.
        ChangeNotifierProxyProvider<ProgressStore, GameController>(
          create: (_) => GameController(),
          update: (_, progress, controller) =>
              (controller ?? GameController())..progressStore = progress,
        ),
      ],
      child: const GameApp(),
    ),
  );
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  Future<FirebaseAnalytics> _initAnalytics() async {
    // Ensures it's safe and ready
    return FirebaseAnalytics.instance;
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Initialize Yandex Ads only on mobile
      MobileAds.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeManager = Provider.of<LocaleManager>(context);
    return FutureBuilder<FirebaseAnalytics>(
      future: _initAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final analytics = snapshot.data!;
        return MaterialApp(
          locale: localeManager.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          title: 'Tile Titans',
          theme:
              themeProvider.isInitialized
                  ? themeProvider.themeData
                  : appThemeData[kDefaultTheme],
          home: const HomeScreen(),
          navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
        );
      },
    );
  }
}
