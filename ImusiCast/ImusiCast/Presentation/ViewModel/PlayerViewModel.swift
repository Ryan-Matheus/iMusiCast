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
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
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
    
    func changeEpisode(to newEpisode: Episode) {
        stopPlayback()
        episode = newEpisode
        currentEpisodeIndex = episodes.firstIndex(where: { $0.id == newEpisode.id }) ?? 0
    }
    
    func preparePlayback() {
        guard player == nil else { return }
        isLoading = true
        error = nil
        setupPlayer()
    }
    
    private func setupPlayer() {
        URLSession.shared.dataTaskPublisher(for: episode.audioUrl)
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] data in
                do {
                    self?.player = try AVAudioPlayer(data: data)
                    self?.player?.prepareToPlay()
                    self?.duration = self?.player?.duration ?? 0.01
                    self?.isLoading = false
                    self?.startTimer()
                } catch {
                    self?.error = error.localizedDescription
                    self?.isLoading = false
                }
            })
            .store(in: &cancellables)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTime = player.currentTime
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        player?.currentTime = time
    }
    
    func stopPlayback() {
        player?.stop()
        timer?.invalidate()
        timer = nil
        player = nil
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
}
