import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Highlight color palette — single source of truth for the manuscript UI.
const kHighlightColors = [
  Color(0xFFC08A28),
  Color(0xFF1E7F72),
  Color(0xFFA83232),
  Color(0xFF6E8B3D),
  Color(0xFF7B5EA7),
];

enum VerseSheetAction { note, bookmark, share, copy, removeHighlight }

class VerseSheetResult {
  final Color? highlightColor;
  final VerseSheetAction? action;
  VerseSheetResult({this.highlightColor, this.action});
}

/// Compact manuscript verse action sheet (highlight swatches + action rows).
Future<VerseSheetResult?> showVerseActionSheet(
  BuildContext context, {
  required String reference,
  required String verseText,
  Color? currentColor,
}) {
  return showModalBottomSheet<VerseSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    builder: (_) => _VerseActionSheet(
      reference: reference,
      verseText: verseText,
      currentColor: currentColor,
    ),
  );
}

class _VerseActionSheet extends StatefulWidget {
  final String reference;
  final String verseText;
  final Color? currentColor;
  const _VerseActionSheet({
    required this.reference,
    required this.verseText,
    this.currentColor,
  });

  @override
  State<_VerseActionSheet> createState() => _VerseActionSheetState();
}

class _VerseActionSheetState extends State<_VerseActionSheet> {
  Color? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.colors;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: t.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 14),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFFC08A28), width: 3),
                ),
              ),
              child: Text(
                '"${widget.verseText}" — ${widget.reference}',
                style: AppText.scripture(
                  context,
                  size: 14.5,
                  style: FontStyle.italic,
                ).copyWith(color: t.inkSoft),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: kHighlightColors.map((c) {
                final sel = _selected == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      setState(() => _selected = c);
                      Navigator.pop(
                        context,
                        VerseSheetResult(highlightColor: c),
                      );
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? t.ink : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            _ActionRow(
              icon: Icons.edit_note,
              label: 'Add note',
              onTap: () => Navigator.pop(
                context,
                VerseSheetResult(action: VerseSheetAction.note),
              ),
            ),
            _ActionRow(
              icon: Icons.bookmark_border,
              label: 'Bookmark',
              onTap: () => Navigator.pop(
                context,
                VerseSheetResult(action: VerseSheetAction.bookmark),
              ),
            ),
            _ActionRow(
              icon: Icons.ios_share,
              label: 'Share as verse card',
              onTap: () => Navigator.pop(
                context,
                VerseSheetResult(action: VerseSheetAction.share),
              ),
            ),
            _ActionRow(
              icon: Icons.copy_outlined,
              label: 'Copy text',
              onTap: () => Navigator.pop(
                context,
                VerseSheetResult(action: VerseSheetAction.copy),
              ),
            ),
            if (widget.currentColor != null)
              _ActionRow(
                icon: Icons.close,
                label: 'Remove highlight',
                color: const Color(0xFFA83232),
                onTap: () => Navigator.pop(
                  context,
                  VerseSheetResult(action: VerseSheetAction.removeHighlight),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: t.surface2,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: color ?? t.inkSoft),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: AppText.ui(
                context,
                size: 13.5,
                w: FontWeight.w500,
                color: color ?? t.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
