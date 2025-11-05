import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/bible_provider.dart';

class VersionSelectorScreen extends StatelessWidget {
  const VersionSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);
    
    final versions = [
      {'code': 'KJV', 'name': 'King James Version', 'language': 'English'},
      {'code': 'AMHARIC', 'name': 'የአማርኛ መጽሐፍ ቅዱስ', 'language': 'አማርኛ'},
    ];

    return Scaffold(
      backgroundColor: AppColors.windowBg,
      appBar: AppBar(
        backgroundColor: AppColors.toolbarPrimary,
        elevation: 0,
        title: const Text(
          'የመጽሐፍ ቅዱስ ቅጂ', // Bible Version
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: versions.length,
        itemBuilder: (context, index) {
          final version = versions[index];
          final isSelected = bibleProvider.currentVersion == version['code'];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isSelected
                  ? BorderSide(color: AppColors.toolbarPrimary, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.toolbarPrimary
                      : AppColors.toolbarPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: isSelected ? Colors.white : AppColors.toolbarPrimary,
                  size: 24,
                ),
              ),
              title: Text(
                version['name']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.mainText,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  version['language']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.toolbarPrimary,
                      size: 28,
                    )
                  : null,
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('እየተጫነ ነው...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                
                await bibleProvider.changeVersion(
                  version['code']!,
                  version['code'] == 'AMHARIC' ? 'am' : 'en',
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${version['name']} loaded successfully!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}

