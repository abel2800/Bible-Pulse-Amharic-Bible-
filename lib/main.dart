import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/theme_provider.dart';
import 'providers/bible_provider.dart';
import 'providers/devotional_provider.dart';
import 'providers/study_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/reading_plan_provider.dart';
import 'providers/reading_history_provider.dart';
import 'providers/hymn_provider.dart';
import 'providers/version_manager_provider.dart';
import 'providers/color_theme_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/navigation_history_provider.dart';
import 'providers/labels_provider.dart';
import 'providers/font_settings_provider.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'screens/splash_screen.dart';
import 'screens/search_screen.dart';
import 'screens/main_shell.dart';
import 'screens/yeamlak_home_screen.dart';
import 'screens/simple_home_screen.dart';
import 'screens/devotions_screen.dart';
import 'screens/reading_plans_screen.dart';
import 'screens/hymns_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/highlights_screen.dart';
import 'screens/version_selector_screen.dart';
import 'screens/bible_reader_screen.dart';
import 'screens/study_screen.dart';
import 'screens/wallpaper_generator_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    tz.initializeTimeZones();
    await NotificationService().initialize();
    await DatabaseService().database;
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  
  runApp(const BiblePulseApp());
}

class BiblePulseApp extends StatelessWidget {
  const BiblePulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BibleProvider()),
        ChangeNotifierProxyProvider<ThemeProvider, DevotionalProvider>(
          create: (_) => DevotionalProvider(),
          update: (_, theme, devotional) => devotional!..updateLocale(theme.locale),
        ),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ReadingPlanProvider()),
        ChangeNotifierProvider(create: (_) => ReadingHistoryProvider()),
        ChangeNotifierProvider(create: (_) => HymnProvider()),
        ChangeNotifierProvider(create: (_) => VersionManagerProvider()),
        ChangeNotifierProvider(create: (_) => ColorThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => NavigationHistoryProvider()),
        ChangeNotifierProvider(create: (_) => LabelsProvider()),
        ChangeNotifierProvider(create: (_) => FontSettingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BiblePulse',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: themeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const SimpleHomeScreen(),
              '/old_yeamlak': (context) => const YeamlakHomeScreen(),
              '/old_home': (context) => const MainShell(),
              '/search': (context) => const SearchScreen(),
              '/bible': (context) => const BibleReaderScreen(),
              '/versions': (context) => const VersionSelectorScreen(),
              '/devotions': (context) => const DevotionsScreen(),
              '/reading_plans': (context) => const ReadingPlansScreen(),
              '/hymns': (context) => const HymnsScreen(),
              '/bookmarks': (context) => const BookmarksScreen(),
              '/notes': (context) => const NotesScreen(),
              '/highlights': (context) => const HighlightsScreen(),
              '/study': (context) => const StudyScreen(),
              '/wallpaper': (context) => const WallpaperGeneratorScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

