import XCTest
@testable import ImusiCast

class PodcastDetailViewModelTests: XCTestCase {
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

    func testInitialization() {
        XCTAssertEqual(viewModel.podcast.title, "Test Podcast")
        XCTAssertEqual(viewModel.podcast.author, "Test Author")
        XCTAssertEqual(viewModel.podcast.genre, "Test Genre")
        XCTAssertEqual(viewModel.podcast.episodes.count, 2)
        XCTAssertTrue(viewModel.isImageLoading)
    }

    func testImageLoaded() {
        XCTAssertTrue(viewModel.isImageLoading)
        viewModel.imageLoaded()
        XCTAssertFalse(viewModel.isImageLoading)
    }

    func testPodcastUpdate() {
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

        viewModel.podcast = newPodcast

        XCTAssertEqual(viewModel.podcast.title, "Updated Podcast")
        XCTAssertEqual(viewModel.podcast.author, "Updated Author")
        XCTAssertEqual(viewModel.podcast.genre, "Updated Genre")
        XCTAssertEqual(viewModel.podcast.episodes.count, 1)
    }
}
