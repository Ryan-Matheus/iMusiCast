import SwiftUI

struct PodcastDetailView: View {
    @ObservedObject var viewModel: PodcastDetailViewModel
    @StateObject private var playerViewModel: PlayerViewModel
    @State private var currentPage = 0
    let episodesPerPage = 5
    
    init(viewModel: PodcastDetailViewModel) {
        self.viewModel = viewModel
        _playerViewModel = StateObject(wrappedValue: PlayerViewModel(episode: viewModel.podcast.episodes.first ?? Episode(id: UUID(), title: "", description: "", audioUrl: URL(string: "...")!, duration: 0, publishDate: Date()), episodes: viewModel.podcast.episodes))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.podcast.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                CachedAsyncImage(url: viewModel.podcast.imageUrl) {
                    ProgressView()
                }
                .frame(height: 200)
                .aspectRatio(contentMode: .fit)
                
                Text(viewModel.podcast.description)
                    .font(.body)
                    .padding(.vertical)
                
                Text("Author: \(viewModel.podcast.author)")
                    .font(.subheadline)
                
                if !viewModel.podcast.genre.isEmpty {
                    Text("Genre: \(viewModel.podcast.genre)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Episodes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ForEach(paginatedEpisodes) { episode in
                    NavigationLink(destination: PlayerView(viewModel: playerViewModel, episode: episode)) {
                        EpisodeRow(episode: episode)
                    }
                }
                
                HStack {
                    if currentPage > 0 {
                        Button("Previous") {
                            currentPage -= 1
                        }
                    }
                    Spacer()
                    Text("Showing episodes \(currentPage * episodesPerPage + 1) to \(min((currentPage + 1) * episodesPerPage, viewModel.podcast.episodes.count))")
                        .font(.caption)
                    Spacer()
                    if (currentPage + 1) * episodesPerPage < viewModel.podcast.episodes.count {
                        Button("Next") {
                            currentPage += 1
                        }
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationBarTitle("Podcast Details", displayMode: .inline)
    }
    
    private var paginatedEpisodes: [Episode] {
        let startIndex = currentPage * episodesPerPage
        let endIndex = min(startIndex + episodesPerPage, viewModel.podcast.episodes.count)
        return Array(viewModel.podcast.episodes[startIndex..<endIndex])
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "Unknown"
    }
}
