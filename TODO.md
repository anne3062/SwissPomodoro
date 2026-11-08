# TODO.md

## SwissPomodoro SwiftUI App (macOS 14+)

### Initial Tasks
- [x] Set up SwiftUI project structure
- [x] Create main Pomodoro timer view
- [x] Add basic timer functionality (start, pause, reset)
- [x] Design minimal UI for macOS 14+
- [ ] Implement settings/preferences
- [ ] Add notifications for session completion
- [ ] Write unit tests for timer logic

### Bugs (fix before adding features)
- [x] **Dial numbers sit 180° away from their ticks** (`ContentView.swift:23-46`).
      Each `VStack` pins the number to the bottom of the 220pt frame while the tick
      is at the top, so "0" renders at 6 o'clock and "30" at 12 o'clock.
      Labels are now placed at an explicit radius and rotated with their tick.
- [x] **Progress arc grows counter-clockwise, opposite the hand** (`ContentView.swift:48-52`).
      The arc is now trimmed from 0 to `progress`, so it sweeps clockwise from
      12 o'clock, and it is drawn behind the ticks/labels.
- [x] **Pause is destructive**: after pausing, the only Start path re-opened the
      duration sheet and restarted from the full duration (`ContentView.swift:78-116`).
      The primary button now reads "Resume" and continues the paused session.
- [ ] **Countdown drifts and stalls**: it decrements a counter per tick instead of
      tracking a deadline, so system sleep, a busy main thread, or dragging the
      window (timers in `.default` run-loop mode are paused by live resize) makes
      the session run long (`ContentView.swift:142-155`).
      Store `endDate`/`remainingAtPause` and derive `timeRemaining` from the clock.
- [ ] **Timer never stops when the window closes** (no `.onDisappear`), and it
      fires one extra tick after `timeRemaining` reaches 0 before
      `timerActive = false`. Invalidate on completion and on view disappearance.
- [ ] **Hardcoded `.black`/`.white` colors break dark mode**: the dial, ticks, and
      knob disappear in dark appearance. Use semantic colors (`Color.primary`,
      `.background`, `.quaternary`) or a fixed light "instrument" surface with an
      explicit background.

### Architecture
- [ ] Extract timer logic out of the view into an `@Observable` model (or a pure
      state struct) so it is testable and the view holds no `Timer` in `@State`.
- [ ] Remove duplicated duration state (`durationMinutes` + `totalTimeSeconds`);
      one source of truth for "chosen duration" vs. "current session".
- [ ] Delete unused `startTimer()` ("kept for backwards compatibility" – nothing calls it).
- [ ] Ship a real `.app` bundle. `swift run` produces a bare executable with no
      bundle identifier, which blocks `UNUserNotificationCenter` (the notification
      task) and gives the menu bar/dock a generic icon. Add an Xcode project or a
      bundling script (`Info.plist` + `.app` layout).

### Testing
- [ ] Replace the `XCTAssertTrue(true)` placeholder with real tests for the
      extracted timer model (elapsed time, pause/resume, completion, reset).
- [ ] Use Swift Testing (`@Suite` / `@Test`) per AGENTS.md; the current file uses XCTest.
- [ ] Add `swift build && swift test` to CI. Note: `swift build` currently fails on
      a CommandLineTools-only toolchain (`SwiftUIMacros` plugin missing for
      `@State`); a full Xcode install is required.

### UX / GUI (from sketch.png / sketch2.png)
- [ ] Single primary Start/Pause button with Space as shortcut, instead of two
      always-visible buttons with disabled states.
- [ ] Show the digital time at all times (or on click), not only on hover – the
      current hover-only text is undiscoverable.
- [ ] Restyle toward the sketch: light-blue case, red progress sector, bold
      outlines, "Period"/"Light" controls, rounded window with material background.
- [ ] Duration presets (25/45/60 + custom) remembered in `@AppStorage`; the sheet
      currently starts from whatever value was last stepped.
- [ ] Show "done" state at 00:00 (color change, sound, banner) – right now
      completion is silent.
- [ ] Menu bar item (`MenuBarExtra`) with remaining time and start/pause.
- [ ] Window title / dock badge reflecting the remaining time.
- [ ] Accessibility: labels for the dial and progress, VoiceOver announcements on
      state changes, respect Reduce Motion for the hand/arc animation.
- [ ] Monospaced digits for the time string so the layout does not jitter.

### Housekeeping
- [ ] Drop the redundant `.enableExperimentalFeature("StrictConcurrency")` in
      `Package.swift`; Swift 6 language mode already enables it.
- [ ] Move the reference sketches (`sketch.png`, `sketch2.png`, ~1.6 MB) into a
      `Docs/` folder or remove them from the repo root.

### Future Enhancements
- [ ] Customizable session lengths
- [ ] Statistics and history tracking
- [ ] Menu bar integration
- [ ] Localization support
- [ ] Accessibility improvements
