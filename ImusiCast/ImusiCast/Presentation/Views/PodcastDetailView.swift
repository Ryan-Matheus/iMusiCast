import SwiftUI

struct PodcastDetailView: View {
    @ObservedObject var viewModel: PodcastDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CachedAsyncImage(url: viewModel.podcast.imageUrl) {
                    ProgressView()
                }
                .frame(height: 200)
                .aspectRatio(contentMode: .fit)
                .onAppear { viewModel.isImageLoading = true }
                .onDisappear { viewModel.isImageLoading = false }
                
                if viewModel.isImageLoading {
                    Text("Loading image...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(viewModel.podcast.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Author: \(viewModel.podcast.author)")
                    .font(.subheadline)
                
                Text("Genre: \(viewModel.podcast.genre)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(viewModel.podcast.description)
                    .font(.body)
                    .padding(.vertical)
                
                Text("Episodes")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ForEach(viewModel.podcast.episodes) { episode in
                    NavigationLink(destination: PlayerView(viewModel: PlayerViewModel(episode: episode))) {
                        EpisodeRow(episode: episode)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Podcast Details", displayMode: .inline)
    }
}

struct EpisodeRow: View {
    let episode: Episode
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(episode.title)
                .font(.headline)
            
            Text(episode.description)
                .font(.subheadline)
                .lineLimit(2)
            
            HStack {
                Text("Published: \(formatDate(episode.publishDate))")
                Spacer()
                Text("Duration: \(formatDuration(episode.duration))")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
