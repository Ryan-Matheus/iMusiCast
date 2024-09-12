import XCTest
@testable import ImusiCast

class RSSSourceViewModelTests: XCTestCase {
    var viewModel: RSSSourceViewModel!
    var mockRSSParser: MockRSSParser!
    var mockCacheManager: MockCacheManager!
    var mockHistoryManager: MockRSSURLHistoryManager!

    override func setUp() {
        super.setUp()
        mockRSSParser = MockRSSParser()
        mockCacheManager = MockCacheManager()
        mockHistoryManager = MockRSSURLHistoryManager()
        viewModel = RSSSourceViewModel(rssParser: mockRSSParser, cacheManager: mockCacheManager, historyManager: mockHistoryManager)
    }

    override func tearDown() {
        viewModel = nil
        mockRSSParser = nil
        mockCacheManager = nil
        mockHistoryManager = nil
        super.tearDown()
    }

    func testLoadPodcastSuccess() {
        let expectation = XCTestExpectation(description: "Load podcast")
        let mockPodcast = Podcast(id: UUID(), title: "Test Podcast", description: "Test Description", imageUrl: URL(string: "https://example.com")!, author: "Test Author", genre: "Test Genre", episodes: [])
        mockRSSParser.mockPodcast = mockPodcast

        viewModel.url = "https://example.com/feed.rss"
        viewModel.loadPodcast()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.podcast?.title, "Test Podcast")
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNil(self.viewModel.error)
            XCTAssertTrue(self.viewModel.cacheStatus.contains("Load time:"))
            XCTAssertEqual(self.mockHistoryManager.savedURL, "https://example.com/feed.rss")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadPodcastFailure() {
        let expectation = XCTestExpectation(description: "Load podcast failure")
        mockRSSParser.mockError = NSError(domain: "Test Error", code: 1, userInfo: nil)

        viewModel.url = "https://example.com/feed.rss"
        viewModel.loadPodcast()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.viewModel.podcast)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNotNil(self.viewModel.error)
            XCTAssertEqual(self.viewModel.error as NSError?, self.mockRSSParser.mockError as NSError?)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testClearCache() {
        viewModel.clearCache()
        XCTAssertNil(mockCacheManager.mockObject)
        XCTAssertNil(mockCacheManager.mockAudioData)
        XCTAssertEqual(viewModel.cacheStatus, "Cache cleared")
    }

    func testLoadURLHistory() {
        mockHistoryManager.mockHistory = RSSURLHistory(urls: ["https://example1.com", "https://example2.com"])
        viewModel.loadURLHistory()
        XCTAssertEqual(viewModel.urlHistory, ["https://example1.com", "https://example2.com"])
    }
}

class MockRSSParser: RSSParser {
    var mockPodcast: Podcast?
    var mockError: Error?

    override func parsePodcast(from url: URL) async throws -> Podcast {
        if let mockError = mockError {
            throw mockError
        }
        return mockPodcast ?? Podcast(id: UUID(), title: "", description: "", imageUrl: URL(string: "https://example.com")!, author: "", genre: "", episodes: [])
    }
}

class MockRSSURLHistoryManager: RSSURLHistoryManager {
    var mockHistory = RSSURLHistory()
    var savedURL: String?

    override func saveURL(_ url: String) {
        savedURL = url
    }

    override func getHistory() -> RSSURLHistory {
        return mockHistory
    }
}
