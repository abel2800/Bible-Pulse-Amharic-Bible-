import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/devotional.dart';
import '../utils/app_theme.dart';

class DailyDevotionalCard extends StatelessWidget {
  final Devotional devotional;
  
  const DailyDevotionalCard({
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
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [
                    Color.lerp(AppTheme.primaryIndigo, AppTheme.darkBackground, 0.2)!,
                    AppTheme.darkBackground,
                  ]
                : [
                    AppTheme.parchment,
                    AppTheme.parchment.withOpacity(0.96),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0x33D4AF37) : const Color(0x22D4AF37),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(24),
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
          : [AppTheme.primaryIndigo, AppTheme.accentTeal],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33D4AF37),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Daily Prayer',
                  style: GoogleFonts.crimsonText(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryIndigo.withOpacity(0.04)
                    : AppTheme.accentTeal.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                devotional.dailyPrayer,
                style: GoogleFonts.crimsonText(
                  fontSize: 16,
                  height: 1.7,
                  color: isDark
                      ? AppTheme.parchment
                      : AppTheme.textDark,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                  },
                    icon: Icon(
                    Icons.share_rounded,
                    size: 18,
                    color: isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo,
                  ),
                  label: Text(
                    'Share',
                    style: GoogleFonts.crimsonText(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/wallpaper');
                  },
                    icon: Icon(
                    Icons.wallpaper_rounded,
                    size: 18,
                    color: isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo,
                  ),
                  label: Text(
                    'Wallpaper',
                    style: GoogleFonts.crimsonText(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo,
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
}
