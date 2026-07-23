import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_capabilities.dart';
import '../l10n/app_localizations.dart';
import '../models/color_theme.dart';
import '../providers/color_theme_provider.dart';
import '../providers/font_settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_download_provider.dart';
import '../providers/audio_store_provider.dart';
import '../providers/bible_provider.dart';
import '../providers/bible_store_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/design/bp_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<ThemeProvider>();
    final readerTheme = context.watch<ColorThemeProvider>();
    final fonts = context.watch<FontSettingsProvider>();
    final capabilities = context.watch<AppCapabilities>();
    final prefs = context.watch<UserPreferencesProvider>();
    final bibleStore = context.watch<BibleStoreProvider>();
    final audioStore = context.watch<AudioStoreProvider>();
    final bible = context.watch<BibleProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final amharic = prefs.appLanguageCode == 'am';
    String text(String english, String amharicText) =>
        amharic ? amharicText : english;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.appBgDark : AppTheme.appBgLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Row(
                  children: [
                    if (Navigator.of(context).canPop()) ...[
                      BpIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        tooltip: l10n.close,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      l10n.settings,
                      style: AppTheme.brandTitle(fontSize: 22, color: ink),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SettingsSection(
                  header: l10n.appearance,
                  children: [
                    SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto_rounded),
                          label: Text(l10n.system),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode_rounded),
                          label: Text(l10n.light),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode_rounded),
                          label: Text(l10n.dark),
                        ),
                      ],
                      selected: {appTheme.themeMode},
                      onSelectionChanged: (selection) =>
                          appTheme.setThemeMode(selection.first),
                    ),
                  ],
                ),
                _SettingsSection(
                  header: l10n.appLanguage,
                  children: [
                    Text(
                      l10n.preferredLanguageSubtitle,
                      style: AppTheme.ui(
                        fontSize: 12.5,
                        color: isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RadioGroup<String>(
                      groupValue: prefs.appLanguageCode,
                      onChanged: (value) async {
                        if (value == null) return;
                        await prefs.setAppLanguage(value);
                        await appTheme.setLocale(Locale(value));
                        if (!context.mounted) return;
                        final hasScripture = bibleStore.installed.values
                            .any((item) => item.language == value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              hasScripture
                                  ? l10n.scriptureLanguageNote
                                  : l10n.noScriptureForLanguage,
                            ),
                            action: SnackBarAction(
                              label: l10n.openBibleStore,
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/bible_store',
                              ),
                            ),
                          ),
                        );
                      },
                      child: _ConnectedSet(
                        children: [
                          for (final entry in [
                            ('en', l10n.english),
                            ('am', l10n.amharic),
                            ('om', l10n.afaanOromo),
                            ('ti', l10n.tigrinya),
                            ('so', l10n.somali),
                          ].asMap().entries)
                            _SetRow(
                              position: entry.key == 0
                                  ? _RowPosition.first
                                  : entry.key == 4
                                      ? _RowPosition.last
                                      : _RowPosition.middle,
                              child: RadioListTile<String>(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                value: entry.value.$1,
                                title: Text(
                                  entry.value.$2,
                                  style:
                                      AppTheme.ui(fontSize: 14, color: ink),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                _SettingsSection(
                  header: l10n.preferredBible,
                  children: [
                    Text(
                      l10n.preferredBibleSubtitle,
                      style: AppTheme.ui(
                        fontSize: 12.5,
                        color: isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.scriptureLanguageNote,
                      style: AppTheme.ui(
                        fontSize: 12.5,
                        color: isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        bibleStore.catalog
                                .where((p) =>
                                    p.versionId == prefs.preferredBibleVersionId)
                                .map((p) => p.name)
                                .firstOrNull ??
                            prefs.preferredBibleVersionId,
                        style: AppTheme.ui(
                          fontSize: 14,
                          weight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                      subtitle: Text(
                        bible.currentVersion,
                        style: AppTheme.ui(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.inkSoftDark
                              : AppTheme.inkSoft,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/bible_store'),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/bible_store'),
                        child: Text(l10n.openBibleStore),
                      ),
                    ),
                  ],
                ),
                _SettingsSection(
                  header: l10n.preferredAudio,
                  children: [
                    Text(
                      l10n.preferredAudioSubtitle,
                      style: AppTheme.ui(
                        fontSize: 12.5,
                        color: isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.audioSetupNote,
                      style: AppTheme.ui(
                        fontSize: 12.5,
                        color: isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        prefs.preferredAudioPackageId.isEmpty
                            ? l10n.notSet
                            : (audioStore.catalog
                                    .where((p) =>
                                        p.id == prefs.preferredAudioPackageId)
                                    .map((p) => p.name)
                                    .firstOrNull ??
                                prefs.preferredAudioPackageId),
                        style: AppTheme.ui(
                          fontSize: 14,
                          weight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/audio_store'),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/audio_store'),
                        child: Text(l10n.openAudioStore),
                      ),
                    ),
                  ],
                ),
                _SettingsSection(
                  header: l10n.readerTheme,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: readerTheme.availableThemes.map((theme) {
                          final selected =
                              readerTheme.currentTheme.id == theme.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _ReaderThemeSwatch(
                              theme: theme,
                              selected: selected,
                              onTap: () => readerTheme.setTheme(theme.id),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SliderSetting(
                      label: text('Scripture text size', 'የቅዱስ ጽሑፍ መጠን'),
                      valueLabel: fonts.fontSize.round().toString(),
                      value: fonts.fontSize.clamp(14, 30).toDouble(),
                      min: 14,
                      max: 30,
                      divisions: 16,
                      onChanged: fonts.setFontSize,
                    ),
                    _SliderSetting(
                      label: text('Line spacing', 'የመስመር ክፍተት'),
                      valueLabel: fonts.lineHeight.toStringAsFixed(1),
                      value: fonts.lineHeight.clamp(1.2, 2).toDouble(),
                      min: 1.2,
                      max: 2,
                      divisions: 8,
                      onChanged: fonts.setLineHeight,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: fonts.resetToDefaults,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: Text(
                          text('Reset reader text', 'የንባብ ጽሑፍ ዳግም አስጀምር'),
                        ),
                      ),
                    ),
                  ],
                ),
                _SettingsSection(
                  header: text('Feature availability', 'የባህሪ ተገኝነት'),
                  children: [
                    _ConnectedSet(
                      children: [
                        _SetRow(
                          position: _RowPosition.first,
                          child: _Capability(
                            label: text(
                              'Cloud account and sync',
                              'የደመና መለያ እና ማመሳሰል',
                            ),
                            available: capabilities.cloud,
                          ),
                        ),
                        _SetRow(
                          position: _RowPosition.middle,
                          child: _Capability(
                            label: text('Chapter audio', 'የምዕራፍ ድምጽ'),
                            available: capabilities.audio,
                          ),
                        ),
                        _SetRow(
                          position: _RowPosition.middle,
                          child: _Capability(
                            label: text('Daily reminders', 'ዕለታዊ ማስታወሻዎች'),
                            available: capabilities.notifications,
                          ),
                        ),
                        _SetRow(
                          position: _RowPosition.last,
                          child: _Capability(
                            label: text(
                              'Wallpaper export',
                              'የግድግዳ ወረቀት ማስቀመጥ',
                            ),
                            available: capabilities.wallpaperExport,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (capabilities.audio) _AudioStorageSection(text: text),
                if (capabilities.notifications)
                  _ThemeNotificationSection(text: text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _RowPosition { first, middle, last, only }

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.header, required this.children});

  final String header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BpGroupHeader(header),
          ...children,
        ],
      ),
    );
  }
}

class _ConnectedSet extends StatelessWidget {
  const _ConnectedSet({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(children: children);
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.position, required this.child});

  final _RowPosition position;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    BorderRadius radius;
    switch (position) {
      case _RowPosition.first:
        radius = const BorderRadius.vertical(top: Radius.circular(14));
      case _RowPosition.last:
        radius = const BorderRadius.vertical(bottom: Radius.circular(14));
      case _RowPosition.only:
        radius = BorderRadius.circular(14);
      case _RowPosition.middle:
        radius = BorderRadius.zero;
    }

    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _ReaderThemeSwatch extends StatelessWidget {
  const _ReaderThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final ReaderColorTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final faint = isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint;

    return Semantics(
      label: '${theme.name} reader theme',
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? AppTheme.gold
                      : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  width: selected ? 2.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.gold.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  'Aa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              theme.name,
              style: AppTheme.ui(
                fontSize: 10,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppTheme.gold : faint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeNotificationSection extends StatelessWidget {
  const _ThemeNotificationSection({required this.text});

  final String Function(String english, String amharic) text;

  @override
  Widget build(BuildContext context) {
    final reminders = context.watch<ReminderProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final soft = isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft;

    return _SettingsSection(
      header: text('Theme notification', 'የጭብጥ ማሳወቂያ'),
      children: [
        Text(
          text(
            'Choose the Scripture need used for the daily 8:00 reminder.',
            'ለዕለታዊ 8:00 ማሳወቂያ የቃሉን ጭብጥ ይምረጡ።',
          ),
          style: AppTheme.ui(fontSize: 13, color: soft),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final theme in ReminderProvider.themes)
              ChoiceChip(
                label: Text(theme),
                selected: reminders.theme == theme,
                onSelected: (_) async {
                  final enabled = await reminders.enableThemeNotification(
                    theme: theme,
                    hour: 8,
                    minute: 0,
                  );
                  if (!enabled && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Notification permission or Scripture is unavailable.',
                        ),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _AudioStorageSection extends StatelessWidget {
  const _AudioStorageSection({required this.text});

  final String Function(String english, String amharic) text;

  @override
  Widget build(BuildContext context) {
    final downloads = context.watch<AudioDownloadProvider>();
    final sizeMb = downloads.cacheSizeBytes / (1024 * 1024);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final soft = isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft;

    return _SettingsSection(
      header: text('Offline audio', 'ከመስመር ውጭ ድምጽ'),
      children: [
        _ConnectedSet(
          children: [
            _SetRow(
              position: _RowPosition.first,
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                title: Text(text('Wi-Fi only downloads', 'በWi-Fi ብቻ አውርድ')),
                subtitle: Text(
                  text(
                    'Streaming-only filesets are never cached.',
                    'ለማውረድ ያልተፈቀዱ ድምጾች አይቀመጡም።',
                  ),
                  style: AppTheme.ui(fontSize: 12, color: soft),
                ),
                value: downloads.wifiOnly,
                onChanged: downloads.downloading ? null : downloads.setWifiOnly,
              ),
            ),
            _SetRow(
              position: _RowPosition.middle,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                leading:
                    const Icon(Icons.storage_rounded, color: AppTheme.teal),
                title: Text(text('Downloaded audio', 'የወረደ ድምጽ')),
                subtitle: Text('${sizeMb.toStringAsFixed(1)} MB'),
                trailing: TextButton(
                  onPressed: downloads.downloading
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                text('Clear audio?', 'ድምጹን ይሰርዙ?'),
                              ),
                              content: Text(
                                text(
                                  'Downloaded chapters will need to be downloaded again.',
                                  'የወረዱ ምዕራፎች እንደገና መውረድ ይኖርባቸዋል።',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(text('Cancel', 'ይቅር')),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(text('Clear', 'ሰርዝ')),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) await downloads.clearCache();
                        },
                  child: Text(text('Clear', 'ሰርዝ')),
                ),
              ),
            ),
            _SetRow(
              position: _RowPosition.last,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                leading: const Icon(
                  Icons.download_for_offline_rounded,
                  color: AppTheme.teal,
                ),
                title: Text(
                  text('Download whole Bible audio', 'ሙሉ የመጽሐፍ ቅዱስ ድምጽ'),
                ),
                subtitle: Text(
                  text(
                    'Only starts when the selected fileset is download-permitted.',
                    'የድምጽ ስብስቡ ለማውረድ ከተፈቀደ ብቻ ይጀምራል።',
                  ),
                  style: AppTheme.ui(fontSize: 12, color: soft),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint,
                ),
                onTap: downloads.downloading
                    ? null
                    : () async {
                        final books = context.read<BibleProvider>().books;
                        final versionId =
                            context.read<BibleProvider>().currentVersion;
                        final chapters = [
                          for (final book in books)
                            for (var chapter = 1;
                                chapter <= book.chapters;
                                chapter++)
                              (bookId: book.id, chapter: chapter),
                        ];
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              text('Download all audio?', 'ሁሉንም ድምጽ ያውርዱ?'),
                            ),
                            content: Text(
                              text(
                                '${chapters.length} chapters will download sequentially. '
                                    'Actual size depends on the licensed fileset.',
                                '${chapters.length} ምዕራፎች በተከታታይ ይወርዳሉ።',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(text('Cancel', 'ይቅር')),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(text('Download', 'አውርድ')),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await downloads.downloadChapters(
                            versionId: versionId,
                            chapters: chapters,
                          );
                        }
                      },
              ),
            ),
          ],
        ),
        if (downloads.downloading) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: downloads.progress),
          const SizedBox(height: 8),
          Text(
            '${downloads.completedChapters}/${downloads.totalChapters} chapters',
            style: AppTheme.ui(fontSize: 12, color: soft),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: downloads.pause,
              icon: const Icon(Icons.pause_rounded),
              label: Text(text('Pause download', 'ማውረዱን አቁም')),
            ),
          ),
        ],
        if (downloads.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              downloads.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;

    return Semantics(
      label: label,
      value: valueLabel,
      slider: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label · $valueLabel',
            style:
                AppTheme.ui(fontSize: 13, weight: FontWeight.w500, color: ink),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Capability extends StatelessWidget {
  const _Capability({required this.label, required this.available});

  final String label;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final faint = isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint;

    return ListTile(
      minTileHeight: 48,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Icon(
        available ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
        color: available ? AppTheme.teal : faint,
      ),
      title: Text(label, style: AppTheme.ui(fontSize: 14, color: ink)),
      trailing: Text(
        available ? 'Available' : 'Not configured',
        style: AppTheme.ui(
          fontSize: 11,
          weight: FontWeight.w500,
          color: faint,
        ),
      ),
    );
  }
}
