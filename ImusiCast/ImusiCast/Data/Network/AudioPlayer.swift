import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    func play(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        isPlaying = true
        
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            self?.duration = playerItem.duration.seconds
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func resume() {
        player?.play()
        isPlaying = true
    }
    
    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }
}
