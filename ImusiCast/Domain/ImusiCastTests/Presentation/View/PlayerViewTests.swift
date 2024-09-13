import XCTest
import SwiftUI
@testable import ImusiCast

class PlayerViewTests: XCTestCase {
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
    
    func testPlayerViewInitialization() {
        let view = PlayerView(viewModel: viewModel, episode: mockEpisodes[0])
        
        XCTAssertEqual(view.episode.title, "Episode 1")
        XCTAssertEqual(view.viewModel.episode.title, "Episode 1")
        XCTAssertFalse(view.viewModel.isPlaying)
    }
    
    func testFormatTime() {
        let view = PlayerView(viewModel: viewModel, episode: mockEpisodes[0])
        
        XCTAssertEqual(view.formatTime(0), "00:00")
        XCTAssertEqual(view.formatTime(61), "01:01")
        XCTAssertEqual(view.formatTime(3600), "60:00")
    }
    
    func testOnAppear() {
        let view = PlayerView(viewModel: viewModel, episode: mockEpisodes[1])
        
        if view.viewModel.episode.id != view.episode.id {
            view.viewModel.changeEpisode(to: view.episode, autoPlay: false)
        } else if !view.viewModel.isPlaying {
            view.viewModel.preparePlayback(autoPlay: false)
        }
        
        XCTAssertEqual(view.viewModel.episode.title, "Episode 2")
        XCTAssertFalse(view.viewModel.isPlaying)
    }
    
    func testOnDisappear() {
        let view = PlayerView(viewModel: viewModel, episode: mockEpisodes[0])
        
        view.viewModel.play()
        XCTAssertTrue(view.viewModel.isPlaying)
        
        view.viewModel.stopPlayback()
        
        XCTAssertFalse(view.viewModel.isPlaying)
        XCTAssertEqual(view.viewModel.currentTime, 0)
    }
    
    func testPlayerControls() {
        let view = PlayerView(viewModel: viewModel, episode: mockEpisodes[0])
        
        view.viewModel.togglePlayPause()
        XCTAssertTrue(view.viewModel.isPlaying)
        view.viewModel.togglePlayPause()
        XCTAssertFalse(view.viewModel.isPlaying)
        
        view.viewModel.nextEpisode()
        XCTAssertEqual(view.viewModel.episode.title, "Episode 2")
        
        view.viewModel.previousEpisode()
        XCTAssertEqual(view.viewModel.episode.title, "Episode 1")
    }
}
