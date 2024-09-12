import XCTest
import SwiftUI
@testable import ImusiCast

class PodcastDetailViewTests: XCTestCase {
    var viewModel: PodcastDetailViewModel!
    var mockPodcast: Podcast!

    override func setUp() {
        super.setUp()
        mockPodcast = Podcast(
            id: UUID(),
            title: "Test Podcast",
            description: "This is a test podcast",
            imageUrl: URL(string: "https://example.com/image.jpg")!,
            author: "Test Author",
            genre: "Test Genre",
            episodes: [
                Episode(id: UUID(), title: "Episode 1", description: "Test episode", audioUrl: URL(string: "https://example.com/episode1.mp3")!, duration: 1800, publishDate: Date()),
                Episode(id: UUID(), title: "Episode 2", description: "Another test episode", audioUrl: URL(string: "https://example.com/episode2.mp3")!, duration: 2400, publishDate: Date())
            ]
        )
        viewModel = PodcastDetailViewModel(podcast: mockPodcast)
    }

    override func tearDown() {
        viewModel = nil
        mockPodcast = nil
        super.tearDown()
    }

    func testPodcastDetailViewInitialization() {
        let view = PodcastDetailView(viewModel: viewModel)
        
        XCTAssertEqual(view.viewModel.podcast.title, "Test Podcast")
        XCTAssertEqual(view.viewModel.podcast.author, "Test Author")
        XCTAssertEqual(view.viewModel.podcast.genre, "Test Genre")
        XCTAssertEqual(view.viewModel.podcast.episodes.count, 2)
        XCTAssertTrue(view.viewModel.isImageLoading)
    }

    func testImageLoadingState() {
        let view = PodcastDetailView(viewModel: viewModel)
        
        XCTAssertTrue(view.viewModel.isImageLoading)
        
        view.viewModel.imageLoaded()
        
        XCTAssertFalse(view.viewModel.isImageLoading)
    }

    func testEpisodeListDisplay() {
        let view = PodcastDetailView(viewModel: viewModel)
        
        XCTAssertEqual(view.viewModel.podcast.episodes.count, 2)
        XCTAssertEqual(view.viewModel.podcast.episodes[0].title, "Episode 1")
        XCTAssertEqual(view.viewModel.podcast.episodes[1].title, "Episode 2")
    }

    func testPodcastInfoDisplay() {
        let view = PodcastDetailView(viewModel: viewModel)
        
        XCTAssertEqual(view.viewModel.podcast.title, "Test Podcast")
        XCTAssertEqual(view.viewModel.podcast.description, "This is a test podcast")
        XCTAssertEqual(view.viewModel.podcast.author, "Test Author")
        XCTAssertEqual(view.viewModel.podcast.genre, "Test Genre")
    }

    func testPodcastUpdate() {
        let view = PodcastDetailView(viewModel: viewModel)
        
        let newPodcast = Podcast(
            id: UUID(),
            title: "Updated Podcast",
            description: "This is an updated podcast",
            imageUrl: URL(string: "https://example.com/updated-image.jpg")!,
            author: "Updated Author",
            genre: "Updated Genre",
            episodes: [
                Episode(id: UUID(), title: "New Episode", description: "New test episode", audioUrl: URL(string: "https://example.com/new-episode.mp3")!, duration: 3000, publishDate: Date())
            ]
        )

        view.viewModel.podcast = newPodcast

        XCTAssertEqual(view.viewModel.podcast.title, "Updated Podcast")
        XCTAssertEqual(view.viewModel.podcast.author, "Updated Author")
        XCTAssertEqual(view.viewModel.podcast.genre, "Updated Genre")
        XCTAssertEqual(view.viewModel.podcast.episodes.count, 1)
    }
}
