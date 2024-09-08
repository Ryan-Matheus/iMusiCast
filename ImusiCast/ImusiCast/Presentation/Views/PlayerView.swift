import SwiftUI

struct PlayerView: View {
    @ObservedObject var viewModel: PlayerViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.episode.title)
                .font(.title)
            
            Text(viewModel.episode.description)
                .font(.subheadline)
                .padding()
            
            Text("Published: \(formatDate(viewModel.episode.publishDate))")
                .font(.caption)
            
            Slider(value: $viewModel.currentTime, in: 0...viewModel.episode.duration) { _ in
                viewModel.seek(to: viewModel.currentTime)
            }
            
            HStack {
                Text(formatTime(viewModel.currentTime))
                Spacer()
                Text(formatTime(viewModel.episode.duration))
            }
            
            Button(action: {
                if viewModel.isPlaying {
                    viewModel.pause()
                } else {
                    viewModel.play()
                }
            }) {
                Image(systemName: viewModel.isPlaying ? "pause.circle" : "play.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .padding()
        .navigationTitle("Now Playing")
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
        .onDisappear {
            viewModel.stopPlayback()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
