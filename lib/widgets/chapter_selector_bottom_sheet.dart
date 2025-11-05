import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bible_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class ChapterSelectorBottomSheet extends StatelessWidget {
  const ChapterSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context);
    final book = bibleProvider.selectedBook;
    final isDark = themeProvider.isDarkMode;
    
    if (book == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
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
            color: isDark
                ? const Color(0x66D4AF37)
                : const Color(0x22D4AF37),
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
                    Icons.format_list_numbered_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.selectChapter,
                        style: GoogleFonts.crimsonText(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8960F),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        book.name,
                        style: GoogleFonts.crimsonText(
                          fontSize: 14,
                          color: isDark ? const Color(0xFFC4B5A0) : const Color(0xFF6B5D4F),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8960F),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: book.chapters,
              itemBuilder: (context, index) {
                final chapter = index + 1;
                final isSelected = bibleProvider.selectedChapter == chapter;
                
                return InkWell(
                  onTap: () async {
                    await bibleProvider.loadChapter(book.id, chapter);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFFD4AF37), const Color(0xFFB8960F)]
                                  : [const Color(0xFFB8960F), const Color(0xFFD4AF37)],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark
                              ? const Color(0x11D4AF37)
                              : const Color(0x08D4AF37)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                                ? const Color(0x33D4AF37)
                                : const Color(0x22D4AF37)),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0x44D4AF37)
                                    : const Color(0x33B8960F),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$chapter',
                        style: GoogleFonts.crimsonText(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? const Color(0xFFD4AF37)
                                  : const Color(0xFFB8960F)),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
