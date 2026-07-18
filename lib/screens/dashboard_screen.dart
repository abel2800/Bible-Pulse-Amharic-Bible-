import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_capabilities.dart';
import '../l10n/app_localizations.dart';
import '../providers/bible_provider.dart';
import '../providers/engagement_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/study_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/design/bp_widgets.dart';
import '../widgets/manuscript_bits.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bible = context.watch<BibleProvider>();
    final dailyVerse = bible.verseOfTheDay;
    final theme = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);
    final capabilities = context.watch<AppCapabilities>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final faint = isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint;

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Builder(
                      builder: (context) => Row(
                        children: [
                          BpIconButton(
                            icon: Icons.menu_rounded,
                            tooltip: 'Open menu',
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                          const Spacer(),
                          BpIconButton(
                            icon: Icons.search_rounded,
                            tooltip: 'Search Scripture',
                            onPressed: () =>
                                context.read<NavigationProvider>().setIndex(2),
                          ),
                          const SizedBox(width: 8),
                          BpIconButton(
                            icon: theme.isDarkMode
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            tooltip: theme.isDarkMode
                                ? 'Use light mode'
                                : 'Use dark mode',
                            onPressed: theme.toggleTheme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _GreetingHeader(l10n: l10n),
                ),
                if (dailyVerse != null)
                  SliverToBoxAdapter(
                    child: _VerseOfDayCard(
                      verse: dailyVerse.text,
                      reference: '${bible.getVerseReference(dailyVerse)} · WEB',
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: BpCard(
                        child:
                            Text('Verified Scripture content has not loaded.'),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        _QuickCard(
                          icon: Icons.compare_arrows_rounded,
                          title: 'Parallel read',
                          subtitle: 'Amharic + English',
                          onTap: () =>
                              context.read<NavigationProvider>().setIndex(1),
                        ),
                        _QuickCard(
                          icon: Icons.headphones_rounded,
                          title: 'Listen',
                          subtitle: capabilities.audio
                              ? 'Chapter audio'
                              : 'Audio gated',
                          onTap: () =>
                              context.read<NavigationProvider>().setIndex(1),
                        ),
                        _QuickCard(
                          icon: Icons.auto_stories_rounded,
                          title: 'Reading plans',
                          subtitle: capabilities.readingPlans
                              ? 'Continue a plan'
                              : 'Coming with license',
                          onTap: capabilities.readingPlans
                              ? () => Navigator.pushNamed(
                                    context,
                                    '/reading_plans',
                                  )
                              : null,
                        ),
                        _QuickCard(
                          icon: Icons.music_note_rounded,
                          title: 'Hymns',
                          subtitle: capabilities.hymns
                              ? 'Open library'
                              : 'Coming with license',
                          onTap: capabilities.hymns
                              ? () => Navigator.pushNamed(context, '/hymns')
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: BpSectionLabel(
                      title: 'Continue reading',
                      action: 'See all',
                      onAction: () =>
                          context.read<NavigationProvider>().setIndex(1),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: BpCard(
                      onTap: () =>
                          context.read<NavigationProvider>().setIndex(1),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppTheme.goldSoft, AppTheme.vermilion],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bible.selectedBook?.name ?? 'Open Scripture',
                                  style: AppTheme.ui(
                                    fontSize: 13.5,
                                    weight: FontWeight.w600,
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bible.selectedBook == null
                                      ? 'Start reading'
                                      : 'Chapter ${bible.selectedChapter}',
                                  style: AppTheme.ui(
                                    fontSize: 11,
                                    color: faint,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: 0.63,
                                    minHeight: 4,
                                    backgroundColor: isDark
                                        ? AppTheme.borderDark
                                        : AppTheme.borderLight,
                                    color: AppTheme.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.goodMorning
        : hour < 17
            ? l10n.goodAfternoon
            : l10n.goodEvening;
    final streak = context.watch<EngagementProvider>().streakWithGrace();
    final memories = context.watch<StudyProvider>().onThisDay();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final faint = isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint;
    final soft = isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting.toUpperCase(),
            style: AppTheme.ui(
              fontSize: 11,
              weight: FontWeight.w600,
              letterSpacing: 1.5,
              color: faint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome',
            style: AppTheme.brandTitle(fontSize: 24, color: ink),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('●',
                  style: TextStyle(color: AppTheme.vermilion, fontSize: 13)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$streak-day streak · grace day available',
                  style: AppTheme.ui(
                      fontSize: 12, weight: FontWeight.w500, color: soft),
                ),
              ),
            ],
          ),
          if (memories.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'On this day · ${memories.first.reference}',
              style: AppTheme.ui(
                  fontSize: 11, weight: FontWeight.w600, color: AppTheme.gold),
            ),
          ],
        ],
      ),
    );
  }
}

class _VerseOfDayCard extends StatelessWidget {
  const _VerseOfDayCard({required this.verse, required this.reference});

  final String verse;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final t = context.colors;
    final drop = verse.trim().isEmpty ? 'A' : verse.trim().characters.first;
    final rest = verse.trim().isEmpty
        ? ''
        : verse.trim().substring(drop.length).trimLeft();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BpCard(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: DropCap(drop.toUpperCase()),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rest,
                        style: AppText.scripture(context, size: 15.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        reference.toUpperCase(),
                        style: AppText.ui(
                          context,
                          size: 11.5,
                          w: FontWeight.w600,
                          color: t.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -10,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'VERSE OF THE DAY',
                style: AppTheme.ui(
                  fontSize: 10,
                  weight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.onGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final faint = isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint;
    final surface2 = isDark ? AppTheme.surface2Dark : AppTheme.surface2Light;

    return BpCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.teal),
          ),
          const Spacer(),
          Text(
            title,
            style:
                AppTheme.ui(fontSize: 13, weight: FontWeight.w600, color: ink),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTheme.ui(fontSize: 11, color: faint),
          ),
        ],
      ),
    );
  }
}
