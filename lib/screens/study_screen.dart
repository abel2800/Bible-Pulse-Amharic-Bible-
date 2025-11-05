import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/study_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/highlight_list_item.dart';
import '../widgets/note_list_item.dart';
import '../widgets/bookmark_list_item.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1611),
                    const Color(0xFF2A2419),
                  ]
                : [
                    const Color(0xFFFFFFFD),
                    const Color(0xFFFAF8F3),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8960F),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
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
                      child: const Icon(Icons.book_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'My Study',
                      style: GoogleFonts.crimsonText(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8960F),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x22D4AF37)
                      : const Color(0x11D4AF37),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFFD4AF37), const Color(0xFFB8960F)]
                          : [const Color(0xFFB8960F), const Color(0xFFD4AF37)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark
                      ? const Color(0xFFC4B5A0)
                      : const Color(0xFF6B5D4F),
                  labelStyle: GoogleFonts.crimsonText(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.highlight_rounded, size: 20),
                      text: 'Highlights',
                    ),
                    Tab(
                      icon: Icon(Icons.note_rounded, size: 20),
                      text: 'Notes',
                    ),
                    Tab(
                      icon: Icon(Icons.bookmark_rounded, size: 20),
                      text: 'Bookmarks',
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    studyProvider.highlights.isEmpty
                        ? _buildEmptyState(
                            icon: Icons.highlight_rounded,
                            message: 'No highlights yet',
                            description: 'Long press any verse to add a highlight',
                            isDark: isDark,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: studyProvider.highlights.length,
                            itemBuilder: (context, index) {
                              return HighlightListItem(
                                highlight: studyProvider.highlights[index],
                              );
                            },
                          ),
                    
                    studyProvider.notes.isEmpty
                        ? _buildEmptyState(
                            icon: Icons.note_rounded,
                            message: 'No notes yet',
                            description: 'Add notes to verses for personal study',
                            isDark: isDark,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: studyProvider.notes.length,
                            itemBuilder: (context, index) {
                              return NoteListItem(
                                note: studyProvider.notes[index],
                              );
                            },
                          ),
                    
                    studyProvider.bookmarks.isEmpty
                        ? _buildEmptyState(
                            icon: Icons.bookmark_rounded,
                            message: 'No bookmarks yet',
                            description: 'Bookmark verses to easily find them later',
                            isDark: isDark,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: studyProvider.bookmarks.length,
                            itemBuilder: (context, index) {
                              return BookmarkListItem(
                                bookmark: studyProvider.bookmarks[index],
                              );
                            },
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
  
  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String description,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0x22D4AF37), const Color(0x11D4AF37)]
                      : [const Color(0x11D4AF37), const Color(0x08D4AF37)],
                ),
                border: Border.all(
                  color: isDark ? const Color(0x44D4AF37) : const Color(0x33D4AF37),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 72,
                color: isDark
                    ? const Color(0x88D4AF37)
                    : const Color(0x88B8960F),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              message,
              style: GoogleFonts.crimsonText(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8960F),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.crimsonText(
                fontSize: 16,
                height: 1.5,
                color: isDark ? const Color(0xFFC4B5A0) : const Color(0xFF6B5D4F),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
