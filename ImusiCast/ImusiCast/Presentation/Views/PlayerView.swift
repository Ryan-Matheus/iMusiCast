import SwiftUI

struct PlayerView: View {
    @StateObject var viewModel: PlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text(viewModel.episode.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                playerControls
            }
        }
        .padding()
        .navigationBarTitle("Now Playing", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            viewModel.stopPlayback()
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
            Text("Back")
        })
        .onDisappear {
            viewModel.stopPlayback()
        }
    }
    
    private var playerControls: some View {
        VStack(spacing: 20) {
            Slider(value: $viewModel.currentTime, in: 0...max(viewModel.duration, 0.01)) { editing in
                if !editing {
                    viewModel.seek(to: viewModel.currentTime)
                }
            }
            .accentColor(.blue)
            
            HStack {
                Text(formatTime(viewModel.currentTime))
                Spacer()
                Text(formatTime(viewModel.duration))
            }
            .font(.caption)
            
            HStack(spacing: 40) {
                Button(action: viewModel.previousEpisode) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                
                Button(action: viewModel.togglePlayPause) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }
                
                Button(action: viewModel.nextEpisode) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
            }
            .foregroundColor(.blue)
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
