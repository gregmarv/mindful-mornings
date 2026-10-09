# Mindful Mornings

A small iOS app for a two-to-five-minute morning routine: a personal mantra with a short
breathing pause, two journal prompts, a streak/heatmap, and an optional 8 PM
"rate your day" check-in. Free, with an optional tip jar (consumable in-app purchases).

**Taking this project over?** Start with [HANDOFF.md](HANDOFF.md) — current status, what's
left before App Store submission, and known issues.

## Requirements

- Xcode 16+ (last built with Xcode 26.6). Deployment target: iOS 17.5.
- SwiftUI, Swift Charts, StoreKit 2, UserNotifications. No third-party dependencies.
- If `xcodebuild` says the iOS platform isn't installed: Xcode → Settings → Components →
  install the iOS platform that matches your Xcode's SDK.

## Run

1. Open `Mindful Mornings.xcodeproj`, scheme **Mindful Mornings**, pick an iPhone simulator, ⌘R.
2. To test onboarding from a fresh state, add the launch argument `-resetState`
   (Product → Scheme → Edit Scheme → Run → Arguments). It wipes all saved data on launch,
   Debug builds only. Leave it off to test streaks/history across launches.
3. Tip jar in the simulator: the scheme uses the local StoreKit config in
   `Mindful Mornings/MindfulMornings.storekit/`, so purchases work without App Store Connect.

## Test

⌘U in Xcode, or:

```bash
xcodebuild test -project "Mindful Mornings.xcodeproj" -scheme "Mindful Mornings" -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

- `Mindful MorningsTests/` — unit tests for `UserData` (seeding, weighted mantra picks,
  focus changes, prompts, streaks, reflections, persistence). Each test uses an isolated
  `UserDefaults` suite, so they never touch real app data.
- `Mindful MorningsUITests/` — one end-to-end onboarding test.

## Code map

```
Mindful Mornings/
  Mindful_MorningsApp.swift     App entry; debug reset flag; StoreKit listener; survey-from-notification sheet
  ContentView.swift             Root: LandingView until onboarded, then HomeView
  Theme.swift                   Colors (light/dark), button & text-field styles — use these, not raw colors
  PrivacyInfo.xcprivacy         Apple privacy manifest (UserDefaults reason CA92.1, no data collected)
  Models/
    UserData.swift              The single source of truth (ObservableObject, persisted in UserDefaults):
                                mantra deck + weights, focus area, completed days/streak, reflections,
                                and all preset content (mantras + prompts)
    ReflectionEntry.swift       One evening rating pair
  Notifications/
    NotificationManager.swift   Schedules/cancels the 8 PM reflection reminder; delegate handles taps
  Views/
    LandingView → OnboardingCarouselView → FocusSelectionView   Onboarding
    HomeView                    Greeting, streak badge, start/revisit routine
    TodaysRoutineView           Mantra (7s pause, like / another / not for me) → 2 prompts → done
    HabitHeatmapView            Streak stats + 16-week grid
    ReflectionHistoryView       Evening reminder toggle + ratings chart
    EveningReflectionSurveyView Two 1–10 ratings
    ManageAccountView           "Settings": focus area, mantra deck, support link
    DonateView                  Tip jar (StoreKit 2)
```

All content lives in `UserData.swift`. `MindfulMornings_ContentInventory.md` is a readable
copy for content review; keep the two in sync.

### How personalization works

- **Focus area** (picked in onboarding, editable in Settings) maps to a theme tag:
  calm / grief / gratitude / growth / connection / "" (general).
- **Mantras:** the deck is seeded with all presets. On-theme ones start at weight 1.3, others at 1.0.
  Picks are weighted random. "Love this" adds +0.5 (max 3.0), "Another" multiplies by 0.7
  (min 0.1), and "Not for me" removes it from the deck.
- **Grief content** (mantras and prompts) only appears if the user chose *Processing loss*.
- **Prompts** stay the same all day (keyed by day of year). For a themed user, 3 of every
  5 days use an on-theme prompt.
