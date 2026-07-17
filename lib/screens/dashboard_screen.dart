import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/bible_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/engagement_provider.dart';
import '../providers/study_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bible = context.watch<BibleProvider>();
    final dailyVerse = bible.verseOfTheDay;
    final theme = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('BiblePulse'),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open menu',
            onPressed: Scaffold.of(context).openDrawer,
            icon: const Icon(Icons.menu_rounded),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search Scripture',
            onPressed: () => Navigator.pushNamed(context, '/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: theme.isDarkMode ? 'Use light mode' : 'Use dark mode',
            onPressed: theme.toggleTheme,
            icon: Icon(
              theme.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _GreetingCard(l10n: l10n),
                const SizedBox(height: 16),
                const _EngagementSummary(),
                const SizedBox(height: 16),
                if (dailyVerse != null)
                  _VerseOfDayCard(
                    verse: dailyVerse.text,
                    reference: bible.getVerseReference(dailyVerse),
                  )
                else
                  const _UnavailableCard(
                    title: 'Daily verse unavailable',
                    message: 'Verified Scripture content has not loaded.',
                  ),
                const SizedBox(height: 24),
                Text(l10n.quickActions,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 850
                        ? 4
                        : constraints.maxWidth >= 520
                            ? 2
                            : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: columns == 1 ? 3.4 : 1.55,
                      children: [
                        _ActionCard(
                          icon: Icons.menu_book_rounded,
                          title: l10n.readBible,
                          description: 'Continue reading Scripture',
                          onTap: () =>
                              context.read<NavigationProvider>().setIndex(1),
                        ),
                        _ActionCard(
                          icon: Icons.bookmarks_rounded,
                          title: l10n.myStudy,
                          description: 'Notes, highlights and bookmarks',
                          onTap: () =>
                              context.read<NavigationProvider>().setIndex(2),
                        ),
                        _ActionCard(
                          icon: Icons.wallpaper_rounded,
                          title: l10n.createWallpaper,
                          description: 'Create a verse image',
                          onTap: () =>
                              Navigator.pushNamed(context, '/wallpaper'),
                        ),
                        _ActionCard(
                          icon: Icons.volunteer_activism_rounded,
                          title: 'Prayer journal',
                          description: 'Private prayers linked to Scripture',
                          onTap: () =>
                              Navigator.pushNamed(context, '/prayer_journal'),
                        ),
                        _ActionCard(
                          icon: Icons.tune_rounded,
                          title: l10n.settings,
                          description: 'Reading and app preferences',
                          onTap: () =>
                              context.read<NavigationProvider>().setIndex(3),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EngagementSummary extends StatelessWidget {
  const _EngagementSummary();

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<EngagementProvider>().streakWithGrace();
    final memories = context.watch<StudyProvider>().onThisDay();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak-day reading streak',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                      'Includes one grace day in each seven-day window.'),
                  if (memories.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'On this day · ${memories.first.reference}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      memories.first.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.goodMorning
        : hour < 17
            ? l10n.goodAfternoon
            : l10n.goodEvening;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              l10n.welcomeBack,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppTheme.darkAccentGold : AppTheme.accentGold;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: gold),
                const SizedBox(width: 10),
                Text(
                  'Verse of the day',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: gold,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              verse,
              style: GoogleFonts.merriweather(fontSize: 18, height: 1.6),
            ),
            const SizedBox(height: 14),
            Text(
              reference,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        minTileHeight: 72,
        leading: const Icon(Icons.info_outline_rounded),
        title: Text(title),
        subtitle: Text(message),
      ),
    );
  }
}
