import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_capabilities.dart';
import '../providers/study_provider.dart';
import '../services/auth_service.dart';
import '../services/study_sync_service.dart';
import '../utils/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final capabilities = context.watch<AppCapabilities>();

    return NavigationDrawer(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryIndigo,
                foregroundColor: AppTheme.parchment,
                child: Icon(Icons.auto_stories_rounded),
              ),
              const SizedBox(height: 16),
              Text(
                'BiblePulse',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Offline reading',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        const Divider(),
        _destination(context, Icons.search_rounded, 'Search', '/search'),
        if (capabilities.devotionals)
          _destination(
            context,
            Icons.self_improvement_rounded,
            'Devotionals',
            '/devotions',
          ),
        if (capabilities.readingPlans)
          _destination(
            context,
            Icons.route_rounded,
            'Reading plans',
            '/reading_plans',
          ),
        if (capabilities.cloud && capabilities.readingPlans)
          _destination(
            context,
            Icons.groups_rounded,
            'Private reading groups',
            '/study_groups',
          ),
        if (capabilities.hymns)
          _destination(context, Icons.music_note_rounded, 'Hymns', '/hymns'),
        _destination(
          context,
          Icons.volunteer_activism_rounded,
          'Prayer journal',
          '/prayer_journal',
        ),
        if (capabilities.community)
          _destination(
            context,
            Icons.forum_outlined,
            'Community',
            '/community',
          ),
        _destination(
          context,
          Icons.wallpaper_rounded,
          'Verse wallpaper',
          '/wallpaper',
          enabled: capabilities.wallpaperExport,
        ),
        const Divider(),
        if (!capabilities.cloud)
          const ListTile(
            minTileHeight: 48,
            leading: Icon(Icons.cloud_off_rounded),
            title: Text('Cloud sync not configured'),
          )
        else if (context.watch<AuthService>().currentUser == null)
          _destination(
            context,
            Icons.login_rounded,
            'Sign in to sync',
            '/auth',
          )
        else ...[
          ListTile(
            minTileHeight: 48,
            leading: const Icon(Icons.sync_rounded),
            title: const Text('Sync study data'),
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
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
            onTap: () async {
              await context.read<AuthService>().signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _destination(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    bool enabled = true,
  }) {
    return ListTile(
      minTileHeight: 48,
      enabled: enabled,
      leading: Icon(icon),
      title: Text(label),
      trailing: enabled
          ? const Icon(Icons.chevron_right_rounded)
          : const Icon(Icons.lock_outline_rounded, size: 18),
      onTap: enabled
          ? () {
              Navigator.pop(context);
              Navigator.pushNamed(context, route);
            }
          : null,
    );
  }
}
