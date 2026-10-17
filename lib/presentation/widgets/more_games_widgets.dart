import 'package:flutter/material.dart';
import 'package:flutter_2048/content/titan_ranks.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/domain/more_games/catalogue.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/widgets/titan_emblem.dart';

const double moreGamesIconSize = 56;
const double moreGamesRateIconSize = 72;

/// A store icon from the network; the app's own colour and emoji show while it
/// loads and when it fails, so a row is never a blank square.
class CatalogueIcon extends StatelessWidget {
  const CatalogueIcon({super.key, required this.app, required this.size});

  final CatalogueApp app;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = _EmojiTile(app: app, size: size);
    final icon = app.icon;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: SizedBox.square(
        dimension: size,
        child:
            icon == null
                ? fallback
                : Image.network(
                  icon,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  semanticLabel: app.name,
                  // frameBuilder, not loadingBuilder: the latter only fires on
                  // download progress events, so a request that never gets a
                  // response at all — exactly what happens offline — drew
                  // nothing and left an empty square beside every name. A null
                  // frame means nothing has painted yet, whatever the reason.
                  frameBuilder:
                      (context, child, frame, wasSyncLoaded) =>
                          wasSyncLoaded || frame != null ? child : fallback,
                  errorBuilder: (context, error, stack) => fallback,
                ),
      ),
    );
  }
}

class _EmojiTile extends StatelessWidget {
  const _EmojiTile({required this.app, required this.size});

  final CatalogueApp app;
  final double size;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Color(app.color),
    child: Center(
      child: Text(app.emoji, style: TextStyle(fontSize: size * 0.5)),
    ),
  );
}

/// "Enjoying Tile Titans?" with the icon, five stars and a Rate button.
class RateCard extends StatelessWidget {
  const RateCard({super.key, required this.self, required this.onRate});

  /// This app's catalogue entry; null falls back to the drawn emblem.
  final CatalogueApp? self;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entry = self;
    return Card(
      key: const Key('more-games-rate-card'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            entry == null
                ? TitanEmblem(
                  emblem: Emblem.shield,
                  color: theme.primaryColor,
                  size: moreGamesRateIconSize,
                )
                : CatalogueIcon(app: entry, size: moreGamesRateIconSize),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.moreGamesEnjoying(l10n.appTitle),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: theme.primaryColor,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.moreGamesRateBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: titanMutedOn(
                        theme.scaffoldBackgroundColor,
                        scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const Key('more-games-rate'),
              onPressed: onRate,
              style: FilledButton.styleFrom(
                backgroundColor: titanButtonFill(context),
                foregroundColor: titanButtonLabel(context),
              ),
              child: Text(l10n.moreGamesRate),
            ),
          ],
        ),
      ),
    );
  }
}

/// One other app: icon, name, tagline; the whole row opens its store page.
class CatalogueRow extends StatelessWidget {
  const CatalogueRow({
    super.key,
    required this.app,
    required this.language,
    required this.onTap,
  });

  final CatalogueApp app;
  final String language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tagline = app.tagline(language);
    return Card(
      child: ListTile(
        key: Key('more-games-${app.id}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CatalogueIcon(app: app, size: moreGamesIconSize),
        title: Text(app.name),
        subtitle: tagline.isEmpty ? null : Text(tagline),
        trailing: Icon(
          Icons.open_in_new,
          semanticLabel: l10n.moreGamesOpenInStore,
        ),
        onTap: onTap,
      ),
    );
  }
}
