import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/domain/more_games/catalogue.dart';
import 'package:flutter_2048/domain/more_games/catalogue_store.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/widgets/more_games_widgets.dart';
import 'package:flutter_2048/presentation/widgets/screen_banner.dart';
import 'package:url_launcher/url_launcher.dart';

/// The store this build links to. Everything but iOS uses Play.
StorePlatform currentStorePlatform() =>
    !kIsWeb && Platform.isIOS ? StorePlatform.ios : StorePlatform.android;

/// The developer's other games, from the shared remote catalogue, with a plain
/// "rate this app" card on top.
///
/// No rewards and no in-app review prompt: a rating that is bought with an
/// in-game bonus is worth less than one that is not, and both stores take a
/// dim view of incentivised reviews.
class MoreGamesScreen extends StatefulWidget {
  const MoreGamesScreen({super.key, this.store});

  /// Injectable for tests; production builds its own.
  final CatalogueStore? store;

  @override
  State<MoreGamesScreen> createState() => _MoreGamesScreenState();
}

class _MoreGamesScreenState extends State<MoreGamesScreen> {
  late final CatalogueStore _store = widget.store ?? CatalogueStore();
  late final bool _ownsStore = widget.store == null;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChanged);
    _store.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_onChanged);
    if (_ownsStore) _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final platform = currentStorePlatform();
    final view = CatalogueView.of(
      _store.apps,
      selfId: selfAppId,
      platform: platform,
    );
    final language = Localizations.localeOf(context).languageCode;

    return Scaffold(
      bottomNavigationBar: const ScreenBanner(),
      appBar: AppBar(title: Text(l10n.moreGames)),
      body: TitanPage(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RateCard(self: view.self, onRate: _rate),
            const SizedBox(height: 16),
            if (view.others.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.moreGamesEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l10n.moreGamesSubtitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: titanMutedOn(
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            for (final app in view.others)
              CatalogueRow(
                app: app,
                language: language,
                onTap: () => _open(app.linkFor(platform)),
              ),
          ],
        ),
      ),
    );
  }

  /// Play's own app page; `market://` would be better but needs a package
  /// visibility entry, and the https link opens the store app anyway.
  void _rate() =>
      _open('https://play.google.com/store/apps/details?id=$selfAppId');

  Future<void> _open(String? url) async {
    if (url == null) return;
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (opened || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.moreGamesOpenFailed),
      ),
    );
  }
}
