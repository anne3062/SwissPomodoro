import SwiftUI

struct ContentView: View {
  @State private var timeRemaining: Int = 25 * 60
  @State private var timerActive: Bool = false
  @State private var timer: Timer? = nil
  @State private var endDate: Date? = nil
  @State private var showDigitalTimer: Bool = false
  @State private var showDurationSheet: Bool = false
  @State private var durationMinutes: Int = 25
  @State private var totalTimeSeconds: Int = 25 * 60

  var body: some View {
    VStack(spacing: 32) {
      Text("Pomodoro Timer")
        .font(.largeTitle)
        .padding(.top)
      ZStack {
        // Outer bold circle
        Circle()
          .stroke(Color.primary, lineWidth: 4)
          .frame(width: 220, height: 220)
        // Red progress arc, drawn behind the ticks so the labels stay readable
        if progress > 0 {
          Circle()
            .trim(from: 0, to: progress)
            .stroke(Color.red, style: StrokeStyle(lineWidth: 32, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: 180, height: 180)
        }
        // Tick marks
        ForEach(0..<60) { tick in
          let isMajor = tick % 5 == 0
          Rectangle()
            .fill(isMajor ? Color.primary : Color.primary.opacity(0.45))
            .frame(width: isMajor ? 2 : 1, height: isMajor ? 14 : 7)
            .offset(y: -(108 - (isMajor ? 7 : 3.5)))
            .rotationEffect(.degrees(Double(tick) * 6))
        }
        // Hour labels, placed just inside the tick marks
        ForEach(0..<12) { hour in
          Text("\(hour * 5)")
            .font(.system(size: 13, weight: .semibold))
            .monospacedDigit()
            .fixedSize()
            .offset(y: -86)
            .rotationEffect(.degrees(Double(hour) * 30))
        }
        // Central knob
        Circle()
          .fill(.background)
          .frame(width: 36, height: 36)
          .overlay(
            Circle()
              .stroke(Color.primary, lineWidth: 3)
          )
        // Minute hand
        Rectangle()
          .fill(Color.accentColor)
          .frame(width: 4, height: 70)
          .offset(y: -35)
          .rotationEffect(.degrees(minuteHandAngle))
        // Digital timer on hover
        if showDigitalTimer {
          Text(timeString)
            .font(.system(size: 36, weight: .bold, design: .monospaced))
        }

      }
      .onHover { hovering in
        showDigitalTimer = hovering
      }

      HStack(spacing: 20) {
        Button(action: startOrResume) {
          Text(isPaused ? "Resume" : "Start")
        }
        .disabled(timerActive)
        Button(action: pauseTimer) {
          Text("Pause")
        }
        .disabled(!timerActive)
        Button(action: resetTimer) {
          Text("Reset")
        }
      }
    }
    .padding()
    .frame(minWidth: 480, minHeight: 520)
    .onDisappear {
      // Closing the window must not leave the run loop retaining the timer and
      // updating a detached state box forever.
      stopTimer()
    }
    .sheet(isPresented: $showDurationSheet) {
      VStack(spacing: 16) {
        Text("Set Duration")
          .font(.title2)
        Stepper(value: $durationMinutes, in: 1...180) {
          Text("Minutes: \(durationMinutes)")
        }
        HStack(spacing: 12) {
          Button("Cancel") {
            showDurationSheet = false
          }
          Button("Start") {
            // configure and start
            totalTimeSeconds = max(1, durationMinutes) * 60
            timeRemaining = totalTimeSeconds
            showDurationSheet = false
            beginTimer()
          }
        }
      }
      .padding(24)
      .frame(minWidth: 300)
    }
  }
  var isPaused: Bool {
    !timerActive && timeRemaining > 0 && timeRemaining < totalTimeSeconds
  }

  var progress: CGFloat {
    guard totalTimeSeconds > 0 else { return 0 }
    return CGFloat(totalTimeSeconds - timeRemaining) / CGFloat(totalTimeSeconds)
  }

  var minuteHandAngle: Double {
    // 0 degrees is 12 o'clock, 360 degrees is a full circle
    let totalMinutes = Double(totalTimeSeconds) / 60.0
    let minutesElapsed = Double(totalTimeSeconds - timeRemaining) / 60.0
    return (minutesElapsed / totalMinutes) * 360.0
  }

  var timeString: String {
    let minutes = timeRemaining / 60
    let seconds = timeRemaining % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

  func startOrResume() {
    if isPaused {
      beginTimer()
    } else {
      showDurationSheet = true
    }
  }

  func startTimer() {
    // kept for backwards compatibility; prefer using beginTimer()
    guard !timerActive else { return }
    beginTimer()
  }

  func beginTimer() {
    guard timeRemaining > 0 else { return }
    timer?.invalidate()
    endDate = Date().addingTimeInterval(TimeInterval(timeRemaining))
    timerActive = true
    // `.common` mode keeps the countdown updating while the window is dragged or
    // a menu is tracking; the remaining time is derived from `endDate`, so ticks
    // that are late or skipped (sleep, main thread stalls) do not drift.
    let newTimer = Timer(timeInterval: 0.5, repeats: true) { _ in
      updateRemaining()
    }
    RunLoop.main.add(newTimer, forMode: .common)
    timer = newTimer
  }

  func updateRemaining() {
    guard let endDate else {
      stopTimer()
      return
    }
    let remaining = endDate.timeIntervalSinceNow
    if remaining > 0 {
      timeRemaining = Int(ceil(remaining))
    } else {
      timeRemaining = 0
      stopTimer()
    }
  }

  func pauseTimer() {
    if let endDate {
      timeRemaining = max(0, Int(ceil(endDate.timeIntervalSinceNow)))
    }
    stopTimer()
  }

  func resetTimer() {
    stopTimer()
    timeRemaining = totalTimeSeconds
  }

  func stopTimer() {
    timer?.invalidate()
    timer = nil
    endDate = nil
    timerActive = false
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
