import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DevotionCard extends StatelessWidget {
  const DevotionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'መነሳት', // Devotion
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/devotions');
                  },
                  child: const Text(
                    'ሁሉንም ለማየት',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textViewAll,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.5,
              children: [
                _buildDevotionItem(
                  context,
                  'Billy Graham',
                  'የቢሊ ግራሃም',
                  Icons.person_outline,
                ),
                _buildDevotionItem(
                  context,
                  'Charles Spurgeon',
                  'የቻርለስ ስፐርጄን',
                  Icons.person_outline,
                ),
                _buildDevotionItem(
                  context,
                  'Rick Warren',
                  'የሪክ ዋረን',
                  Icons.person_outline,
                ),
                _buildDevotionItem(
                  context,
                  'Our Daily Journey',
                  'የእለታዊ ጉዞአችን',
                  Icons.explore_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevotionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/devotions');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.windowBg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.toolbarPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.mainText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

