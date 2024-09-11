import SwiftUI

struct PodcastDetailView: View {
    @ObservedObject var viewModel: PodcastDetailViewModel
    @StateObject private var playerViewModel: PlayerViewModel
    @State private var currentPage = 0
    @State private var searchText = ""
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
                
                HStack {
                    TextField("Search episodes", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            HStack {
                                Spacer()
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.trailing, 8)
                                }
                            }
                        )
                    
                    if !searchText.isEmpty {
                        Button("Cancel") {
                            searchText = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                .padding(.vertical)
                
                Text("Episodes")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if filteredEpisodes.isEmpty {
                    Text("No episodes found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(paginatedFilteredEpisodes) { episode in
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
                        Text("Showing episodes \(currentPage * episodesPerPage + 1) to \(min((currentPage + 1) * episodesPerPage, filteredEpisodes.count)) of \(filteredEpisodes.count)")
                            .font(.caption)
                        Spacer()
                        if (currentPage + 1) * episodesPerPage < filteredEpisodes.count {
                            Button("Next") {
                                currentPage += 1
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .navigationBarTitle("Podcast Details", displayMode: .inline)
    }
    
    private var filteredEpisodes: [Episode] {
        if searchText.isEmpty {
            return viewModel.podcast.episodes
        } else {
            return viewModel.podcast.episodes.filter { episode in
                episode.title.lowercased().contains(searchText.lowercased()) ||
                episode.description.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    private var paginatedFilteredEpisodes: [Episode] {
        let startIndex = currentPage * episodesPerPage
        let endIndex = min(startIndex + episodesPerPage, filteredEpisodes.count)
        return Array(filteredEpisodes[startIndex..<endIndex])
    }
}

struct EpisodeRow: View {
    let episode: Episode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "Unknown"
    }
}
