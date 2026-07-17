import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bible_provider.dart';
import '../providers/color_theme_provider.dart';
import '../providers/font_settings_provider.dart';
import '../providers/theme_provider.dart';
import 'splash_screen.dart';

enum BootstrapStatus { loading, ready, failed }

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  BootstrapStatus _status = BootstrapStatus.loading;
  Object? _error;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initialize();
      });
    }
  }

  Future<void> _initialize() async {
    setState(() {
      _status = BootstrapStatus.loading;
      _error = null;
    });

    try {
      await Future.wait([
        context.read<ThemeProvider>().ready,
        context.read<BibleProvider>().ready,
        context.read<ColorThemeProvider>().loadTheme(),
        context.read<FontSettingsProvider>().loadFontSettings(),
      ]);

      if (!mounted) return;
      setState(() => _status = BootstrapStatus.ready);
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = BootstrapStatus.failed;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status != BootstrapStatus.failed) {
      return const SplashScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sync_problem_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'BiblePulse could not finish starting.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your local data is safe. Check the app resources and try again.\n\n$_error',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _initialize,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
