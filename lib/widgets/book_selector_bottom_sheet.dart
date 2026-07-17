import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bible_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class BookSelectorBottomSheet extends StatelessWidget {
  const BookSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context);
    final isDark = themeProvider.isDarkMode;
    final otBooks =
        bibleProvider.books.where((b) => b.testament == 'OT').toList();
    final ntBooks =
        bibleProvider.books.where((b) => b.testament == 'NT').toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF2A2419),
                  const Color(0xFF1A1611),
                ]
              : [
                  const Color(0xFFFFFFFD),
                  const Color(0xFFFAF8F3),
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x66D4AF37) : const Color(0x22D4AF37),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0x44D4AF37) : const Color(0x33D4AF37),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0x22D4AF37), const Color(0x00D4AF37)]
                    : [const Color(0x11D4AF37), const Color(0x00D4AF37)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFFD4AF37), const Color(0xFFB8960F)]
                          : [const Color(0xFFB8960F), const Color(0xFFD4AF37)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.selectBook,
                    style: GoogleFonts.crimsonText(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFB8960F),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFB8960F),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x22D4AF37)
                          : const Color(0x11D4AF37),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFFD4AF37),
                                  const Color(0xFFB8960F)
                                ]
                              : [
                                  const Color(0xFFB8960F),
                                  const Color(0xFFD4AF37)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark
                          ? const Color(0xFFC4B5A0)
                          : const Color(0xFF6B5D4F),
                      labelStyle: GoogleFonts.crimsonText(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      tabs: [
                        Tab(text: l10n.oldTestament),
                        Tab(text: l10n.newTestament),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBookList(context, otBooks, bibleProvider, isDark),
                        _buildBookList(context, ntBooks, bibleProvider, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(
    BuildContext context,
    List books,
    BibleProvider provider,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isSelected = provider.selectedBook?.id == book.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: isDark
                        ? [const Color(0x44D4AF37), const Color(0x22D4AF37)]
                        : [const Color(0x33D4AF37), const Color(0x11D4AF37)],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDark ? const Color(0x88D4AF37) : const Color(0x66D4AF37))
                  : (isDark
                      ? const Color(0x11D4AF37)
                      : const Color(0x08D4AF37)),
              width: 1.5,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: isDark
                            ? [const Color(0xFFD4AF37), const Color(0xFFB8960F)]
                            : [
                                const Color(0xFFB8960F),
                                const Color(0xFFD4AF37)
                              ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark
                        ? const Color(0x22D4AF37)
                        : const Color(0x11D4AF37)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  book.name.substring(0, 1),
                  style: GoogleFonts.crimsonText(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFFB8960F)),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            title: Text(
              book.name,
              style: GoogleFonts.crimsonText(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 17,
                color: isDark
                    ? (isSelected
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFFAF8F3))
                    : (isSelected
                        ? const Color(0xFFB8960F)
                        : const Color(0xFF2D2516)),
                letterSpacing: 0.3,
              ),
            ),
            subtitle: Text(
              '${book.chapters} ${AppLocalizations.of(context).chapters}',
              style: GoogleFonts.crimsonText(
                fontSize: 14,
                color:
                    isDark ? const Color(0xFFC4B5A0) : const Color(0xFF6B5D4F),
              ),
            ),
            trailing: isSelected
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFFD4AF37), const Color(0xFFB8960F)]
                            : [
                                const Color(0xFFB8960F),
                                const Color(0xFFD4AF37)
                              ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                : Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark
                        ? const Color(0x44D4AF37)
                        : const Color(0x44B8960F),
                  ),
            onTap: () async {
              await provider.loadChapter(book.id, 1);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
