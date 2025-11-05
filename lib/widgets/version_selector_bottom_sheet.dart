import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../providers/bible_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class VersionSelectorBottomSheet extends StatelessWidget {
  const VersionSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context);
    final isDark = themeProvider.isDarkMode;
    
    final versions = [
      {'code': 'KJV', 'name': 'King James Version', 'language': 'en'},
      {'code': 'NIV', 'name': 'New International Version', 'language': 'en'},
      {'code': 'ESV', 'name': 'English Standard Version', 'language': 'en'},
      {'code': 'AMHARIC', 'name': 'Amharic Bible', 'language': 'am'},
    ];
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
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
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.accentTeal.withOpacity(0.27) : AppTheme.accentTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
              decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppTheme.accentTeal.withOpacity(0.13), AppTheme.accentTeal.withOpacity(0.0)]
                    : [AppTheme.accentTeal.withOpacity(0.07), AppTheme.accentTeal.withOpacity(0.0)],
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
                          ? [AppTheme.accentTeal, AppTheme.primaryIndigo]
                          : [AppTheme.primaryIndigo, AppTheme.accentTeal],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.selectVersion,
                    style: GoogleFonts.crimsonText(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8960F),
                      letterSpacing: 0.5,
                    ),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: versions.length,
              itemBuilder: (context, index) {
                final version = versions[index];
                final isSelected = bibleProvider.currentVersion == version['code'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
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
            ? (isDark ? AppTheme.accentTeal.withOpacity(0.53) : AppTheme.accentTeal.withOpacity(0.4))
            : (isDark ? AppTheme.accentTeal.withOpacity(0.07) : AppTheme.accentTeal.withOpacity(0.03)),
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                colors: isDark
                  ? [AppTheme.accentTeal, AppTheme.primaryIndigo]
                  : [AppTheme.primaryIndigo, AppTheme.accentTeal],
                              )
                            : null,
            color: isSelected
              ? null
              : (isDark ? AppTheme.accentTeal.withOpacity(0.13) : AppTheme.accentTeal.withOpacity(0.06)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          version['code']!.substring(0, 1),
                          style: GoogleFonts.crimsonText(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                  ? Colors.white
                    : (isDark ? AppTheme.accentTeal : AppTheme.primaryIndigo),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      version['name']!,
                      style: GoogleFonts.crimsonText(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 17,
            color: isDark
              ? (isSelected ? AppTheme.accentTeal : AppTheme.parchment)
              : (isSelected ? AppTheme.primaryIndigo : AppTheme.textDark),
                        letterSpacing: 0.3,
                      ),
                    ),
                    subtitle: Text(
                      version['language'] == 'en' ? 'English' : 'አማርኛ (Amharic)',
                      style: GoogleFonts.crimsonText(
                        fontSize: 14,
                        color: isDark ? const Color(0xFFC4B5A0) : const Color(0xFF6B5D4F),
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [AppTheme.accentTeal, AppTheme.primaryIndigo]
                                    : [AppTheme.primaryIndigo, AppTheme.accentTeal],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: isDark ? const Color(0x44D4AF37) : const Color(0x44B8960F),
                          ),
                    onTap: () async {
                      await bibleProvider.changeVersion(
                        version['code']!,
                        version['language']!,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
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
