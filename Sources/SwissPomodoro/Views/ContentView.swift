import AppKit
import SwiftUI

private enum Palette {
  static let ink = Color(red: 0.10, green: 0.11, blue: 0.12)
  static let red = Color(red: 0.83, green: 0.20, blue: 0.18)
  static let caseTop = Color(red: 0.76, green: 0.85, blue: 0.88)
  static let caseBottom = Color(red: 0.64, green: 0.76, blue: 0.80)
  static let dial = Color(red: 0.97, green: 0.96, blue: 0.93)
}

private let durationPresets = Preferences.durationPresets

struct ContentView: View {
  var pomodoro: PomodoroTimer
  @AppStorage(Preferences.sessionMinutesKey) private var storedMinutes: Int = PomodoroTimer.defaultMinutes
  @State private var showDurationSheet: Bool = false
  @State private var durationMinutes: Int = PomodoroTimer.defaultMinutes
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    VStack(spacing: 16) {
      header
      dial
      Text(pomodoro.timeString)
        .font(.system(size: 38, weight: .semibold, design: .rounded).monospacedDigit())
        .foregroundStyle(pomodoro.phase == .finished ? Palette.red : Palette.ink)
        .accessibilityElement()
        .accessibilityLabel("Time remaining")
        .accessibilityValue(pomodoro.timeString)
      Text(caption)
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(Palette.red)
      controls
    }
    .padding(26)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 32, style: .continuous)
        .fill(
          LinearGradient(
            colors: [Palette.caseTop, Palette.caseBottom],
            startPoint: .top,
            endPoint: .bottom
          )
        )
    }
    .overlay {
      RoundedRectangle(cornerRadius: 32, style: .continuous)
        .strokeBorder(Palette.ink, lineWidth: 5)
    }
    .padding(14)
    .frame(minWidth: 400, minHeight: 560)
    .onAppear {
      if pomodoro.phase == .idle {
        durationMinutes = storedMinutes
        pomodoro.setIdleDuration(minutes: storedMinutes)
      }
    }
    .navigationTitle(windowTitle)
    .onChange(of: pomodoro.phase) { _, newPhase in
      guard newPhase == .finished else { return }
      NSSound.beep()
      NSApplication.shared.requestUserAttention(.informationalRequest)
      NSAccessibility.post(
        element: NSApplication.shared,
        notification: .announcementRequested,
        userInfo: [
          .announcement: "Session complete. Take a break.",
          .priority: NSAccessibilityPriorityLevel.high.rawValue,
        ]
      )
    }
    .sheet(isPresented: $showDurationSheet) {
      VStack(spacing: 16) {
        Text("Set Duration")
          .font(.title2)
        HStack(spacing: 8) {
          ForEach(durationPresets, id: \.self) { minutes in
            Button {
              durationMinutes = minutes
            } label: {
              Text("\(minutes)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .frame(minWidth: 34)
                .padding(.vertical, 6)
                .background {
                  Capsule().fill(minutes == durationMinutes ? Palette.red : Palette.dial)
                }
                .overlay {
                  Capsule().strokeBorder(Palette.ink, lineWidth: 1.5)
                }
                .foregroundStyle(minutes == durationMinutes ? Color.white : Palette.ink)
            }
            .buttonStyle(.plain)
          }
        }
        Stepper(value: $durationMinutes, in: 1...180) {
          Text("Minutes: \(durationMinutes)")
            .monospacedDigit()
        }
        HStack(spacing: 12) {
          Button("Cancel") {
            showDurationSheet = false
          }
          Button("Start") {
            storedMinutes = durationMinutes
            showDurationSheet = false
            pomodoro.start(minutes: durationMinutes)
          }
        }
      }
      .padding(24)
      .frame(minWidth: 320)
    }
  }

  private var header: some View {
    HStack {
      Button {
        presentDurationSheet()
      } label: {
        HStack(spacing: 8) {
          Text("Period")
          Text("\(pomodoro.totalSeconds / 60)")
            .monospacedDigit()
        }
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundStyle(Palette.ink)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(Palette.dial))
        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 2))
      }
      .buttonStyle(.plain)
      .help("Change the session length")

      Spacer()

      VStack(spacing: 3) {
        Circle()
          .fill(pomodoro.isRunning ? Palette.red : Palette.red.opacity(0.3))
          .frame(width: 16, height: 16)
          .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 2))
        Text("Light")
          .font(.system(size: 8, weight: .bold, design: .rounded))
          .foregroundStyle(Palette.ink.opacity(0.65))
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("Session light")
      .accessibilityValue(pomodoro.isRunning ? "On" : "Off")
    }
  }

  private var dial: some View {
    ZStack {
      Circle()
        .fill(Palette.dial)
      ProgressSector(progress: pomodoro.progress)
        .fill(Palette.red)
        .animation(reduceMotion ? nil : .linear(duration: 0.5), value: pomodoro.progress)
      Circle()
        .strokeBorder(Palette.ink, lineWidth: 4)
      // Tick marks
      ForEach(0..<60) { tick in
        let isMajor = tick % 5 == 0
        Rectangle()
          .fill(isMajor ? Palette.ink : Palette.ink.opacity(0.45))
          .frame(width: isMajor ? 2 : 1, height: isMajor ? 14 : 7)
          .offset(y: -(108 - (isMajor ? 7 : 3.5)))
          .rotationEffect(.degrees(Double(tick) * 6))
      }
      // Hour labels, placed just inside the tick marks
      ForEach(0..<12) { hour in
        Text("\(hour * 5)")
          .font(.system(size: 13, weight: .semibold, design: .rounded))
          .monospacedDigit()
          .foregroundStyle(Palette.ink)
          .fixedSize()
          .offset(y: -86)
          .rotationEffect(.degrees(Double(hour) * 30))
      }
      // Central knob
      Circle()
        .fill(Palette.dial)
        .frame(width: 34, height: 34)
        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 3))
    }
    .frame(width: 220, height: 220)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Session progress")
    .accessibilityValue(progressDescription)
  }

  private var controls: some View {
    HStack(spacing: 12) {
      Button {
        pomodoro.toggle(at: storedMinutes)
      } label: {
        Text(pomodoro.primaryActionTitle)
          .frame(minWidth: 54)
      }
      .buttonStyle(CaseButtonStyle(kind: .primary))
      .keyboardShortcut(.space, modifiers: [])

      Button {
        pomodoro.reset()
      } label: {
        Text("Reset")
      }
      .buttonStyle(CaseButtonStyle(kind: .secondary))
      .disabled(pomodoro.phase == .idle)
    }
  }

  private var progressDescription: String {
    "\(Int((pomodoro.progress * 100).rounded())) percent"
  }

  private var windowTitle: String {
    switch pomodoro.phase {
    case .idle:
      return "SwissPomodoro"
    case .running:
      return "\(pomodoro.timeString) — SwissPomodoro"
    case .paused:
      return "Paused — SwissPomodoro"
    case .finished:
      return "Time's up — SwissPomodoro"
    }
  }

  private var caption: String {
    switch pomodoro.phase {
    case .running, .idle:
      return "Flow with your own rhythm."
    case .paused:
      return "Paused."
    case .finished:
      return "Time's up — take a break."
    }
  }

  private func presentDurationSheet() {
    durationMinutes = storedMinutes
    showDurationSheet = true
  }
}

