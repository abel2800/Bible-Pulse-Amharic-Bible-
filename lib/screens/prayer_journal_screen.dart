import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/engagement_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/design/bp_widgets.dart';

class PrayerJournalScreen extends StatelessWidget {
  const PrayerJournalScreen({super.key, this.initialVerseReference});

  final String? initialVerseReference;

  @override
  Widget build(BuildContext context) {
    final engagement = context.watch<EngagementProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final soft = isDark ? AppTheme.inkSoftDark : AppTheme.inkSoft;
    final faint = isDark ? AppTheme.inkFaintDark : AppTheme.inkFaint;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPrayer(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New prayer',
          style: AppTheme.ui(fontSize: 13, weight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
              child: Row(
                children: [
                  BpIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Prayer journal',
                    style: AppTheme.brandTitle(fontSize: 22, color: ink),
                  ),
                ],
              ),
            ),
            Expanded(
              child: engagement.prayers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.surface2Dark
                                    : AppTheme.surface2Light,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.borderDark
                                      : AppTheme.borderLight,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.volunteer_activism_rounded,
                                size: 36,
                                color: AppTheme.gold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No prayers yet',
                              style:
                                  AppTheme.brandTitle(fontSize: 20, color: ink),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Your private prayers stay on this device until cloud '
                              'journal sync is explicitly enabled.',
                              textAlign: TextAlign.center,
                              style: AppTheme.scripture(
                                fontSize: 15,
                                height: 1.55,
                                color: soft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                      itemCount: engagement.prayers.length,
                      itemBuilder: (context, index) {
                        final prayer = engagement.prayers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BpCard(
                            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  tooltip: prayer.isAnswered
                                      ? 'Mark active'
                                      : 'Mark answered',
                                  onPressed: () =>
                                      engagement.toggleAnswered(prayer.id),
                                  icon: Icon(
                                    prayer.isAnswered
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: prayer.isAnswered
                                        ? AppTheme.teal
                                        : faint,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prayer.text,
                                        style: AppTheme.scripture(
                                          fontSize: 15,
                                          height: 1.55,
                                          color: ink,
                                        ).copyWith(
                                          decoration: prayer.isAnswered
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationColor: soft,
                                        ),
                                      ),
                                      if (prayer.verseReference != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          prayer.verseReference!.toUpperCase(),
                                          style: AppTheme.ui(
                                            fontSize: 11,
                                            weight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                            color: AppTheme.gold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete prayer',
                                  onPressed: () =>
                                      engagement.deletePrayer(prayer.id),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppTheme.vermilion,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPrayer(BuildContext context) async {
    final controller = TextEditingController();
    final referenceController =
        TextEditingController(text: initialVerseReference);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'New prayer',
          style: AppTheme.brandTitle(fontSize: 18, color: ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 4,
              style: AppTheme.scripture(fontSize: 15, color: ink),
              decoration: const InputDecoration(labelText: 'Prayer'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: referenceController,
              style: AppTheme.ui(fontSize: 14, color: ink),
              decoration: const InputDecoration(
                labelText: 'Verse reference (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTheme.ui(fontSize: 13, weight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      await context.read<EngagementProvider>().addPrayer(
            controller.text,
            verseReference: referenceController.text.trim().isEmpty
                ? null
                : referenceController.text.trim(),
          );
    }
    controller.dispose();
    referenceController.dispose();
  }
}
