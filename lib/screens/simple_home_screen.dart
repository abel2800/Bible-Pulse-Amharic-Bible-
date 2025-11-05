import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/bible_provider.dart';
import '../widgets/yeamlak_drawer.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({Key? key}) : super(key: key);

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);
    final vod = bibleProvider.verseOfTheDay;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Consumer<BibleProvider>(
          builder: (context, bible, child) {
            final versionName = bible.currentVersion == 'AMHARIC' 
                ? 'መጽሐፍ ቅዱስ' 
                : 'Holy Bible';
            return Text(
              versionName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/versions');
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      drawer: const YeamlakDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          bibleProvider.currentVersion == 'AMHARIC'
                              ? 'የዛሬ ቃል'
                              : 'Verse of the Day',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (vod != null) ...[
                          Text(
                            vod.text,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: AppColors.mainText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            bibleProvider.getVerseReference(vod),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ] else
                          const Text(
                            'Loading verse...',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.secondaryText,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSimpleButton(
                    context,
                    icon: Icons.menu_book,
                    title: bibleProvider.currentVersion == 'AMHARIC'
                        ? 'መጽሐፍ ቅዱስ ያንብቡ'
                        : 'Read Bible',
                    onTap: () => Navigator.pushNamed(context, '/bible'),
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleButton(
                    context,
                    icon: Icons.bookmark,
                    title: bibleProvider.currentVersion == 'AMHARIC'
                        ? 'ዕልባቶች'
                        : 'Bookmarks',
                    onTap: () => Navigator.pushNamed(context, '/bookmarks'),
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleButton(
                    context,
                    icon: Icons.note,
                    title: bibleProvider.currentVersion == 'AMHARIC'
                        ? 'ማስታወሻዎች'
                        : 'Notes',
                    onTap: () => Navigator.pushNamed(context, '/notes'),
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleButton(
                    context,
                    icon: Icons.highlight,
                    title: bibleProvider.currentVersion == 'AMHARIC'
                        ? 'ምርጥ ቃላት'
                        : 'Highlights',
                    onTap: () => Navigator.pushNamed(context, '/highlights'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainText,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

