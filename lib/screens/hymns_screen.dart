import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/hymn_provider.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({Key? key}) : super(key: key);

  @override
  State<HymnsScreen> createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.windowBg,
      appBar: AppBar(
        backgroundColor: AppColors.toolbarPrimary,
        elevation: 0,
        title: const Text(
          'መዝሙራት', // Hymns/Songs
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'ሁሉም'), // All
            Tab(text: 'ተወዳጅ'), // Favorites
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllHymnsList(),
          _buildFavoriteHymnsList(),
        ],
      ),
    );
  }

  Widget _buildAllHymnsList() {
    return Consumer<HymnProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 50, // Sample count
          itemBuilder: (context, index) {
            return _buildHymnItem(context, index + 1);
          },
        );
      },
    );
  }

  Widget _buildFavoriteHymnsList() {
    return Consumer<HymnProvider>(
      builder: (context, provider, child) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: AppColors.controlNormal,
              ),
              SizedBox(height: 16),
              Text(
                'ምንም ተወዳጅ መዝሙራት የሉም',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHymnItem(BuildContext context, int number) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.toolbarPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.toolbarPrimary,
              ),
            ),
          ),
        ),
        title: Text(
          'መዝሙር $number',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.mainText,
          ),
        ),
        subtitle: const Text(
          'መዝሙረ ዳዊት',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite_border),
          color: AppColors.controlNormal,
          onPressed: () {
          },
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('መዝሙር $number - Coming soon!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

