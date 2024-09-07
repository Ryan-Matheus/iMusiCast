import Foundation
import AVFoundation

class PlayerViewModel: ObservableObject {
    @Published var episode: Episode
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    
    private var player: AVPlayer?
    
    init(episode: Episode) {
        self.episode = episode
        setupPlayer()
    }
    
    private func setupPlayer() {
        let playerItem = AVPlayerItem(url: episode.audioUrl)
        player = AVPlayer(playerItem: playerItem)
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        currentTime = time
    }
}
