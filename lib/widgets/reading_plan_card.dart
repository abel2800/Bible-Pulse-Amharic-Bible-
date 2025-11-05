import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ReadingPlanCard extends StatelessWidget {
  const ReadingPlanCard({Key? key}) : super(key: key);

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
                  'የንባብ መርሃግብር', // Reading Plan
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reading_plans');
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
            child: Column(
              children: [
                _buildPlanItem(
                  context,
                  'Bible in One Year',
                  'በአንድ አመት ውስጥ መጽሐፍ ቅዱስን ያንብቡ',
                  Icons.calendar_today_outlined,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildPlanItem(
                  context,
                  'New Testament in 90 Days',
                  'አዲስ ኪዳን በ90 ቀናት',
                  Icons.auto_stories_outlined,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildPlanItem(
                  context,
                  'Psalms & Proverbs',
                  'መዝሙራት እና ምሳሌዎች',
                  Icons.music_note_outlined,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/reading_plans');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.windowBg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.controlNormal,
            ),
          ],
        ),
      ),
    );
  }
}

