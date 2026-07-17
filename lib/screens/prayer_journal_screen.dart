import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/engagement_provider.dart';

class PrayerJournalScreen extends StatelessWidget {
  const PrayerJournalScreen({super.key, this.initialVerseReference});

  final String? initialVerseReference;

  @override
  Widget build(BuildContext context) {
    final engagement = context.watch<EngagementProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer journal')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPrayer(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New prayer'),
      ),
      body: engagement.prayers.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Your private prayers stay on this device until cloud '
                  'journal sync is explicitly enabled.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: engagement.prayers.length,
              itemBuilder: (context, index) {
                final prayer = engagement.prayers[index];
                return Card(
                  child: ListTile(
                    minTileHeight: 72,
                    leading: IconButton(
                      tooltip:
                          prayer.isAnswered ? 'Mark active' : 'Mark answered',
                      onPressed: () => engagement.toggleAnswered(prayer.id),
                      icon: Icon(
                        prayer.isAnswered
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: prayer.isAnswered
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                      ),
                    ),
                    title: Text(
                      prayer.text,
                      style: TextStyle(
                        decoration: prayer.isAnswered
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: prayer.verseReference == null
                        ? null
                        : Text(prayer.verseReference!),
                    trailing: IconButton(
                      tooltip: 'Delete prayer',
                      onPressed: () => engagement.deletePrayer(prayer.id),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _addPrayer(BuildContext context) async {
    final controller = TextEditingController();
    final referenceController =
        TextEditingController(text: initialVerseReference);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New prayer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Prayer'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: referenceController,
              decoration: const InputDecoration(
                labelText: 'Verse reference (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
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
