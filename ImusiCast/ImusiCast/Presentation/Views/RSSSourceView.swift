import SwiftUI

struct RSSSourceView: View {
    @StateObject private var viewModel = RSSSourceViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter RSS URL", text: $viewModel.url)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Load Podcast") {
                    viewModel.loadPodcast()
                }
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if let podcast = viewModel.podcast {
                    Text("Loaded: \(podcast.title) by \(podcast.author)")
                } else if let error = viewModel.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("RSS Source")
        }
    }
}
