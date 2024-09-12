import XCTest
@testable import ImusiCast

class RSSParserDelegateTests: XCTestCase {
    var parserDelegate: RSSParserDelegate!
    var parser: XMLParser!

    override func setUp() {
        super.setUp()
        parserDelegate = RSSParserDelegate()
    }

    override func tearDown() {
        parserDelegate = nil
        parser = nil
        super.tearDown()
    }

    func testParsePodcastInfo() {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <title>Test Podcast</title>
                <description>This is a test podcast</description>
                <itunes:author>Ryan</itunes:author>
                <itunes:category text="Technology"/>
                <itunes:image href="https://example.com/image.jpg"/>
            </channel>
        </rss>
        """
        parser = XMLParser(data: xmlString.data(using: .utf8)!)
        parser.delegate = parserDelegate
        XCTAssertTrue(parser.parse())

        XCTAssertEqual(parserDelegate.podcast?.title, "Test Podcast")
        XCTAssertEqual(parserDelegate.podcast?.description, "This is a test podcast")
        XCTAssertEqual(parserDelegate.podcast?.author, "Ryan")
        XCTAssertEqual(parserDelegate.podcast?.imageUrl, URL(string: "https://example.com/image.jpg"))
    }

    func testParseEpisode() {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <item>
                    <title>Test Episode</title>
                    <description>This is a test episode</description>
                    <pubDate>Tue, 10 Mar 2020 15:00:00 +0000</pubDate>
                    <enclosure url="https://example.com/episode.mp3" type="audio/mpeg" length="1024"/>
                    <itunes:duration>3600</itunes:duration>
                </item>
            </channel>
        </rss>
        """
        parser = XMLParser(data: xmlString.data(using: .utf8)!)
        parser.delegate = parserDelegate
        XCTAssertTrue(parser.parse())

        XCTAssertEqual(parserDelegate.podcast?.episodes.count, 1)
        let episode = parserDelegate.podcast?.episodes.first
        XCTAssertEqual(episode?.title, "Test Episode")
        XCTAssertEqual(episode?.description, "This is a test episode")
        XCTAssertEqual(episode?.audioUrl, URL(string: "https://example.com/episode.mp3"))
        XCTAssertEqual(episode?.duration, 3600)
        XCTAssertEqual(episode?.publishDate, DateFormatter.rfc2822.date(from: "Tue, 10 Mar 2020 15:00:00 +0000"))
    }

    func testStripHTMLTags() {
        let htmlString = "<p>This is <b>bold</b> and <i>italic</i> text.</p>"
        XCTAssertEqual(htmlString.stripHTMLTags, "This is bold and italic text.")
    }

    func testParseDurationString() {
        XCTAssertEqual(parserDelegate.parseDurationString("01:30:45"), 5445)
        XCTAssertEqual(parserDelegate.parseDurationString("45:30"), 2730)
        XCTAssertNil(parserDelegate.parseDurationString("invalid"))
    }
}
