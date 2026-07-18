import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Opens the chapter grid and returns the chosen chapter number, or null.
Future<int?> showChapterSelector(
  BuildContext context, {
  required String book,
  required int chapterCount,
  required int current,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: context.colors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ChapterSelectorSheet(
      book: book,
      chapterCount: chapterCount,
      current: current,
    ),
  );
}

class _ChapterSelectorSheet extends StatelessWidget {
  final String book;
  final int chapterCount;
  final int current;
  const _ChapterSelectorSheet({
    required this.book,
    required this.chapterCount,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.colors;
    return FractionallySizedBox(
      heightFactor: 0.6,
      child: Column(
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
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(book, style: AppText.display(context, size: 17)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: chapterCount,
              itemBuilder: (context, i) {
                final chapter = i + 1;
                final selected = chapter == current;
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.pop(context, chapter),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFC08A28)
                          : t.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFC08A28)
                            : t.border,
                      ),
                    ),
                    child: Text(
                      '$chapter',
                      style: AppText.ui(
                        context,
                        size: 13.5,
                        w: FontWeight.w700,
                        color: selected
                            ? const Color(0xFF241804)
                            : t.ink,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