private struct CaseButtonStyle: ButtonStyle {
  enum Kind {
    case primary
    case secondary
  }

  var kind: Kind

  @Environment(\.isEnabled) private var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 13, weight: .bold, design: .rounded))
      .foregroundStyle(kind == .primary ? Color.white : Palette.ink)
      .padding(.horizontal, 18)
      .padding(.vertical, 8)
      .background {
        Capsule().fill(kind == .primary ? Palette.red : Palette.dial)
      }
      .overlay {
        Capsule().strokeBorder(Palette.ink, lineWidth: 2)
      }
      .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
  }
}

/// Filled pie wedge from 12 o'clock clockwise, used as the progress indicator.
private struct ProgressSector: Shape {
  var progress: Double

  var animatableData: Double {
    get { progress }
    set { progress = newValue }
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()
    guard progress > 0 else { return path }
    if progress >= 1 {
      path.addEllipse(in: rect)
      return path
    }
    let center = CGPoint(x: rect.midX, y: rect.midY)
    path.move(to: center)
    path.addArc(
      center: center,
      radius: min(rect.width, rect.height) / 2,
      startAngle: .degrees(-90),
      endAngle: .degrees(-90 + 360 * progress),
      clockwise: false
    )
    path.closeSubpath()
    return path
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(pomodoro: PomodoroTimer())
  }
}
