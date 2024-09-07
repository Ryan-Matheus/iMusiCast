import SwiftUI

struct RSSSourceView: View {
    @StateObject private var viewModel = RSSSourceViewModel()
    @State private var showingClearCacheAlert = false
    
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
                .disabled(viewModel.url.isEmpty)
                
                if viewModel.isLoading {
                    ProgressView()
                } else if let podcast = viewModel.podcast {
                    VStack {
                        Text("Loaded: \(podcast.title)")
                        Text(viewModel.cacheStatus)
                            .font(.caption)
                        NavigationLink(destination: PodcastDetailView(viewModel: PodcastDetailViewModel(podcast: podcast))) {
                            Text("View Podcast Details")
                        }
                    }
                } else if let error = viewModel.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                }
                
                Button("Clear Cache") {
                    showingClearCacheAlert = true
                }
                .padding()
            }
            .navigationTitle("RSS Source")
            .alert(isPresented: $showingClearCacheAlert) {
                Alert(
                    title: Text("Clear Cache"),
                    message: Text("Are you sure you want to clear the cache?"),
                    primaryButton: .destructive(Text("Clear")) {
                        viewModel.clearCache()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
