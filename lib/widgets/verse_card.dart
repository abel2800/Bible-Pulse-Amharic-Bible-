import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/bible_verse.dart';
import '../providers/study_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/verse_action_bottom_sheet.dart';

class VerseCard extends StatelessWidget {
  final BibleVerse verse;
  final String reference;
  final bool isHighlighted;
  final Color? highlightColor;
  final bool isBookmarked;
  final bool hasNote;
  
  const VerseCard({
    super.key,
    required this.verse,
    required this.reference,
    this.isHighlighted = false,
    this.highlightColor,
    this.isBookmarked = false,
    this.hasNote = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showActions(context);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showActions(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isHighlighted
              ? highlightColor?.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 18,
              height: 1.8,
              letterSpacing: 0.3,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: 'Georgia',
            ),
            children: [
              TextSpan(
                text: '${verse.verse} ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  fontFeatures: const [FontFeature.enable('sups')],
                ),
              ),
              TextSpan(
                text: verse.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const TextSpan(text: ' '),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VerseActionBottomSheet(
        verse: verse,
        reference: reference,
      ),
    );
  }
}
