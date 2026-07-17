import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_capabilities.dart';
import '../providers/color_theme_provider.dart';
import '../providers/font_settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_download_provider.dart';
import '../providers/bible_provider.dart';
import '../providers/reminder_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<ThemeProvider>();
    final readerTheme = context.watch<ColorThemeProvider>();
    final fonts = context.watch<FontSettingsProvider>();
    final capabilities = context.watch<AppCapabilities>();
    final amharic = appTheme.locale.languageCode == 'am';

    String text(String english, String amharicText) =>
        amharic ? amharicText : english;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        title: Text(text('Settings', 'ቅንብሮች')),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(
                  title: text('Appearance', 'ገጽታ'),
                  children: [
                    SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto_rounded),
                          label: Text(text('System', 'የስርዓት')),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode_rounded),
                          label: Text(text('Light', 'ብርሃን')),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode_rounded),
                          label: Text(text('Dark', 'ጨለማ')),
                        ),
                      ],
                      selected: {appTheme.themeMode},
                      onSelectionChanged: (selection) =>
                          appTheme.setThemeMode(selection.first),
                    ),
                  ],
                ),
                _Section(
                  title: text('Language', 'ቋንቋ'),
                  children: [
                    RadioGroup<String>(
                      groupValue: appTheme.locale.languageCode,
                      onChanged: (value) {
                        if (value != null) {
                          appTheme.setLocale(Locale(value));
                        }
                      },
                      child: const Column(
                        children: [
                          RadioListTile<String>(
                            value: 'en',
                            title: Text('English'),
                          ),
                          RadioListTile<String>(
                            value: 'am',
                            title: Text('አማርኛ'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _Section(
                  title: text('Reader theme', 'የንባብ ገጽታ'),
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: readerTheme.availableThemes
                          .map(
                            (theme) => Semantics(
                              label: '${theme.name} reader theme',
                              selected: readerTheme.currentTheme.id == theme.id,
                              button: true,
                              child: ChoiceChip(
                                selected:
                                    readerTheme.currentTheme.id == theme.id,
                                avatar: CircleAvatar(
                                  backgroundColor: theme.backgroundColor,
                                  child: Icon(
                                    Icons.text_fields_rounded,
                                    color: theme.textColor,
                                    size: 16,
                                  ),
                                ),
                                label: Text(theme.name),
                                onSelected: (_) =>
                                    readerTheme.setTheme(theme.id),
                              ),
                            ),
                          )
                          .toList(),
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
                            text('Reset reader text', 'የንባብ ጽሑፍ ዳግም አስጀምር')),
                      ),
                    ),
                  ],
                ),
                _Section(
                  title: text('Feature availability', 'የባህሪ ተገኝነት'),
                  children: [
                    _Capability(
                      label:
                          text('Cloud account and sync', 'የደመና መለያ እና ማመሳሰል'),
                      available: capabilities.cloud,
                    ),
                    _Capability(
                      label: text('Chapter audio', 'የምዕራፍ ድምጽ'),
                      available: capabilities.audio,
                    ),
                    _Capability(
                      label: text('Daily reminders', 'ዕለታዊ ማስታወሻዎች'),
                      available: capabilities.notifications,
                    ),
                    _Capability(
                      label: text('Wallpaper export', 'የግድግዳ ወረቀት ማስቀመጥ'),
                      available: capabilities.wallpaperExport,
                    ),
                  ],
                ),
                if (capabilities.audio)
                  _AudioStorageSection(
                    text: text,
                  ),
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

class _ThemeNotificationSection extends StatelessWidget {
  const _ThemeNotificationSection({required this.text});

  final String Function(String english, String amharic) text;

  @override
  Widget build(BuildContext context) {
    final reminders = context.watch<ReminderProvider>();
    return _Section(
      title: text('Theme notification', 'የጭብጥ ማሳወቂያ'),
      children: [
        Text(
          text(
            'Choose the Scripture need used for the daily 8:00 reminder.',
            'ለዕለታዊ 8:00 ማሳወቂያ የቃሉን ጭብጥ ይምረጡ።',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
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
    return _Section(
      title: text('Offline audio', 'ከመስመር ውጭ ድምጽ'),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(text('Wi-Fi only downloads', 'በWi-Fi ብቻ አውርድ')),
          subtitle: Text(
            text(
              'Streaming-only filesets are never cached.',
              'ለማውረድ ያልተፈቀዱ ድምጾች አይቀመጡም።',
            ),
          ),
          value: downloads.wifiOnly,
          onChanged: downloads.downloading ? null : downloads.setWifiOnly,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.storage_rounded),
          title: Text(text('Downloaded audio', 'የወረደ ድምጽ')),
          subtitle: Text('${sizeMb.toStringAsFixed(1)} MB'),
          trailing: TextButton(
            onPressed: downloads.downloading
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(text('Clear audio?', 'ድምጹን ይሰርዙ?')),
                        content: Text(
                          text(
                            'Downloaded chapters will need to be downloaded again.',
                            'የወረዱ ምዕራፎች እንደገና መውረድ ይኖርባቸዋል።',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
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
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.download_for_offline_rounded),
          title: Text(text('Download whole Bible audio', 'ሙሉ የመጽሐፍ ቅዱስ ድምጽ')),
          subtitle: Text(
            text(
              'Only starts when the selected fileset is download-permitted.',
              'የድምጽ ስብስቡ ለማውረድ ከተፈቀደ ብቻ ይጀምራል።',
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: downloads.downloading
              ? null
              : () async {
                  final books = context.read<BibleProvider>().books;
                  final versionId =
                      context.read<BibleProvider>().currentVersion;
                  final chapters = [
                    for (final book in books)
                      for (var chapter = 1; chapter <= book.chapters; chapter++)
                        (bookId: book.id, chapter: chapter),
                  ];
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title:
                          Text(text('Download all audio?', 'ሁሉንም ድምጽ ያውርዱ?')),
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
        if (downloads.downloading) ...[
          LinearProgressIndicator(value: downloads.progress),
          const SizedBox(height: 8),
          Text(
            '${downloads.completedChapters}/${downloads.totalChapters} chapters',
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
          Text(
            downloads.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
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
    return Semantics(
      label: label,
      value: valueLabel,
      slider: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label · $valueLabel'),
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
    return ListTile(
      minTileHeight: 48,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        available ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
        color: available
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      trailing: Text(available ? 'Available' : 'Not configured'),
    );
  }
}
