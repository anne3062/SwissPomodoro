# AGENTS.md

Notes for agents working on SwissPomodoro, a SwiftUI Pomodoro timer for macOS 14+.
Human-facing docs live in `README.md`; the work list lives in `TODO.md`.

## Commands
- **Build**: `swift build`
- **Run**: `swift run` (unbundled, so system notifications are skipped)
- **Bundle**: `Scripts/bundle.sh` → `SwissPomodoro.app` (ad-hoc signed; use it to test notifications)
- **Test all**: `swift test`
- **Test single**: `swift test --filter "<suite or test name>"`
- **CI check**: `Scripts/ci.sh` (build + test, fails fast without full Xcode)
- No linter or formatter is configured.

## Code style
- SwiftUI, 2-space indentation, one import per line, alphabetized (AppKit before SwiftUI).
- Prefer structs and value types; use classes only where identity is required (`@Observable` model).
- camelCase members, PascalCase types; `guard` for early returns; no force unwraps.
- Swift 6 strict concurrency: keep UI and model on the main actor; avoid `@unchecked Sendable`.
- Comments only for non-obvious logic.
- Views: property wrappers first, then computed properties, then actions.
- Use `String(format:)` for time strings and monospaced digits in the UI.
- Add a `PreviewProvider` for every view.

## Architecture
- `Models/PomodoroTimer.swift` is the single source of truth (`@MainActor @Observable`): phase,
  deadline, ticks, formatting. Views receive it; never duplicate timer state in a view.
- The countdown is deadline-based (`endDate` + a `.common` run-loop timer), not tick-counted.
- `Models/Preferences.swift` holds the `UserDefaults` keys shared by views and services.
- `Services/CompletionNotifier.swift` observes `.pomodoroSessionDidFinish` and posts notifications.
- `App/SwissPomodoroApp.swift` owns the model and the `Window`, `MenuBarExtra` and `Settings` scenes.

## Testing
- Swift Testing only (`@Suite`, `@Test`), files in `Tests/` with `@testable import SwissPomodoro`.
- Name suites `<Type>Tests`; test names describe behaviour, not implementation.
- Inject the clock into `PomodoroTimer` to test time without waiting.
- Cover state transitions and time math; skip trivial getter tests.

## Gotchas
- `swift run` has no bundle identifier, so `UNUserNotificationCenter` is not used and the app has
  no proper bundle identity. Use `Scripts/bundle.sh` when testing notifications, the menu bar icon
  or anything that depends on `Bundle.main`.
- The menu bar label is the only view mounted for the whole app lifetime; it drives the dock badge.
- A running session intentionally survives closing the window, so do not stop the timer in
  `onDisappear`.
- Record decisions and follow-ups in `TODO.md`.
