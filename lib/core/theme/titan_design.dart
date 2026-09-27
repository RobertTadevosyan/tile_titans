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

/// A softened [foreground] that still clears AA against [surface].
///
/// Secondary text is dimmed so it sits below the heading, but dimming costs
/// contrast. A flat 65% alpha put the CONTINUE card's subtitle at 3.54:1 on
/// the deep green fill — visible, under the floor for 13px text. The fade now
/// stops as soon as it would become unreadable rather than at a fixed alpha.
Color titanMutedOn(Color surface, Color foreground) {
  for (var alpha = 0.65; alpha < 1.0; alpha += 0.05) {
    final blended =
        Color.alphaBlend(foreground.withValues(alpha: alpha), surface);
    if (titanContrastRatio(surface, blended) >= kMinBodyContrast) {
      return blended;
    }
  }
  return foreground;
}

/// An app bar whose title is guaranteed to be readable on it.
///
/// Every theme hardcoded its bar's foreground, and two of them chose a colour
/// that does not survive contact with their own fill: Classic's white on
/// #66BB6A measured 2.36:1 and Ocean's 3.32:1, on the title that sits at the
/// top of every screen. The fill goes through the same rule as a prominent
/// card, so a mid-tone bar is deepened out of the muddy band rather than being
/// left readable-but-washed-out, and the title colour is measured against
/// whatever the fill ends up being.
AppBarTheme titanAppBar(Color background) {
  final surface = titanProminentSurface(background);
  return AppBarTheme(
    backgroundColor: surface,
    foregroundColor: titanForegroundOn(surface),
    elevation: 0,
  );
}

/// The fill and text colour for a dialog that is filled with the theme accent.
///
/// The end-of-game dialogs used the app bar colour as their background and then
/// let the body text fall back to the page's `onSurface`. On Classic that put
/// near-black body text on a mid green while the title above it was white —
/// two different answers to the same question in one dialog. Both now come from
/// here, so every theme gets one settled surface and one readable foreground.
({Color surface, Color foreground}) titanDialogColors(BuildContext context) {
  final theme = Theme.of(context);
  final base =
      theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
  final surface = titanProminentSurface(base);
  return (surface: surface, foreground: titanForegroundOn(surface));
}

/// A foreground colour guaranteed to be readable on [background].
Color titanForegroundOn(Color background) =>
    background.computeLuminance() > kContrastCrossover
        ? const Color(0xFF14181C)
        : const Color(0xFFF7F4F0);

/// The contrast ratio between two colours, as WCAG defines it.
double titanContrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// The minimum contrast for body text, from WCAG AA.
const double kMinBodyContrast = 4.5;

/// The fill for a prominent card, pushed away from the muddy middle.
///
/// Maximising the contrast ratio alone is not enough. A mid-luminance accent —
/// Classic's #81C784 sits near 0.47 — technically scores well against black,
/// but dark text on a mid green reads washed out and cheap. Anything in that
/// band is deepened until white text sits on it cleanly, which is both more
/// readable and more deliberate-looking.
///
/// Then the result is pushed further from the crossover until it clears AA for
/// body text. Retro's brown needed this: it was already dark enough to take
/// white text and still only reached 4.3:1, which is under the floor.
Color titanProminentSurface(Color accent) {
  var surface = accent;
  final luminance = accent.computeLuminance();

  if (luminance > 0.22 && luminance < 0.72) {
    // Darken toward a confident, saturated version of the same hue rather than
    // desaturating it, so each theme keeps its identity.
    final hsl = HSLColor.fromColor(accent);
    surface = hsl
        .withLightness((hsl.lightness * 0.45).clamp(0.12, 0.34))
        .withSaturation((hsl.saturation * 1.15).clamp(0.0, 1.0))
        .toColor();
  }

  // Move away from the crossover in whichever direction the text is already
  // on, so each step adds contrast instead of cancelling it out.
  final goesDarker = surface.computeLuminance() <= kContrastCrossover;
  var guard = 0;
  while (titanContrastRatio(surface, titanForegroundOn(surface)) <
          kMinBodyContrast &&
      guard < 40) {
    guard++;
    final hsl = HSLColor.fromColor(surface);
    final step = goesDarker ? -0.02 : 0.02;
    final next = (hsl.lightness + step).clamp(0.0, 1.0);
    if (next == hsl.lightness) break; // Nowhere further to go.
    surface = hsl.withLightness(next).toColor();
  }

  return surface;
}

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
    // Inside a TitanCard both of these are scoped to that card, so secondary
    // text is measured against the fill it actually sits on.
    final scheme = Theme.of(context).colorScheme;
    return titanMutedOn(scheme.surface, scheme.onSurface);
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
  final Widget? child;

  /// The card's content, built against the card's own theme.
  ///
  /// A prominent card overrides `onSurface` for its subtree, but a [child] the
  /// caller already built sits *above* that override and keeps resolving
  /// against the page. That is how the completion dialog ended up with dark
  /// text on a dark green fill while its icon, resolved in place, turned white
  /// — the card looked fixed and its heading was still unreadable. Prominent
  /// cards must use this, which the constructor enforces.
  final WidgetBuilder? contentBuilder;

  final EdgeInsets padding;
  final Color? accent;

  /// Draws the card as the page's primary action.
  final bool prominent;

  const TitanCard({
    super.key,
    this.child,
    this.contentBuilder,
    this.onTap,
    this.padding = const EdgeInsets.all(TitanSpacing.lg),
    this.accent,
    this.prominent = false,
  })  : assert(child != null || contentBuilder != null,
            'TitanCard needs either child or contentBuilder'),
        assert(!prominent || contentBuilder != null,
            'A prominent TitanCard must use contentBuilder: its fill is the '
            'accent colour, and a child built by the caller resolves its text '
            'against the page theme instead of this card.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = accent ?? theme.primaryColor;
    final surface = prominent
        ? titanProminentSurface(base)
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
      // `surface` travels with `onSurface` so anything inside the card that
      // softens text can measure the fade against this fill.
      colorScheme: theme.colorScheme
          .copyWith(onSurface: foreground, surface: surface),
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
                    // Built here, below the scoped theme, so TitanText helpers
                    // resolve against this card rather than the page.
                    child: Builder(
                      builder: (context) =>
                          contentBuilder?.call(context) ?? child!,
                    ),
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
