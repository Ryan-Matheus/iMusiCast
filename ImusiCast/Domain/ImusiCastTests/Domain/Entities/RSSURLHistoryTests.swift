import XCTest
@testable import ImusiCast

class RSSURLHistoryTests: XCTestCase {
    func testRSSURLHistoryInitialization() {
        let history = RSSURLHistory(urls: ["https://example1.com", "https://example2.com"])
        
        XCTAssertEqual(history.urls.count, 2)
        XCTAssertEqual(history.urls[0], "https://example1.com")
        XCTAssertEqual(history.urls[1], "https://example2.com")
    }
    
    func testRSSURLHistoryCodable() throws {
        let history = RSSURLHistory(urls: ["https://example1.com", "https://example2.com"])
        
        let encodedData = try JSONEncoder().encode(history)
        let decodedHistory = try JSONDecoder().decode(RSSURLHistory.self, from: encodedData)
        
        XCTAssertEqual(history.urls, decodedHistory.urls)
    }
}
