import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/bible_provider.dart';
import '../utils/app_theme.dart';
import 'design/bp_widgets.dart';

class VersionSelectorBottomSheet extends StatelessWidget {
  const VersionSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bible = context.watch<BibleProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.selectVersion,
                      style: AppTheme.brandTitle(
                        fontSize: 19,
                        weight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                  ),
                  BpIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BpCard(
                padding: EdgeInsets.zero,
                onTap: () async {
                  await bible.changeVersion('WEB');
                  if (context.mounted) Navigator.pop(context);
                },
                child: ListTile(
                  minTileHeight: 72,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.gold.withValues(alpha: 0.4),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'W',
                      style: AppTheme.brandTitle(
                        fontSize: 18,
                        weight: FontWeight.w700,
                        color: AppTheme.gold,
                      ),
                    ),
                  ),
                  title: Text(
                    'World English Bible',
                    style: AppTheme.ui(
                      fontSize: 14,
                      weight: FontWeight.w600,
                      color: ink,
                    ),
                  ),
                  subtitle: Text(
                    'English · Public Domain',
                    style: AppTheme.ui(
                      fontSize: 12,
                      color: isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft,
                    ),
                  ),
                  trailing: bible.currentVersion == 'WEB'
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.teal,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
