import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/bible_provider.dart';

class VodCard extends StatefulWidget {
  const VodCard({Key? key}) : super(key: key);

  @override
  State<VodCard> createState() => _VodCardState();
}

class _VodCardState extends State<VodCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);
    final vod = bibleProvider.verseOfTheDay;

    if (vod == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
            Container(
              width: double.infinity,
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
            ),
              Positioned(
                bottom: 8,
                left: 9,
                child: Text(
                  bibleProvider.getVerseReference(vod),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.only(
                left: 12,
                right: 8,
                top: 8,
                bottom: 6,
              ),
              child: Text(
                vod.text,
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.contentTextPrimary,
                  height: 1.25,
                ),
              ),
            ),
          ),
          
          Container(
            height: 33,
            padding: const EdgeInsets.only(right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isExpanded)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/bible');
                    },
                    child: const Text(
                      'ሁሉንም ለማየት',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vodViewAll,
                      ),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  color: AppColors.controlNormal,
                  onPressed: () {
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

