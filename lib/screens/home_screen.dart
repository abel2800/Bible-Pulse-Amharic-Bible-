import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/devotional_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/daily_devotional_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/verse_of_the_day_card.dart';
import '../l10n/app_localizations.dart';
import '../providers/navigation_provider.dart';
class HomeScreen extends StatefulWidget {
	const HomeScreen({super.key});

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

	@override
	Widget build(BuildContext context) {
		final devotionalProvider = Provider.of<DevotionalProvider>(context);
		final themeProvider = Provider.of<ThemeProvider>(context);
		final l10n = AppLocalizations.of(context);

		return Scaffold(
			appBar: AppBar(
				elevation: 0,
				backgroundColor: Colors.transparent,
				foregroundColor: Theme.of(context).colorScheme.onBackground,
				title: Row(
					children: [
						Container(
							padding: const EdgeInsets.all(6),
							decoration: BoxDecoration(
								color: Theme.of(context).colorScheme.primary,
								borderRadius: BorderRadius.circular(8),
							),
							child: const Icon(Icons.auto_stories, size: 18, color: Colors.white),
						),
						const SizedBox(width: 12),
						Text(
							l10n.appName,
							style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
						),
					],
				),
				actions: [
					IconButton(
						icon: const Icon(Icons.search_rounded),
						onPressed: () => Navigator.pushNamed(context, '/search'),
					),
					TextButton(
						onPressed: () => themeProvider.toggleLanguage(),
						child: Text(themeProvider.locale.languageCode.toUpperCase()),
					),
					IconButton(
						icon: Icon(themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
						onPressed: () => themeProvider.toggleTheme(),
					),
				],
			),
						body: SafeArea(
								child: Builder(builder: (context) {
							final bottomInset = MediaQuery.of(context).padding.bottom + 80.0;

							return SingleChildScrollView(
								padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Container(
								padding: const EdgeInsets.all(14),
								decoration: BoxDecoration(
									color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
									borderRadius: BorderRadius.circular(12),
								),
								child: _buildGreeting(context),
							),
							const SizedBox(height: 16),

							if (devotionalProvider.todayDevotional != null) ...[
								VerseOfTheDayCard(devotional: devotionalProvider.todayDevotional!),
								const SizedBox(height: 12),
								DailyDevotionalCard(devotional: devotionalProvider.todayDevotional!),
								const SizedBox(height: 20),
							],

							Text(
								l10n.quickActions,
								style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
							),
							const SizedBox(height: 12),

							GridView.count(
								shrinkWrap: true,
								crossAxisCount: 2,
								childAspectRatio: 3 / 2,
								crossAxisSpacing: 12,
								mainAxisSpacing: 12,
								physics: const NeverScrollableScrollPhysics(),
								children: [
									QuickActionCard(
										icon: Icons.menu_book_rounded,
										title: l10n.readBible,
										color: Theme.of(context).colorScheme.secondary,
										onTap: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(1),
									),
									QuickActionCard(
										icon: Icons.bookmark_rounded,
										title: l10n.myStudy,
										color: Theme.of(context).colorScheme.primary,
										onTap: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(2),
									),
									QuickActionCard(
										icon: Icons.wallpaper_rounded,
										title: l10n.createWallpaper,
										color: Theme.of(context).colorScheme.surfaceVariant,
										onTap: () => Navigator.pushNamed(context, '/wallpaper'),
									),
									QuickActionCard(
										icon: Icons.notifications_rounded,
										title: l10n.setReminder,
										color: Theme.of(context).colorScheme.primary,
										onTap: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(3),
									),
								],
							),

							const SizedBox(height: 24),

							Text(
								'Recent updates',
								style: Theme.of(context).textTheme.bodyMedium,
							),
							const SizedBox(height: 8),
							Text(
								'Keep reading',
								style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
							),
						],
					),
					); // SingleChildScrollView
				}), // Builder
				), // SafeArea
			); // Scaffold
	}

	Widget _buildGreeting(BuildContext context) {
		final l10n = AppLocalizations.of(context);
		final hour = DateTime.now().hour;
		String greeting;

		if (hour < 12) {
			greeting = l10n.goodMorning;
		} else if (hour < 17) {
			greeting = l10n.goodAfternoon;
		} else {
			greeting = l10n.goodEvening;
		}

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					greeting,
					style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
				),
				const SizedBox(height: 6),
				Text(
					l10n.welcomeBack,
					style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
				),
			],
		);
	}

}




