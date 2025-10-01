# Clueo Games

A polished daily puzzle hub focused on word & logic puzzles, built with SwiftUI and following Apple's best practices.

## 🎯 Overview

**Clueo Games** is a modern iOS app that delivers daily word and logic puzzles in a clean, NYT-style interface. The app features:

- **Daily Connections-style puzzles**: 4x4 grid word grouping challenges
- **Mini Crossword puzzles**: 5x5 crossword engine with keyboard input
- **Streak tracking**: Daily puzzle completion streaks
- **Premium subscription**: Access to past puzzles and ad-free experience
- **Modern UI**: Clean, minimalist design with smooth animations

## 📱 App Details

- **Bundle Display Name**: "Clueo Games"
- **Target**: iOS 17+
- **Language**: Swift 5
- **Architecture**: MVVM with SwiftUI
- **Concurrency**: Swift async/await
- **Persistence**: UserDefaults + Core Data ready

## 🏗️ Project Structure

```
CluoGames/
├── Models/
│   ├── PuzzleModels.swift          # Core puzzle data models
│   └── SubscriptionModels.swift    # Subscription and monetization models
├── ViewModels/
│   ├── HomeViewModel.swift         # Home screen logic
│   └── ConnectionsGameViewModel.swift # Game logic
├── Views/
│   ├── HomeView.swift              # Main home screen
│   ├── ConnectionsGameView.swift   # Game interface
│   ├── PuzzleResultView.swift      # Results screen
│   └── SubscriptionView.swift      # Premium subscription
├── Services/
│   ├── PuzzleService.swift         # Puzzle data management
│   ├── SubscriptionService.swift   # StoreKit 2 integration
│   ├── AnalyticsService.swift      # Analytics tracking
│   ├── NotificationService.swift   # Local notifications
│   └── LocalizationService.swift   # i18n support
├── Resources/
│   ├── connections_puzzles.json    # Sample puzzle data
│   ├── crossword_puzzles.json      # Sample crossword data
│   └── Localizable.strings         # English localization
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ Simulator or Device
- Apple Developer Account (for StoreKit testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd CluoGames
   ```

2. **Open in Xcode**
   ```bash
   open CluoGames.xcodeproj
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

### First Run

The app will automatically:
- Request notification permissions
- Load today's puzzle
- Initialize analytics tracking
- Set up daily reminders

## 🎮 Game Modes

### Connections
- **Objective**: Group 16 words into 4 categories of 4
- **Mechanics**: Tap words to select, groups auto-check when 4 selected
- **Feedback**: Visual animations, mistake tracking, time recording
- **Difficulty**: 4 levels per puzzle (1=Easy, 4=Hard)

### Crossword (Coming Soon)
- **Objective**: Fill in the 5x5 grid using provided clues
- **Mechanics**: Tap cells, type letters, navigate with clues
- **Features**: Auto-save progress, hint system

## 💰 Monetization

### StoreKit 2 Integration

The app includes complete StoreKit 2 integration with:

- **Monthly Subscription**: `com.clueogames.premium.monthly`
- **Yearly Subscription**: `com.clueogames.premium.yearly`
- **One-time Purchase**: `com.clueogames.pastpuzzles.onetime`

#### Setup StoreKit Testing

1. **Create StoreKit Configuration File**
   - File → New → File → StoreKit Configuration File
   - Add products with the IDs above
   - Set test prices and descriptions

2. **Enable StoreKit Testing**
   - Edit Scheme → Run → Options
   - Set StoreKit Configuration to your file

3. **Test Purchases**
   - Use test accounts in Settings → App Store → Sandbox Account
   - Test subscription flows and restore purchases


## 📊 Analytics

The app includes a comprehensive analytics service with predefined events:

### Key Events Tracked
- Puzzle started/completed/abandoned
- Subscription events
- User engagement (shares, streaks)

### Integration Options
- **Firebase Analytics**: Uncomment Firebase code in `AnalyticsService.swift`
- **Amplitude**: Replace with Amplitude SDK
- **Custom Analytics**: Implement your own tracking

## 🔔 Notifications

Local notifications are configured for:
- **Daily Reminders**: 9:00 AM puzzle availability
- **Streak Reminders**: After 3+ day streaks
- **Custom Scheduling**: User-configurable times

### Notification Setup
```swift
// Request permissions
await NotificationService.shared.requestPermission()

