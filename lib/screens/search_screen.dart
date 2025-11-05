import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bible_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/verse_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bible'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter search term',
                  prefixIcon: Icon(Icons.search),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    bibleProvider.searchVerses(value.trim());
                  }
                },
              ),
              const SizedBox(height: 12),
              if (bibleProvider.isSearching)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (bibleProvider.searchResults.isEmpty)
                const Expanded(child: Center(child: Text('No results')))
              else
                Expanded(
                  child: ListView.separated(
                        itemCount: bibleProvider.searchResults.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final verse = bibleProvider.searchResults[index];
                          final reference = bibleProvider.getVerseReference(verse);
                          return InkWell(
                            onTap: () async {
                              await bibleProvider.goToVerse(verse.book, verse.chapter, verse.verse);
                              Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
                              if (mounted) Navigator.pop(context);
                            },
                            child: VerseCard(
                              verse: verse,
                              reference: reference,
                              isHighlighted: false,
                            ),
                          );
                        },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
