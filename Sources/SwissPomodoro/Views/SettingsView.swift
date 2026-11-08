import SwiftUI

struct SettingsView: View {
  @AppStorage(Preferences.sessionMinutesKey) private var sessionMinutes: Int = PomodoroTimer.defaultMinutes
  @AppStorage(Preferences.soundEnabledKey) private var soundEnabled: Bool = true

  var body: some View {
    Form {
      Stepper(value: $sessionMinutes, in: 1...180) {
        Text("Session length: \(sessionMinutes) min")
          .monospacedDigit()
      }
      Toggle("Play a sound when a session ends", isOn: $soundEnabled)
    }
    .formStyle(.grouped)
    .padding(4)
    .frame(width: 380)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
