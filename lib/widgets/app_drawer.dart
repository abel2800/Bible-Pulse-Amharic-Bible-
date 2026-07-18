import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_capabilities.dart';
import '../providers/study_provider.dart';
import '../services/auth_service.dart';
import '../services/study_sync_service.dart';
import '../utils/app_theme.dart';
import 'design/bp_widgets.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final capabilities = context.watch<AppCapabilities>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final inkSoft = isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft;

    return Drawer(
      backgroundColor: isDark ? AppTheme.appBgDark : AppTheme.appBgLight,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BpBrandMark(size: 52),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      style: AppTheme.brandTitle(fontSize: 22, color: ink),
                      children: const [
                        TextSpan(text: 'Bible'),
                        TextSpan(
                          text: 'Pulse',
                          style: TextStyle(color: AppTheme.gold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Offline reading',
                    style: AppTheme.ui(fontSize: 12.5, color: inkSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const BpRule(),
            _item(context, Icons.search_rounded, 'Search', '/search'),
            if (capabilities.devotionals)
              _item(
                context,
                Icons.self_improvement_rounded,
                'Devotionals',
                '/devotions',
              ),
            if (capabilities.readingPlans)
              _item(
                context,
                Icons.route_rounded,
                'Reading plans',
                '/reading_plans',
              ),
            if (capabilities.cloud && capabilities.readingPlans)
              _item(
                context,
                Icons.groups_rounded,
                'Private reading groups',
                '/study_groups',
              ),
            if (capabilities.hymns)
              _item(context, Icons.music_note_rounded, 'Hymns', '/hymns'),
            _item(
              context,
              Icons.volunteer_activism_rounded,
              'Prayer journal',
              '/prayer_journal',
            ),
            if (capabilities.community)
              _item(context, Icons.forum_outlined, 'Community', '/community'),
            _item(
              context,
              Icons.wallpaper_rounded,
              'Verse wallpaper',
              '/wallpaper',
              enabled: capabilities.wallpaperExport,
            ),
            const SizedBox(height: 8),
            const BpRule(),
            if (!capabilities.cloud)
              ListTile(
                minTileHeight: 48,
                leading: Icon(Icons.cloud_off_rounded, color: inkSoft),
                title: Text(
                  'Cloud sync not configured',
                  style: AppTheme.ui(fontSize: 13, color: inkSoft),
                ),
              )
            else if (context.watch<AuthService>().currentUser == null)
              _item(context, Icons.login_rounded, 'Sign in to sync', '/auth')
            else ...[
              ListTile(
                minTileHeight: 48,
                leading: Icon(Icons.sync_rounded, color: inkSoft),
                title: Text(
                  'Sync study data',
                  style: AppTheme.ui(
                      fontSize: 13.5, weight: FontWeight.w500, color: ink),
                ),
                onTap: () async {
                  final user = context.read<AuthService>().currentUser!;
                  await context.read<StudyProvider>().synchronize(
                        context.read<StudySyncGateway>(),
                        user.uid,
                      );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                minTileHeight: 48,
                leading: Icon(Icons.logout_rounded, color: inkSoft),
                title: Text(
                  'Sign out',
                  style: AppTheme.ui(
                      fontSize: 13.5, weight: FontWeight.w500, color: ink),
                ),
                onTap: () async {
                  await context.read<AuthService>().signOut();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final inkSoft = isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft;
    final faint = isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint;

    return ListTile(
      minTileHeight: 48,
      enabled: enabled,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(icon, color: enabled ? inkSoft : faint),
      title: Text(
        label,
        style: AppTheme.ui(
          fontSize: 13.5,
          weight: FontWeight.w500,
          color: enabled ? ink : faint,
        ),
      ),
      trailing: Icon(
        enabled ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
        size: 18,
        color: faint,
      ),
      onTap: enabled
          ? () {
              Navigator.pop(context);
              Navigator.pushNamed(context, route);
            }
          : null,
    );
  }
}
