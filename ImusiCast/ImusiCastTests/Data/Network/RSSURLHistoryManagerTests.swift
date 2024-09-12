import XCTest
@testable import ImusiCast

class RSSURLHistoryManagerTests: XCTestCase {
    var historyManager: RSSURLHistoryManager!
    var mockUserDefaults: MockUserDefaults!

    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        historyManager = RSSURLHistoryManager()
        historyManager.userDefaults = mockUserDefaults
    }

    override func tearDown() {
        historyManager = nil
        mockUserDefaults = nil
        super.tearDown()
    }

    func testSaveURL() {
        let url = "https://example.com/podcast.rss"
        historyManager.saveURL(url)

        let history = historyManager.getHistory()
        XCTAssertEqual(history.urls.first, url)
    }

    func testSaveURLLimitTo5() {
        for i in 1...6 {
            historyManager.saveURL("https://example.com/podcast\(i).rss")
        }

        let history = historyManager.getHistory()
        XCTAssertEqual(history.urls.count, 5)
        XCTAssertEqual(history.urls.first, "https://example.com/podcast6.rss")
    }

    func testGetHistoryWhenEmpty() {
        let history = historyManager.getHistory()
        XCTAssertTrue(history.urls.isEmpty)
    }
}

class MockUserDefaults: UserDefaults {
    var storage: [String: Any] = [:]

    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }

    override func data(forKey defaultName: String) -> Data? {
        return storage[defaultName] as? Data
    }
}
