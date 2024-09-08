import Foundation
import AVFoundation

class PlayerViewModel: ObservableObject {
    @Published var episode: Episode
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    
    private var player: AVPlayer?
    private var cancellables = Set<AnyCancellable>()
    
    init(episode: Episode) {
        self.episode = episode
        setupPlayer()
    }
    
    deinit {
        stopPlayback()
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
    func stopPlayback() {
        player?.pause()
        player?.seek(to: .zero)
        stopTimer()
        cancellables.removeAll()
        isPlaying = false
        currentTime = 0
    }
    
    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        currentTime = time
    }
}
