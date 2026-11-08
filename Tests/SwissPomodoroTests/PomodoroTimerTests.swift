import Foundation
import Testing

@testable import SwissPomodoro

@MainActor
@Suite("PomodoroTimer")
struct PomodoroTimerTests {
  @Test("Starting sets the session length and begins running")
  func startBeginsSession() {
    let (timer, _) = makeTimer()

    timer.start(minutes: 25)

    #expect(timer.phase == .running)
    #expect(timer.totalSeconds == 25 * 60)
    #expect(timer.remainingSeconds == 25 * 60)
    #expect(timer.progress == 0)
    #expect(timer.timeString == "25:00")

    timer.reset()
  }

  @Test("Remaining time is derived from the deadline, not the tick count")
  func tickUsesDeadline() {
    let (timer, clock) = makeTimer()
    timer.start(minutes: 25)

    clock.advance(by: 60)
    timer.tick()
    #expect(timer.remainingSeconds == 24 * 60)

    // A late tick (window drag, system sleep) still lands on the right value.
    clock.advance(by: 90)
    timer.tick()
    #expect(timer.remainingSeconds == 24 * 60 - 150)

    timer.reset()
  }

  @Test("Pausing freezes the remaining time and resuming continues the session")
  func pauseAndResume() {
    let (timer, clock) = makeTimer()
    timer.start(minutes: 25)

    clock.advance(by: 300)
    timer.pause()
    #expect(timer.phase == .paused)
    #expect(timer.remainingSeconds == 20 * 60)

    clock.advance(by: 600)
    timer.tick()
    #expect(timer.remainingSeconds == 20 * 60, "a paused session must not move")

    timer.resume()
    #expect(timer.phase == .running)

    clock.advance(by: 60)
    timer.tick()
    #expect(timer.remainingSeconds == 19 * 60)

    timer.reset()
  }

  @Test("Reaching the deadline finishes the session")
  func reachingDeadlineFinishes() {
    let (timer, clock) = makeTimer()
    timer.start(minutes: 1)

    clock.advance(by: 59)
    timer.tick()
    #expect(timer.remainingSeconds == 1)
    #expect(timer.phase == .running)

    clock.advance(by: 1)
    timer.tick()
    #expect(timer.remainingSeconds == 0)
    #expect(timer.phase == .finished)
    #expect(timer.progress == 1)
  }

  @Test("Reset returns to a full, idle session")
  func resetReturnsToIdle() {
    let (timer, clock) = makeTimer()
    timer.start(minutes: 25)
    clock.advance(by: 120)
    timer.tick()

    timer.reset()

    #expect(timer.phase == .idle)
    #expect(timer.remainingSeconds == timer.totalSeconds)
    #expect(timer.progress == 0)
  }
}

@MainActor
private func makeTimer() -> (PomodoroTimer, FakeClock) {
  let clock = FakeClock()
  return (PomodoroTimer(now: { clock.now }), clock)
}

private final class FakeClock {
  var now = Date(timeIntervalSince1970: 1_000_000)

  func advance(by seconds: TimeInterval) {
    now = now.addingTimeInterval(seconds)
  }
}
