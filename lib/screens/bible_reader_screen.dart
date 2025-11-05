import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../providers/study_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/book_selector_bottom_sheet.dart';
import '../widgets/version_selector_bottom_sheet.dart';
import '../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';


class BibleReaderScreen extends StatefulWidget {
  const BibleReaderScreen({super.key});

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  final ScrollController _scrollController = ScrollController();

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
  final l10n = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetVersion = themeProvider.locale.languageCode == 'am' ? 'AMHARIC' : 'KJV';
      if (bibleProvider.currentVersion != targetVersion) {
        bibleProvider.changeVersion(targetVersion, themeProvider.locale.languageCode);
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bibleProvider.selectedBook?.name ?? l10n.selectBook,
              style: GoogleFonts.merriweather(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            if (bibleProvider.selectedBook != null)
              Text('${l10n.chapter} ${bibleProvider.selectedChapter}', style: GoogleFonts.openSans(fontSize: 12)),
          ],
        ),
        actions: [
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              if (bibleProvider.selectedBook != null)
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _showChapterSelector(context, bibleProvider),
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text('Chapter ${bibleProvider.selectedChapter}'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          textStyle: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: bibleProvider.selectedBook != null ? () => bibleProvider.previousChapter() : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: bibleProvider.selectedBook != null ? () => bibleProvider.nextChapter() : null,
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
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final verse = bibleProvider.currentChapter[index];
                              final reference = bibleProvider.getVerseReference(verse);
                              final isHighlighted = studyProvider.isHighlighted(reference);
                              final highlightColor = studyProvider.getHighlightColor(reference);

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isHighlighted
                                      ? highlightColor?.withOpacity(0.12)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('${verse.verse}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        verse.text,
                                        style: GoogleFonts.merriweather(fontSize: 18, height: 1.6),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
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
        final index = bibleProvider.currentChapter.indexWhere((v) => v.verse == pending);
        if (index != -1) {
          final offset = (index * 120).toDouble(); // approximate per-item height
          try {
            final max = _scrollController.position.maxScrollExtent;
            final target = offset.clamp(0.0, max);
            _scrollController.animateTo(target, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
          } catch (_) {}
        }
        bibleProvider.clearPendingScroll();
      }
    });
  }

  Widget _buildEmptyStateMobile(BuildContext context, BibleProvider bibleProvider, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.chooseBookToRead, style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.w700)),
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
                  backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                  foregroundColor: isSelected ? Colors.white : null,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  bibleProvider.loadChapter(bibleProvider.selectedBook!.id, chap);
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
