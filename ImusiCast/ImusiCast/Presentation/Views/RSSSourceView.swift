import SwiftUI

struct RSSSourceView: View {
    @StateObject private var viewModel = RSSSourceViewModel()
    @State private var showingClearCacheAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
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
                                    .foregroundColor(.blue)
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
                    
                    if !viewModel.urlHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent RSS URLs")
                                .font(.headline)
                            ForEach(viewModel.urlHistory, id: \.self) { url in
                                Button(action: {
                                    viewModel.url = url
                                    viewModel.loadPodcast()
                                }) {
                                    Text(url)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("RSS Source")
                        .font(.headline)
                }
            }
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
