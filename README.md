# BiblePulse

**Offline-first Bible reading and study for English readers — built with Flutter for Android, iOS, web, Windows, macOS, and Linux.**

BiblePulse is a focused Scripture reader with real local persistence, adaptive navigation, and a single coherent design system. Features that need licensed content, API credentials, or production cloud configuration stay hidden until those dependencies are in place. What you see in the app is what actually works.

| | |
|---|---|
| **Package** | `bible_pulse` |
| **App ID** | `app.biblepulse.reader` |
| **Version** | `1.0.0+1` |
| **Flutter** | 3.44.1 (CI-pinned) |
| **Repository** | [abel2800/Bible-Pulse-Amharic-Bible-](https://github.com/abel2800/Bible-Pulse-Amharic-Bible-) |

---

## Table of contents

1. [What you get today](#what-you-get-today)
2. [Platforms](#platforms)
3. [Product tour](#product-tour)
4. [Design system](#design-system)
5. [Architecture](#architecture)
6. [Project structure](#project-structure)
7. [Getting started](#getting-started)
8. [Gated integrations](#gated-integrations)
9. [Content and licensing](#content-and-licensing)
10. [Testing and CI](#testing-and-ci)
11. [Release and signing](#release-and-signing)
12. [Documentation](#documentation)

---

## What you get today

### Scripture and reading

- **World English Bible (WEB)** — full 66-book Protestant edition, bundled offline from eBible.org (public domain).
- Book and chapter navigation with last-read restoration.
- Exact scroll-to-verse when opening a search result.
- Date-rotating verse of the day from verified WEB text.
- Independent reader themes (Light, Sepia, Dark, True Black, Blue Night, Forest) that do not follow the app chrome theme.
- Persistent font size and line spacing for Scripture text.

### Search

- Unicode indexed search with bounded results.
- **SQLite FTS5** on Android, iOS, and macOS.
- **In-memory token index** on web, Windows, and Linux.

### Study tools

Tap or long-press any verse to:

| Action | Behavior |
|---|---|
| Highlight | One color per verse; persists until you remove it |
| Note | Create or update a note on that verse |
| Bookmark | Add or remove a bookmark |
| Copy / Share | Clipboard and system share sheet |
| Verse card | Open branded image export for that verse |
| Cross-references | Show verified related verses when available |

Guest study data is stored locally:

- **SQLite** on Android, iOS, and macOS (versioned schema with migrations).
- **SharedPreferences** fallback on web, Windows, and Linux.

When cloud sync is configured, deletion uses tombstones and last-write-wins conflict resolution.

### Engagement

- Reading streaks with **one grace day** per seven-day window.
- **On this day** memories from past-year highlights and notes.
- Private **prayer journal** (local, optionally linked to a verse, with answered toggle).
- Branded **verse cards** (square / feed / status aspect ratios) with save and share.

### Navigation and locale

- Adaptive shell: bottom navigation on phones, navigation rail on tablet/desktop.
- App light / dark / system themes.
- English and Amharic **UI** locale selection (Amharic Scripture text is not bundled yet — see [Content and licensing](#content-and-licensing)).

### Capability-gated (implemented, off until configured)

These ship in code and activate only when credentials, licenses, or content exist:

- Parallel Amharic / English reading
- Bible Brain audio (stream, offline download, karaoke-style verse sync)
- Firebase auth and study sync
- Private reading groups
- Community feed with moderation hooks
- Devotional, reading-plan, and hymn catalogs
- Theme-based verse reminders (Android / iOS)

---

## Platforms

| Platform | Local DB | Notifications | Gallery export | Audio* | Cloud* |
|---|---|---|---|---|---|
| Android | SQLite | Yes | Yes | Gated | Gated |
| iOS | SQLite | Yes | Yes | Gated | Gated |
| macOS | SQLite | — | — | Gated | Gated |
| Windows | Prefs | — | — | Gated | Gated |
| Linux | Prefs | — | — | Gated | Gated |
| Web | Prefs | — | — | Gated | Gated |

\*Audio and cloud require build-time configuration. See [Gated integrations](#gated-integrations).

Minimum iOS deployment target: **15.0** (required by current Firebase Flutter plugins).

---

## Product tour

| Screen | Role |
|---|---|
| **Bootstrap / splash** | Readiness-driven startup (providers + assets). No fixed delay. |
| **Home (dashboard)** | Greeting, verse of the day, streak / memories, quick actions |
| **Bible** | Adaptive reader with themes, verse actions, optional parallel / audio UI |
| **Search** | Indexed Scripture search → jump to exact verse |
| **Study** | Highlights, notes, and bookmarks |
| **Settings** | Appearance, locale, fonts, audio cache (when enabled), theme reminders |
| **Prayer journal** | Private prayers linked to Scripture |
| **Verse card** | Generate and share branded images |
| **Auth / groups / community / catalogs** | Visible only when capabilities allow |

---

## Design system

Illuminated-manuscript language: warm parchment, gold rubrication, vermilion accents, and serif Scripture. Light and dark modes are designed together.

### Brand accents

| Token | Value | Use |
|---|---|---|
| Gold | `#C08A28` | Primary actions, active nav, verse numbers |
| Soft gold | `#E8C766` | Gradients and dark-mode gold |
| Vermilion | `#A83232` | Streaks, destructive actions |
| Teal | `#1E7F72` | Secondary accents, progress |

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
- **Amharic:** Noto Serif Ethiopic  
- Card radius: 16 · Controls: 10–12 · Icon buttons: 34×34 · Minimum touch target: 48×48

Reader presets (Light, Sepia, Dark, True Black, Blue Night, Forest) stay independent of app light/dark mode.

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
| Audio | `just_audio`, `audio_session` |
| Notifications | `flutter_local_notifications` |
| Cloud | `firebase_core`, `firebase_auth`, `cloud_firestore` |
| Networking | `http`, `connectivity_plus` |
| Images / share | `screenshot`, `image_gallery_saver_plus`, `share_plus` |
| Fonts | `google_fonts` |

---

## Project structure

```text
lib/
  config/          # Cloud, audio, and capability flags
  l10n/            # English / Amharic UI strings
  models/          # Immutable domain types
  providers/       # Presentation state
  repositories/    # Community repository boundary
  screens/         # Adaptive shell and feature screens
  services/        # Bible, search, DB, audio, sync, catalogs
  utils/           # Theme and shared helpers
  widgets/         # Reusable UI (drawer, verse card, sheets)
assets/
  bible/web.json               # Bundled WEB Scripture
  content_manifest.json        # Rights + SHA-256 gate
  biblepulse_app_icon.png
docs/
  CONTENT_SOURCES.md           # Provenance and license notes
  INTEGRATIONS_AND_RELEASE.md  # Firebase, audio, signing
tools/
  content/                     # Manifest validator
  scripture/                   # WEB fetch / USFM conversion
test/                          # Unit, widget, accessibility, golden, migration
integration_test/              # Browser smoke test
firebase-tests/                # Firestore security-rule tests
.github/workflows/ci.yml       # Multi-platform CI
```

---

## Getting started

### Requirements

- Flutter **3.44.1** or a compatible stable release  
- Dart SDK compatible with `>=3.6.0 <4.0.0`  
- Python 3 only if regenerating Scripture assets  

### Install

```powershell
flutter pub get
```

### Run

```powershell
flutter run -d chrome
# or: windows / android / ios / macos / linux device
```

### Local quality gate

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze lib test integration_test
python tools/content/validate_manifest.py
flutter test --exclude-tags golden
flutter test test/goldens
flutter build web --release --no-wasm-dry-run
```

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

Filesets are discovered from the API (not hardcoded). Only filesets listed for your key under `/download/list` may be cached for offline use. HTTPS host allowlisting is enforced. Settings expose Wi-Fi-only downloads, progress, pause, cache size, and clear cache.

### Notifications

Permission is requested only after the user picks a theme reminder in Settings (Android / iOS). Schedules use inexact alarms — no exact-alarm permission.

---

## Content and licensing

Only content with verified redistribution terms may ship. Every payload must appear in `assets/content_manifest.json` with attribution, commercial-redistribution approval, and an exact SHA-256. CI rejects unlisted or changed files.

| Content | Status |
|---|---|
| World English Bible | **Bundled** — public domain (eBible `engwebp`) |
| Amharic Scripture | **Not bundled** — eBible Amharic NT is copyrighted UBS/BSE text with non-commercial limits; needs written permission for store distribution |
| Audio | Implemented; needs Bible Brain approval + rights record |
| Devotionals / plans / hymns | Catalog plumbing ready; no licensed payloads bundled |

Details: [`docs/CONTENT_SOURCES.md`](docs/CONTENT_SOURCES.md).

---

## Testing and CI

GitHub Actions (`.github/workflows/ci.yml`) runs on every push:

| Job | Checks |
|---|---|
| **verify** | Format, `flutter analyze`, content manifest, unit/widget/accessibility/migration tests, web release build |
| **windows** | Golden tests + Windows release build |
| **android** | Unsigned APK + App Bundle |
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

CI artifacts are **unsigned verification builds**, not store packages.

- Android release signing activates only when `BIBLEPULSE_ANDROID_KEYSTORE` and related passwords/alias are set.
- Windows post-build signing is documented in the integrations guide.
- Confirm ownership of `app.biblepulse.reader` before store submission.
- Do not commit keystores, API keys, or Firebase production secrets.

See [`docs/INTEGRATIONS_AND_RELEASE.md`](docs/INTEGRATIONS_AND_RELEASE.md).

### Security posture

- Android release builds do not fall back to debug signing.
- Firestore rules isolate study data per authenticated owner.
- Audio accepts only configured HTTPS media hosts and download-permitted filesets.
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

Application code in this repository is provided for development of BiblePulse. Bundled Scripture text remains under its upstream terms (WEB: public domain). Do not add translations, devotionals, hymns, or audio without updating the content manifest and documenting redistribution rights.

When opening a pull request, keep changes focused, preserve the fail-closed capability model, and ensure `flutter analyze` and tests pass on application-owned code.

---

**BiblePulse** — read Scripture offline, study with intention, unlock richer features only when the rights and credentials are real.
