import AppKit
import SwiftUI

struct MenuBarLabel: View {
  var pomodoro: PomodoroTimer

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "timer")
      Text(pomodoro.timeString)
        .monospacedDigit()
    }
    .onAppear {
      updateDockBadge()
    }
    .onChange(of: pomodoro.timeString) { _, _ in
      updateDockBadge()
    }
    .onChange(of: pomodoro.phase) { _, _ in
      updateDockBadge()
    }
  }

  /// The status bar label is the only view that is mounted for the whole app
  /// lifetime, so the dock badge is driven from here.
  private func updateDockBadge() {
    let showsBadge = pomodoro.phase == .running || pomodoro.phase == .paused
    NSApplication.shared.dockTile.badgeLabel = showsBadge ? pomodoro.timeString : nil
  }
}

struct MenuBarContent: View {
  var pomodoro: PomodoroTimer

  @AppStorage(Preferences.sessionMinutesKey) private var storedMinutes: Int = PomodoroTimer.defaultMinutes
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    Text(status)
    Divider()
    Button(pomodoro.primaryActionTitle) {
      pomodoro.toggle(at: storedMinutes)
    }
    Button("Reset") {
      pomodoro.reset()
    }
    .disabled(pomodoro.phase == .idle)
    Divider()
    Button("Open Timer") {
      openWindow(id: "main")
      NSApplication.shared.activate()
    }
    Button("Quit Swiss Pomodoro") {
      NSApplication.shared.terminate(nil)
    }
  }

  private var status: String {
    switch pomodoro.phase {
    case .idle:
      return "Ready — \(storedMinutes) min"
    case .running:
      return "\(pomodoro.timeString) left"
    case .paused:
      return "Paused at \(pomodoro.timeString)"
    case .finished:
      return "Time's up"
    }
  }
}
