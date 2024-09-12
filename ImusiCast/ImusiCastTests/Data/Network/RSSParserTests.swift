import XCTest
@testable import ImusiCast

class RSSParserTests: XCTestCase {
    var rssParser: RSSParser!
    var mockCacheManager: MockCacheManager!

    override func setUp() {
        super.setUp()
        mockCacheManager = MockCacheManager()
        rssParser = RSSParser(cacheManager: mockCacheManager)
    }

    override func tearDown() {
        rssParser = nil
        mockCacheManager = nil
        super.tearDown()
    }

    func testParsePodcastFromCache() async throws {
        let url = URL(string: "https://example.com/podcast.rss")!
        let expectedPodcast = Podcast(id: UUID(), title: "Tech Talk", description: "Latest in tech", imageUrl: URL(string: "https://example.com/image.jpg")!, author: "Ryan", genre: "Technology", episodes: [])
        mockCacheManager.mockObject = expectedPodcast as AnyObject

        let result = try await rssParser.parsePodcast(from: url)

        XCTAssertEqual(result.title, expectedPodcast.title)
        XCTAssertEqual(result.author, expectedPodcast.author)
    }

    func testParsePodcastFromURL() async throws {
        let url = URL(string: "https://example.com/podcast.rss")!
        let mockData = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <title>Tech Talk</title>
                <description>Latest in tech</description>
                <link>https://example.com</link>
                <language>en-us</language>
                <itunes:author>Ryan</itunes:author>
                <itunes:category text="Technology"/>
                <itunes:image href="https://example.com/image.jpg"/>
                <item>
                    <title>Episode 1</title>
                    <description>First episode</description>
                    <pubDate>Tue, 10 Mar 2020 15:00:00 +0000</pubDate>
                    <enclosure url="https://example.com/episode1.mp3" type="audio/mpeg" length="1024"/>
                    <itunes:duration>3600</itunes:duration>
                </item>
            </channel>
        </rss>
        """.data(using: .utf8)!
        
        URLProtocol.registerClass(MockURLProtocol.self)
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockError = nil

        do {
            let result = try await rssParser.parsePodcast(from: url)
            XCTAssertEqual(result.title, "Tech Talk")
            XCTAssertEqual(result.author, "Ryan")
            XCTAssertEqual(result.episodes.count, 1)
        } catch {
            XCTFail("Parsing failed with error: \(error)")
        }

        URLProtocol.unregisterClass(MockURLProtocol.self)
    }
}
