# BiblePulse

**Offline-first Bible reading and study — built with Flutter for Android, iOS, web, Windows, macOS, and Linux.**

BiblePulse is a focused Scripture reader with real local persistence, adaptive navigation, and one coherent design system. Core reading works without network. Features that need licensed content, API credentials, or production cloud configuration stay hidden until those dependencies are real. What you see in the app is what actually works.

> *Scripture, illuminated.*

| | |
|---|---|
| **Package** | `bible_pulse` |
| **App ID** | `app.biblepulse.reader` |
| **Version** | `1.0.0+1` |
| **Flutter** | 3.44.1 (CI-pinned; pubspec requires `>=3.27.0`) |
| **Dart** | `>=3.6.0 <4.0.0` |
| **Repository** | [abel2800/Bible-Pulse-Amharic-Bible-](https://github.com/abel2800/Bible-Pulse-Amharic-Bible-) |

---

## Table of contents

1. [What you get today](#what-you-get-today)
2. [Platforms](#platforms)
3. [Product tour](#product-tour)
4. [Daily engagement](#daily-engagement)
5. [Design system](#design-system)
6. [Architecture](#architecture)
7. [Project structure](#project-structure)
8. [Getting started](#getting-started)
9. [Gated integrations](#gated-integrations)
10. [Content and licensing](#content-and-licensing)
11. [Testing and CI](#testing-and-ci)
12. [Release and signing](#release-and-signing)
13. [Documentation](#documentation)

---

## What you get today

### Scripture and reading

- **World English Bible (WEB)** — full 66-book Protestant edition, bundled offline from eBible.org (public domain).
- **King James Version (KJV)** and **American Standard Version (ASV)** — public-domain texts installable from the in-app **Bible Store**.
- Book / chapter navigation with last-read restoration and exact scroll-to-verse from search.
- Version picker and unified book → chapter bottom sheet.
- Reader themes: **Light**, **Dark** (navy `#10182A`), and **Eye Comfort** (legacy Sepia / parchment / night themes map into these).
- Persistent font size, line spacing, and font family for Scripture text.
- Strong’s markup stripped from display text for clean reading.

### Search (Discover)

- Unicode indexed search with bounded results and Old / New / All filters.
- **SQLite FTS5** on Android, iOS, and macOS.
- **In-memory token index** on web, Windows, and Linux.

### Study tools (Plans tab)

Tap or long-press any verse to:

| Action | Behavior |
|---|---|
| Highlight | One color per verse; persists until removed |
| Note | Create or update a note on that verse |
| Bookmark | Add or remove a bookmark |
| Copy / Share | Clipboard and system share sheet |
| Verse card / wallpaper | Branded image export when the platform allows |
| Cross-references | Related verses when available |

Guest study data is stored locally:

- **SQLite** on Android, iOS, and macOS (versioned schema with migrations).
- **SharedPreferences** fallback on web, Windows, and Linux.

When cloud sync is configured, deletion uses tombstones and last-write-wins conflict resolution.

### Audio

- **Default (no API keys):** public-domain **WEB Henson** narration via eBible HTTPS — stream and chapter cache from the **Audio Store**.
- **Optional Bible Brain:** stream / offline download with host allowlisting when `BIBLE_BRAIN_*` dart-defines are set.
- Unified audio bar on the reader when a session is active; Wi‑Fi-only downloads and cache controls in Settings.

### Engagement

- Reading streaks with **one grace day** per seven-day window.
- Milestone titles (“Week warrior”, “Month of devotion”, …) and progress toward the next badge.
- Celebration snackbar when a new reading day is sealed.
- **On this day** memories from past-year highlights and notes.
- Private **prayer journal** (local, optionally linked to a verse, with answered toggle).
- Branded **verse cards** (square / feed / status) with save and share on mobile.

### Navigation and locale

- Adaptive shell: bottom navigation on phones, navigation rail on tablet/desktop (≥ 720px).
- Tabs: **Home · Bible · Plans · Discover · You**.
- App light / dark / system themes.
- UI locales: **English, Amharic, Afaan Oromo, Tigrinya, Somali**.  
  Amharic and other non-English **Scripture** texts are catalog placeholders until redistribution rights are approved — see [Content and licensing](#content-and-licensing).

### Capability-gated (implemented, off until configured)

| Feature | Turns on when |
|---|---|
| Parallel Amharic / English reading | Licensed Amharic text + parallel UI |
| Bible Brain audio beyond public-domain WEB | `BIBLE_BRAIN_*` defines |
| Firebase auth and study sync | `FIREBASE_*` defines |
| Private reading groups / community feed | Cloud + `BIBLEPULSE_ENABLE_COMMUNITY` |
| Devotional, reading-plan, and hymn catalogs | Approved entries in the content manifest |
| Wallpaper export / gallery save | Android / iOS |
| Daily verse + streak notifications | Android / iOS, user enables reminders |

---

## Platforms

| Platform | Local DB | Notifications | Gallery export | Audio* | Cloud* |
|---|---|---|---|---|---|
| Android | SQLite | Yes | Yes | Yes (WEB Henson; BB gated) | Gated |
| iOS | SQLite | Yes | Yes | Yes (WEB Henson; BB gated) | Gated |
| macOS | SQLite | — | — | Yes (WEB Henson; BB gated) | Gated |
| Windows | Prefs | — | — | Yes (WEB Henson; BB gated) | Gated |
| Linux | Prefs | — | — | Yes (WEB Henson; BB gated) | Gated |
| Web | Prefs | — | — | Yes (WEB Henson; BB gated) | Gated |

\*Bible Brain and Firebase require build-time configuration. Public-domain WEB Henson audio works without keys.

Minimum iOS deployment target: **15.0** (required by current Firebase Flutter plugins).

---

## Product tour

| Screen | Role |
|---|---|
| **Bootstrap / splash** | Readiness-driven startup (providers + assets). No fixed delay. |
| **Home** | Time-of-day greeting, streak card, verse of the day, continue reading / study shortcuts, drawer |
| **Bible** | Chapter reader, book/version chips, verse actions, optional audio bar |
| **Plans** | Highlights, notes, and bookmarks |
| **Discover** | Indexed Scripture search → jump to exact verse |
| **You (Settings)** | Appearance, UI language, preferred Bible/audio, reader theme & fonts, reminders, offline audio cache |
| **Bible Store / Audio Store** | Install public-domain texts and audio packages |
| **Prayer journal** | Private prayers linked to Scripture |
| **Verse card / wallpaper** | Generate and share branded images (mobile) |
| **Auth / groups / community / catalogs** | Visible only when capabilities allow |

---

## Daily engagement

BiblePulse treats daily Scripture as a habit loop, not a guilt trip.

| Piece | Behavior |
|---|---|
| **Verse of the Day** | Curated, date-rotating WEB verse on Home |
| **Streak** | Opens a chapter → seals today; one missed day of grace per week |
| **Home streak card** | Title, encouragement, progress to next milestone, “Keep the flame alive” CTA |
| **Morning notification** | Verse of the Day (default ~08:00 local) |
| **Evening notification** | Streak keep-alive / appreciation (~19:00) |
| **Settings** | **Verse + streak reminders** (Android / iOS); permission asked when enabling |

On web and desktop, in-app streak UI and celebrations still work; push notifications stay off.

---

## Design system

Illuminated-manuscript language: warm parchment, gold rubrication, and navy dark surfaces. Light and dark modes are designed together.

### Brand accents

| Token | Value | Use |
|---|---|---|
| Gold | `#C08A28` | Primary actions, active nav, verse numbers |
| Soft gold | `#E8C766` | Gradients and dark-mode gold |
| Vermilion | `#A83232` | Destructive actions |
| Teal | `#1E7F72` | Progress, “today counts” affirmations |

### Surfaces

| | Light | Dark |
|---|---|---|
| App background | `#F6F0E1` | `#10182A` |
| Surface | `#FFFDF8` | `#161F33` |
| Elevated | `#FBF4E4` | `#1B2540` |
| Border | `#DED0AC` | `#2A3654` |
| Ink | `#201A10` | `#F1E9D6` |
| Ink soft | `#6B5D42` | `#B7AD90` |
| Ink faint | `#9C8D6C` | `#6E7793` |

### Typography and shape

- **Brand / titles:** Fraunces  
- **Scripture:** Source Serif 4  
- **UI chrome:** Inter  
- **Ethiopic UI:** Noto Serif Ethiopic  
- Card radius: 16 · Controls: 10–12 · Icon buttons: 34×34 · Minimum touch target: 48×48

Reader presets stay independent of app light/dark mode where configured; Dark reader aligns with the home navy surface.

---

## Architecture

BiblePulse uses a layered Flutter architecture with **Provider** for presentation state.

```text
UI (screens / widgets)
        │
   Providers (ChangeNotifier)
        │
   Services / gateways
        │
 Local DB · SharedPreferences · Assets · (optional) Firebase / Bible Brain
```

### Design principles

- **Offline-first** — core reading and study work without network.
- **Fail closed** — unconfigured integrations do not initialize or appear as broken buttons.
- **Content gate** — `assets/content_manifest.json` plus CI checksum validation block unlicensed payloads.
- **Readiness startup** — `BootstrapScreen` waits for real initialization, not a timer.
- **Platform-aware capabilities** — `AppCapabilities` turns features on or off by platform and config.

### Key packages

| Concern | Package |
|---|---|
| State | `provider` |
| Local DB | `sqflite` |
| Preferences | `shared_preferences`, `path_provider` |
| Audio | `just_audio`, `audio_session` |
| Notifications | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Cloud | `firebase_core`, `firebase_auth`, `cloud_firestore` |
| Networking | `http`, `connectivity_plus` |
| Images / share | `screenshot`, `image_gallery_saver_plus`, `share_plus`, `permission_handler` |
| Fonts | `google_fonts` |

---

## Project structure

```text
lib/
  config/          # Cloud, audio, and capability flags
  l10n/            # en / am / om / ti / so UI strings
  models/          # Immutable domain types
  providers/       # Presentation state (Bible, study, streaks, reminders, …)
  repositories/    # Community repository boundary
  screens/         # Adaptive shell and feature screens
  services/        # Bible, search, DB, audio, sync, catalogs, notifications
  utils/           # Theme, streak copy, greetings, scripture cleanup
  widgets/         # Drawer, verse card, sheets, design system
assets/
  bible/           # web.json, kjv.json, asv.json
  catalog/         # Bible + audio catalogs, Henson manifest
  content_manifest.json
docs/
  CONTENT_SOURCES.md
  INTEGRATIONS_AND_RELEASE.md
tools/
  content/         # Manifest validator
  scripture/       # WEB fetch / USFM conversion
test/              # Unit, widget, accessibility, golden, migration
integration_test/  # Browser smoke test
firebase-tests/    # Firestore security-rule tests
.github/workflows/ci.yml
```

---

## Getting started

### Requirements

- Flutter **3.44.1** (or a compatible stable release matching CI)
- Dart SDK `>=3.6.0 <4.0.0`
- Python 3 only if regenerating Scripture assets
- Android Studio / SDK for local APK builds

### Install

```powershell
flutter pub get
```

### Run

```powershell
# Chrome (recommended flag avoids CanvasKit CDN failures)
flutter run -d chrome --no-web-resources-cdn

# Or any other device
flutter run -d windows
flutter run -d android
```

VS Code / Cursor: use the **BiblePulse (Chrome)** launch config in `.vscode/launch.json` (includes `--no-web-resources-cdn`).

### Local quality gate

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze lib test integration_test
python tools/content/validate_manifest.py
flutter test --exclude-tags golden
flutter test test/goldens
flutter build web --release --no-wasm-dry-run
```

### Release APK (local)

```powershell
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

CI also uploads an unsigned APK + AAB as the **android-unsigned-verification** artifact on every push.

### Rebuild WEB Scripture (optional)

```powershell
powershell -ExecutionPolicy Bypass -File tools/scripture/fetch_web.ps1
```

Output: `assets/bible/web.json`. The converter refuses manifests that do not approve app-store redistribution. Upstream archives are not committed.

---

## Gated integrations

Full setup steps live in [`docs/INTEGRATIONS_AND_RELEASE.md`](docs/INTEGRATIONS_AND_RELEASE.md). Summary:

### Firebase (auth + study sync)

Pass values with `--dart-define` (never commit secrets):

```text
FIREBASE_API_KEY
FIREBASE_APP_ID
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_PROJECT_ID
FIREBASE_AUTH_DOMAIN          # optional
FIREBASE_STORAGE_BUCKET       # optional
FIREBASE_USE_EMULATORS=true   # optional local
BIBLEPULSE_ENABLE_COMMUNITY=true  # optional community UI
```

Study records are owner-scoped. Firestore rules and emulator tests live under `firestore.rules` and `firebase-tests/`.

### Bible Brain audio

```text
BIBLE_BRAIN_API_KEY
BIBLE_BRAIN_BIBLE_IDS_JSON={"WEB":"approved-bible-id"}
BIBLE_BRAIN_MEDIA_HOSTS=approved.cdn.host
```

Without these defines, BiblePulse still uses **public-domain WEB Henson** audio. Bible Brain filesets are discovered from the API; only download-listed filesets may be cached. HTTPS host allowlisting is enforced.

### Notifications

Permission is requested when the user enables **Verse + streak reminders** in Settings (Android / iOS). Schedules use inexact alarms — no exact-alarm permission.

---

## Content and licensing

Only content with verified redistribution terms may ship. Every payload must appear in `assets/content_manifest.json` with attribution, commercial-redistribution approval, and an exact SHA-256. CI rejects unlisted or changed files.

| Content | Status |
|---|---|
| World English Bible | **Bundled** — public domain (eBible `engwebp`) |
| King James Version | **Store install** — public domain |
| American Standard Version | **Store install** — public domain |
| WEB Henson audio | **Default stream/cache** — public domain (eBible) |
| Amharic / Oromo / Tigrinya / Somali Scripture | **Not bundled** — catalog placeholders; need written redistribution rights |
| Bible Brain audio | Implemented behind dart-defines + rights record |
| Devotionals / plans / hymns | Catalog plumbing ready; no licensed payloads bundled |

Details: [`docs/CONTENT_SOURCES.md`](docs/CONTENT_SOURCES.md).

---

## Testing and CI

GitHub Actions (`.github/workflows/ci.yml`) runs on every push and pull request:

| Job | Checks |
|---|---|
| **verify** | Format, `flutter analyze`, content manifest, unit/widget/accessibility/migration tests, web release build |
| **windows** | Golden tests + Windows release build |
| **android** | Debug-signed APK + App Bundle → artifact `android-verification-apk` (sideload the `.apk`, not the `.aab`) |
| **apple** | iOS (`--no-codesign`) + macOS release |
| **linux** | Linux release bundle |
| **firebase-emulators** | Firestore rules (Node 24, Java 21) |
| **web-integration** | Chrome smoke test via `flutter drive --profile` + xvfb |

Golden tests are tagged `golden` and run on Windows runners to avoid Linux/Windows pixel drift. Non-golden tests use `--exclude-tags golden` on Ubuntu.

Local Firestore rules:

```powershell
npm ci --prefix firebase-tests
npx firebase-tools@latest emulators:exec --only firestore "npm --prefix firebase-tests test"
```

---

## Release and signing

CI artifacts are **verification builds**, not Play Store packages.

- Without release keystore secrets, the Android APK is **debug-signed** so it installs on devices for testing. With `BIBLEPULSE_ANDROID_*` set, it uses your release keystore.
- From GitHub Actions: download **`android-verification-apk`**, unzip, install **`app-release.apk`**. Do not try to install the `.aab` or the zip itself.
- Windows post-build signing is documented in the integrations guide.
- Confirm ownership of `app.biblepulse.reader` before store submission.
- Do not commit keystores, API keys, or Firebase production secrets.

See [`docs/INTEGRATIONS_AND_RELEASE.md`](docs/INTEGRATIONS_AND_RELEASE.md).

### Security posture

- Publishable Android builds require explicit `BIBLEPULSE_ANDROID_*` keystore env vars (`./gradlew verifyReleaseSigning`). CI without those secrets uses debug signing only so verification APKs can be sideloaded.
- Firestore rules isolate study data per authenticated owner.
- Audio accepts only configured HTTPS media hosts and download-permitted filesets (Bible Brain path).
- Exact-alarm Android permissions are not requested.
- Content checksum gate prevents silent asset substitution.

---

## Documentation

| Document | Contents |
|---|---|
| [docs/CONTENT_SOURCES.md](docs/CONTENT_SOURCES.md) | Scripture provenance, Amharic status, catalog policy |
| [docs/INTEGRATIONS_AND_RELEASE.md](docs/INTEGRATIONS_AND_RELEASE.md) | Firebase, Bible Brain, notifications, signing |

---

## License and contribution

Application code in this repository is provided for development of BiblePulse. Bundled Scripture and public-domain audio remain under their upstream terms (WEB / KJV / ASV / Henson: public domain). Do not add translations, devotionals, hymns, or proprietary audio without updating the content manifest and documenting redistribution rights.

When opening a pull request:

- Keep changes focused.
- Preserve the fail-closed capability model.
- Run format, analyze, and tests on application-owned code.
- Do not add AI co-author trailers to commits.

---

**BiblePulse** — read Scripture offline, keep a joyful daily streak, and unlock richer features only when the rights and credentials are real.
