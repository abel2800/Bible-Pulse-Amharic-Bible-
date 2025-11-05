import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/devotional.dart';
import '../utils/app_theme.dart';

class VerseOfTheDayCard extends StatelessWidget {
  final Devotional devotional;
  
  const VerseOfTheDayCard({
    super.key,
    required this.devotional,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Color.lerp(AppTheme.primaryIndigo, AppTheme.darkBackground, 0.2)!,
                    AppTheme.darkBackground,
                  ]
                : [
                    AppTheme.parchment,
                    AppTheme.parchment.withOpacity(0.95),
                    AppTheme.primaryIndigo.withOpacity(0.06),
                    AppTheme.accentTeal.withOpacity(0.06),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.accentTeal.withOpacity(0.27) : AppTheme.accentTeal.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppTheme.accentTeal.withOpacity(0.18)
                  : AppTheme.accentTeal.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppTheme.accentTeal, AppTheme.primaryIndigo]
                          : [AppTheme.accentTeal.withOpacity(0.9), AppTheme.primaryIndigo.withOpacity(0.9)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Verse of the Day',
                  style: GoogleFonts.crimsonText(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryIndigo.withOpacity(0.06)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                devotional.dailyVerse,
                style: GoogleFonts.crimsonText(
                  fontSize: 19,
                  height: 1.7,
                  color: isDark ? AppTheme.parchment : AppTheme.primaryIndigo,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [AppTheme.accentTeal, AppTheme.primaryIndigo]
                          : [AppTheme.primaryIndigo, AppTheme.primaryIndigo.withOpacity(0.6)],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  devotional.verseReference,
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.accentTeal
                        : AppTheme.primaryIndigo.withOpacity(0.95),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
