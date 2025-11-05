import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bible_verse.dart';
import '../providers/study_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class VerseActionBottomSheet extends StatefulWidget {
  final BibleVerse verse;
  final String reference;
  
  const VerseActionBottomSheet({
    super.key,
    required this.verse,
    required this.reference,
  });

  @override
  State<VerseActionBottomSheet> createState() => _VerseActionBottomSheetState();
}

class _VerseActionBottomSheetState extends State<VerseActionBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    final existingNote = studyProvider.getNoteForVerse(widget.reference);
    if (existingNote != null) {
      _noteController.text = existingNote.text;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isHighlighted = studyProvider.isHighlighted(widget.reference);
    final isBookmarked = studyProvider.isBookmarked(widget.reference);
    final isDark = themeProvider.isDarkMode;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Color.lerp(AppTheme.primaryIndigo, AppTheme.darkBackground, 0.2)!,
                  AppTheme.darkBackground,
                ]
              : [
                  AppTheme.parchment,
                  AppTheme.parchment.withOpacity(0.98),
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.accentTeal.withOpacity(0.4)
                : AppTheme.accentTeal.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.accentTeal.withOpacity(0.27) : AppTheme.accentTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppTheme.accentTeal, AppTheme.primaryIndigo]
                          : [AppTheme.primaryIndigo, AppTheme.accentTeal],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.reference,
                    style: GoogleFonts.crimsonText(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryIndigo.withOpacity(0.04)
                    : AppTheme.accentTeal.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.accentTeal.withOpacity(0.2) : AppTheme.accentTeal.withOpacity(0.12),
                ),
              ),
              child: Text(
                widget.verse.text,
                style: GoogleFonts.crimsonText(
                  fontSize: 17,
                  height: 1.7,
                  color: isDark ? AppTheme.parchment : AppTheme.textDark,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppTheme.accentTeal, AppTheme.primaryIndigo]
                          : [AppTheme.primaryIndigo, AppTheme.accentTeal],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Highlight Color',
                  style: GoogleFonts.crimsonText(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final color in AppTheme.highlightColors)
                  _buildHighlightButton(context, color, studyProvider, isDark),
                if (isHighlighted)
                  _buildRemoveHighlightButton(context, studyProvider, isDark),
              ],
            ),
            const SizedBox(height: 24),
            
            Container(
                decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryIndigo.withOpacity(0.04)
                    : AppTheme.accentTeal.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.accentTeal.withOpacity(0.2) : AppTheme.accentTeal.withOpacity(0.12),
                ),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 3,
                style: GoogleFonts.crimsonText(
                  fontSize: 16,
                  color: isDark ? AppTheme.parchment : AppTheme.textDark,
                ),
                decoration: InputDecoration(
                  labelText: 'Add Note',
                  labelStyle: GoogleFonts.crimsonText(
                    color: isDark ? AppTheme.parchment.withOpacity(0.8) : AppTheme.textDark.withOpacity(0.7),
                  ),
                  hintText: 'Write your thoughts here...',
                  hintStyle: GoogleFonts.crimsonText(
                    color: isDark ? AppTheme.parchment.withOpacity(0.4) : AppTheme.textDark.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
              colors: isDark
                ? [AppTheme.accentTeal, AppTheme.primaryIndigo]
                : [AppTheme.primaryIndigo, AppTheme.accentTeal],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_noteController.text.isNotEmpty) {
                        await studyProvider.addNote(
                          widget.reference,
                          _noteController.text,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Note saved',
                                style: GoogleFonts.crimsonText(),
                              ),
                              backgroundColor: isDark
                                  ? const Color(0xFFD4AF37)
                                  : const Color(0xFFB8960F),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isBookmarked) {
                        await studyProvider.removeBookmark(widget.reference);
                      } else {
                        await studyProvider.addBookmark(
                          widget.reference,
                          widget.verse.text,
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 20,
                    ),
                    label: Text(
                      isBookmarked ? 'Bookmarked' : 'Bookmark',
                      style: GoogleFonts.crimsonText(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? (isBookmarked ? const Color(0xFFD4AF37) : const Color(0x22D4AF37))
                          : (isBookmarked ? const Color(0xFFB8960F) : const Color(0x11D4AF37)),
                      foregroundColor: isBookmarked
                          ? Colors.white
                          : (isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8960F)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: isBookmarked
                            ? BorderSide.none
                            : BorderSide(
                                color: isDark
                                    ? const Color(0x44D4AF37)
                                    : const Color(0x33D4AF37),
                              ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: Text(
                      'Share',
                      style: GoogleFonts.crimsonText(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0x22D4AF37)
                          : const Color(0x11D4AF37),
                      foregroundColor: isDark
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFB8960F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0x44D4AF37)
                              : const Color(0x33D4AF37),
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHighlightButton(
    BuildContext context,
    Color color,
    StudyProvider studyProvider,
    bool isDark,
  ) {
    final currentColor = studyProvider.getHighlightColor(widget.reference);
    final isSelected = currentColor == color;
    
    return GestureDetector(
      onTap: () async {
        await studyProvider.addHighlight(
          widget.reference,
          widget.verse.text,
          color,
        );
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✨ Verse highlighted!',
                style: GoogleFonts.crimsonText(color: Colors.white),
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: color,
            ),
          );
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8960F))
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
            : null,
      ),
    );
  }
  
  Widget _buildRemoveHighlightButton(
    BuildContext context,
    StudyProvider studyProvider,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () async {
        await studyProvider.removeHighlight(widget.reference);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Highlight removed',
                style: GoogleFonts.crimsonText(),
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: isDark
                  ? const Color(0xFFB8960F)
                  : const Color(0xFFD4AF37),
            ),
          );
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0x22D4AF37)
              : const Color(0x11D4AF37),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.red.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.red, size: 26),
      ),
    );
  }
  
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
