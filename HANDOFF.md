# Mindful Mornings — Handoff

_Last updated: 2026-10-09_

## Where things stand

The app is feature-complete for a v1.0 and code-clean: no compiler warnings, 16 passing
unit tests, and one onboarding UI test. What remains is mostly **App Store setup**, plus a
few **product decisions** and **one unbuilt feature** (morning reminder) whose UI is
already partly visible. See [README.md](README.md) for how to build, run and test, and for
a map of the code.

The full business/App Store walkthrough (DBA, developer account, App Store Connect,
screenshots, IAP setup, submission) is in `MindfulMornings_PublishingChecklist.docx`.
Read the corrections to it below before following it.

---

## 1. Blockers before submission (do these first)

| # | Item | Notes |
|---|------|-------|
| 1 | **Decide the bundle ID** | The Xcode project uses `com.mindfulmorningsapp.Mindful-Mornings`; the checklist says `com.mindfulmornings.app`. Whichever is registered in the Apple Developer portal wins. Update the other to match (target → General → Bundle Identifier). The test targets have their own IDs and don't matter. |
| 2 | **Signing team** | Project is set to team `3QFK9GYAN8`. A new owner will need access to that team, or will need to switch to their own team (which then also means re-registering the bundle ID and IAPs under it). |
| 3 | **Morning reminder: build it or hide it** | Settings shows a "Morning reminder — Not set" row, but there is no way to set it and no notification is scheduled (`UserData.reminderTime` is never written). App Review flags non-functional UI. Fastest fix: delete the row in `ManageAccountView`. Proper fix: see §3. |
| 4 | **Create the 3 tip IAPs in App Store Connect** | IDs must match exactly: `com.mindfulmornings.donate.small` / `.medium` / `.large`, all **Consumable**. Prices and names are in the checklist. Each needs a review screenshot of the Support screen. |
| 5 | **Privacy policy URL** | Required for every app. The app collects **no data** (everything stays on-device in UserDefaults; there is no account, email, analytics or network code), so a short policy saying that is enough. In App Store Connect → App Privacy, answer **"Data Not Collected."** |
| 6 | **Sandbox-test the tip jar on a real device** | Simulator purchases use the local `.storekit` file; only a device with a sandbox account tests the real App Store Connect products. |
| 7 | **Review notes** | The tip jar is now always reachable via **Settings (person icon) → Support Mindful Mornings**. The heart on Home still appears only after a 7-day streak, so point the reviewer to Settings, not the heart (the checklist's example note is wrong on this). |

### Corrections to the publishing checklist

- **"Push Notifications" capability: not needed.** The app only uses *local* notifications.
  Adding the push capability without using it can trigger an App Store Connect warning.
- **The privacy policy reason "email address in onboarding counts" is outdated.** The app no
  longer collects email. A policy is still required (see #5).
- **The `#if DEBUG` reset is no longer automatic.** It now runs only with the `-resetState`
  launch argument, and only in Debug builds. Nothing to remove before archiving.
- **Deployment target is iOS 17.5, not 16.0.** Consider lowering it to **17.0**: nothing in
  the code needs 17.5, and it would reach more devices. Re-test after changing it.

---

## 2. Product decisions to make (quick, but someone needs to own them)

- **Inconsistent time promise.** The Landing screen says "Under two minutes, every morning"; the
  onboarding carousel says "under five minutes." Pick one (`LandingView.swift`,
  `OnboardingCarouselView.swift`).
- **Journal answers aren't saved.** The two morning prompts are text boxes, but what the user
  types is discarded when they tap Finish. Only "completed today" is recorded. That's
  defensible ("write it, let it go"), but users may expect to see past entries. Either save
  them (add to `UserData` alongside `reflectionEntries`) or add a line of copy saying
  entries aren't kept.
- **Health claim on the value-prop screen.** "Studies show that a short daily gratitude
  practice can meaningfully improve mood…" Fine in spirit, but App Review can push back
  on unsourced health claims (guideline 1.4). Consider softening it or citing a source.
- **iPhone landscape.** The target allows landscape on iPhone, but layouts are designed for
  portrait (stacked spacers, fixed sizes). Recommend unchecking Landscape Left/Right under
  the target → General → Deployment Info → iPhone Orientation.
- **iPad.** iPad is enabled as a destination, which means App Review will also run the app on
  iPad and you'll need iPad screenshots. If iPad isn't a goal, remove it from Supported
  Destinations.

## 3. Unbuilt / incomplete features

- **Morning reminder** (see blocker #3). Suggested build:
  - Add a `DatePicker(.hourAndMinute)` in the Settings row, stored in `reminderTime`
    (or change it to two Ints).
  - Add `scheduleMorningReminder(hour:minute:)` / `cancelMorningReminder()` to
    `NotificationManager` with its own identifier. Copy the evening pattern, which already
    handles permission prompts and the denied-in-Settings case in
    `ReflectionHistoryView.handleToggleChange`.
  - Optionally offer it at the end of onboarding, which is the highest-intent moment.
- **Evening reminder time is fixed at 8 PM.** `scheduleEveningReflection(hour:minute:)` already
  takes parameters; it just needs UI if you want it configurable.
- **Leftover state from an older account-based design:** `UserData.email` and `useFaceID` are
  persisted but unused, and `resetAccount()` is never called from the UI. Safe to delete,
  or wire `resetAccount()` to a "Reset all data" button in Settings (and also cancel
  notifications there).

## 4. Known rough edges (non-blocking)

- **Onboarding → Home navigation.** `FocusSelectionView` pushes a `HomeView` *and* flips
  `isOnboarded`, which also makes `ContentView` swap its root to `HomeView`. It works, but
  if you see a double transition or odd back behavior after onboarding, remove the
  `navigateToHome` push and rely on the root swap. Verify on device.
- **StoreKit config location.** `MindfulMornings.storekit` is a *folder* containing
  `Configuration.storekit`, and it's in the app's Copy Bundle Resources phase, so it ships
  inside the app. Harmless, but tidy it up: uncheck its target membership, and confirm Edit
  Scheme → Run → Options → StoreKit Configuration points at `Configuration.storekit`.
- **Streak breaks across time zones / DST** can be off by a day in rare cases, because dates
  are stored as local `yyyy-MM-dd` keys. That's acceptable for v1.
- **No data backup.** Everything is in UserDefaults on-device. Deleting the app loses
  streaks and reflections. Fine for v1; iCloud key-value sync would be a cheap v1.1 win.

---

## 5. Changes made in the `handoff-cleanup` branch

Bugs fixed:
- **Changing focus area from Settings wiped the user's mantra deck.** It reran onboarding:
  reseeding the deck, which lost custom mantras, likes and discards, and pushing a second
  Home screen. Settings now opens focus selection in edit mode (`isEditing: true`), which
  just saves and goes back. Grief mantras are added or removed to match the opt-in rule.
- **Tip jar was unreachable until a 7-day streak**, so App Review wouldn't have been able to
  find the IAPs. Added an always-visible "Support Mindful Mornings" row in Settings.
- **Debug builds wiped all user data on every launch**, which made streaks, the heatmap and
  history untestable. The wipe is now opt-in via the `-resetState` launch argument.
- **Tapping the evening notification while the app was closed** could miss opening the
  survey (race on cold launch). Fixed with a pending flag on `NotificationDelegate`.
- **"Not for me" on the last remaining mantra** left the screen showing "No mantras
  available." The button is now hidden when one mantra is left.
- **Mantra timer kept running** after leaving the routine screen. It's now invalidated on
  disappear and on discard.
- **Streak date keys** used the device's calendar and locale, so they would break for users
  on Buddhist/Japanese calendars. They now use a fixed Gregorian/POSIX formatter, shared
  with the heatmap. Existing keys from Gregorian users are unchanged.
- `resetAccount()` now also clears `reminderTime`.

Submission readiness:
- **Added `PrivacyInfo.xcprivacy`** (UserDefaults required-reason API `CA92.1`, no tracking,
  no data collected). Uploads without it are rejected by App Store Connect.
- **Added a StoreKit 2 `Transaction.updates` listener** at app launch, so Ask-to-Buy and
  interrupted tips get finished (Apple requires this).

Cleanup:
- Deleted orphaned duplicates (`Mindful Mornings/NotificationManager.swift`,
  `Mindful Mornings/Tests/`). They weren't in the Xcode project.
- Removed an empty "New Group" from the project. Replaced a deprecated `onChange` call.
- Rewrote the unit tests: the old ones called methods that no longer exist, so the test
  target didn't compile. `UserData` now takes an injectable `UserDefaults` so tests are
  isolated.
- Replaced stale UI tests (old login and donation-amount screens) with a real onboarding test.

**Verification note:** the machine these changes were made on didn't have the iOS 26.5 Xcode
platform installed, so the full Xcode build and simulator run weren't done. Instead, all
app and test sources were type-checked against the iOS simulator SDK with zero errors or
warnings, and the unit tests were run on macOS against the same model code (16/16 pass).
**First task for whoever picks this up: build, run ⌘U, and click through the app once in
the simulator**, especially onboarding, Settings → Focus Area, and the tip jar.
