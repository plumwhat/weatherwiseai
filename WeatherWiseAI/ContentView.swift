import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "cloud.sun.fill")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("WeatherWiseAI")
                .font(.title)
                .fontWeight(.bold)
            Text("Smart weather-based activity recommendations")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
