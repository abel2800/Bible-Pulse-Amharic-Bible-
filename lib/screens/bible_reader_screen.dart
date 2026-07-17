import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_capabilities.dart';
import '../models/bible_verse.dart';
import '../providers/bible_provider.dart';
import '../providers/color_theme_provider.dart';
import '../providers/font_settings_provider.dart';
import '../providers/study_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/engagement_provider.dart';
import '../providers/parallel_reading_provider.dart';
import '../widgets/book_selector_bottom_sheet.dart';
import '../widgets/version_selector_bottom_sheet.dart';
import '../widgets/audio_player_bottom_sheet.dart';
import '../services/audio_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/verse_action_bottom_sheet.dart';
import 'package:google_fonts/google_fonts.dart';

class BibleReaderScreen extends StatefulWidget {
  const BibleReaderScreen({super.key});

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  int? _parallelBook;
  int? _parallelChapter;
  int? _lastAudioVerse;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final readerTheme = context.watch<ColorThemeProvider>().currentTheme;
    final fontSettings = context.watch<FontSettingsProvider>().fontSettings;
    final capabilities = context.watch<AppCapabilities>();
    final audioService = context.watch<AudioService>();
    final parallel = context.watch<ParallelReadingProvider>();
    final l10n = AppLocalizations.of(context);
    if (bibleProvider.currentChapter.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<EngagementProvider>().recordReading();
      });
    }
    final selectedBook = bibleProvider.selectedBook;
    if (parallel.enabled &&
        selectedBook != null &&
        (_parallelBook != selectedBook.id ||
            _parallelChapter != bibleProvider.selectedChapter)) {
      _parallelBook = selectedBook.id;
      _parallelChapter = bibleProvider.selectedChapter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        parallel.loadChapter(selectedBook.id, bibleProvider.selectedChapter);
      });
    }
    if (audioService.currentVerse != null &&
        audioService.currentVerse != _lastAudioVerse) {
      _lastAudioVerse = audioService.currentVerse;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final verseContext = _verseKeys[_lastAudioVerse]?.currentContext;
        if (verseContext != null) {
          Scrollable.ensureVisible(
            verseContext,
            duration: const Duration(milliseconds: 350),
            alignment: 0.35,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: readerTheme.backgroundColor,
      appBar: AppBar(
        elevation: 1,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bibleProvider.selectedBook?.name ?? l10n.selectBook,
              style: GoogleFonts.merriweather(
                  fontWeight: FontWeight.w700, fontSize: 18),
            ),
            if (bibleProvider.selectedBook != null)
              Text('${l10n.chapter} ${bibleProvider.selectedChapter}',
                  style: GoogleFonts.openSans(fontSize: 12)),
          ],
        ),
        actions: [
          if (parallel.available)
            IconButton(
              tooltip: parallel.enabled
                  ? 'Disable Amharic parallel reading'
                  : 'Enable Amharic parallel reading',
              onPressed: () => parallel.setEnabled(!parallel.enabled),
              icon: Icon(
                parallel.enabled
                    ? Icons.view_column_rounded
                    : Icons.view_column_outlined,
              ),
            ),
          IconButton(
            tooltip: capabilities.audio
                ? 'Play chapter audio'
                : 'Audio is not configured',
            icon: const Icon(Icons.volume_up),
            onPressed: capabilities.audio
                ? () {
                    if (bibleProvider.selectedBook == null) return;

                    final audioService =
                        Provider.of<AudioService>(context, listen: false);
                    audioService.playChapter(
                        bibleProvider.currentVersion,
                        bibleProvider.selectedBook!.id,
                        bibleProvider.selectedChapter);

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AudioPlayerBottomSheet(
                        book: bibleProvider.selectedBook!,
                        chapter: bibleProvider.selectedChapter,
                        versionId: bibleProvider.currentVersion,
                      ),
                    );
                  }
                : null,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            onSelected: (value) async {
              if (value == 'am') {
                await themeProvider.setLocale(const Locale('am', ''));
              } else {
                await themeProvider.setLocale(const Locale('en', ''));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'am', child: Text('Amharic')),
            ],
          ),
          IconButton(
            tooltip: 'Reading appearance',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _showReadingAppearance(context),
          ),
          IconButton(
            tooltip: 'Parallel translation view',
            icon: const Icon(Icons.view_column_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Parallel Amharic view is unavailable until redistribution permission is verified.',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const VersionSelectorBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: ColoredBox(
        color: readerTheme.backgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                if (bibleProvider.selectedBook != null)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () =>
                              _showChapterSelector(context, bibleProvider),
                          icon: const Icon(Icons.menu_book_rounded),
                          label:
                              Text('Chapter ${bibleProvider.selectedChapter}'),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                            textStyle: GoogleFonts.openSans(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: bibleProvider.selectedBook != null
                            ? () => bibleProvider.previousChapter()
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: bibleProvider.selectedBook != null
                            ? () => bibleProvider.nextChapter()
                            : null,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: bibleProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : bibleProvider.currentChapter.isEmpty
                          ? _buildEmptyStateMobile(context, bibleProvider, l10n)
                          : ListView.separated(
                              controller: _scrollController,
                              itemCount: bibleProvider.currentChapter.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final verse =
                                    bibleProvider.currentChapter[index];
                                final reference =
                                    bibleProvider.getVerseReference(verse);
                                final isHighlighted =
                                    studyProvider.isHighlighted(reference);
                                final highlightColor =
                                    studyProvider.getHighlightColor(reference);
                                final isSpoken =
                                    audioService.currentVerse == verse.verse;
                                final secondary = parallel.enabled
                                    ? parallel.verse(verse.verse)
                                    : null;

                                return Container(
                                  key: _verseKeys.putIfAbsent(
                                    verse.verse,
                                    GlobalKey.new,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isHighlighted
                                        ? highlightColor?.withValues(alpha: 0.2)
                                        : isSpoken
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withValues(alpha: 0.15)
                                            : readerTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSpoken
                                        ? Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showVerseActions(
                                      context,
                                      verse,
                                      reference,
                                    ),
                                    onLongPress: () => _showVerseActions(
                                      context,
                                      verse,
                                      reference,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color:
                                                  readerTheme.verseNumberColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${verse.verse}',
                                              style: TextStyle(
                                                color:
                                                    readerTheme.backgroundColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                final texts = [
                                                  Text(
                                                    verse.text,
                                                    style: fontSettings
                                                        .toTextStyle(
                                                      color:
                                                          readerTheme.textColor,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                  if (secondary != null)
                                                    Text(
                                                      secondary.text,
                                                      style: fontSettings
                                                          .toTextStyle(
                                                        color: readerTheme
                                                            .textColor,
                                                      ),
                                                      textAlign:
                                                          TextAlign.justify,
                                                    ),
                                                ];
                                                if (texts.length == 1) {
                                                  return texts.first;
                                                }
                                                if (constraints.maxWidth >=
                                                    620) {
                                                  return Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(child: texts[0]),
                                                      const VerticalDivider(
                                                        width: 32,
                                                      ),
                                                      Expanded(child: texts[1]),
                                                    ],
                                                  );
                                                }
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    texts[0],
                                                    const Divider(height: 24),
                                                    texts[1],
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bibleProvider = Provider.of<BibleProvider>(context, listen: false);
      final pending = bibleProvider.pendingScrollVerse;
      if (pending != null &&
          bibleProvider.pendingScrollBookId == bibleProvider.selectedBook?.id &&
          bibleProvider.pendingScrollChapter == bibleProvider.selectedChapter) {
        final index =
            bibleProvider.currentChapter.indexWhere((v) => v.verse == pending);
        if (index != -1) {
          final verseContext = _verseKeys[pending]?.currentContext;
          if (verseContext != null) {
            Scrollable.ensureVisible(
              verseContext,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              alignment: 0.15,
            );
          }
        }
        bibleProvider.clearPendingScroll();
      }
    });
  }

  Future<void> _showVerseActions(
    BuildContext context,
    BibleVerse verse,
    String reference,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => VerseActionBottomSheet(
        verse: verse,
        reference: reference,
      ),
    );
  }

  Future<void> _showReadingAppearance(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading appearance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Consumer<ColorThemeProvider>(
                  builder: (context, provider, _) => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: provider.availableThemes
                        .map(
                          (theme) => ChoiceChip(
                            selected: provider.currentTheme.id == theme.id,
                            avatar: CircleAvatar(
                              backgroundColor: theme.backgroundColor,
                            ),
                            label: Text(theme.name),
                            onSelected: (_) => provider.setTheme(theme.id),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Consumer<FontSettingsProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Text size · ${provider.fontSize.round()}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Slider(
                          min: 14,
                          max: 30,
                          divisions: 16,
                          value: provider.fontSize.clamp(14, 30).toDouble(),
                          label: provider.fontSize.round().toString(),
                          onChanged: provider.setFontSize,
                        ),
                        Text(
                          'Line spacing · ${provider.lineHeight.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Slider(
                          min: 1.2,
                          max: 2,
                          divisions: 8,
                          value: provider.lineHeight.clamp(1.2, 2).toDouble(),
                          onChanged: provider.setLineHeight,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateMobile(BuildContext context,
      BibleProvider bibleProvider, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded,
              size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.chooseBookToRead,
              style: GoogleFonts.merriweather(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const BookSelectorBottomSheet(),
              );
            },
            child: Text(l10n.browseBooks),
          ),
        ],
      ),
    );
  }

  void _showChapterSelector(BuildContext context, BibleProvider bibleProvider) {
    final chapters = bibleProvider.selectedBook?.chapters ?? 0;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
            ),
            itemCount: chapters,
            itemBuilder: (context, index) {
              final chap = index + 1;
              final isSelected = bibleProvider.selectedChapter == chap;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).cardColor,
                  foregroundColor: isSelected ? Colors.white : null,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  bibleProvider.loadChapter(
                      bibleProvider.selectedBook!.id, chap);
                },
                child: Text('$chap'),
              );
            },
          ),
        );
      },
    );
  }
}
