import SwiftUI

@main
struct SwissPomodoroApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .windowStyle(.titleBar)
    .windowResizability(.contentMinSize)
  }
}
