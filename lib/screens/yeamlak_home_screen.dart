import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/bible_provider.dart';
import '../widgets/yeamlak_drawer.dart';
import '../widgets/vod_card.dart';
import '../widgets/devotion_card.dart';
import '../widgets/reading_plan_card.dart';
import '../widgets/last_read_card.dart';

class YeamlakHomeScreen extends StatefulWidget {
  const YeamlakHomeScreen({Key? key}) : super(key: key);

  @override
  State<YeamlakHomeScreen> createState() => _YeamlakHomeScreenState();
}

class _YeamlakHomeScreenState extends State<YeamlakHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.toolbarPrimary,
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
                ? 'መጽሐፍ ቅዱስ (አማርኛ)' 
                : 'መጽሐፍ ቅዱስ (English)';
            return Text(
              versionName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
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
            tooltip: 'የቅጂ ምርጫ',
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
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
          padding: const EdgeInsets.all(6),
          children: const [
            VodCard(),
            SizedBox(height: 8),
            
            LastReadCard(),
            SizedBox(height: 8),
            
            DevotionCard(),
            SizedBox(height: 8),
            
            ReadingPlanCard(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