// Schedule daily reminder
NotificationService.shared.scheduleDailyReminder(at: 9, minute: 0)
```

## 🌍 Localization

The app supports multiple languages with:
- **English**: Complete localization
- **Extensible**: Easy to add new languages
- **Accessibility**: VoiceOver support

### Adding New Languages
1. Add new `.strings` files for target languages
2. Update `Localizable.strings` with translations
3. Test with different system languages

## 🧪 Testing

### UI Testing
- **SwiftUI Previews**: All views have preview code
- **Accessibility**: VoiceOver labels and hints
- **Device Testing**: iPhone and iPad layouts

## 📱 App Store Metadata

### App Information
- **Name**: Clueo Games
- **Subtitle**: Word, Logic and Daily Puzzles
- **Keywords**: word,logic,puzzle,daily,brain,teaser,riddle,crossword,grid,streak,challenge
- **Category**: Games → Word
- **Age Rating**: 4+ (No objectionable content)

### Screenshots Needed
- Home screen with today's puzzle
- Game in progress
- Results screen with streak
- Subscription screen
- iPad layouts (if supporting)

## 🔧 Configuration

### Environment Setup
```swift
// Development
#if DEBUG
let isDebugMode = true
let analyticsEnabled = false
#endif

// Production
#if RELEASE
let isDebugMode = false
let analyticsEnabled = true
#endif
```

### Feature Flags
- **Analytics**: Toggle tracking
- **Ads**: Enable/disable ad serving
- **Notifications**: Control reminder frequency
- **Premium Features**: Gate access to past puzzles

## 🚨 Legal & Branding

### Important Notes
- **"Clueo Games"** is used as a working title
- **Replace with your brand** before App Store submission
- **Update all references** in code, assets, and metadata
- **Check trademark availability** for your chosen name

### Required Legal Pages
- Terms of Service
- Privacy Policy
- Subscription Terms
- Data Usage Policy

## 🐛 Troubleshooting

### Common Issues

**Build Errors**
- Ensure iOS 17+ deployment target
- Check Swift version compatibility
- Verify all dependencies are installed

**StoreKit Issues**
- Use test accounts in sandbox
- Check product IDs match configuration
- Verify App Store Connect setup


**Analytics Issues**
- Check network connectivity
- Verify API keys and configuration
- Review console logs for errors

## 📈 Performance

### Optimization Tips
- **Lazy Loading**: Images and data loaded on demand
- **Memory Management**: Proper cleanup of resources
- **Battery Usage**: Efficient background processing
- **Network**: Minimal API calls, caching strategies

### Monitoring
- **Crash Reporting**: Integrate Crashlytics or similar
- **Performance**: Monitor app launch time, memory usage
- **Analytics**: Track user engagement and retention

## 🔄 Updates & Maintenance

### Regular Tasks
- **Puzzle Updates**: Add new daily puzzles
- **Bug Fixes**: Address user feedback
- **Feature Updates**: New game modes, improvements
- **iOS Updates**: Compatibility with new iOS versions

### Version Management
- **Semantic Versioning**: Major.Minor.Patch
- **Release Notes**: Clear changelog for users
- **Rollback Plan**: Ability to revert problematic updates

## 📞 Support

### User Support
- **In-App Help**: Tutorial and FAQ
- **Contact**: Support email or form
- **Community**: User forums or social media

### Developer Support
- **Documentation**: Keep README updated
- **Code Comments**: Explain complex logic
- **Testing**: Comprehensive test coverage

## 🎉 Launch Checklist

### Pre-Launch
- [ ] Replace placeholder content with real data
- [ ] Update all branding and legal references
- [ ] Configure production analytics and crash reporting
- [ ] Set up App Store Connect and TestFlight
- [ ] Test on multiple devices and iOS versions
- [ ] Verify all monetization flows work correctly
- [ ] Check accessibility compliance
- [ ] Prepare App Store assets (screenshots, descriptions)

### Launch Day
- [ ] Submit for App Store review
- [ ] Monitor for crashes and issues
- [ ] Respond to user feedback
- [ ] Track key metrics and analytics

---

**Built with ❤️ using SwiftUI and following Apple's Human Interface Guidelines**

*This project serves as a complete, production-ready foundation for a daily puzzle app. Customize the branding, add your own puzzles, and launch your own puzzle game!*
