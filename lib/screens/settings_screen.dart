import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/color_theme_provider.dart';
import '../providers/font_settings_provider.dart';
import '../providers/version_manager_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.windowBg,
      appBar: AppBar(
        backgroundColor: AppColors.toolbarPrimary,
        elevation: 0,
        title: const Text(
          'ማስተካከያ', // Settings
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader('ማሳያ'), // Display
          _buildSettingItem(
            context,
            icon: Icons.palette_outlined,
            title: 'ቀለም ገጽታ', // Color Theme
            subtitle: 'ብርሃን',
            onTap: () {
              _showColorThemeDialog(context);
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.format_size,
            title: 'የፊደል መጠን', // Font Size
            subtitle: 'መካከለኛ',
            onTap: () {
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.font_download_outlined,
            title: 'የፊደል ቅርጸት', // Font Style
            subtitle: 'ነባሪ',
            onTap: () {
            },
          ),
          
          const Divider(height: 1),
          
          _buildSectionHeader('የመጽሐፍ ቅዱስ ቅጂ'), // Bible Version
          _buildSettingItem(
            context,
            icon: Icons.translate,
            title: 'የትርጉም ቋንቋ', // Translation Language
            subtitle: 'አማርኛ (Amharic)',
            onTap: () {
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.download_outlined,
            title: 'የተወረዱ ቅጂዎች', // Downloaded Versions
            subtitle: '3 ቅጂዎች',
            onTap: () {
            },
          ),
          
          const Divider(height: 1),
          
          _buildSectionHeader('ማስታወቂያዎች'), // Notifications
          _buildSettingItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'የእለት ግቦች', // Daily Reminders
            subtitle: 'ጠዋት 8:00',
            onTap: () {
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.alarm_outlined,
            title: 'የንባብ ማስታወሻ', // Reading Reminder
            subtitle: 'እንቅስቃሴ ላይ',
            onTap: () {
            },
          ),
          
          const Divider(height: 1),
          
          _buildSectionHeader('ሌሎች'), // Other
          _buildSettingItem(
            context,
            icon: Icons.share_outlined,
            title: 'መተግበሪያውን አጋራ', // Share App
            onTap: () {
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.star_outline,
            title: 'ግምገማ', // Rate Us
            onTap: () {
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.help_outline,
            title: 'እገዛ', // Help
            onTap: () {
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.info_outline,
            title: 'ስለ', // About
            onTap: () {
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'የግላዊነት ፖሊሲ', // Privacy Policy
            onTap: () {
            },
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: Text(
              'ቅጅ 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.toolbarPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      elevation: 0,
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.controlActivated,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.mainText,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.controlNormal,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showColorThemeDialog(BuildContext context) {
    final themes = [
      {'name': 'ብርሃን', 'color': Colors.white},
      {'name': 'ሴፒያ', 'color': const Color(0xFFFFF8DC)},
      {'name': 'ጨለማ', 'color': const Color(0xFF212121)},
      {'name': 'እውነተኛ ጥቁር', 'color': Colors.black},
      {'name': 'ሰማያዊ ምሽት', 'color': const Color(0xFF1A237E)},
      {'name': 'ደን', 'color': const Color(0xFF1B5E20)},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ቀለም ገጽታ ይምረጡ'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: themes.length,
              itemBuilder: (context, index) {
                final theme = themes[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme['color'] as Color,
                    radius: 16,
                  ),
                  title: Text(theme['name'] as String),
                  onTap: () {
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ዝጋ'),
            ),
          ],
        );
      },
    );
  }
}
