import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../utils/font_env_stub.dart'
    if (dart.library.io) '../utils/font_env_io.dart';

/// Illuminated drop-cap used to open a chapter or the verse-of-the-day card.
class DropCap extends StatelessWidget {
  final String letter;
  final double size;
  const DropCap(this.letter, {super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final style = isFlutterTest
        ? TextStyle(
            fontFamily: 'serif',
            fontSize: size,
            fontWeight: FontWeight.w700,
            height: 0.8,
            color: const Color(0xFFC08A28),
            shadows: const [
              Shadow(color: Color(0xFFA83232), offset: Offset(1, 1)),
            ],
          )
        : GoogleFonts.fraunces(
            fontSize: size,
            fontWeight: FontWeight.w700,
            height: 0.8,
            color: const Color(0xFFC08A28),
            shadows: const [
              Shadow(color: Color(0xFFA83232), offset: Offset(1, 1)),
            ],
          );
    return SizedBox(
      width: size * 0.85,
      child: Text(letter, style: style),
    );
  }
}

/// Thin manuscript-style rule with a gold diamond at center.
class ManuscriptRule extends StatelessWidget {
  const ManuscriptRule({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 1, color: t.border),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            color: t.appBg,
            child: const Text(
              '◆',
              style: TextStyle(fontSize: 8, color: Color(0xFFC08A28)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded pill for eyebrow labels and filter chips.
class AppPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? selectedColor;
  const AppPill({
    super.key,
    required this.label,
    this.selected = false,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.colors;
    final bg = selected ? (selectedColor ?? const Color(0xFF1E7F72)) : t.surface2;
    final textStyle = isFlutterTest
        ? TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : t.inkSoft,
          )
        : GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : t.inkSoft,
          );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? bg : t.border),
      ),
      child: Text(label, style: textStyle),
    );
  }
}
