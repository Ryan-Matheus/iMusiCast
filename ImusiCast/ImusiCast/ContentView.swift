import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                RSSSourceView()
            }
            .tabItem {
                Label("Podcasts", systemImage: "mic")
            }
        }
    }
}

#Preview {
    ContentView()
}
