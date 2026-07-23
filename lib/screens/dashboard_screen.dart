import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_capabilities.dart';
import '../l10n/app_localizations.dart';
import '../providers/bible_provider.dart';
import '../providers/engagement_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/study_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _topTab = 0;

  @override
  Widget build(BuildContext context) {
    final bible = context.watch<BibleProvider>();
    final dailyVerse = bible.verseOfTheDay;
    final theme = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);
    final capabilities = context.watch<AppCapabilities>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : AppTheme.appBgLight;
    final ink = isDark ? Colors.white : AppTheme.ink;
    final soft = isDark ? Colors.white70 : AppTheme.inkSoft;
    final card = isDark ? const Color(0xFF1C1C1E) : AppTheme.surfaceLight;
    final streak = context.watch<EngagementProvider>().streakWithGrace();
    final auth = context.watch<AuthService>();
    final name = auth.currentUser?.displayName?.split(' ').first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.goodMorning
        : hour < 17
            ? l10n.goodAfternoon
            : l10n.goodEvening;
    final greetLine =
        name == null || name.isEmpty ? greeting : '$greeting, $name';

    return Scaffold(
      backgroundColor: bg,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
                    child: Builder(
                      builder: (context) => Row(
                        children: [
                          _TopTab(
                            label: 'Today',
                            selected: _topTab == 0,
                            accent: const Color(0xFFE53935),
                            onTap: () => setState(() => _topTab = 0),
                          ),
                          const SizedBox(width: 18),
                          _TopTab(
                            label: 'Community',
                            selected: _topTab == 1,
                            accent: const Color(0xFFE53935),
                            onTap: () {
                              setState(() => _topTab = 1);
                              if (capabilities.community) {
                                Navigator.pushNamed(context, '/community');
                              }
                            },
                          ),
                          const Spacer(),
                          _HeaderIcon(
                            icon: Icons.bolt_rounded,
                            badge: streak > 0 ? '$streak' : null,
                            onTap: () {},
                          ),
                          const SizedBox(width: 4),
                          _HeaderIcon(
                            icon: Icons.notifications_none_rounded,
                            onTap: () => Scaffold.of(context).openDrawer(),
                          ),
                          const SizedBox(width: 4),
                          _HeaderIcon(
                            icon: theme.isDarkMode
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            onTap: theme.toggleTheme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Text(
                      greetLine,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: ink,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
                if (dailyVerse != null)
                  SliverToBoxAdapter(
                    child: _VerseOfDayHero(
                      verse: dailyVerse.text,
                      reference:
                          '${bible.getVerseReference(dailyVerse)} · WEB',
                      isDark: isDark,
                      onOpen: () async {
                        await bible.goToVerse(
                          dailyVerse.book,
                          dailyVerse.chapter,
                          dailyVerse.verse,
                        );
                        if (context.mounted) {
                          context.read<NavigationProvider>().setIndex(1);
                        }
                      },
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: _GuidedRow(
                      eyebrow: 'Continue reading',
                      title: bible.selectedBook == null
                          ? 'Open Scripture'
                          : '${bible.selectedBook!.name} ${bible.selectedChapter}',
                      durationLabel: capabilities.audio ? '▶ Listen' : 'Read',
                      cardColor: card,
                      ink: ink,
                      soft: soft,
                      onTap: () =>
                          context.read<NavigationProvider>().setIndex(1),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _GuidedRow(
                      eyebrow: 'Study',
                      title: context.watch<StudyProvider>().notes.isEmpty
                          ? 'Capture a note while you read'
                          : '${context.watch<StudyProvider>().notes.length} notes saved',
                      durationLabel: 'Open',
                      cardColor: card,
                      ink: ink,
                      soft: soft,
                      onTap: () =>
                          context.read<NavigationProvider>().setIndex(2),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                    child: Text(
                      'More for you',
                      style: AppTheme.ui(
                        fontSize: 18,
                        weight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Need a place to begin? Open the Bible and listen while you read.',
                                  style: AppTheme.ui(
                                    fontSize: 14,
                                    color: soft,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () => context
                                      .read<NavigationProvider>()
                                      .setIndex(1),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: isDark
                                        ? const Color(0xFF2C2C2E)
                                        : AppTheme.surface2Light,
                                    foregroundColor: ink,
                                  ),
                                  child: const Text('Open Bible'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF5B2C6F),
                                  Color(0xFF1A1A2E),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white70,
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

class _TopTab extends StatelessWidget {
  const _TopTab({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.ui(
              fontSize: 16,
              weight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? (isDark ? Colors.white : AppTheme.ink)
                  : (isDark ? Colors.white54 : AppTheme.inkSoft),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 28,
            height: 2.5,
            color: selected ? accent : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: badge != null,
        label: badge == null ? null : Text(badge!),
        child: Icon(
          icon,
          color: isDark ? Colors.white : AppTheme.ink,
        ),
      ),
    );
  }
}

class _VerseOfDayHero extends StatelessWidget {
  const _VerseOfDayHero({
    required this.verse,
    required this.reference,
    required this.isDark,
    required this.onOpen,
  });

  final String verse;
  final String reference;
  final bool isDark;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF2D1B4E), Color(0xFF0D0D0D)]
                    : const [Color(0xFF3D2B1F), Color(0xFF1A1420)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verse of the Day',
                    style: AppTheme.ui(
                      fontSize: 12,
                      weight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reference,
                    style: AppTheme.ui(
                      fontSize: 13,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    verse,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 20,
                      height: 1.45,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(Icons.favorite_border,
                          size: 18, color: Colors.white70),
                      SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline,
                          size: 18, color: Colors.white70),
                      SizedBox(width: 16),
                      Icon(Icons.ios_share_rounded,
                          size: 18, color: Colors.white70),
                      Spacer(),
                      Icon(Icons.more_horiz, color: Colors.white70),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidedRow extends StatelessWidget {
  const _GuidedRow({
    required this.eyebrow,
    required this.title,
    required this.durationLabel,
    required this.cardColor,
    required this.ink,
    required this.soft,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String durationLabel;
  final Color cardColor;
  final Color ink;
  final Color soft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: AppTheme.ui(fontSize: 12, color: soft),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: AppTheme.ui(
                        fontSize: 16,
                        weight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      durationLabel,
                      style: AppTheme.ui(fontSize: 12, color: soft),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A5568), Color(0xFF1A202C)],
                  ),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
