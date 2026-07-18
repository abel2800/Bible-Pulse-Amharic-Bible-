import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bible_book.dart';
import '../providers/bible_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Opens the book picker. Selecting a book loads chapter 1 via [BibleProvider].
Future<void> showBookSelector(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const BookSelectorBottomSheet(),
  );
}

class BookSelectorBottomSheet extends StatefulWidget {
  const BookSelectorBottomSheet({super.key});

  @override
  State<BookSelectorBottomSheet> createState() =>
      _BookSelectorBottomSheetState();
}

class _BookSelectorBottomSheetState extends State<BookSelectorBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.colors;
    final bible = context.watch<BibleProvider>();
    final currentName = bible.selectedBook?.name ?? '';

    bool matches(BibleBook b) =>
        b.name.toLowerCase().contains(_query.toLowerCase());

    final ot = bible.books
        .where((b) => b.testament == 'OT')
        .where(matches)
        .toList();
    final nt = bible.books
        .where((b) => b.testament == 'NT')
        .where(matches)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: t.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: AppText.ui(context),
                decoration: const InputDecoration(
                  hintText: 'Search books…',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                ),
              ),
            ),
            TabBar(
              controller: _tabs,
              labelColor: const Color(0xFFC08A28),
              unselectedLabelColor: t.inkFaint,
              indicatorColor: const Color(0xFFC08A28),
              labelStyle: AppText.ui(context, size: 13, w: FontWeight.w700),
              tabs: const [
                Tab(text: 'Old Testament'),
                Tab(text: 'New Testament'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _BookGrid(
                    books: ot,
                    current: currentName,
                    scrollController: scrollController,
                    onSelect: (book) async {
                      await bible.loadChapter(book.id, 1);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                  _BookGrid(
                    books: nt,
                    current: currentName,
                    scrollController: scrollController,
                    onSelect: (book) async {
                      await bible.loadChapter(book.id, 1);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BookGrid extends StatelessWidget {
  final List<BibleBook> books;
  final String current;
  final ScrollController scrollController;
  final Future<void> Function(BibleBook book) onSelect;

  const _BookGrid({
    required this.books,
    required this.current,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.colors;
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.6,
      ),
      itemCount: books.length,
      itemBuilder: (context, i) {
        final book = books[i];
        final selected = book.name == current;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelect(book),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFC08A28) : t.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFFC08A28) : t.border,
              ),
            ),
            child: Text(
              book.name,
              textAlign: TextAlign.center,
              style: AppText.ui(
                context,
                size: 13,
                w: FontWeight.w600,
                color: selected ? const Color(0xFF241804) : t.ink,
              ),
            ),
          ),
        );
      },
    );
  }
}
