import SwiftUI

struct PodcastDetailView: View {
    @ObservedObject var viewModel: PodcastDetailViewModel
    @StateObject private var playerViewModel: PlayerViewModel
    @State private var currentPage = 0
    @State private var searchText = ""
    let episodesPerPage = 6
    
    init(viewModel: PodcastDetailViewModel) {
        self.viewModel = viewModel
        _playerViewModel = StateObject(wrappedValue: PlayerViewModel(episode: viewModel.podcast.episodes.first ?? Episode(id: UUID(), title: "", description: "", audioUrl: URL(string: "...")!, duration: 0, publishDate: Date()), episodes: viewModel.podcast.episodes))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color(#colorLiteral(red: 0.2, green: 0, blue: 0, alpha: 1))]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(viewModel.podcast.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    CachedAsyncImage(url: viewModel.podcast.imageUrl) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    }
                    .frame(height: 200)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(15)
                    .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text(viewModel.podcast.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical)
                    
                    infoRow(title: "Author", value: viewModel.podcast.author)
                    
                    if !viewModel.podcast.genre.isEmpty {
                        infoRow(title: "Genre", value: viewModel.podcast.genre)
                    }
                    
                    searchBar
                    
                    Text("Episodes")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    episodesList
                    
                    paginationControls
                }
                .padding()
            }
        }
        .navigationBarTitle("Podcast Details", displayMode: .inline)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title + ":")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search episodes", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red.opacity(0.5), lineWidth: 1))
                .foregroundColor(.white)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red.opacity(0.6))
                }
            }
        }
    }
    
    private var episodesList: some View {
        Group {
            if filteredEpisodes.isEmpty {
                Text("No episodes found")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(paginatedFilteredEpisodes) { episode in
                    NavigationLink(destination: PlayerView(viewModel: playerViewModel, episode: episode)) {
                        EpisodeRow(episode: episode)
                    }
                }
            }
        }
    }
    
    private var paginationControls: some View {
        let totalPages = max(1, (filteredEpisodes.count + episodesPerPage - 1) / episodesPerPage)
        
        return HStack {
            Button(action: {
                withAnimation {
                    currentPage = max(0, currentPage - 1)
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(currentPage > 0 ? .red : .gray)
            }
            .disabled(currentPage <= 0)
            
            Spacer()
            Text("Episodes \(min(currentPage * episodesPerPage + 1, filteredEpisodes.count)) - \(min((currentPage + 1) * episodesPerPage, filteredEpisodes.count)) of \(filteredEpisodes.count)")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            
            Button(action: {
                withAnimation {
                    currentPage = min(currentPage + 1, totalPages - 1)
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(currentPage < totalPages - 1 ? .red : .gray)
            }
            .disabled(currentPage >= totalPages - 1)
        }
        .padding(.top)
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
        let totalPages = max(1, (filteredEpisodes.count + episodesPerPage - 1) / episodesPerPage)
        let safePage = max(0, min(currentPage, totalPages - 1))
        
        let startIndex = safePage * episodesPerPage
        let endIndex = min(startIndex + episodesPerPage, filteredEpisodes.count)
        
        guard startIndex < filteredEpisodes.count else {
            return []
        }
        
        return Array(filteredEpisodes[startIndex..<endIndex])
    }
}

struct EpisodeRow: View {
    let episode: Episode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(episode.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text(formatDate(episode.publishDate))
                Spacer()
                Text(formatDuration(episode.duration))
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 140)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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
