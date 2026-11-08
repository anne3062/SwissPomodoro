import SwiftUI

struct ContentView: View {
  @State private var pomodoro = PomodoroTimer()
  @State private var showDigitalTimer: Bool = false
  @State private var showDurationSheet: Bool = false
  @State private var durationMinutes: Int = PomodoroTimer.defaultMinutes

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
        if pomodoro.progress > 0 {
          Circle()
            .trim(from: 0, to: CGFloat(pomodoro.progress))
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
          .rotationEffect(.degrees(pomodoro.progress * 360))
        // Digital timer on hover
        if showDigitalTimer {
          Text(pomodoro.timeString)
            .font(.system(size: 36, weight: .bold, design: .monospaced))
        }
      }
      .onHover { hovering in
        showDigitalTimer = hovering
      }

      HStack(spacing: 20) {
        Button {
          startOrResume()
        } label: {
          Text(pomodoro.isPaused ? "Resume" : "Start")
        }
        .disabled(pomodoro.isRunning)
        Button(action: { pomodoro.pause() }) {
          Text("Pause")
        }
        .disabled(!pomodoro.isRunning)
        Button(action: { pomodoro.reset() }) {
          Text("Reset")
        }
      }
    }
    .padding()
    .frame(minWidth: 480, minHeight: 520)
    .onDisappear {
      // Closing the window must not leave the run loop retaining the timer and
      // updating a detached state box forever.
      pomodoro.stop()
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
            showDurationSheet = false
            pomodoro.start(minutes: durationMinutes)
          }
        }
      }
      .padding(24)
      .frame(minWidth: 300)
    }
  }

  func startOrResume() {
    if pomodoro.isPaused {
      pomodoro.resume()
    } else {
      showDurationSheet = true
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
