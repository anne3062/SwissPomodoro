import SwiftUI

struct ContentView: View {
  @State private var timeRemaining: Int = 25 * 60
  @State private var timerActive: Bool = false
  @State private var timer: Timer? = nil
  @State private var showDigitalTimer: Bool = false

  var body: some View {
    VStack(spacing: 32) {
      Text("Pomodoro Timer")
        .font(.largeTitle)
        .padding(.top)
      ZStack {
        Circle()
          .stroke(Color.gray.opacity(0.3), lineWidth: 32)
          .frame(width: 180, height: 180)
        // Progress arc
        Circle()
          .trim(from: 0, to: progress)
          .stroke(Color.red.opacity(0.5), style: StrokeStyle(lineWidth: 16, lineCap: .round))
          .rotationEffect(.degrees(-90))
          .frame(width: 180, height: 180)
        // Minute hand
        Rectangle()
          .fill(Color.red)
          .frame(width: 8, height: 80)
          .offset(y: -40)
          .rotationEffect(.degrees(minuteHandAngle))
        if showDigitalTimer {
          Text(timeString)
            .font(.system(size: 36, weight: .bold, design: .monospaced))
        }
      }
      .onHover { hovering in
        showDigitalTimer = hovering
      }
      var minuteHandAngle: Double {
        // Start from top (12 o'clock) and move counterclockwise
        let totalMinutes = Double(totalTime) / 60.0
        let minutesElapsed = Double(totalTime - timeRemaining) / 60.0
        return 0.0 - (minutesElapsed / totalMinutes) * 360.0
      }
      HStack(spacing: 20) {
        Button(action: startTimer) {
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
    .frame(minWidth: 300, minHeight: 320)
  }
  var totalTime: Int { 25 * 60 }
  var progress: CGFloat {
    CGFloat(totalTime - timeRemaining) / CGFloat(totalTime)
  }

  var timeString: String {
    let minutes = timeRemaining / 60
    let seconds = timeRemaining % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

  func startTimer() {
    guard !timerActive else { return }
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
    timeRemaining = 25 * 60
    timerActive = false
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
