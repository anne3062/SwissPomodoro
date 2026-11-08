import Foundation
import Observation

/// Timer state and countdown logic for a single Pomodoro session.
///
/// The remaining time is derived from a deadline rather than counted down per
/// tick, so late ticks (window drag, busy main thread, system sleep) do not make
/// the session run long.
@MainActor
@Observable
final class PomodoroTimer {
  enum Phase: Equatable {
    case idle
    case running
    case paused
    case finished
  }

  static let defaultMinutes = 25

  private(set) var phase: Phase = .idle
  private(set) var totalSeconds: Int = defaultMinutes * 60
  private(set) var remainingSeconds: Int = defaultMinutes * 60

  @ObservationIgnored private var timer: Timer?
  @ObservationIgnored private var endDate: Date?
  @ObservationIgnored private let now: () -> Date

  init(now: @escaping () -> Date = Date.init) {
    self.now = now
  }

  var isRunning: Bool { phase == .running }
  var isPaused: Bool { phase == .paused }

  /// Fraction of the session that has elapsed, 0...1.
  var progress: Double {
    guard totalSeconds > 0 else { return 0 }
    return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
  }

  var timeString: String {
    String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
  }

  /// Title for the primary start/pause/resume control.
  var primaryActionTitle: String {
    switch phase {
    case .running:
      return "Pause"
    case .paused:
      return "Resume"
    case .idle, .finished:
      return "Start"
    }
  }

  /// Starts a new session of `minutes` length, replacing any current one.
  func start(minutes: Int) {
    totalSeconds = max(1, minutes) * 60
    remainingSeconds = totalSeconds
    phase = .running
    scheduleTicks()
  }

  /// Resizes an idle session, e.g. from the persisted default duration.
  func setIdleDuration(minutes: Int) {
    guard phase == .idle else { return }
    totalSeconds = max(1, minutes) * 60
    remainingSeconds = totalSeconds
  }

  /// Starts a session when idle or finished, otherwise toggles pause/resume.
  func toggle(at minutes: Int) {
    switch phase {
    case .running:
      pause()
    case .paused:
      resume()
    case .idle, .finished:
      start(minutes: minutes)
    }
  }

  func resume() {
    guard phase == .paused, remainingSeconds > 0 else { return }
    phase = .running
    scheduleTicks()
  }

  func pause() {
    guard phase == .running, let endDate else { return }
    let remaining = Int(ceil(endDate.timeIntervalSince(now())))
    stopTicking()
    if remaining > 0 {
      remainingSeconds = remaining
      phase = .paused
    } else {
      remainingSeconds = 0
      phase = .finished
    }
  }

  func reset() {
    stopTicking()
    remainingSeconds = totalSeconds
    phase = .idle
  }

  /// Stops counting without discarding the session, e.g. when the window closes.
  func stop() {
    stopTicking()
    if phase == .running {
      phase = .paused
    }
  }

  /// Recomputes the remaining time from the deadline. Called every tick.
  func tick() {
    guard phase == .running, let endDate else { return }
    let remaining = Int(ceil(endDate.timeIntervalSince(now())))
    if remaining > 0 {
      remainingSeconds = remaining
    } else {
      remainingSeconds = 0
      phase = .finished
      stopTicking()
    }
  }

  private func scheduleTicks() {
    stopTicking()
    endDate = now().addingTimeInterval(TimeInterval(remainingSeconds))
    // `.common` mode keeps the countdown updating while the window is dragged or
    // a menu is tracking.
    let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
      // The timer is added to the main run loop, so this is already main-actor work.
      MainActor.assumeIsolated {
        self?.tick()
      }
    }
    RunLoop.main.add(timer, forMode: .common)
    self.timer = timer
  }

  private func stopTicking() {
    timer?.invalidate()
    timer = nil
    endDate = nil
  }
}
