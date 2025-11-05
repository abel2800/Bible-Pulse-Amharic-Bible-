import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class WallpaperGeneratorScreen extends StatefulWidget {
  const WallpaperGeneratorScreen({super.key});

  @override
  State<WallpaperGeneratorScreen> createState() => _WallpaperGeneratorScreenState();
}

class _WallpaperGeneratorScreenState extends State<WallpaperGeneratorScreen> {
  final TextEditingController _textController = TextEditingController(
    text: 'For God so loved the world, that he gave his only begotten Son',
  );
  final TextEditingController _referenceController = TextEditingController(
    text: 'John 3:16',
  );
  final ScreenshotController _screenshotController = ScreenshotController();
  
  int _selectedBackgroundIndex = 0;
  double _fontSize = 24.0;
  Color _textColor = Colors.white;
  TextAlign _textAlign = TextAlign.center;
  
  final List<LinearGradient> _backgrounds = [
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
    ),
    const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B6B), Color(0xFFFFB4B4)],
    ),
    const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    ),
    const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
    ),
    const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF00416A), Color(0xFFE4E5E6)],
    ),
  ];
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Wallpaper',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _saveWallpaper,
            tooltip: 'Save Wallpaper',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _backgrounds[_selectedBackgroundIndex],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _textController.text,
                          textAlign: _textAlign,
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontWeight: FontWeight.w600,
                            color: _textColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _referenceController.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _fontSize * 0.6,
                            color: _textColor.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Verse Text',
                      hintText: 'Enter your verse here',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Reference',
                      hintText: 'e.g., John 3:16',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Background',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _backgrounds.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedBackgroundIndex = index),
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              gradient: _backgrounds[index],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedBackgroundIndex == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Font Size',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _fontSize,
                    min: 16,
                    max: 36,
                    divisions: 20,
                    label: _fontSize.round().toString(),
                    onChanged: (value) => setState(() => _fontSize = value),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Text Color',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildColorOption(Colors.white),
                      _buildColorOption(Colors.black),
                      _buildColorOption(const Color(0xFFFFEB3B)),
                      _buildColorOption(const Color(0xFF4CAF50)),
                      _buildColorOption(const Color(0xFF2196F3)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Text Alignment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildAlignmentButton(Icons.format_align_left, TextAlign.left),
                      _buildAlignmentButton(Icons.format_align_center, TextAlign.center),
                      _buildAlignmentButton(Icons.format_align_right, TextAlign.right),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _textColor = color),
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _textColor == color
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            width: _textColor == color ? 3 : 1,
          ),
        ),
      ),
    );
  }
  
  Widget _buildAlignmentButton(IconData icon, TextAlign align) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => setState(() => _textAlign = align),
          style: ElevatedButton.styleFrom(
            backgroundColor: _textAlign == align
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).cardColor,
            foregroundColor: _textAlign == align
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
          child: Icon(icon),
        ),
      ),
    );
  }
  
  Future<void> _saveWallpaper() async {
    try {
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallpaper feature works on mobile devices. On web, take a screenshot instead!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required')),
          );
        }
        return;
      }
      
      final image = await _screenshotController.capture();
      if (image != null) {
        await ImageGallerySaver.saveImage(image);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ Wallpaper saved to gallery!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note: Wallpaper saving works on mobile devices'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}

