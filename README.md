# BiblePulse

BiblePulse is an offline-first Flutter Bible reader and study app. The current
verified release surface is deliberately smaller than the historical
prototype: it exposes only features backed by real content and working local
persistence.

## Verified features

- World English Bible, 66-book Protestant edition, bundled for offline use.
- Adaptive navigation: mobile bottom bar and wide-screen navigation rail.
- Scripture navigation by book and chapter.
- Unicode indexed search with bounded results.
  - SQLite FTS5 on Android, iOS, and macOS.
  - In-memory token index on web, Windows, and Linux.
- Tap or long-press verse actions:
  - highlight and remove highlight;
  - create/update notes;
  - bookmark and remove bookmark;
  - copy and share;
  - pass the verse into wallpaper creation;
  - show verified cross-reference availability.
- Persistent guest study data.
  - SQLite on Android, iOS, and macOS.
  - SharedPreferences fallback on web, Windows, and Linux.
- Last-read restoration and exact search-to-verse scrolling.
- Date-rotating verse of the day from verified WEB text.
- App light/dark/system themes.
- Independent reader themes: Light, Sepia, Dark, True Black, Blue Night,
  and Forest.
- Persistent Scripture font size and line spacing.
- English and Amharic application locale selection.
- Single-color highlights that remain until explicit removal and synchronize
  deletion tombstones when cloud sync is enabled.
- Reading streaks with one grace day per seven-day window, yearly study
  memories, and a private local prayer journal.
- Branded square/feed/status verse-card generation and image sharing.
- Gated features that activate only when their licensed dependencies exist:
  parallel Amharic/English reading, audio-synchronized verse following,
  private reading groups, hymn/Scripture links, and themed reminders.

## Intentionally unavailable

These features are hidden or disabled, not represented as working:

- Amharic Scripture: the identified eBible source is a copyrighted Amharic New
  Testament with non-commercial conditions. It is not bundled without broader
  written permission.
- Firebase accounts and cloud sync: implementation, owner-scoped rules, and
  emulator tests exist, but no production project/configuration or published
  privacy/deletion policy has been supplied.
- Community: post/report/block/moderation infrastructure is implemented but
  remains hidden until cloud configuration and moderation operations exist.
- Bible audio: catalog discovery, live download-permission checks, stream
  playback, resumable offline downloads, cache controls, and timing support are
  implemented, but no approved credential, Bible IDs, CDN allowlist, or
  confirmed language rights have been supplied.
- Devotional, reading-plan, and hymn catalogs: no rights-documented payloads
  are bundled.
- Theme reminder controls are available only on Android/iOS and request
  permission after a user explicitly chooses a theme.

See `docs/CONTENT_SOURCES.md` and `docs/INTEGRATIONS_AND_RELEASE.md`.

## Design system

- Primary indigo: `#0B2545`
- Accent teal: `#2EC4B6`
- Limited devotional gold: `#D4AF37` light / `#E8C766` dark
- Light background: `#F7F3EA`
- Dark background: `#0A1420`
- UI typography: Inter
- Scripture typography: Merriweather
- Cards: 14 logical-pixel radius
- Controls: 12 logical-pixel radius
- Minimum interactive target: 48 by 48 logical pixels

## Architecture

- `lib/screens`: adaptive shell, dashboard, reader, settings, and enabled flows.
- `lib/providers`: Provider-based presentation state, including audio
  downloads, engagement, parallel reading, and private groups.
- `lib/services`: assets, local database, search, notifications, Firebase sync,
  Bible Brain audio/cache, community, and licensed-catalog boundaries.
- `lib/models`: immutable/serializable domain data.
- `assets/content_manifest.json`: approved-content rights and checksum gate.
- `assets/bible/web.json`: deterministic canonical WEB asset.
- `tools/scripture`: USFM downloader/checksum gate and converter.
- `docs`: content provenance plus integration and release configuration.

Startup is readiness-driven through `BootstrapScreen`; it has no fixed
three-second delay. Unavailable integrations do not initialize.

The project uses hosted Flutter plugins. Obsolete local plugin copies, example
apps, build reports, and planning-only scaffolding are intentionally excluded.

## Development

Requirements:

- Flutter 3.44.1 or compatible stable release
- Dart 3.12.1 or compatible SDK
- Python 3 only when regenerating Scripture

Install and verify:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze lib test integration_test
python tools/content/validate_manifest.py
flutter test
flutter build web --release --no-wasm-dry-run
```

Run web:

```powershell
flutter run -d chrome
```

## Platform verification

CI verifies web and unsigned Android, iOS, macOS, Linux, and Windows builds.
Signed store releases require platform certificates and manual release
validation. The application identifier is `app.biblepulse.reader`; confirm its
store availability and ownership before publication.

## Release security

- Android release builds no longer use debug signing.
- Firestore rules isolate study data per authenticated owner and gate community
  writes; Firebase remains off unless complete build-time config is supplied.
- Audio accepts only configured HTTPS media hosts and caches only filesets
  returned by the credential-scoped `/download/list`.
- Exact-alarm Android permissions are not requested.
- CI pins Flutter 3.44.1 and covers app-owned analysis, content rights,
  unit/widget/accessibility/golden/migration tests, Firebase rules, web
  integration, and Android/iOS/macOS/Linux/Windows/web builds.
- CI artifacts are unsigned verification builds. Signing variables and manual
  release commands are documented in `docs/INTEGRATIONS_AND_RELEASE.md`; no
  signing secrets are committed.
