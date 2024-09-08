import Foundation
import AVFoundation
import Combine

class PlayerViewModel: ObservableObject {
    @Published var episode: Episode
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isLoading = true
    @Published var error: String?
    
    private var player: AVPlayer?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    var episodes: [Episode]
    var currentEpisodeIndex: Int
    
    init(episode: Episode, episodes: [Episode]) {
        self.episode = episode
        self.episodes = episodes
        self.currentEpisodeIndex = episodes.firstIndex(where: { $0.id == episode.id }) ?? 0
        setupPlayer()
    }
    
    deinit {
        stopPlayback()
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: episode.audioUrl)
        
        player?.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            DispatchQueue.main.async {
                if let duration = self?.player?.currentItem?.asset.duration {
                    self?.duration = CMTimeGetSeconds(duration)
                }
                self?.isLoading = false
            }
        }
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            .sink { [weak self] _ in
                self?.playerDidFinishPlaying()
            }
            .store(in: &cancellables)
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
            stopTimer()
        } else {
            if currentTime >= duration {
                seek(to: 0)
            }
            player?.play()
            startTimer()
        }
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        currentTime = time
    }
    
    private func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTime = self.duration
            self.stopTimer()
            self.nextEpisode()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTime = CMTimeGetSeconds(player.currentTime())
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func stopPlayback() {
        player?.pause()
        player?.seek(to: .zero)
        stopTimer()
        cancellables.removeAll()
        isPlaying = false
        currentTime = 0
    }
    
    func nextEpisode() {
        currentEpisodeIndex = (currentEpisodeIndex + 1) % episodes.count
        changeEpisode(to: episodes[currentEpisodeIndex])
    }
    
    func previousEpisode() {
        currentEpisodeIndex = (currentEpisodeIndex - 1 + episodes.count) % episodes.count
        changeEpisode(to: episodes[currentEpisodeIndex])
    }
    
    private func changeEpisode(to newEpisode: Episode) {
        stopPlayback()
        episode = newEpisode
        setupPlayer()
        togglePlayPause()
    }
    
    }
}
