import SwiftUI

struct PodcastDetailView: View {
    @ObservedObject var viewModel: PodcastDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                AsyncImage(url: viewModel.podcast.imageUrl) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
                
                Text(viewModel.podcast.title)
                    .font(.title)
                Text(viewModel.podcast.author)
                    .font(.subheadline)
                Text("Genre: \(viewModel.podcast.genre)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(viewModel.podcast.description)
                    .padding(.top)
                
                Text("Episodes")
                    .font(.title2)
                    .padding(.top)
                
                ForEach(viewModel.podcast.episodes) { episode in
                    VStack(alignment: .leading) {
                        Text(episode.title)
                            .font(.headline)
                        Text(episode.description)
                            .font(.subheadline)
                        Text("Duration: \(formatDuration(episode.duration))")
                            .font(.caption)
                        Text("Published: \(formatDate(episode.publishDate))")
                            .font(.caption)
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding()
        }
        .navigationTitle("Podcast Details")
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
