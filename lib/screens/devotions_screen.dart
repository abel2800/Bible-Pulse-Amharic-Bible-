import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/devotional_provider.dart';

class DevotionsScreen extends StatelessWidget {
  const DevotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DevotionalProvider>();
    final devotional = provider.todayDevotional;
    return Scaffold(
      appBar: AppBar(title: const Text('Devotionals')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : devotional == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No licensed devotional catalog is installed.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      devotional.verseReference,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(devotional.dailyVerse),
                    const SizedBox(height: 24),
                    Text(
                      'Prayer',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(devotional.dailyPrayer),
                  ],
                ),
    );
  }
}
