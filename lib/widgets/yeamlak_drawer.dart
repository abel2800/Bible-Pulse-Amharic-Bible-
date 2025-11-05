import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class YeamlakDrawer extends StatelessWidget {
  const YeamlakDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.mainBg,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.toolbarPrimary,
                  AppColors.primaryDark,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.menu_book,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerButton(
                  context,
                  icon: Icons.book_outlined,
                  text: 'መነሻ', // Devotion
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/devotions');
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.calendar_today_outlined,
                  text: 'የንባብ መርሃግብር', // Reading Plan
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/reading_plans');
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.menu_book_outlined,
                  text: 'መጽሐፍ ቅዱስ', // Bible
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/bible');
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.translate,
                  text: 'የቅጂ ምርጫ', // Version Selection
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/versions');
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.bookmark_border,
                  text: 'ዕልባቶች', // Bookmarks
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/bookmarks');
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.note_outlined,
                  text: 'ማስታወሻዎች', // Notes
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/notes');
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.highlight_outlined,
                  text: 'ምርጥ ቃላት', // Highlights
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/highlights');
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.music_note_outlined,
                  text: 'መዝሙራት', // Songs/Hymns
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/hymns');
                  },
                ),
                const Divider(height: 1),
                _buildDrawerButton(
                  context,
                  icon: Icons.alarm_outlined,
                  text: 'ማስታወሻ', // Reminder
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.settings_outlined,
                  text: 'ማስተካከያ', // Settings
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.share_outlined,
                  text: 'ለማካፈል', // Share
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.star_border,
                  text: 'ለመገምገም', // Rate Us
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.info_outline,
                  text: 'ስለ እኛ', // About
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppColors.robotoLight,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.robotoLight,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

