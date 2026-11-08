import AppKit
import SwiftUI

@main
struct SwissPomodoroApp: App {
  @State private var pomodoro = PomodoroTimer()

  var body: some Scene {
    Window("SwissPomodoro", id: "main") {
      ContentView(pomodoro: pomodoro)
    }
    .windowStyle(.titleBar)
    .windowResizability(.contentMinSize)

    MenuBarExtra {
      MenuBarContent(pomodoro: pomodoro)
    } label: {
      MenuBarLabel(pomodoro: pomodoro)
    }
  }
}
