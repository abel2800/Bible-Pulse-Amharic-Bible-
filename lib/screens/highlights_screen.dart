import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/bible_provider.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({Key? key}) : super(key: key);

  @override
  State<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends State<HighlightsScreen> {
  String _selectedColor = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.windowBg,
      appBar: AppBar(
        backgroundColor: AppColors.toolbarPrimary,
        elevation: 0,
        title: const Text(
          'ምርጥ ቃላት', // Highlights
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: [
                _buildColorFilter('all', 'ሁሉም', Colors.grey),
                _buildColorFilter('yellow', 'ቢጫ', Colors.yellow),
                _buildColorFilter('green', 'አረንጓዴ', Colors.green),
                _buildColorFilter('blue', 'ሰማያዊ', Colors.blue),
                _buildColorFilter('red', 'ቀይ', Colors.red),
                _buildColorFilter('purple', 'ወይንጠጅ', Colors.purple),
              ],
            ),
          ),
          Expanded(
            child: Consumer<BibleProvider>(
              builder: (context, provider, child) {
                final highlights = provider.highlights;
                
                if (highlights.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.highlight_outlined,
                          size: 64,
                          color: AppColors.controlNormal,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ምንም ምርጥ ቃላት የሉም',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: highlights.length,
                  itemBuilder: (context, index) {
                    final highlight = highlights[index];
                    return _buildHighlightCard(context, highlight, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorFilter(String id, String label, Color color) {
    final isSelected = _selectedColor == id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (id != 'all')
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
            if (id != 'all') const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedColor = id;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.toolbarPrimary.withOpacity(0.2),
        checkmarkColor: AppColors.toolbarPrimary,
      ),
    );
  }

  Widget _buildHighlightCard(
    BuildContext context,
    Map<String, dynamic> highlight,
    BibleProvider provider,
  ) {
    final highlightColor = _getHighlightColor(highlight['color'] ?? 'yellow');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      elevation: 1,
      child: InkWell(
        onTap: () {
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: highlightColor,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            highlight['reference'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mainText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            highlight['date'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.controlNormal,
                      onPressed: () {
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: highlightColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    highlight['text'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mainText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getHighlightColor(String colorName) {
    switch (colorName) {
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.yellow;
    }
  }
}

