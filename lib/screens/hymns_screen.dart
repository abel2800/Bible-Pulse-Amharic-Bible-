import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/hymn_provider.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({super.key});

  @override
  State<HymnsScreen> createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<HymnProvider>().loadHymns(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HymnProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Hymns')),
      body: switch ((provider.isLoading, provider.hymns.isEmpty)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (false, true) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No licensed hymn catalog is installed.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        _ => ListView.builder(
            itemCount: provider.hymns.length,
            itemBuilder: (context, index) {
              final hymn = provider.hymns[index];
              return ListTile(
                minTileHeight: 56,
                title: Text('${hymn.number}. ${hymn.title}'),
                subtitle: hymn.author == null ? null : Text(hymn.author!),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(hymn.title),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hymn.scripture != null) ...[
                            Chip(
                              avatar: const Icon(Icons.menu_book_rounded),
                              label: Text(hymn.scripture!),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(hymn.fullText),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                trailing: IconButton(
                  tooltip: provider.isFavorite(hymn.id)
                      ? 'Remove favorite'
                      : 'Add favorite',
                  onPressed: () => provider.toggleFavorite(hymn.id),
                  icon: Icon(
                    provider.isFavorite(hymn.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
              );
            },
          ),
      },
    );
  }
}
