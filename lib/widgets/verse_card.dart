import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bible_verse.dart';
import '../utils/app_theme.dart';
import '../widgets/verse_action_bottom_sheet.dart';

class VerseCard extends StatelessWidget {
  final BibleVerse verse;
  final String reference;
  final bool isHighlighted;
  final Color? highlightColor;
  final bool isBookmarked;
  final bool hasNote;
  final bool isDropCap;
  final bool isAudioActive;
  final Color? textColor;
  final Color? verseNumberColor;
  final double fontSize;
  final double lineHeight;

  const VerseCard({
    super.key,
    required this.verse,
    required this.reference,
    this.isHighlighted = false,
    this.highlightColor,
    this.isBookmarked = false,
    this.hasNote = false,
    this.isDropCap = false,
    this.isAudioActive = false,
    this.textColor,
    this.verseNumberColor,
    this.fontSize = 16,
    this.lineHeight = 1.75,
  });

  @override
  Widget build(BuildContext context) {
    final ink = textColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppTheme.inkDark
            : AppTheme.ink);
    final numberColor = verseNumberColor ?? AppTheme.gold;
    final tint = isAudioActive
        ? AppTheme.teal.withValues(alpha: 0.16)
        : isHighlighted
            ? (highlightColor ?? AppTheme.gold).withValues(alpha: 0.16)
            : Colors.transparent;

    final body = isDropCap
        ? _DropCapVerse(text: verse.text, color: ink, fontSize: fontSize)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 16,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${verse.verse}',
                    style: AppTheme.ui(
                      fontSize: 10.5,
                      weight: FontWeight.w700,
                      color: numberColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  verse.text,
                  style: AppTheme.scripture(
                    fontSize: fontSize,
                    height: lineHeight,
                    color: ink,
                  ),
                ),
              ),
            ],
          );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showActions(context);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showActions(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.symmetric(
          horizontal: tint == Colors.transparent ? 0 : 0,
          vertical: 0,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 9,
          horizontal: tint == Colors.transparent ? 0 : 10,
        ),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(10),
        ),
        child: body,
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => VerseActionBottomSheet(
        verse: verse,
        reference: reference,
      ),
    );
  }
}

class _DropCapVerse extends StatelessWidget {
  const _DropCapVerse({
    required this.text,
    required this.color,
    required this.fontSize,
  });

  final String text;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();
    final drop = trimmed.characters.first;
    final rest = trimmed.substring(drop.length).trimLeft();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          drop.toUpperCase(),
          style: AppTheme.brandTitle(
            fontSize: 52,
            weight: FontWeight.w700,
            color: AppTheme.gold,
          ).copyWith(
            height: 0.85,
            shadows: const [
              Shadow(offset: Offset(1, 1), color: AppTheme.vermilion),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            rest,
            style: AppTheme.scripture(
              fontSize: fontSize,
              height: 1.75,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
