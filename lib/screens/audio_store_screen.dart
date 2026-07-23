import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_capabilities.dart';
import '../l10n/app_localizations.dart';
import '../models/audio_package.dart';
import '../providers/audio_download_provider.dart';
import '../providers/audio_store_provider.dart';
import '../providers/bible_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../utils/app_theme.dart';

class AudioStoreScreen extends StatelessWidget {
  const AudioStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = context.watch<AudioStoreProvider>();
    final t = context.colors;
    final capabilities = context.watch<AppCapabilities>();

    return Scaffold(
      backgroundColor: t.appBg,
      appBar: AppBar(title: Text(l10n.audioStore)),
      body: !store.ready
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!capabilities.audio)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: t.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.border),
                      ),
                      child: Text(
                        l10n.audioSetupNote,
                        style: AppText.ui(context, size: 13, color: t.inkSoft),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: TextField(
                    onChanged: store.setQuery,
                    decoration: InputDecoration(
                      hintText: l10n.searchAudio,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: store.visiblePackages.length,
                    itemBuilder: (context, index) {
                      return _AudioCard(package: store.visiblePackages[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _AudioCard extends StatelessWidget {
  const _AudioCard({required this.package});

  final AudioPackageInfo package;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = context.watch<AudioStoreProvider>();
    final prefs = context.watch<UserPreferencesProvider>();
    final t = context.colors;
    final installed = store.isInstalled(package.id);
    final canActivate = store.canActivate(package);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(package.name, style: AppText.display(context, size: 17)),
          const SizedBox(height: 6),
          Text(
            '${package.languageName} · ${package.translation} · ${package.narrator}',
            style: AppText.ui(context, size: 12, color: t.inkSoft),
          ),
          const SizedBox(height: 10),
          Text(
            package.description,
            style: AppText.ui(context, size: 13, color: t.inkSoft),
          ),
          const SizedBox(height: 10),
          Text(
            '${l10n.quality}: ${package.quality} · ${l10n.duration}: ${package.durationLabel}',
            style: AppText.uiFaint(context),
          ),
          const SizedBox(height: 14),
          if (!package.approved)
            Text(
              l10n.requiresLicense,
              style: AppText.ui(
                context,
                size: 12.5,
                w: FontWeight.w600,
                color: AppBrand.vermilion,
              ),
            )
          else if (!canActivate)
            Text(l10n.audioGated, style: AppText.ui(context, size: 12.5))
          else
            Row(
              children: [
                if (!installed)
                  ElevatedButton(
                    onPressed: () async {
                      final bible = context.read<BibleProvider>();
                      try {
                        final downloads = context.read<AudioDownloadProvider>();
                        final book = bible.selectedBook;
                        if (book != null) {
                          await downloads.downloadBook(
                            versionId: package.bibleVersionId,
                            bookId: book.id,
                            chapterCount: book.chapters,
                          );
                        }
                      } catch (_) {
                        // Audio download provider may be gated off.
                      }
                      await store.markInstalled(package);
                      await prefs.setPreferredAudio(package.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.downloadComplete)),
                        );
                      }
                    },
                    child: Text(l10n.download),
                  )
                else ...[
                  OutlinedButton(
                    onPressed: () => prefs.setPreferredAudio(package.id),
                    child: Text(l10n.preferredAudio),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => store.uninstall(package.id),
                    child: Text(l10n.delete),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
