import Foundation
import UserNotifications

/// Posts a system notification when a session finishes so that completion is
/// still signalled while the window is closed.
@MainActor
final class CompletionNotifier {
  /// `UNUserNotificationCenter.current()` aborts for processes without a bundle
  /// identifier (e.g. `swift run`), so notifications are only used when the app
  /// is launched from its `.app` bundle.
  private var isBundled: Bool {
    Bundle.main.bundleIdentifier != nil
  }

  init() {
    guard isBundled else { return }
    requestAuthorization()
    NotificationCenter.default.addObserver(
      forName: .pomodoroSessionDidFinish,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      // The observer is registered on the main queue.
      MainActor.assumeIsolated {
        self?.postSessionFinished()
      }
    }
  }

  private func requestAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
  }

  private func postSessionFinished() {
    let content = UNMutableNotificationContent()
    content.title = "Session complete"
    content.body = "Time for a break."
    let soundEnabled = UserDefaults.standard.object(forKey: Preferences.soundEnabledKey) as? Bool ?? true
    content.sound = soundEnabled ? .default : nil

    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: nil
    )
    UNUserNotificationCenter.current().add(request)
  }
}
