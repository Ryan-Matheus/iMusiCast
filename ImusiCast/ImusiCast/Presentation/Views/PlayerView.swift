import SwiftUI

struct PlayerView: View {
    @ObservedObject var viewModel: PlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let episode: Episode
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color(#colorLiteral(red: 0.2, green: 0, blue: 0, alpha: 1))]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Text(viewModel.episode.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.7))
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text(viewModel.episode.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                        
                        Spacer(minLength: 150)
                    }
                    .padding()
                }
            }
            
            playerControls
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .navigationBarTitle("Now Playing", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            viewModel.stopPlayback()
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.red)
        })
        .onAppear {
            if viewModel.episode.id != episode.id {
                viewModel.changeEpisode(to: episode, autoPlay: false)
            } else if !viewModel.isPlaying {
                viewModel.preparePlayback(autoPlay: false)
            }
        }
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
            .accentColor(.red)
            
            HStack {
                Text(formatTime(viewModel.currentTime))
                Spacer()
                Text(formatTime(viewModel.duration))
            }
            .font(.caption)
            .foregroundColor(.gray)
            
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
            .foregroundColor(.red)
        }
    }
    
    func formatTime(_ time: Double) -> String {
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
