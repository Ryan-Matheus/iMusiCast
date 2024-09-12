import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                RSSSourceView()
            }
        }
    }
}

#Preview {
    ContentView()
}
