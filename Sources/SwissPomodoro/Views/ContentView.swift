import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Text("SwissPomodoro")
        .font(.title)
      Text("Coming soon...")
        .font(.subheadline)
    }
    .padding()
    .frame(minWidth: 300, minHeight: 200)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
