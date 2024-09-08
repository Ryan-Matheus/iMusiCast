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
                VStack(spacing: 20) {
                    HStack {
                        Text(formatTime(viewModel.currentTime))
                        Spacer()
                        Text(formatTime(viewModel.duration))
                    }
                    .font(.caption)
                    
                    if viewModel.duration > 0 {
                        Slider(
                            value: Binding(
                                get: { min(viewModel.currentTime, viewModel.duration) },
                                set: { viewModel.seek(to: $0) }
                            ),
                            in: 0...viewModel.duration
                        )
                        .accentColor(.blue)
                    } else {
                        ProgressView()
                    }
                    
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
                .padding()
            }
        }
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
    
    private func formatTime(_ time: Double) -> String {
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
