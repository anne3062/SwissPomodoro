import SwiftUI

struct ContentView: View {
  @State private var timeRemaining: Int = 25 * 60
  @State private var timerActive: Bool = false
  @State private var timer: Timer? = nil
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
          .stroke(Color.black, lineWidth: 4)
          .frame(width: 220, height: 220)
        // Tick marks and numbers
        ForEach(0..<60) { i in
          VStack {
            if i % 5 == 0 {
              Rectangle()
                .fill(Color.black)
                .frame(width: 2, height: 16)
            } else {
              Rectangle()
                .fill(Color.black)
                .frame(width: 1, height: 8)
                .opacity(0.5)
            }
            Spacer()
            if i % 5 == 0 {
              Text("\(i)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 30, height: 20)
                .offset(y: -10)
            }
          }
          .frame(width: 220, height: 220)
          .rotationEffect(.degrees(Double(i) * 6))
        }
        // Red progress arc
        Circle()
          .trim(from: 1 - progress, to: 1)
          .stroke(Color.red, style: StrokeStyle(lineWidth: 32, lineCap: .round))
          .rotationEffect(.degrees(-90))
          .frame(width: 180, height: 180)
        // Central knob
        Circle()
          .fill(Color.white)
          .frame(width: 36, height: 36)
          .overlay(
            Circle()
              .stroke(Color.black, lineWidth: 3)
          )
        // Minute hand
        Rectangle()
          .fill(Color.blue)
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
        Button(action: { showDurationSheet = true }) {
          Text("Start")
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

  func startTimer() {
    // kept for backwards compatibility; prefer using beginTimer()
    guard !timerActive else { return }
    beginTimer()
  }

  func beginTimer() {
    timer?.invalidate()
    timerActive = true
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
      DispatchQueue.main.async {
        if timeRemaining > 0 {
          timeRemaining -= 1
        } else {
          timer?.invalidate()
          timerActive = false
        }
      }
    }
  }

  func pauseTimer() {
    timer?.invalidate()
    timerActive = false
  }

  func resetTimer() {
    timer?.invalidate()
    timeRemaining = totalTimeSeconds
    timerActive = false
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
