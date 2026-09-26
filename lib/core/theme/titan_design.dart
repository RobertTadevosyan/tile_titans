import 'package:flutter/material.dart';

/// The design system.
///
/// One source for spacing, radius, motion and text roles so screens compose
/// instead of carrying their own styling. The audit found the opposite: four
/// near-duplicate layout builders in one screen, each with its own paddings and
/// font sizes.
///
/// Colour deliberately stays with the existing `ThemeProvider` palettes — those
/// are a shipped, user-facing feature and the redesign should not quietly
/// replace them.
/// Luminance at which dark foreground beats light.
///
/// Derived, not guessed: contrast against white is 1.05 / (L + 0.05) and
/// against black is (L + 0.05) / 0.05, equal at L ≈ 0.179.
const double kContrastCrossover = 0.179;

/// A foreground colour guaranteed to be readable on [background].
Color titanForegroundOn(Color background) =>
    background.computeLuminance() > kContrastCrossover
        ? const Color(0xFF14181C)
        : const Color(0xFFF7F4F0);

class TitanSpacing {
  const TitanSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class TitanRadius {
  const TitanRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;

  static BorderRadius get small => BorderRadius.circular(sm);
  static BorderRadius get medium => BorderRadius.circular(md);
  static BorderRadius get large => BorderRadius.circular(lg);
}

class TitanMotion {
  const TitanMotion._();

  /// State changes that should feel instant but not jarring.
  static const Duration quick = Duration(milliseconds: 120);

  /// The default for most transitions.
  static const Duration standard = Duration(milliseconds: 200);

  /// Entrances and anything that travels a distance.
  static const Duration slow = Duration(milliseconds: 280);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasis = Curves.easeOutBack;
}

/// Layout breakpoints. A phone gets a single column; wider surfaces get a
/// constrained body rather than text lines stretched to 1000 px.
class TitanBreakpoints {
  const TitanBreakpoints._();

  static const double compact = 600;
  static const double expanded = 900;

  /// Page bodies never exceed this, so tablets and unfolded foldables stay
  /// readable instead of sprawling.
  static const double maxBodyWidth = 680;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide < compact;
}

/// Typography roles.
///
/// Identity lives in the display and heading faces. Numerals on the board are
/// deliberately excluded — legibility there outranks personality.
class TitanText {
  const TitanText._();

  static TextStyle display(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                height: 1.05,
                color: Theme.of(context).colorScheme.onSurface,
              ) ??
      const TextStyle(fontSize: 28, fontWeight: FontWeight.w800);

  static TextStyle sectionLabel(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: _muted(context),
      );

  static TextStyle cardTitle(BuildContext context) => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle cardBody(BuildContext context) => TextStyle(
        fontSize: 13,
        height: 1.3,
        color: _muted(context),
      );

  static TextStyle metric(BuildContext context) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static Color _muted(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return onSurface.withValues(alpha: 0.65);
  }
}

/// Wraps a page body so every screen gets the same gutters and width cap.
class TitanPage extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const TitanPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: TitanSpacing.lg,
      vertical: TitanSpacing.md,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: TitanBreakpoints.maxBodyWidth,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A small caps-ish label that heads a group of cards.
class TitanSectionHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const TitanSectionHeader({super.key, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: TitanSpacing.lg,
        bottom: TitanSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: TitanText.sectionLabel(context),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// The standard tappable card. Everything selectable on the home screen is one
/// of these, so touch targets and corner radii cannot drift between screens.
class TitanCard extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsets padding;
  final Color? accent;

  /// Draws the card as the page's primary action.
  final bool prominent;

  const TitanCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(TitanSpacing.lg),
    this.accent,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = accent ?? theme.primaryColor;
    final surface = prominent
        ? base
        : Color.alphaBlend(
            base.withValues(alpha: 0.1),
            theme.scaffoldBackgroundColor,
          );

    // A prominent card is filled with the accent colour, so text inside it
    // must not keep resolving against the page's onSurface — on a dark theme
    // that is near-white, and near-white on ember is unreadable. Overriding
    // onSurface for the subtree makes every TitanText helper, and any icon,
    // pick a foreground that actually contrasts with this card.
    final foreground = titanForegroundOn(surface);
    final scoped = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(onSurface: foreground),
      iconTheme: theme.iconTheme.copyWith(color: foreground),
    );

    return Semantics(
      button: onTap != null,
      child: Material(
        color: surface,
        borderRadius: TitanRadius.large,
        clipBehavior: Clip.antiAlias,
        elevation: prominent ? 3 : 0,
        child: InkWell(
          onTap: onTap,
          // Comfortably above the 48dp minimum target.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: padding,
              child: Theme(
                data: scoped,
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: foreground),
                  child: IconTheme.merge(
                    data: IconThemeData(color: foreground),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled figure, used across statistics and the home screen.
class TitanMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const TitanMetric({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TitanText.metric(context),
        ),
        const SizedBox(height: TitanSpacing.xs),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TitanText.cardBody(context),
        ),
      ],
    );
  }
}

/// Formats large numbers so a nine-digit score cannot blow out a card.
String titanCompact(int value) {
  if (value < 1000) return '$value';
  if (value < 1000000) {
    final k = value / 1000;
    return '${k.toStringAsFixed(k < 10 ? 1 : 0)}K';
  }
  final m = value / 1000000;
  return '${m.toStringAsFixed(m < 10 ? 1 : 0)}M';
}

/// Formats a duration in seconds as a short human string.
String titanDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final minutes = seconds ~/ 60;
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final remaining = minutes % 60;
  return remaining == 0 ? '${hours}h' : '${hours}h ${remaining}m';
}
