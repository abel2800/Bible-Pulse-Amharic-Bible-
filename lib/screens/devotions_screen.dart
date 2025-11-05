import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DevotionsScreen extends StatelessWidget {
  const DevotionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.windowBg,
      appBar: AppBar(
        backgroundColor: AppColors.toolbarPrimary,
        elevation: 0,
        title: const Text(
          'መነሻ', // Devotion
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: [
          _buildDevotionCard(
            context,
            'Billy Graham',
            'የቢሊ ግራሃም መነሳት',
            '365 ቀናት',
            Colors.blue,
          ),
          _buildDevotionCard(
            context,
            'Charles Spurgeon',
            'የቻርለስ ስፐርጄን መነሳት',
            '365 ቀናት',
            Colors.green,
          ),
          _buildDevotionCard(
            context,
            'Rick Warren',
            'የሪክ ዋረን መነሳት',
            '40 ቀናት',
            Colors.orange,
          ),
          _buildDevotionCard(
            context,
            'Our Daily Journey',
            'የእለታዊ ጉዞአችን',
            '365 ቀናት',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildDevotionCard(
    BuildContext context,
    String title,
    String subtitle,
    String duration,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$subtitle - Coming soon!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.book_outlined,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

