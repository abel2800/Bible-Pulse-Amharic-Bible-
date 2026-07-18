import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_capabilities.dart';
import '../utils/app_theme.dart';
import '../widgets/design/bp_widgets.dart';

class WallpaperGeneratorScreen extends StatefulWidget {
  const WallpaperGeneratorScreen({super.key});

  @override
  State<WallpaperGeneratorScreen> createState() =>
      _WallpaperGeneratorScreenState();
}

class _WallpaperGeneratorScreenState extends State<WallpaperGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _initializedFromRoute = false;

  int _selectedBackgroundIndex = 0;
  double _fontSize = 24.0;
  Color _textColor = Colors.white;
  TextAlign _textAlign = TextAlign.center;
  double _aspectRatio = 9 / 16;

  final List<LinearGradient> _backgrounds = [
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppTheme.appBgDark, AppTheme.teal],
    ),
    const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF6E8B3D), AppTheme.teal],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppTheme.vermilion, AppTheme.goldSoft],
    ),
    const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [AppTheme.gold, AppTheme.onGold],
    ),
    const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF7B5EA7), AppTheme.appBgDark],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppTheme.goldSoft, AppTheme.gold],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.appBgDark,
        AppTheme.surface2Dark,
        AppTheme.surfaceDark,
      ],
    ),
    const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppTheme.teal, AppTheme.appBgLight],
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedFromRoute) return;
    _initializedFromRoute = true;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map) {
      _textController.text = arguments['text'] as String? ?? '';
      _referenceController.text = arguments['reference'] as String? ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final capabilities = context.watch<AppCapabilities>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  BpIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Create Verse Card',
                      style: AppTheme.brandTitle(fontSize: 22, color: ink),
                    ),
                  ),
                  BpIconButton(
                    icon: Icons.download_rounded,
                    tooltip: capabilities.wallpaperExport
                        ? 'Save wallpaper'
                        : 'Wallpaper export is unavailable on this platform',
                    onPressed:
                        capabilities.wallpaperExport ? _saveWallpaper : null,
                  ),
                  const SizedBox(width: 8),
                  BpIconButton(
                    icon: Icons.share_rounded,
                    tooltip: 'Share branded verse card',
                    onPressed: _shareCard,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AspectRatio(
                        aspectRatio: _aspectRatio,
                        child: Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _backgrounds[_selectedBackgroundIndex],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border),
                            ),
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _textController.text,
                                  textAlign: _textAlign,
                                  style: AppTheme.brandTitle(
                                    fontSize: _fontSize,
                                    weight: FontWeight.w500,
                                    color: _textColor,
                                  ).copyWith(height: 1.55),
                                ),
                                const SizedBox(height: 24),
                                if (_referenceController.text.isNotEmpty)
                                  Text(
                                    _referenceController.text.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: AppTheme.ui(
                                      fontSize: _fontSize * 0.45,
                                      weight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: AppTheme.gold,
                                    ),
                                  ),
                                const Spacer(),
                                Text(
                                  'BiblePulse',
                                  style: AppTheme.brandTitle(
                                    fontSize: 14,
                                    weight: FontWeight.w700,
                                    color: AppTheme.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _textController,
                            maxLines: 3,
                            style: AppTheme.scripture(fontSize: 15, color: ink),
                            decoration: const InputDecoration(
                              labelText: 'Verse Text',
                              hintText: 'Enter your verse here',
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _referenceController,
                            style: AppTheme.ui(fontSize: 14, color: ink),
                            decoration: const InputDecoration(
                              labelText: 'Reference',
                              hintText: 'e.g., John 3:16',
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 24),
                          const BpSectionLabel(title: 'Format'),
                          SegmentedButton<double>(
                            segments: [
                              ButtonSegment(
                                value: 1,
                                label: Text(
                                  'Square',
                                  style: AppTheme.ui(fontSize: 12),
                                ),
                              ),
                              ButtonSegment(
                                value: 4 / 5,
                                label: Text(
                                  'Feed',
                                  style: AppTheme.ui(fontSize: 12),
                                ),
                              ),
                              ButtonSegment(
                                value: 9 / 16,
                                label: Text(
                                  'Status',
                                  style: AppTheme.ui(fontSize: 12),
                                ),
                              ),
                            ],
                            selected: {_aspectRatio},
                            onSelectionChanged: (value) =>
                                setState(() => _aspectRatio = value.first),
                          ),
                          const SizedBox(height: 24),
                          const BpSectionLabel(title: 'Background'),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _backgrounds.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedBackgroundIndex = index,
                                  ),
                                  child: Container(
                                    width: 60,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      gradient: _backgrounds[index],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedBackgroundIndex == index
                                            ? AppTheme.gold
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
                          const BpSectionLabel(title: 'Font Size'),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.gold,
                              inactiveTrackColor: border,
                              thumbColor: AppTheme.gold,
                              overlayColor:
                                  AppTheme.gold.withValues(alpha: 0.15),
                            ),
                            child: Slider(
                              value: _fontSize,
                              min: 16,
                              max: 36,
                              divisions: 20,
                              label: _fontSize.round().toString(),
                              onChanged: (value) =>
                                  setState(() => _fontSize = value),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const BpSectionLabel(title: 'Text Color'),
                          Row(
                            children: [
                              _buildColorOption(Colors.white),
                              _buildColorOption(AppTheme.onGold),
                              _buildColorOption(AppTheme.goldSoft),
                              _buildColorOption(AppTheme.teal),
                              _buildColorOption(AppTheme.ink),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const BpSectionLabel(title: 'Text Alignment'),
                          Row(
                            children: [
                              _buildAlignmentButton(
                                Icons.format_align_left,
                                TextAlign.left,
                              ),
                              _buildAlignmentButton(
                                Icons.format_align_center,
                                TextAlign.center,
                              ),
                              _buildAlignmentButton(
                                Icons.format_align_right,
                                TextAlign.right,
                              ),
                            ],
                          ),
                        ],
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

  Future<void> _shareCard() async {
    final bytes = await _screenshotController.capture(pixelRatio: 3);
    if (bytes == null) return;
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: 'biblepulse-verse-card.png',
        ),
      ],
      text: _referenceController.text,
    );
  }

  Widget _buildColorOption(Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

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
            color: _textColor == color ? AppTheme.gold : border,
            width: _textColor == color ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildAlignmentButton(IconData icon, TextAlign align) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final ink = isDark ? AppTheme.inkDark : AppTheme.ink;
    final selected = _textAlign == align;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: selected ? AppTheme.gold : surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: selected ? AppTheme.gold : border),
          ),
          child: InkWell(
            onTap: () => setState(() => _textAlign = align),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(
                icon,
                color: selected ? AppTheme.onGold : ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveWallpaper() async {
    try {
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Wallpaper feature works on mobile devices. On web, take a screenshot instead!',
                style: AppTheme.ui(fontSize: 13),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Storage permission is required',
                style: AppTheme.ui(fontSize: 13),
              ),
            ),
          );
        }
        return;
      }

      final image = await _screenshotController.capture();
      if (image != null) {
        await ImageGallerySaverPlus.saveImage(image);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Wallpaper saved to gallery!',
                style: AppTheme.ui(fontSize: 13),
              ),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Note: Wallpaper saving works on mobile devices',
              style: AppTheme.ui(fontSize: 13),
            ),
            duration: const Duration(seconds: 2),
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
