import Foundation
import AVFoundation
import Combine

class PlayerViewModel: ObservableObject {
    @Published var episode: Episode
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0.01
    @Published var isLoading = false
    @Published var error: String?
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    var episodes: [Episode]
    var currentEpisodeIndex: Int
    
    init(episode: Episode, episodes: [Episode]) {
        self.episode = episode
        self.episodes = episodes
        self.currentEpisodeIndex = episodes.firstIndex(where: { $0.id == episode.id }) ?? 0
    }
    
    deinit {
        stopPlayback()
    }
    
    func changeEpisode(to newEpisode: Episode, autoPlay: Bool = true) {
        stopPlayback()
        episode = newEpisode
        currentEpisodeIndex = episodes.firstIndex(where: { $0.id == newEpisode.id }) ?? 0
        preparePlayback(autoPlay: autoPlay)
    }
    
    func preparePlayback(autoPlay: Bool = false) {
        stopPlayback()
        isLoading = true
        error = nil
        setupPlayer(autoPlay: autoPlay)
    }
    
    private func setupPlayer(autoPlay: Bool) {
        guard let url = URL(string: episode.audioUrl.absoluteString) else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        let asset = AVAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        setupPlayerObservers(autoPlay: autoPlay)
    }
    
    private func setupPlayerObservers(autoPlay: Bool) {
        player?.publisher(for: \.status)
            .sink { [weak self] status in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch status {
                    case .readyToPlay:
                        self.isLoading = false
                        self.duration = self.playerItem?.asset.duration.seconds ?? 0
                        if autoPlay {
                            self.play()
                        }
                    case .failed:
                        self.error = "Failed to load audio"
                        self.isLoading = false
                    default:
                        break
                    }
                }
            }
            .store(in: &cancellables)
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }
    
    func stopPlayback() {
        player?.pause()
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        player = nil
        playerItem = nil
        isPlaying = false
        currentTime = 0
        cancellables.removeAll()
    }
    
    func nextEpisode() {
        currentEpisodeIndex = (currentEpisodeIndex + 1) % episodes.count
        changeEpisode(to: episodes[currentEpisodeIndex], autoPlay: true)
    }
    
    func previousEpisode() {
        currentEpisodeIndex = (currentEpisodeIndex - 1 + episodes.count) % episodes.count
        changeEpisode(to: episodes[currentEpisodeIndex], autoPlay: true)
    }
}
