# TODO.md

## SwissPomodoro SwiftUI App (macOS 14+)

### Initial Tasks
- [x] Set up SwiftUI project structure
- [x] Create main Pomodoro timer view
- [x] Add basic timer functionality (start, pause, reset)
- [x] Design minimal UI for macOS 14+
- [ ] Implement settings/preferences
- [ ] Add notifications for session completion
      (must also fire while the window is closed; hook into the model, not the view).
- [x] Write unit tests for timer logic

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
- [x] **Countdown drifts and stalls**: it decremented a counter per tick, so system
      sleep, a busy main thread, or dragging the window made the session run long.
      The remaining time is now derived from an `endDate` and the timer runs in
      `.common` run-loop mode.
- [x] **Timer never stops when the window closes** (no `.onDisappear`). The timer
      stops exactly at zero, and the model is now owned by the app so a running
      session deliberately survives closing the window (the menu bar shows it).
- [x] **Hardcoded `.black`/`.white` colors break dark mode**: the dial, ticks, and
      knob disappeared in dark appearance. The redesigned case and dial use their
      own fixed palette, so the device reads the same in either appearance.

### Architecture
- [x] Extract timer logic out of the view into an `@Observable` model (or a pure
      state struct) so it is testable and the view holds no `Timer` in `@State`.
      `Models/PomodoroTimer.swift` now owns phase, deadline, ticks and formatting.
- [x] Remove duplicated duration state (`durationMinutes` + `totalTimeSeconds`);
      the model owns `totalSeconds`/`remainingSeconds`, the view only keeps the
      picker value.
- [x] Delete unused `startTimer()` ("kept for backwards compatibility" – nothing calls it).
- [x] Ship a real `.app` bundle. `Scripts/bundle.sh` assembles and ad-hoc signs
      `SwissPomodoro.app` from `Resources/Info.plist`, giving the app a bundle
      identifier for notifications and a proper name in the dock/menu bar.

### Testing
- [x] Replace the `XCTAssertTrue(true)` placeholder with real tests for the
      extracted timer model (elapsed time, pause/resume, completion, reset).
- [x] Use Swift Testing (`@Suite` / `@Test`) per AGENTS.md; the current file uses XCTest.
- [x] Add `swift build && swift test` to CI. `Scripts/ci.sh` does it and fails fast
      when the active toolchain is CommandLineTools only (no SwiftUI macros).

### UX / GUI (from sketch.png / sketch2.png)
- [x] Single primary Start/Pause button with Space as shortcut, instead of two
      always-visible buttons with disabled states.
- [x] Show the digital time at all times (or on click), not only on hover – the
      current hover-only text is undiscoverable.
- [x] Restyle toward the sketch: light-blue case, red progress sector, bold
      outlines, "Period"/"Light" controls, rounded window with material background.
- [x] Duration presets (25/45/60 + custom) remembered in `@AppStorage`; the sheet
      now prefills from the last confirmed duration.
- [x] Show "done" state at 00:00 (color change, sound, banner) – completion is no
      longer silent: red time, "Time's up" caption, system beep and dock bounce.
- [x] Menu bar item (`MenuBarExtra`) with remaining time and start/pause.
- [ ] Window title / dock badge reflecting the remaining time.
- [ ] Accessibility: labels for the dial and progress, VoiceOver announcements on
      state changes, respect Reduce Motion for the hand/arc animation.
- [x] Monospaced digits for the time string so the layout does not jitter.

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
