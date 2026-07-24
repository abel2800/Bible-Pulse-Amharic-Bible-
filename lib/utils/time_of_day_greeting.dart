import '../l10n/app_localizations.dart';

/// Greeting based on the user's **local** clock.
class TimeOfDayGreeting {
  TimeOfDayGreeting._();

  /// Morning 5–11 · Afternoon 12–16 · Evening 17–20 · Night 21–4
  static String forTime(DateTime local, AppLocalizations l10n) {
    final hour = local.hour;
    if (hour >= 5 && hour < 12) return l10n.goodMorning;
    if (hour >= 12 && hour < 17) return l10n.goodAfternoon;
    if (hour >= 17 && hour < 21) return l10n.goodEvening;
    return l10n.goodNight;
  }

  static String now(AppLocalizations l10n) => forTime(DateTime.now(), l10n);
}
