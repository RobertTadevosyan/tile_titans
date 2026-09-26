import 'package:flutter/material.dart';
import 'package:flutter_2048/config/ads_config.dart';
import 'package:flutter_2048/utils/helper.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'package:flutter_2048/content/titan_ranks.dart';
import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/domain/engine/rules.dart';
import 'package:flutter_2048/domain/engine/trial.dart';
import 'package:flutter_2048/presentation/controllers/game_controller.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/l10n_content.dart';
import 'package:flutter_2048/presentation/screens/game_screen.dart';
import 'package:flutter_2048/presentation/screens/leaderboard_screen.dart';
import 'package:flutter_2048/presentation/screens/settings_screen.dart';
import 'package:flutter_2048/presentation/screens/stats_screen.dart';
import 'package:flutter_2048/presentation/screens/trial_screen.dart';
import 'package:flutter_2048/presentation/screens/trials_screen.dart';
import 'package:flutter_2048/presentation/widgets/titan_emblem.dart';
import 'package:provider/provider.dart';

/// The launch surface.
///
/// Before this, the app opened straight onto a playable board, so nothing
/// communicated that the game had modes, authored puzzles, competition or
/// progression — which is precisely why it read as a 2048 clone. Everything
/// that distinguishes Tile Titans is now one tap from launch, in the order a
/// player (or a reviewer) would want it.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _adRequest = AdRequest(
    contextQuery: 'puzzle, games, mobile apps, games',
  );

  BannerAd? _banner;
  int _bannerHeight = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_banner == null && isMobile()) {
      _loadBanner();
    }
  }

  /// The home screen is browsed rather than played, so a banner here cannot
  /// cause a mis-tap mid-swipe the way one under the board could.
  Future<void> _loadBanner() async {
    final width = MediaQuery.sizeOf(context).width.toInt();
    final size = BannerAdSize.sticky(width: width);
    final calculated = await size.getCalculatedBannerAdSize();
    if (!mounted) return;

    final ad = BannerAd(
      adUnitId: AdsConfig.getHomeBannerID(),
      adSize: size,
      adRequest: _adRequest,
      onAdLoaded: () {},
      // Collapse the slot if nothing fills, so the page never shows a gap.
      onAdFailedToLoad: (_) {
        if (!mounted) return;
        setState(() => _bannerHeight = 0);
      },
      onAdClicked: () {},
      onLeftApplication: () {},
      onReturnedToApplication: () {},
      onImpression: (_) {},
    );

    // Do not call loadAd() here. This SDK registers the banner's platform
    // channel only when its AdWidget is mounted, so loading first throws
    // MissingPluginException — and because the slot was sized from onAdLoaded,
    // the widget never mounted and the ad could never load. Size the slot from
    // the calculated size and let mounting drive the request.
    setState(() {
      _banner = ad;
      _bannerHeight = calculated.height;
    });
  }

  @override
  void dispose() {
    _banner?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = context.watch<ProgressStore>();
    final daily = dailyTrialFor(DateTime.now());

    return Scaffold(
      bottomNavigationBar: _bannerHeight > 0 && _banner != null
          ? SafeArea(
              child: SizedBox(
                height: _bannerHeight.toDouble(),
                child: AdWidget(bannerAd: _banner!),
              ),
            )
          : null,
      body: SafeArea(
        child: TitanPage(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Masthead(l10n: l10n, progress: progress),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: TitanSpacing.lg),
                    _PrimaryAction(l10n: l10n),
                    const SizedBox(height: TitanSpacing.md),
                    _DailyTrialCard(
                      l10n: l10n,
                      trial: daily,
                      progress: progress,
                    ),
                    TitanSectionHeader(label: l10n.homeChooseChallenge),
                    _ModeGrid(l10n: l10n),
                    TitanSectionHeader(label: l10n.homeTitanTrials),
                    _TrialsCard(l10n: l10n, progress: progress),
                    const SizedBox(height: TitanSpacing.md),
                    _SecondaryRow(l10n: l10n),
                    const SizedBox(height: TitanSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Masthead extends StatelessWidget {
  final AppLocalizations l10n;
  final ProgressStore progress;

  const _Masthead({required this.l10n, required this.progress});

  @override
  Widget build(BuildContext context) {
    final rank = progress.rank;
    final next = progress.nextRank;
    final points = progress.points;

    // Progress toward the next rung, or a full bar at the top of the path.
    final span = next == null ? 1 : (next.required - rank.required);
    final into = next == null ? 1 : (points - rank.required);
    final fraction = span <= 0 ? 1.0 : (into / span).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(top: TitanSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.appTitle, style: TitanText.display(context)),
                const SizedBox(height: TitanSpacing.xs),
                Text(
                  '${l10n.homeRank}: ${ContentStrings.rank(l10n, rank)}',
                  style: TitanText.cardBody(context),
                ),
                const SizedBox(height: TitanSpacing.sm),
                // Rank is derived from achievement points only — it cannot be
                // bought or ground out, so the bar always reflects real play.
                ClipRRect(
                  borderRadius: TitanRadius.small,
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: TitanSpacing.md),
          Semantics(
            label: '${l10n.homeRank}: ${ContentStrings.rank(l10n, rank)}',
            child: TitanEmblem(
              emblem: _emblemForRank(rank.name),
              color: Theme.of(context).primaryColor,
              size: 44,
              weight: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Ranks borrow sigils from the tile ladder so the two systems read as one
  /// visual language rather than two unrelated icon sets.
  Emblem _emblemForRank(String rankName) {
    switch (rankName) {
      case 'Warrior':
        return Emblem.crossedAxes;
      case 'Champion':
        return Emblem.crown;
      case 'Titan':
        return Emblem.rune;
      case 'Legend':
        return Emblem.sun;
      default:
        return Emblem.shield;
    }
  }
}

class _PrimaryAction extends StatelessWidget {
  final AppLocalizations l10n;

  const _PrimaryAction({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return TitanCard(
      prominent: true,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const GameScreen()),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: TitanSpacing.lg,
        vertical: TitanSpacing.xl,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeContinue.toUpperCase(),
                  style: TitanText.display(context).copyWith(fontSize: 24),
                ),
                const SizedBox(height: TitanSpacing.xs),
                Text(l10n.homePlayed, style: TitanText.cardBody(context)),
              ],
            ),
          ),
          const Icon(Icons.play_arrow_rounded, size: 40),
        ],
      ),
    );
  }
}

class _DailyTrialCard extends StatelessWidget {
  final AppLocalizations l10n;
  final Trial trial;
  final ProgressStore progress;

  const _DailyTrialCard({
    required this.l10n,
    required this.trial,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final record = progress.recordFor(trial.id);
    final streak = progress.dailyStreak;

    return TitanCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TrialScreen(trial: trial, isDaily: true),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: TitanSpacing.sm),
              Expanded(
                child: Text(
                  l10n.homeDailyTrial.toUpperCase(),
                  style: TitanText.sectionLabel(context),
                ),
              ),
              if (streak > 0)
                Text(
                  l10n.homeStreakDays(streak),
                  style: TitanText.cardBody(context),
                ),
            ],
          ),
          const SizedBox(height: TitanSpacing.sm),
          Text(
            ContentStrings.objective(l10n, trial.objective),
            style: TitanText.cardTitle(context),
          ),
          const SizedBox(height: TitanSpacing.sm),
          Wrap(
            spacing: TitanSpacing.sm,
            runSpacing: TitanSpacing.xs,
            children: [
              if (trial.constraints.moveLimit != null)
                _Chip(label: l10n.trialMoveLimit(trial.constraints.moveLimit!)),
              if (trial.constraints.timeLimit != null)
                _Chip(label: l10n.trialTimeLimit(trial.constraints.timeLimit!)),
              if (!trial.constraints.allowUndo) _Chip(label: l10n.trialNoUndo),
              _Chip(label: '${trial.gridSize}×${trial.gridSize}'),
              if (record?.completed == true)
                _Chip(
                  label: '${l10n.homeBest}: ${record!.bestMoves}',
                  highlighted: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeGrid extends StatelessWidget {
  final AppLocalizations l10n;

  const _ModeGrid({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final modes = <({
      String name,
      String description,
      IconData icon,
      RuleSet rules
    })>[
      (
        name: l10n.modeClassic,
        description: l10n.modeClassicDesc,
        icon: Icons.grid_4x4_rounded,
        rules: RuleSet.classic
      ),
      (
        name: l10n.modeZen,
        description: l10n.modeZenDesc,
        icon: Icons.spa_rounded,
        rules: RuleSet.zen
      ),
      (
        name: l10n.modeTimeAttack,
        description: l10n.modeTimeAttackDesc,
        icon: Icons.timer_rounded,
        rules: RuleSet.timeAttack
      ),
      (
        name: l10n.modeHardcore,
        description: l10n.modeHardcoreDesc,
        icon: Icons.whatshot_rounded,
        rules: RuleSet.hardcore
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two columns on anything phone-width or wider, so the four modes read
        // as one glanceable set rather than a long scroll. Only genuinely
        // narrow surfaces fall back to a single column.
        final columns = constraints.maxWidth > 330 ? 2 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: TitanSpacing.md,
          crossAxisSpacing: TitanSpacing.md,
          childAspectRatio: columns == 2 ? 1.3 : 3.2,
          children: [
            for (final mode in modes)
              TitanCard(
                onTap: () => _startMode(context, mode.rules),
                padding: const EdgeInsets.all(TitanSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(mode.icon, size: 22),
                    const SizedBox(height: TitanSpacing.sm),
                    Text(mode.name, style: TitanText.cardTitle(context)),
                    const SizedBox(height: 2),
                    // The rule difference must be understandable before you
                    // start, without reading a paragraph.
                    Text(
                      mode.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TitanText.cardBody(context),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TrialsCard extends StatelessWidget {
  final AppLocalizations l10n;
  final ProgressStore progress;

  const _TrialsCard({required this.l10n, required this.progress});

  @override
  Widget build(BuildContext context) {
    final total = allTrials.length;
    final done = progress.trialsCompleted;

    return TitanCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const TrialsScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.homeCompleted(done, total),
                  style: TitanText.cardTitle(context),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: TitanSpacing.md),
          for (final chapter in trialChapters) ...[
            _ChapterRow(chapter: chapter, progress: progress),
            if (chapter != trialChapters.last)
              const SizedBox(height: TitanSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  final TrialChapter chapter;
  final ProgressStore progress;

  const _ChapterRow({required this.chapter, required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final done = chapter.trials
        .where((t) => progress.recordFor(t.id)?.completed == true)
        .length;
    final fraction = done / chapter.trials.length;

    return Row(
      children: [
        // Wide enough for the longest chapter name, and for its translations:
        // "The Proving Ground" truncated at 118.
        SizedBox(
          width: 152,
          child: Text(
            ContentStrings.chapter(l10n, chapter.id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TitanText.cardBody(context),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: TitanRadius.small,
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 5,
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.18),
            ),
          ),
        ),
        const SizedBox(width: TitanSpacing.sm),
        Text('$done/${chapter.trials.length}',
            style: TitanText.cardBody(context)),
      ],
    );
  }
}

class _SecondaryRow extends StatelessWidget {
  final AppLocalizations l10n;

  const _SecondaryRow({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TitanCard(
            padding: const EdgeInsets.symmetric(
              vertical: TitanSpacing.md,
              horizontal: TitanSpacing.md,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LeaderboardScreen()),
            ),
            child: _IconLabel(
              icon: Icons.emoji_events_rounded,
              label: l10n.homeHallOfTitans,
            ),
          ),
        ),
        const SizedBox(width: TitanSpacing.md),
        Expanded(
          child: TitanCard(
            padding: const EdgeInsets.symmetric(
              vertical: TitanSpacing.md,
              horizontal: TitanSpacing.md,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StatsScreen()),
            ),
            child: _IconLabel(
              icon: Icons.insights_rounded,
              label: l10n.statistics,
            ),
          ),
        ),
        const SizedBox(width: TitanSpacing.md),
        SizedBox(
          width: 56,
          child: TitanCard(
            padding: const EdgeInsets.symmetric(vertical: TitanSpacing.md),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            child: Semantics(
              label: l10n.settings,
              child: const Icon(Icons.settings_rounded),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: TitanSpacing.sm),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TitanText.cardBody(context),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _Chip({required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: TitanRadius.small,
        color: base.withValues(alpha: highlighted ? 0.32 : 0.16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Starts free play under a rule set and opens the board.
void _startMode(BuildContext context, RuleSet rules) {
  context.read<GameController>().startMode(rules);
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const GameScreen()),
  );
}

