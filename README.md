# BiblePulse - A Comprehensive Bible Study App

## What is BiblePulse?

BiblePulse is a cross-platform Bible app built with Flutter. It started as a learning project where I wanted to see if I could build a comprehensive Bible study experience for mobile devices. It's definitely not finished, but it has grown into something I'm pretty proud of.

The idea was to combine traditional Bible reading with modern features like devotionals, reading plans, and study tools. You can read Scripture in multiple versions (KJV, ASV, Amharic), take notes on verses, create bookmarks, follow reading plans, and start your day with devotionals. It's meant to feel natural whether you've been reading the Bible for years or you're just getting started.

## The Story Behind This App

I started this as a simple experiment. Could I build a Bible app that was both powerful and easy to use? As I kept working on it, it grew way beyond what I originally planned. I kept adding features from other Bible apps I liked, experimented with different UI patterns, and tried to make the reading experience really pleasant.

What you see here is an unfinished but functional prototype. It's rough around the edges and there's a lot of work left to do, but it shows what's possible when you combine good design with thoughtful features. Some parts are more polished than others, but that's just how side projects go.

## What Can You Do With BiblePulse?

### Core Bible Reading
- **Multiple Versions**: Switch between KJV, ASV, and Amharic translations
- **Easy Navigation**: Jump between books and chapters without the UI getting in your way
- **Search**: Find verses or topics across the entire Bible
- **Customization**: Adjust fonts, text size, line height, and pick from multiple color themes (light, dark, sepia, true black for AMOLED screens)

### Study Tools
- **Bookmarks**: Save important verses for later
- **Highlights**: Color-code verses to organize your thoughts
- **Notes**: Write personal reflections tied to specific verses
- **Labels**: Tag verses by topic or theme
- **Cross-References**: See how different parts of Scripture connect

### Daily Devotionals
- **Daily Readings**: Devotionals from well-known authors
- **Verse of the Day**: Fresh Scripture every day
- **Reading Plans**: Structured plans to read through the Bible
- **Reading History**: Track your progress and see stats
- **Reminders**: Set up notifications to build daily habits

### Hymns
- **Hymn Library**: Traditional Christian hymns with full lyrics
- **Categories**: Browse by theme (worship, thanksgiving, prayer, Christmas, Easter, etc.)
- **Favorites**: Save your favorite hymns
- **Search**: Find hymns by title, number, author, or lyrics

### Other Features
- **Wallpaper Generator**: Turn verses into phone wallpapers
- **Sharing**: Share verses with friends and family
- **Multi-language**: English and Amharic interface

## What Makes This Different?

Most Bible apps are either super simple text readers or they're packed with so many features you can't find anything. I tried to find a middle ground with powerful tools that don't overwhelm you.

The design uses "progressive disclosure" - when you first open the app, you get a clean reading experience. As you explore, you discover more features like notes, highlights, and reading plans. Everything is integrated smoothly without cluttering the interface.

I also spent a lot of time on aesthetics. Reading the Bible should feel special, so there's nice typography, smooth animations, and colors that are easy on your eyes during long reading sessions.

## Tech Stack

**Built With:**
- Flutter (iOS, Android, Web, Windows, Mac, Linux)
- Provider for state management
- SQLite for local data storage
- Shared Preferences for settings
- Google Fonts for typography

**Project Structure:**
- `models/` - Data structures
- `providers/` - State management
- `screens/` - UI pages
- `widgets/` - Reusable components
- `services/` - Business logic
- `assets/` - Bible files and resources

## Current Status

### ✅ Works Great
- Bible reading with multiple versions
- Chapter/book navigation
- Search functionality
- Theme switching
- Font customization
- Bookmarks, notes, highlights (UI done)
- Daily devotionals
- Hymn browsing
- Basic navigation

### ⚠️ Partially Done
- Reading plans (UI exists, limited content)
- Verse sharing (works but basic)
- Reading statistics
- Cross-references (structure done, needs content)
- Notifications (framework there, needs work)

### ❌ Not Implemented Yet
- Cloud sync
- User accounts
- Social features
- Audio Bible
- Advanced study tools (commentaries, dictionaries)
- More Bible version downloads
- Full reading plans library
- Complete hymn database with audio
- Hebrew/Greek tools

## Known Issues

Let's be real about what needs work:

1. **Search is slow** on older devices (it scans the whole Bible)
2. **Limited content** for devotionals and reading plans
3. **Some data doesn't persist** between sessions yet
4. **Error handling** could be better
5. **Testing** is mostly manual, not automated
6. **UI inconsistencies** across different screens
7. **Some duplicate code** that could be refactored
8. **Web version** works but it's really designed for mobile

## Future Plans

If I keep working on this, here's what I'd love to add:

**Short Term:**
- More devotionals and reading plans
- Better search performance
- Complete database persistence
- Polish the UI
- Better error handling

**Medium Term:**
- Cloud sync for your notes and highlights
- Social features (study groups, sharing)
- Audio Bible
- Better offline support
- More Bible translations
- Study tools like commentaries and maps
- Smarter notifications

**Long Term:**
- AI-powered verse suggestions
- Hebrew/Greek study tools
- Live collaborative Bible study
- Church integration features
- Better accessibility
- Personalized recommendations

## Getting Started

**Prerequisites:**
- Flutter SDK 3.0.0+
- Dart SDK
- Android Studio or Xcode
- Your favorite code editor

**Installation:**

1. Clone the repo
```bash
git clone https://github.com/abel2800/Bible-Pulse-Amharic-Bible-.git
cd bible
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

4. Build for release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

**Configuration:**

The Bible content is already included in `assets/bible/`:
- `kjv.json` - King James Version
- `asv.json` - American Standard Version
- `amharic.json` - Amharic Bible

No API keys or additional setup needed.

## What I Learned

**What Worked:**
- Flutter's cross-platform approach is genuinely powerful
- Provider is simple and works great for this scale
- Building features incrementally kept things manageable
- Local-first approach makes it fast and private

**Challenges:**
- The Bible is a LOT of text. Performance matters.
- Feature creep is real. Started simple, kept adding stuff.
- Keeping UI consistent across screens is harder than expected
- Maintaining momentum on a side project over months is tough

**What I'd Do Different:**
- Plan the architecture better from day one
- Write tests earlier
- Create a design system first
- Keep the scope smaller and do fewer things really well
- Have a content strategy from the start

## Contributing

This is mainly a personal learning project, but I'm open to ideas and feedback. Feel free to:
- Suggest features
- Report bugs
- Contribute code
- Fork it for your own project

The code is here to learn from and build on.

## Bible Content & Copyright

The Bible translations are all public domain:
- King James Version (1611)
- American Standard Version (1901)
- Amharic Bible (public domain)

Devotional content is either public domain or used for educational purposes. If this becomes commercial, proper licensing would be needed.

## Final Thoughts

Building this has taught me a ton about Flutter and mobile development, but also about the challenges of making something meaningful. Every feature took hours of work, and some parts I'm really happy with while others still need work.

If you're checking out this code, I hope you find something useful. Maybe a solution to a problem you're facing, or inspiration for your own project, or just a reminder that all software starts messy and imperfect.

The Bible has been around for thousands of years and has helped billions of people. Building an app to help people read it in modern ways is humbling. This app isn't perfect, but it's made with care for both the craft and the content.

## License

This project is provided as-is for educational and personal use. Bible translations are public domain.

---

**Note:** This is an unfinished learning project. It's not production-ready and you'd need significant work before using it commercially. But it's a solid starting point and shows a lot of Flutter concepts in action.

Good luck with your own projects!
