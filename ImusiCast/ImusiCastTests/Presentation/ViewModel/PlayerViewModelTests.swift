import XCTest
import AVFoundation
@testable import ImusiCast

class PlayerViewModelTests: XCTestCase {
    var viewModel: PlayerViewModel!
    var mockEpisodes: [Episode]!
    
    override func setUp() {
        super.setUp()
        mockEpisodes = [
            Episode(id: UUID(), title: "Episode 1", description: "Description 1", audioUrl: URL(string: "https://example.com/audio1.mp3")!, duration: 300, publishDate: Date()),
            Episode(id: UUID(), title: "Episode 2", description: "Description 2", audioUrl: URL(string: "https://example.com/audio2.mp3")!, duration: 400, publishDate: Date())
        ]
        viewModel = PlayerViewModel(episode: mockEpisodes[0], episodes: mockEpisodes)
    }
    
    override func tearDown() {
        viewModel = nil
        mockEpisodes = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertEqual(viewModel.episode.title, "Episode 1")
        XCTAssertEqual(viewModel.episodes.count, 2)
        XCTAssertEqual(viewModel.currentEpisodeIndex, 0)
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.currentTime, 0)
        XCTAssertEqual(viewModel.duration, 0.01)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func testChangeEpisode() {
        viewModel.changeEpisode(to: mockEpisodes[1], autoPlay: false)
        XCTAssertEqual(viewModel.episode.title, "Episode 2")
        XCTAssertEqual(viewModel.currentEpisodeIndex, 1)
    }
    
    func testNextEpisode() {
        viewModel.nextEpisode()
        XCTAssertEqual(viewModel.episode.title, "Episode 2")
        XCTAssertEqual(viewModel.currentEpisodeIndex, 1)
        
        viewModel.nextEpisode()
        XCTAssertEqual(viewModel.episode.title, "Episode 1")
        XCTAssertEqual(viewModel.currentEpisodeIndex, 0)
    }
    
    func testPreviousEpisode() {
        viewModel.previousEpisode()
        XCTAssertEqual(viewModel.episode.title, "Episode 2")
        XCTAssertEqual(viewModel.currentEpisodeIndex, 1)
        
        viewModel.previousEpisode()
        XCTAssertEqual(viewModel.episode.title, "Episode 1")
        XCTAssertEqual(viewModel.currentEpisodeIndex, 0)
    }
    
    func testTogglePlayPause() {
        viewModel.togglePlayPause()
        XCTAssertTrue(viewModel.isPlaying)
        
        viewModel.togglePlayPause()
        XCTAssertFalse(viewModel.isPlaying)
    }
    
    func testStopPlayback() {
        viewModel.play()
        XCTAssertTrue(viewModel.isPlaying)
        
        viewModel.stopPlayback()
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.currentTime, 0)
    }
}
